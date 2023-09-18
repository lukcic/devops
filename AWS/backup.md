Error:
```
The provided role arn:aws:iam::1234567890:role/aws-service-role/backup.amazonaws.com/AWSServiceRoleForBackup cannot be assumed by AWS Backup.
```

Solution - create service-linked role:

```sh
aws iam create-service-linked-role --aws-service-name backup.amazonaws.com
```