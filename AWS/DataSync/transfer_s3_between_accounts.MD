# Transfer S3 bucket content to another account

https://docs.aws.amazon.com/datasync/latest/userguide/tutorial_s3-s3-cross-account-transfer.html
https://repost.aws/questions/QUPD3ZX7p3T3OQkk19QN-iEw/datasync-between-s3-buckets-failing-ensure-bucket-access-role-has-s3-listbucket-permission

## Source account

### Create DataSync source location

Using creator choose source bucket.

### Create an IAM role for DataSync

Role for AWS service with `AWSDataSyncFullAccess` policy.

Edit trust relationship for role (add your user):
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "datasync.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::0123456789:user/your.username"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

Add inline policy to the role:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::DESTINATION-BUCKET"
    },
    {
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:ListMultipartUploadParts",
        "s3:PutObject",
        "s3:GetObjectTagging",
        "s3:PutObjectTagging"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::DESTINATION-BUCKET/*"
    }
  ]
}

## Destination account

### Create new bucket and disable ACLs!

### Set up bucket policy:
```json
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "DataSyncCreateS3LocationAndTaskAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::SOURCE-ACCOUNT:role/SOURCE-DATASYNC-ROLE"
      },
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:AbortMultipartUpload",
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:ListMultipartUploadParts",
        "s3:PutObject",
        "s3:GetObjectTagging",
        "s3:PutObjectTagging"
      ],
      "Resource": [
        "arn:aws:s3:::DESTINATION-BUCKET",
        "arn:aws:s3:::DESTINATION-BUCKET/*"
      ]
    },
    {
      "Sid": "DataSyncCreateS3Location",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::SOURCE-ACCOUNT:role/SOURCE-DATASYNC-ROLE"
      },
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::DESTINATION-BUCKET"
    }
  ]
}
```

## Source account

### Create DataSync destination location

Using CloudShell:
```sh
aws sts get-caller-identity  # check your current identity
aws sts assume-role --role-arn arn:aws:iam::0123456789:role/RoleForWriteBucketInDiffAccount --role-session-name test
aws sts get-caller-identity  # you should still be a user
export AWS_ACCESS_KEY_ID=ASI... # switch identity to role using generated above credentials
export AWS_SECRET_ACCESS_KEY=8LV8r...
export AWS_SESSION_TOKEN=IQoJb3J...PMcjQ==
aws sts get-caller-identity  
aws datasync create-location-s3 --s3-bucket-arn arn:aws:s3:::test-backups-archive --s3-config '{"BucketAccessRoleArn": "arn:aws:iam::0123456789:role/RoleForWriteBucketInDiffAccount"}'
```

Create Data Sync task:
```sh
aws datasync create-task --source-location-arn 'arn:aws:datasync:eu-central-1:0123456789:location/loc-0206db4ba3865b297' --destination-location-arn 'arn:aws:datasync:eu-central-1:0123456789:location/loc-08818af32b62ba69a' --cloud-watch-log-group-arn 'arn:aws:logs:eu-central-1:0123456789:log-group:/aws/datasync' --name 'migration'
```

## Run task