# Plataquery

## Debugging extension locally on macos
1. `brew install osquery`
1. `osqueryi`
1. `select * from osquery_extensions;`
```
osquery> select * from osquery_extensions;
+------+------+---------+-------------+---------------------------------------+------+
| uuid | name | version | sdk_version | path                                  | type |
+------+------+---------+-------------+---------------------------------------+------+
| 0    | core | 5.0.1   | 0.0.0       | /Users/testuser/.osquery/shell.em     | core |
+------+------+---------+-------------+---------------------------------------+------+
```
1. `go build -o osq-ext-s3.ext main.go`
1. `./osq-ext-s3.ext --socket /Users/testuser/.osquery/shell.em`

## References
### Terraform
* [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)
* [How can I create an AWS Kinesis Firehose connected to S3 using Terraform?](https://stackoverflow.com/questions/67574884/how-can-i-create-an-aws-kinesis-firehose-connected-to-s3-using-terraform)
* [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
* [aws_s3_bucket_lifecycle_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration)
* [aws_kinesis_firehose_delivery_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream)
* [Grant Your Application Access to Your Kinesis Data Firehose Resources](https://docs.aws.amazon.com/firehose/latest/dev/controlling-access.html#using-iam-s3)
* [Use case: Kinesis Data Streams vs Kinesis Data Firehose](https://medium.com/aws-architech/use-case-kinesis-data-streams-vs-kinesis-data-firehose-74d639214e89)
* []()
* []()

### Osquery
* [osquery/osquery-go](https://github.com/osquery/osquery-go)
* [osquery-go/examples/table/main.go](https://github.com/osquery/osquery-go/blob/master/examples/table/main.go)
* [Logging osquery to AWS](https://osquery.readthedocs.io/en/stable/deployment/aws-logging/)
* [FleetDM-Automation/conf/osquery/osquery_linux.flags](https://github.com/CptOfEvilMinions/FleetDM-Automation/blob/main/conf/osquery/osquery_linux.flags)
* []()
* []()
* []()
* []()
* []()

### Golang
* [Convert map[interface {}]interface {} to map[string]string](https://stackoverflow.com/questions/26975880/convert-mapinterface-interface-to-mapstringstring)
* [Fetching and reading files from S3 using Go](https://dev.to/seanyboi/fetching-and-reading-files-from-s3-using-go-4180)
* [Reading Unstructured Data from JSON Files](https://golangdocs.com/golang-read-json-file)
* [How To Convert JSON To Map In Golang](https://appdividend.com/2022/03/15/how-to-convert-json-to-map-in-golang/)
* []()
* []()
* []()
* []()
* []()