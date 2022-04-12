resource "random_string" "random_s3_prefix" {
  length = 5
  upper   = false
  lower   = true
  number  = true
  special = false
}

######################################### config bucket #########################################
resource "aws_s3_bucket" "osquery_configs" {
  bucket = "osquery-configs-${random_string.random_s3_prefix.result}"
  tags = {
    Name    = "osquery-configs"
    Project = var.PROJECT_PREFIX
    Team    = var.TEAM
  }
}

resource "aws_s3_bucket_acl" "osquery_configs_acl" {
  bucket = aws_s3_bucket.osquery_configs.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "osquery_configs_versioning" {
  bucket = aws_s3_bucket.osquery_configs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "osquery_configs_logging" {
  bucket = aws_s3_bucket.osquery_configs.id

  target_bucket = aws_s3_bucket.osquery_config_access_logging.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_lifecycle_configuration" "osquery_config_lifecycle" {
  bucket = aws_s3_bucket.osquery_configs.id
  rule {
    id = "osquery-config-lifecycle-rule"
    filter {}
    expiration {
      days = 90
    }
    status = "Enabled"
  }
}

data "aws_iam_policy_document" "osquery_agent_s3_bucket_policy_document" {
  version = "2012-10-17"
  statement {
    sid = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.plataquery_user.arn]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.osquery_configs.arn,
      "${aws_s3_bucket.osquery_configs.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "osquery_config_allow_agent_access" {
  bucket = aws_s3_bucket.osquery_configs.id
  policy = data.aws_iam_policy_document.osquery_agent_s3_bucket_policy_document.json
}


######################################### access log bucket #########################################
resource "aws_s3_bucket" "osquery_config_access_logging" {
  bucket = "osquery-config-access-logging-${random_string.random_s3_prefix.result}"
  tags = {
    Name    = "osquery-config-access-logging"
    Project = var.PROJECT_PREFIX
    Team    = var.TEAM
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "osquery_config_access_logging_lifecycle" {
  bucket = aws_s3_bucket.osquery_config_access_logging.id
  rule {
    id = "osquery-config-access-logging-lifecycle-rule"
    filter {
      prefix = "logs/"
    }
    expiration {
      days = 90
    }
    status = "Enabled"
  }
}

######################################### osquery log bucket #########################################
resource "aws_s3_bucket" "osquery_logs" {
  bucket = "osquery-logs-${random_string.random_s3_prefix.result}"
  tags = {
    Name    = "osquery-logs"
    Project = var.PROJECT_PREFIX
    Team    = var.TEAM
  }
}

resource "aws_s3_bucket_acl" "osquery_logs_acl" {
  bucket = aws_s3_bucket.osquery_logs.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "osquery_logs_lifecycle" {
  bucket = aws_s3_bucket.osquery_logs.id
  rule {
    id = "osquery-logs-lifecycle-rule"
    filter {}
    expiration {
      days = 90
    }
    status = "Enabled"
  }
}