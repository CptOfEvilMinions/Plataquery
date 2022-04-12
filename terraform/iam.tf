######################################### IAM user #########################################
resource "aws_iam_user" "plataquery_user" {
  name = "plataquery-osquery"
  tags = {
    Project = var.PROJECT_PREFIX
    Team    = var.TEAM
  }
}

resource "aws_iam_access_key" "plataquery_access_key" {
  user = aws_iam_user.plataquery_user.name
}

resource "aws_iam_user_policy" "plataquery_user_policy" {
  name   = "plataquery-user-policy"
  user   = aws_iam_user.plataquery_user.name
  policy = data.aws_iam_policy_document.osquery_agent_policy_document.json
}

######################################### IAM policy #########################################
data "aws_iam_policy_document" "osquery_agent_policy_document" {
  version = "2012-10-17"
  statement {
    sid = "AllowOsqueryAgentToGetS3config"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]
    resources = [ 
      aws_s3_bucket.osquery_configs.arn,
      "${aws_s3_bucket.osquery_configs.arn}/*"
      ]
  }

  statement {
    sid = "AllowOsqueryAgentToLogToFirehose"
    effect = "Allow"
    actions = [
      "firehose:DeleteDeliveryStream",
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
      "firehose:UpdateDestination"
    ]
  
    resources = [ 
      aws_kinesis_firehose_delivery_stream.osquery_firehose.arn
    ]
  }

}

resource "aws_iam_policy" "osquery_agent_policy" {
  name   = "osquery-agent-policy"
  policy = data.aws_iam_policy_document.osquery_agent_policy_document.json
}

######################################## Firehose #########################################
data "aws_iam_policy_document" "firehose_assume_role_document" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "firehose_role_policy_document" {
  version = "2012-10-17"
  statement {
    sid = "AllowFirehoseToWriteToS3"
    effect = "Allow"
    actions = [ 
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject" 
    ]
    resources = [
      aws_s3_bucket.osquery_logs.arn,
      "${aws_s3_bucket.osquery_logs.arn}/*"
    ]
  }
}
resource "aws_iam_policy" "firehose_role_policy" {
  name = "firehose-role-policy"
  policy = data.aws_iam_policy_document.firehose_role_policy_document.json
}

resource "aws_iam_role" "firehose_assume_role" {
  name = "firehose-assume-role"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role_document.json
  managed_policy_arns = [aws_iam_policy.firehose_role_policy.arn]
  tags = {
    Project = var.PROJECT_PREFIX
    Team    = var.TEAM
  }
}