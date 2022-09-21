## Systems Manager
Manage fleet of EC2s at scale. Get operational insights about the state of your infrastructure, easily detect problems. Patching automation. Free service. Use agent - do not need opening SSH port.

To add instance to fleet manager:
1. Add IAM role to EC2: AmazonEC2RoleforSSM
2. Install SSM Agent on instance (Amazon and some Ubuntu got pre-installed software).

### SSM - Documents

Definition of actions and parameters. Can be made in JSON or YAML.

### SSM Run Command
Execution of document (script) or run single command on multiple instances (resource groups). Integrated with IAM & CloudTrail. Output from console can be send into S3, SNS or CloudWatchLogs. Command can be invoked (run) using EventBridge.

Rate control - how much instances will run script simultaneously or manual stop execution of command if X errors occurs.

### SSM Automation
Automation task on AWS resources from outside of resource (command works from inside of resource). Used to create: EBS snapshots, creating AMIs, restarting instances. Can be trigerred manually, scheduled, by EventBridge or by AWS Config for rules remediations.

Automation run-book - SSM Documents type: Automation.

### SSM Parameter Store
Securely store configuration and secrets in AWS. Optional encryption (KMS). Version tracking. Integration with CloudFormation and CloudWatch Events. Hierarchy of stored secrets - path in name eg. “/my-app/dev/db-pass”.

Pricing:
Standard - free. max 10k parameters (4KB). Pay only for high output of API.
Advanced - 0.05$ per parameter. Max 100k (8KB). Parameters policies.

 Policies - create TTL of parameters (passwords).

Parameters types:
* string
* string list
* secure string

Accessing parameters by CLI:
`aws ssm get-parameters —names /my-app/dev/db-pass /my-app/prod/db-url`

`—with-decryption`
will check if user got KSM keys and if yes, will return decrypted secret

`aws ssm get-parameters-by-path —path /my-app/dev --recursive`
will return all parameters from given path

### SSM State Manager
Automate the process of keeping your instances in state that you defined. Used for eg. updating/patching OS. Uses SSM Documents to create Association (eg. SSM document to configure CloudWatch Agent.

State Manager Association
* defines the state that you want to maintain, eg. port 22 must be closed
* specify a schedule when the configuration is applied

### SSM Inventory

Collect data form your managed instances (EC2/on-prem): installed software, OS drivers, configurations, updates, running services etc. Data can be viewed in AWS Console or stored in S3 to query and analyze by Athena and QuickSight. Collection interval can be set.


### SSM Patch manager
Automates the process of patching OS (Linux,, macOS, Windows). Scan instances and generate patch compliance report.

Patch baseline - defines which patches should be installed (can be custom). Auto-approve within days of release. By default installs only critical/security patches.

Patch group - set of instances with specific Patch baseline (eg. environment: dev, prod). Use tag:  “Patch Group “.  Instance can be in only one Patch Group. Patch group can be registered with only one Patch baseline.

SSM Maintenance Window
* defines a schedule for when to perform actions on instances
* contains: schedule, duration, set of registered instances and tasks.

### SSM Session manager
Allows to SSH on EC2 and on-prem. Access through AWS Console, CLI or Session Manager SDK. Do not need SSH access, bastion host or keys (use agent). Can log connections (CloudWatch, S3). CloudTrail can listen sessions. Requires IAM permissions. Use tags for defining instances access. Even commands can be restricted.