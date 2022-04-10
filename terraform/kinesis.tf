######################################### Kinesis streams #########################################
resource "aws_kinesis_stream" "osquery_stream" {
  name             = "osquery-stream"
  retention_period = 24

  shard_level_metrics = [
    "IncomingRecords",
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  tags = {
    Project = var.PROJECT_PREFIX
    Team    = var.TEAM
  }
}

resource "aws_kinesis_firehose_delivery_stream" "test_stream" {
  name        = "osquery-delivery-stream-to-s3"
  destination = "s3"

  s3_configuration {
    role_arn   = aws_iam_role.kinesis_assume_role.arn
    bucket_arn = aws_s3_bucket.osquery_logs.arn
  }
}