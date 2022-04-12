package main

import (
	"context"
	"encoding/json"
	"flag"
	"io/ioutil"
	"log"
	"time"

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
var s3Client *s3.S3

var (
	socket       = flag.String("socket", "", "Path to the extensions UNIX domain socket")
	timeout      = flag.Int("timeout", 3, "Seconds to wait for autoloaded extensions")
	interval     = flag.Int("interval", 3, "Seconds delay between connectivity checks")
	secretConfig = flag.String("secretConfig", "/etc/osquery/osquery.secret", "Path to osquery secret file")
)

func readS3config(filePath string) (S3Config, error) {
	// Read S3 creds from secret fole
	content, err := ioutil.ReadFile(filePath)
	if err != nil {
		log.Fatal(err)
		return S3Config{}, err
	}

	// Now let's unmarshall the data into `payload`
	var s3config S3Config
	err = json.Unmarshal(content, &s3config)
	if err != nil {
		log.Fatal(err)
		return S3Config{}, err
	}
	return s3config, nil
}

func getS3config() (string, error) {
	// Download file
	result, err := s3Client.GetObject(&s3.GetObjectInput{
		Bucket: aws.String(s3config.Bucket),
		Key:    aws.String(s3config.Config),
	})
	if err != nil {
		log.Fatal(err)
		return "", err
	}
	defer result.Body.Close()

	// Read file contents into buffer
	s3FileByteArray, err := ioutil.ReadAll(result.Body)
	if err != nil {
		log.Fatal(err)
		return "", err
	}
	return string(s3FileByteArray), nil
}

func GenerateConfigs(ctx context.Context) (map[string]string, error) {
	// Get S3 config
	var err error
	if s3config, err = readS3config(*secretConfig); err != nil {
		log.Fatal(err)
	}

	// Create a session instance.
	s3sess, err := session.NewSession(&aws.Config{
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
	s3Client = s3.New(s3sess)

	osqueryConfig, err := getS3config()
	if err != nil {
		log.Fatal(err)
		return nil, err
	}
	return map[string]string{
		"config1": osqueryConfig,
	}, nil
}

func main() {
	flag.Parse()

	if *socket == "" {
		log.Fatalln("Missing required --socket argument")
	}

	serverTimeout := osquery.ServerTimeout(
		time.Second * time.Duration(*timeout),
	)
	serverPingInterval := osquery.ServerPingInterval(
		time.Second * time.Duration(*interval),
	)

	server, err := osquery.NewExtensionManagerServer(
		"s3",
		*socket,
		serverTimeout,
		serverPingInterval,
	)
	if err != nil {
		log.Fatalf("Error creating extension: %s\n", err)
	}

	// create and register the plugin
	server.RegisterPlugin(config.NewPlugin("s3", GenerateConfigs))
	if err := server.Run(); err != nil {
		log.Fatalln(err)
	}
}
