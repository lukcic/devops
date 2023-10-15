Saving automated snapshot:

```sh
aws rds copy-db-snapshot --source-db-snapshot-identifier $id_migawki --target-db-snapshot-identifier copied_snapshot
```

Policy for protecting RDS from deletion:
```json
{
    "Version": "2012-10-17",
    "Statement": [{
        "Sid": "test",
        "Effect": "Deny",
        "Action": ["rds:Delete*", "rds:Remove*"],
        "Resource": "*"
    }]
}
```