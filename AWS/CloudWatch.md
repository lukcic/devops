Alarm for EC2 recovery

```yml
RecoveryAlarm:
Type: 'AWS::CloudWatch::Alarm'
Properties:
    AlarmDescription: 'Odzyskaj instancje EC2 w razie awarii bazowego sprzetu.'
    Namespace: 'AWS/EC2'
    MetricName: 'StatusCheckFailed_System'
    Statistic: Maximum
    Period: 60
    EvaluationPeriods: 5
    ComparisonOperator: GreaterThanThreshold
    Threshold: 0
    AlarmActions:
    - !Sub 'arn:aws:automate:${AWS::Region}:ec2:recover'
    Dimensions:
    - Name: InstanceId
    Value: !Ref VM
```