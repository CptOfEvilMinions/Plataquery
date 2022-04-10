package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/osquery/osquery-go"
	"github.com/osquery/osquery-go/plugin/config"
)

type S3Config struct {
	AccessKey string `json:"access_key"`
	SecretKey string `json:"secret_key"`
	Region    string `json:"region"`
	Bucket    string `json:"bucket"`
	Config    string `json:"config"`
}

var s3config S3Config
var s3sess *session.Session

func readS3config(filePath string) (S3Config, error) {
	// Read S3 creds from secret fole
	content, err := ioutil.ReadFile(filePath)
	if err != nil {
		return S3Config{}, err
	}

	// Now let's unmarshall the data into `payload`
	var s3config S3Config
	err = json.Unmarshal(content, &s3config)
	if err != nil {
		return S3Config{}, err
	}
	return s3config, nil
}

func getS3config() (map[string]string, error) {
	// Download file
	s3Client := s3.New(s3sess)
	result, err := s3Client.GetObject(&s3.GetObjectInput{
		Bucket: aws.String(s3config.Bucket),
		Key:    aws.String(s3config.Config),
	})
	if err != nil {
		return nil, err
	}
	defer result.Body.Close()

	// Read file contents into buffer
	s3FileByteArray, err := ioutil.ReadAll(result.Body)
	if err != nil {
		return nil, err
	}

	// Buffer byte array to map
	var osqueryJsonConfig map[string]interface{}
	json.Unmarshal(s3FileByteArray, &osqueryJsonConfig)

	// map[string]interface{} -> map[string]string
	osqueryConfig := make(map[string]string)
	for key, value := range osqueryJsonConfig {
		strKey := fmt.Sprintf("%v", key)
		strValue := fmt.Sprintf("%v", value)
		osqueryConfig[strKey] = strValue
	}
	return osqueryConfig, nil
}

func GenerateConfigs(ctx context.Context) (map[string]string, error) {
	osqueryConfig, err := getS3config()
	if err != nil {
		return nil, err
	}
	return osqueryConfig, nil
}

func main() {
	socket := flag.String("socket", "", "Path to osquery socket file")
	secretConfig := flag.String("secretConfig", "/etc/osquery/osquery.secret", "Path to osquery secret file")
	flag.Parse()
	if *socket == "" {
		log.Fatalf(`Usage: %s --socket SOCKET_PATH`, os.Args[0])
	}

	server, err := osquery.NewExtensionManagerServer("s3", *socket)
	if err != nil {
		log.Fatalf("Error creating extension: %s\n", err)
	}

	// Get S3 config
	if s3config, err = readS3config(*secretConfig); err != nil {
		log.Fatal(err)
	}

	// Create a session instance.
	s3sess, err = session.NewSession(&aws.Config{
		Region: aws.String(s3config.Region),
		Credentials: credentials.NewStaticCredentials(
			s3config.AccessKey,
			s3config.SecretKey,
			"",
		),
	})
	if err != nil {
		log.Fatalln(err)
	}

	// create and register the plugin
	server.RegisterPlugin(config.NewPlugin("s3", GenerateConfigs))
	if err := server.Run(); err != nil {
		log.Fatalln(err)
	}
}
