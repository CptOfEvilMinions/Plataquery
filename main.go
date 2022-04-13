package main

import (
	"context"
	"encoding/json"
	"flag"
	"io/ioutil"
	"log"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/osquery/osquery-go"
	osquery_config "github.com/osquery/osquery-go/plugin/config"
)

type S3Config struct {
	AccessKey string `json:"access_key"`
	SecretKey string `json:"secret_key"`
	Region    string `json:"region"`
	Bucket    string `json:"bucket"`
	Config    string `json:"config"`
}

var s3config S3Config
var s3Client *s3.Client

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

func initS3client() (*s3.Client, error) {
	// Get S3 config
	var err error
	if s3config, err = readS3config(*secretConfig); err != nil {
		return nil, err
	}

	// Set S3 creds
	creds := credentials.NewStaticCredentialsProvider(
		s3config.AccessKey,
		s3config.SecretKey,
		"",
	)

	// Init S3 config
	cfg, err := config.LoadDefaultConfig(
		context.TODO(),
		config.WithCredentialsProvider(creds),
		config.WithRegion(s3config.Region),
	)
	if err != nil {
		return nil, err
	}

	// Init S3 client
	return s3.NewFromConfig(cfg), nil
}

func getS3config(ctx context.Context) (string, error) {
	// Download file
	output, err := s3Client.GetObject(ctx, &s3.GetObjectInput{
		Bucket: aws.String(s3config.Bucket),
		Key:    aws.String(s3config.Config),
	})
	if err != nil {
		log.Fatal(err)
		return "", err
	}
	defer output.Body.Close()

	// Read file contents into buffer
	s3FileByteArray, err := ioutil.ReadAll(output.Body)
	if err != nil {
		log.Fatal(err)
		return "", err
	}
	return string(s3FileByteArray), nil
}

func GenerateConfigs(ctx context.Context) (map[string]string, error) {
	// Get Osquery config
	osqueryConfig, err := getS3config(ctx)
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

	// Init S3 client
	var err error
	s3Client, err = initS3client()
	if err != nil {
		log.Fatalf("Error creating extension: %s\n", err)
	}

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
	server.RegisterPlugin(osquery_config.NewPlugin("s3", GenerateConfigs))
	if err := server.Run(); err != nil {
		log.Fatalln(err)
	}
}
