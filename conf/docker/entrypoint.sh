#!/bin/bash

sed -i "s#{{ aws_access_key }}#${AWS_ACCESS_KEY}#g" /etc/osquery/osquery.secret
sed -i "s#{{ aws_secret_key }}#${AWS_SECRET_KEY}#g" /etc/osquery/osquery.secret
sed -i "s#{{ aws_region }}#${AWS_REGION}#g" /etc/osquery/osquery.secret
sed -i "s#{{ s3_bucket }}#${S3_BUCKET}#g" /etc/osquery/osquery.secret
sed -i "s#{{ config_name }}#${S3_CONFIG}#g" /etc/osquery/osquery.secret

sed -i "s#{{ aws_firehose_stream }}#${AWS_FIREHOSE_STREAM}#g" /etc/osquery/osquery.flags
sed -i "s#{{ aws_access_key_id }}#${AWS_ACCESS_KEY}#g" /etc/osquery/osquery.flags
sed -i "s#{{ aws_secret_access_key }}#${AWS_SECRET_KEY}#g" /etc/osquery/osquery.flags
sed -i "s#{{ aws_region }}#${AWS_REGION}#g" /etc/osquery/osquery.flags

/opt/osquery/bin/osqueryd --flagfile /etc/osquery/osquery.flags 