# Observability
The ability to measure and understand how internal systems work in  order to answer questions regarding performance, tolerance, security and faults with a system/application.

To obtain observability you need to use Metrics, Logs and traces. you have to use them together!

>Metrics - variable to monitor CPU, RAM etc. Has timestamps.

>Traces - a history of requests that is travels through multiple apps/services so we can pinpoint performance or failure.

>Insight - wgląd, rozeznanie

# CloudWatch

Monitoring solution for AWS resources.

Umbrella service - collection of monitoring tools as:
* Logs - any log data (custom too)
* Metrics - represents a time-ordered set of data-points
* Events - trigger an event based on a condition
* Alarms - triggers notifications based on metrics
* Dashboards - create visualizations based on metrics
* Service Lens - visualize and analyze the health, performance, availability of your app in a single place
* Container insights - collets, aggregates and summarizes metrics and logs from your containerized apps and microservices
* Synthetics - test your web apps to see if they're broken
* Contributor Insights - view the top contributor impacting the performance of your systems and apps in real time

![](.pictures/cloudwatch.jpg)

## CloudWatch LOGS

### AWS Logs

Service logs:
* CloudTrail trails - trace all API calls
* Config Rules - for Config and compliance over time
* CloudWatch logs - for full data retention
* VPC Flow logs - IP traffic within your VPC
* ELB Access logs - metadata of requests made to load-balancers
* CloudFront logs - web distribution access logs
* WAF logs - full logging of al requests analyzed by the service

Logs can be stored in S3 and analyzed using Athena.
Log protection: S3 encryption, control access using IAM and Bucket Policies, MFA on deletion. Can be moved to Glacier for cost savings.

Sources:
* SDK
* CloudWatch log agent (unified)
* ElasticBeanstalk application
* ECS - logs from containers
* Lambda - logs from function
* VPC Flow Logs
* CloudTrail based on filter
* Route53 DNS queries
* API gateway

Destinations:
* S3 (exports)
* Kinesis Data SStream
* Kinesis Data Firehouse
* AWS Lambda
* Elasticsearch

>Log event - single event in a log file

>Log stream - sequence of events from monitored application or instance

>Log groups - collection of log streams. Name that is representing application (can be any name).


### Encryption
By default, log groups are encrypted at rest using SSE. Own Customer Master Key from KMS can be used.

### Retention
By default logs never expire.
Log expiration policies - can be set to amount of time (1day to max 10 years) for each log group or disable retention.

### Filtering
Filter expressions - can be used to ex: find specific IP within a log or count "ERROR" occurrences (create metric) and trigger CloudWatch Alarm.

Subscription Filter - can be used to send logs into other services (Lambda, ES, Kinesis) in near real-time.

#### Log Insights
Interactively search and analyze CloudWatch log data.
More robust filtering than using the simple filter events in a log stream.
More simple than analyzing logs in Athena.
Used to do ad-hoc queries against log groups via AWS Console.
Can be used to add queries to CloudWatch Dashboards.

Has its own language called `CloudWatch Logs Insights Query Syntax`.
AWS provides sample queries for common tasks.

Insights analyze the log event and try to structure the content by generating fields that you can use in the query (log parsing).

Five system fields (automatically generated):
* @message - the raw, unparsed log event
* @timestamp
* @ingestionTime - time when the log event was received by CW logs
* @logStream - the name of the log stream that the log event was added to
* @log - log group identifier in the form of: account-id:log-group-name

### Agent
CloudWatch log agent -can be installed on EC2 machines or on-premise servers for collecting logs by CloudWatch.

## CloudWatch METRICS

Metrics belongs to namespaces (groups).\
Dimension is an attribute of a metric (instance id, environment, etc...).\
Column name in AWS Console. Up to 10 dimensions per metric.

EC2 Default - metrics every 5mins, Detailed - every 1 min (paid extra)
Billing - Total Estimated Charge is available only in us-east-1 (for whole account)

Important metrics:
* `NetworkIn` and `NetworkOut` - usage of network by instance
* `DataTransfer-Out-Bytes` - used in AWS Cost Explorer reports to see pricing
* `DiskReadBytes`, `DiskWriteBytes` - data from all instance volumes, determine speed of application
* `ResourceCount` - metric used to determine the amount of resources running in the account

### Custom Metrics

For custom metrics is used API call: PutMetricData. It can be send with with dimensions (attributes) to segment metrics: Instance.Id, Environment.name.

Examples:
* memory usage (RAM)
* disk space
* number of logged users

Resolution:
* standard - 1min
* high resolution: 1, 5, 10, 30 seconds (higher cost)

You can retrieve custom metrics from your applications or services using the `StatsD` and `collectd` protocols. StatsD is supported on both Linux servers and servers running Windows Server. collectd is supported only on Linux servers.

Metrics are accepted with timestamp for 2 weeks in the past and 2 hours in the future. You must be sure about time settings in your server.

Push metric data:
```
aws cloudwatch put-metric-data --namespace "Usage Metrics" --metric-data file://metric.json

[
  {
    "MetricName": "New Posts",
    "Timestamp": "Wednesday, June 12, 2013 8:28:20 PM",
    "Value": 0.50,
    "Unit": "Count"
  }
]
```
```
aws cloudwatch put-metric-data --metric-name Buffers --namespace MyNameSpace --unit Bytes --value 231434333 --dimensions InstanceID=1-23456789,InstanceType=m1.small
```

## CloudWatch ALARMS

Trigger notifications for any metric.

Alarm states:
>OK                 - all is alright\
>INSUFFICIENT_DATA  - not enough data points to decide\
>ALARM              - when state is wrong

Targets:
* EC2 - stop, Terminate, Recover instance
* ASG - trigger Auto-scaling action
* SNS - send notification into an SNS topic (later to Lambda)

Status check:
* Instance status - check the VM
* System status - check the underlying hardware

StatusCheckFailed_System - can be used to recover the EC2 (same subnet, Elastic IP, metadata, placement group).

To set the alarming state (testing) use CLI:\
`aws cloudwatch set-alarm-state --alarm-name "my-alarm" --state-value ALARM --state-reason "testing purposes`

## CloudWatch EVENTS

Make an action on target when event occur on source by creating Event rule.

>Fourth pillar of observability.

* Event pattern - get events from AWS services (sources) to make reaction (SNS topic when IAM root user logged in). Can get any API call using CloudTrail integration.
* Schedule cron jobs

JSON payload is created from the event and passed to a target:
* compute - Lambda, Batch ECS task
* integration - SQS, SNS, Kinesis
* orchestration - Step functions, CodePipeline, CodeBuild
* maintenance - SSM, EC2 Action

### Amazon EventBridge
Evolution of CloudWatch events. It uses teh same service API and endpoint.

* Default Event BUS - generated by AWS services (CloudWatch Events)
* Partner Event Bus - receive event from SaaS service or applications (DataDog, Auth0)
* Custom Event Buses - for your own applications

Events can be archived after sent to Event Bus, and replayed from archive.

Rules - defines how to process the events.

Schema Registry:\
Event Bridge can analyze the events in bus and gather the schema.
Schema (JSON) registry allows you to generate the code from your application, that will know in advance how data is structured in the event bus. Schema can be versioned.

Resource-based Policy:\
Event Buses can be accessed from other AWS accounts. Policy manage permissions for a specific Event Bus, ex: allow/deny events from another AWS account. Use-case: to aggregate all events from AWS Organization in a single AWS account.

For Lambda functions and Amazon SNS topics configured as a target to EventBridge, you need to provide resource-based policy. IAM roles for rules are only used for events related to Kinesis Streams.

For Lambda, Amazon SNS, Amazon SQS, and Amazon CloudWatch Logs resources, EventBridge relies on resource-based policies. For Kinesis streams, EventBridge relies on IAM roles.

Sandbox:\
Test rules and patterns without creating the rule.

## CloudWatch DASHBOARDS
* dashboards are global
* can include graphs from different AWS accounts and regions
* timezone and time range can be changed
* automatic refresh (10s-15m)
* can be shared with people without AWS account (public, email address, 3rd party SSO through Amazon Cognito)
* 3 dashboards (up to 50 metrics) for free, $3 per dsb per month

# CloudTrail (ślad)
Governance, compliance and audit for AWS account.
Enabled by default, diagnose who did what.
History of events/API calls within account (console, CLI, SDK connections), can put logs to CloudWatch or S3.

Events types:
* Management Events (logged by default) - operations performed on resources: create resource, attach policy. Read and Write events (modifications). No charges, KMS events can be excluded (amount).

* Data Events (not logged by default) - operations on S3 object level: Get, Put, Delete Object, Lambda executions. Read and Write events.

* Insight Events (additional payment) - detect unusual activities (service limits, provisioning problems, gaps in maintenance). Create baseline of normal activity and continuously analyze write events.

Retention:\
Events are stored by 90 days. Can be stored in S3 to use in Athena (SQL analysis).

Log File Integrity Validation
Digest Files - reference of log files from last hour - contains hash of each log file. Is stored in the same bucket as logs, but in different directory (index).
Determine if log file was modified after deliver by CloudTrail. Bucket should be protected by: policy, versioning, MFA Delete Protection, encryption, object lock.

Integration with EventBridge
Every API call can be sent to Event Bridge. Cloudtrail is not real-time, 15 min for event delivery, 5 mins to store log file in S3 bucket.

Organization Trails
CloudTrail can be set on Organization level - events from all accounts in Organization. Member accounts have read-only access to it't trails.

# Service Quotas

How near you are from reaching service limits. CloudWatch Alarm can be set when you're close to threshold. You can check any type of actions and request for higher quota value.

# AWS Config

Record configurations of services and it's changes over time for audits and compliance needs. Use rules to check f current config is compliant or not. Rules don't prevent actions from happening - it's only view of changes. Configuration data can be stored in S3 to analyze in Athena. Alerts using SNS notifications when configuration changes (resource is non-compliant). Per region service, data can be aggregated form many regions. Paid service.

Problems:
* Is any unrestricted SSH access in my security groups?
* Do any of my buckets have public access?
* Has my ELB configuration changed over time?

Config Rules:
* AWS managed config rules (over 75)
* custom rules (must be defined in AWS Lambda)

Rules can be evaluated/triggered:
* for each config change
* scheduled

>Pricing - $0.003 per configuration item recorded, $0.001 per config rule evaluation.

### Remediation (korekta)
Non-compliant resources can be remediated using SSM Automation Documents (can be custom). Max 5 Remediation Retries. Ex: deactivate ssk keys older than 90 days.

### Aggregators
One AWS Account that has enabled aggregator - centralized view of config from all source accounts. It's aggregates rules, resources, etc across multiple account and regions. Without Organizations on all account must be created authorizations.
Rules are created in each account separately, to deploy rules to multiple target account CloudFormation StackSets must be used.


