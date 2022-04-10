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
    sid = "AllowOsqueryAgentToLogToKinesis"
    effect = "Allow"
    actions = [
      "kinesis:DescribeStream",
      "kinesis:PutRecord",
      "kinesis:PutRecords",
    ]
  
    resources = [ 
      "${aws_s3_bucket.osquery_configs.arn}/*" 
    ]
  }

}

resource "aws_iam_policy" "osquery_agent_policy" {
  name   = "osquery-agent-policy"
  policy = data.aws_iam_policy_document.osquery_agent_policy_document.json
}

######################################### Kinesis #########################################
data "aws_iam_policy_document" "kinesis_assume_role_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "kinesis_assume_role" {
  name = "kinesis-assume-role"
  assume_role_policy = data.aws_iam_policy_document.kinesis_assume_role_document.json
  tags = {
    Project = var.PROJECT_PREFIX
    Team    = var.TEAM
  }
}