######################################### Firehose #########################################
resource "aws_kinesis_firehose_delivery_stream" "osquery_firehose" {
  name        = "osquery-delivery-stream-to-s3"
  destination = "s3"

  s3_configuration {
    role_arn   = aws_iam_role.firehose_assume_role.arn
    bucket_arn = aws_s3_bucket.osquery_logs.arn
  }
}