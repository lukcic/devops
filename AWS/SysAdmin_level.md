# SysOps level
## Enhanced networking
**EC2 enhanced networking (SR-IOV)**
* higher bandwidth, hight PPS (packet per second), low latency
* option1 - Elastic Network Adapter (ENA) - up to 100Gbps
* option 2- Intel 82599VF uto to 10 Gbps (legacy)
* works on newer generation EC2 instances (from t3.x)

Checking ENA kernel module in Amazon Linux:
$modinfo ena 	# if present, module in installed

Checking type of  NIC in system
$ethtool -i eth0 # driver **ena** not **vif**
 
**Elastic Fabric Adapter (EFA)**
* improved ENA (Elastic network adapter) for High PerformanceComputing - only works with Linux
* great for inter-node communications, tightly coupled workloads (lives in the same cluster)
* leverages Message Passing Interface (MPI) standard
* bypasses the underlying Linux OS to provide low-latency, reliable transport

## Placement groups
Control where EC2 instances are placement. Placement group is chosen during EC2 creation (advanced options).

Strategies:
* cluster - EC2s grouped together in low latency hardware setup (rack) in single AZ, higher performance (10 Gbps) and higher risk
* spread - spread EC2 across different hardware (max 7 instances per placement group per AZ), for critical applications (reduces risk of simultaneous failure)
* partition - spread instances across many different partitions (separated sets of racks) within AZ, scales to 100s of EC2 instances per placement group (Hadoop, Cassandra, Kafka), up to 7 partitions per AZ

## Shutdown behavior an termination protection
Shutdown behavior is applicable only when shutdown is done from OS level - not form AWS console.
Termination protection is applicable from AWS console.

Termination protection on + shutdown behavior termination = 
the instance will be terminated during OS stop!!!
and cannot be terminated from AWS console.

## EC2 launch troubleshooting
### Instance limit
By default max 64 vCPU limit for on-demand and spot instances. 
Use another region or request higher limit.

Service Quotas service.

### Insufficient instance capacity
Not enough on-demand capacity in AWS AZ. 
Change AZ, wait or change instance type or amount. 

### Instance terminates immediately
* EBS volume limit is reached
* EBS snapshot is corrupted
* root EBS volume is encrypted and you don’t have permissions (key)
* AMI is missing required part (image.part.xx file)

## SSH connection problems
### Wrong username
* host key not found
* permission denied
* connection closed by [instance] on port 22
* too many authentication failures

### Connection timed out:
* SG config problem
* NACL config problem 
* route table config problem
* instance doesn’t have public IPv4
* CPU load of instance too high

### EC2 Instance connect
Allow SG to access from IP range used by AWS. 
Filter EC2_INSTANCE_CONNECT in https://ip-ranges.amazonaws.com/ip-ranges.json to look for proper IP range.

## SPOT instances
Spot request:
* maximum price
* desired number of instances
* lauch specification
* valid: from - until
* request time: one-time, persistent

Request time:
* one-time - request is done after one cycle reservation - termination
* persistent - if instances were terminated because price, spot request is stil valid and will be relaunched

Request status:
* open
* active
* closed (in one-time request after done)
* disabled
* failed
* cancelled 

Cancelling spot request doesn’t mean that instances will be terminated.
First cancel the request, then terminate instances!
You can only cancel requests that are: open, active or disabled.

## Burstable instances T2/T3
Burst means, that instance can utilize “burst credits” for spikes of CPU load.   Temporary increases the EC2 instance performance. Great for unexpected traffic. 
If the credits are over, then performance is decreased below normal! Credits are accumulated over time. 

T2/T3 Unlimited - pay extra money if you go over your credit balance, but you don’t lose performance. Instances should be monitored. To enable it use “Credit specification - Unlimited” in EC2 launch settings.

## Elastic IP
Can be attached to one instance at the time. but can be remap to another. (to mask the failure) You don’t pay for Elastic IP when it’s attached to a server. If not, you pay. Default limit 5 IPs. 

## CloudWatch metrics
Standard - every 5min
Detailed - every 1 min (paid).

Metrics types:
* CPU utilization + credits (T2/T3)
* Network in and out
* Disk - read and write (instance store only)
* Status Check
	* instance status - checks the VM
	* system status - checks the underlying hardware

RAM is not included in standard metrics! Needs CloudWatch agent.

### Status Checks
CloudWatch Metrics:
* StatusCheckFailed
* StatusCheckFailed_System
* StatusCheckFailed_Instance

Recovery - CloudWatch alarm
Send notification using SNS and/or recover EC2 with the same IPs, metadata and placement groups.

Recovery - Auto Scaling Group
Set ASG, cannot save the same public IP, EBS etc.

Custom metrics:
* basic resolution - every 1 min
* high resolution - 1s and less
* includes RAM and application level metrics
* need configured agent (standalone or SSM)
* need permissions on EC2 role to send data to CloudWatch, eg. CloudWatchAgentServerPolicy  or CloudWatchAgentAdminPolicy (can add data to parameter store)

### CloudWatch Unified Agent
Unified - new type, metrics and loga at the same time.
Default namespace for metrics from agent is called CWAgent.

procstat plugin - collect metrics and monitor system utilizaiton of individual processes (pid_file - pid, exe - process name, regex pattern).

Lessons 23 and 24 - configuration of agent.


## EC2 hibernate
RAM is preserved (saved on encrypted EBS) while stoping the VM. Boot is much faster. Use cases: long-running processing, saving the ram state, services that take time to initialize.

RAM less than 150GB, root volume must be EBS. Available for on-demand, reserved and spot instances. No more than 60 days!

Can be set in EC2 launch options -  “Stop - Hibernate behavior”. 
For check use uptime command. 

## AMI
AMIs are regional scoped. Custom AMIs are created from EBS snapshots. 

Creating AMI:
On running EC2 instance: Image and templates - Create image

No-reboot option - must be used when creating AMI form running EC2 (helps data integrity).

Moving Instances between AZs:
* create AMI from instance
* launch instance from AMI in different AZ

Cross account AMI sharing and copying
Edit AMI permissions.

Sharing does not affect ownership of AMI. AMIs with encrypted EBS can be shared only when customer managed key was used to encryption.

Copying images - owner of source AMI must grant you privileges of backbone storage (EBS snapshots). 

## EC2 Image Builder
Automate the creation, maintain, validate and test EC2 AMIs.
Free service - you pay for underlaying resources. Can be run on schedule.

EC2 Image Builder creates Builder EC2 Instance and applied Build Components (software customization) on it. New Ami is created from Builder instance that can be tested and it is distributed to region (or multiple regions). 

Recipe - the document that defines how source image will be customized. 

Policies used be Image Builder role:
EC2InstanceProfileForImageBuilder
EC2InstanceProfileForImageBuilderECRContainerBuilds
AmazonSSMManagedInstanceCore

AMIs verification for production
AMIs can be tagged and using IAM policy with condition users can only launch approved AMIs.
AWS Config can monitor AMIs and tag compliant AMIs for production.

## Resource groups
Logical groups of resources that share the same tags. Regional service.
Can be made on CloudFormation stack.

Tag “Name” will set EC2 name on instances list. 

## Systems Manager
Manage fleet of EC2s at scale. Get operational insights about the state of your infrastructure, easily detect problems. Patching automation. Free service. Use agent - do not need opening SSH port.

To add instance to fleet manager:
1. Add IAM role to EC2: AmazonEC2RoleforSSM 
2. Install SSM Agent on instance (Amazon and some Ubuntus got pre-installed software). 

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

## Load balancers
Use cases:
* spread load across multiple downstream instances
* expose a single point of access (DNS) to your application
* seamlessly handle failure of downstream instances
* do regular health-checks  to your instances
* provide SSL termination (HTTPS) for your instances
* enforce stickCross account backups.  ness with cookies
* high availability across zones
* separate public traffic from private traffic

### Load balancer types
* Classic Load Balancer (CLB) - old gen, 4 and 7: HTTP, HTTPS, TCP, SSL (secure TLS), fixed hostname
* Application Load Balancer (ALB) - newer gen, 7: HTTP, HTTPS WebSocket, 
* Network Load Balancer (NLB) - newer gen, TCP, TLS (secure TCP), UDP
* Gateway Load Balancer (GWLB) - newer gen, IP (layer 3)

LB can be set up as internal (private) or external (public).

Load balancer SG: allow 80 and 443 from anywhere.
EC2 SG: allow 80 from load balancer SG only! 

### Application Load Balancer 
Target groups - group of target machines. 
* EC2 instances (even from ASG) - HTTP
* ECS tasks - HTTP
* Lambda functions (HTTP request is translated into a JSON event)
* IP address (private)

Load balancing to multiple apps on the same machines (containers),. 
Automatically redirect HTTP to HTTPS.
Routing tables to different target groups - based on path in URL: example.com/users & example.com/posts
Routing based on hostname in URL 
(one.exaplme.com & two.example.com)
Routing based on Query Strings, Headers: 
example.com/users?id=123&order=true

The app servers don’t see client IPs, X-Forwarded-For, X-Forwarded-Port and X-Forwarded-Proto headers must be used. 

Listener Rules
Processed in order, default rule on the end. 
Weighting target groups - specific weight for each target group on a single rule, eg. multiple versions of your app, blue/green deployment. Allows to control the distribution of the traffic to your applications. 

Supported actions:
* forward - to a specific target group
* redirect - to a specific URL
* fixed-response - generate response to client

Rule conditions:
* host-header
* http-request-method
* path-pattern
* source-ip
* http-header
* query-string

### Network Load Balancer
Milion request per second - 100 ms latency (vs 400 ms for ALB).
Forward TCP and UDP traffic to instances. 
NLB has one static IP per AZ (instead static hostname) and supports Elastic IP assigning.

NLB target groups:
* EC2 instances
* private IP
* Application Load Balancer

From target perspective incoming traffic looks like from client (no from NLB) so traffic from all sources must be allowed!

### Gateway Load Balancer
Deploy, scale and manage a fleet of 3rd party network virtual appliances (Firewalls, IDS, IPS, Deep packet inspection etc). 
Operates at Layer 3 -Network layer (IP).

Combines the following functions:
* Transparent Network Gateway - single entry/exit for all traffic
* Load Balancer - distributes traffic to your virtual appliances.

Uses the GENEVE protocol on port 6081!

Target groups:
* EC2 instances
* IP addresses (private).

### Sticky sessions (session affinity)
The same client is always redirected to the same instance behind load balancer. Works in Classic and Application Load balancers. Uses cookie with expiration date. 

Cookie names:
* Application based cookies
	* AWSALBAPP (generated by ALB)
	* Custom cookie - generated by the target instance, individual for each target group. Cannot use reserver names.
* Duration based cookies
	* AWSALB generated by ALB
	* AWSELB generated by CLB

### Cross-Zone Load Balancing
LBs in different AZs - they can distribute load across instances in different than their Availability zones. 

Options:
* Application LB - always on (can’t be disabled), no charges for inter AZ data
* Network LB - disabled by default, pay charge for inter AZ data (if enabled)
* Classic Load Balancer - disabled by default, do NOT pay for inter AZ data.

### Connection draining
For CLB - connection draining, for newer gen. (ALB and NLB) - De-registration Delay. Time to complete in-flight requests while instance is de-registering from LB (disabling or unhealthy). LB will stop sending requests to this instance and wait set value of time to complete opened requests. Value can be set 0-3600 seconds (default 300). You should set low value only if your request are short. 

### Health Checks
* HealthCheckProtocol - HTTP - protocol used to perform health checks.
* HealthCheckPort - 80 - port used to check
* HealthCheckPath - / - destination on target 
* HeathCheckTimeoutSeconds - 5 - check failed if no response after 5s
* HeathCheckIntervalSeconds - 30 - send check every 30s
* HealthyThresholdCount - 3 - target healthy after 3 successful checks
* UnhealthyThresholdCount - 5 - target unhealthy target after 5 failed checks

Status:
* Initial - registering the target
* Healthy
* Unhealthy
* Unused - target is not registered
* Draining - de-registering the target
* Unavailable - health checks disabled

### Metrics:
* BackedconnectionErrors
* Healthy/UnhealthyHostCount
* HTTPCode_Backend_2xx - successful requests
* HTTPCode_Backend_3xx - redirected requests
* HTTPCode_Backend_4xx - client error codes
* HTTPCode_Backend_5xx - server error codes (from LB)
* Latency - how fast clients gets response
* RequestCount
* RequestCountPertarget
* SurgeQueueLength - the total number of requests/connections that are pending routing to healthy instance (help to scale out ASG)
* SpilloverCount - total number of rejected requests (because of full queue)

### Access Logs
Only pay for S3 storage with access logs. 

LB logs include:
* time
* client IP
* latencies
* request paths
* server response
* trace ID (X-Amzn-Trace-Id header)

### Target Group Settings
* deregistration_delay.timeout_seconds - time to load balancer waits before deregistering the target
* slow_start.duration_seconds - time to warm-up for instance, number of requests will linearly increase
* load_balancing.algorithm.type - RoundRobin, Least Outstanding Requests
* stickiness.enabled
* stickiness.type - application-based or duration-based cookie
* stickiness.app_cookie.cookie_name - name of the application cookie
* stickiness.app_cookie.duration_seconds - app-based cookie expiration
* stickiness.lb_cookie.duration_seconds - duration-based cookie expiration

### Routing Algorithms:
1. Least Outgoing Requests - the next instance to receive the request is the instance that has the lowest number of pending/unfinished requests. Works for ALB and CLB (HTTPS/HTTPS). The least busy instance!
2. Round Robin - equally chose the targets from the target group. Works with ALB and CLB (TCP).
3. Flow Hash - selects the target based on the protocol, source/destination IP, source/destination port and TCP sequence number. Each TCP/UDP connection is routed to a single target for the life of connection. Works with NLB -  equivalent of sticky sessions.  

## SSL
### Server Name Indication (SNI)
Protocol requires from client to indicate the hostname of webpage that is trying to reach during the initial SSL handshake. Works only with new gen. LB (Application , Network, CloudFront). Classic LB supports only 1! SSL cert. 

## Auto Scaling Group (ASG)
Services:
* Amazon EC2 Auto Scaling Groups
* Amazon EC2 Spot Fleet Requests (new or interrupted by price)
* Amazon ECS (adjust ECS service desired count up/down)
* Amazon DynamoDB (table or global secondary index)
* Amazon Aurora (Dynamic Read Replicas Auto Scaling)

Launch template (launch configurations) - contains information how to launch instances in AGS:
* MIN size, MAX size, initial capacity
* scaling policies
* AMI + instance type
* EC2 user data
* EBS volumes
* Security groups
* SSH key pair
* IAM roles
* Network + subnet information
* load balancer information 

Scale out - to add instances
Scale in - to remove instances

### Dynamic Scaling Policies
1. Target tracking scaling - average ASG CPU must stay at around 40%.
2. Simple/step scaling - when CloudWatch alarm is triggered, eg. CPU > 70%, then add 2 units, when <30, then remove 1 unit.
3. Scheduled actions - known usage patterns, eg. increase capacity to 10 at 5PM on Fridays. 
4. Predictive scaling - continuously forecast load and schedule scaling ahead. 

### Metrics
* ASG-level (optional)
	* GroupMinSize, GroupMaxSize, GroupDesiredCapacity, GroupInServiceInstances, GroupPendingInstaces, GroupStandbyInstances, GroupTerminatingInstances, GroupTotalInstances
* EC2-level metrics (enabled)
	* Basic: every 5mins
	* Detailed (paid): every 1 minute
	* CPUUtilization, RequestCountPerTarged, Average Network In/Out
	

### ASG Health Checks
* EC2 status check
* ELB status check
* Custom health check (send check using CLI or SDK: set-instance-health and terminate-instance-in-auto-scaling-group)

ASG always launch a new instance after termination unhealthy one.
ASG cannot reboot unhealthy instances. 

Scaling cooldown - after a scaling activity happens, ASG is in the cooldown period. During this, the ASG will not launch or terminate additional instances to allow metrics to stabilize. 

### ASG Lifecycle Hook
Vy default as soon as an instance is launched in an ASG group it’s in service. 

1. User can perform extra steps before the instance goes in service (pending state) - define a script to run on the instance as they start (eg. prepare instance)

Scale out -> Pending -> Lifecycle hook: EC2_Instance_Launching -> Pending: Wait -> Pending: Proceed -> In service

2. User can perform some actions before instance is terminated - pause the instances for. eg. troubleshooting, extract logs, create EBS snapshot. 

In Service -> Scale In -> Terminating -> Lifecycle hook: EC2_Instance_Terminating -> Terminating: Wait -> Terminating; Proceed -> Terminated

Integration wit: Event Bridge (Lambda), SNS, SQS.

### SQS withASG
CloudWatch metric - Queue length (ApproximateNumberOfMessages), if too high -> CloudWatch alarm -> ASG scale out
---

## Elastic Beanstalk
Platform as a Service. Layer that use all the components: EC2, ASG, ELB, RDS.  Free service - payment for used resources. 

Architecture models:
* single instance - for dev environments
* LB + ASG - for production or preproduction web apps
* ASG only - for non-web apps in production (using queue)

Components:
 * application - collection of Elastic Beanstalk components (environments, versions, configurations)
 * version - each deployment gets assigned version (iteration)
 * environment (dev, test, prod - free naming) collection of AWS resources running the application version (only one version at a time)
 * tiers: web server environment & worker environment

After deploying app version to giver environment, you can promote app version to next environment. Can do rollbacks. 

Create app -> upload version -> launch environment -> manage environment

Web Server tier - http endpoint, ELB + ASG + EC2
Worker tier - SQS Queue + ASG (scale based on SQS messages amount
---

## AWS Data Sync
Move large amount of data:
*  on-premise (NFS, SMB) -> AWS. 
* AWS EFS Region1 -> AWS NFS Region2

Can synchronise to S3 (all classes), EFS, FSx. Use Data Sync agent. Use scheduler (not continuous replication!) and can set bandwidth limit. 
---

## AWS Backup
Cross account backups.  
Cross region backups (store backup on another region). 
PITR (Point in Time Recovery) for supported services (Aurora).
Scheduler, tag-based backup policies. 

Backup plans - policies:
* frequency
* backup window
* transition to cold storage
* retention peroid

Backup Vault Lock:
* WORM (Write once, read many) state
* even root cannot delete backups
___

## CloudFormation
Templates have to be uploaded into S3 and then referenced in CloudFormation.
Stacks are identified by the name. Cannot be edited - versioning. 
Deleting a Stack deletes every single artifact that was created by CloudFormation!

Deploying templates:
1. Manual way - editing templates in CL designer and using console to input parameters etc.
2. Automated way - editing templates in YAML files, using the CLI to deploy templates. 

Building Blocks:
* resources [mandatory element] (AWS components
* parameters (the dynamic inputs for the template)
* mappings (static variables)
* outputs (references to what has been created)
* conditionals (list of conditions to perform resource creations)
* metadata

Template helpers:
* references 
* functions (transform data in template)

Stack template:
```
---
Resources:
  MyInstance:
    Type: AWS::EC2::Instance
    Properties:
      AvailabilityZone: us-east-1a
      ImageID: ami-a4c7edb2
      InstanceType: t2.micro
```

Change set preview - information about stack resources change during update. 

Resources identifiers:
```
AWS::service-name::data-type-name
```

[AWS resource and property types reference - AWS CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html)

Update requires:
* Replacement - new resource will be created
* No interruption - any changes to existing resource

### Parameters 
Way to provide  inputs to CF templates. Used when you won’t have to re-upload a template to change its content.

```
Parameters:
  SecurityGroupDescription:
    Description: Security Group Description (Simple parameter)
    Type: String
```
 
Parameters:
 * Type:
	* String
	* Number
	* CommaDelimitedList
	* List<Type>
	* AWS Parameter (to help catch invalid values)
* Description
* Constrains
* ConstraintDescription (String)
* Min/MaxLength (for string)
* Min/MaxValue (for numbers)
* Defaults
* AllowedValues (array) to restrict the number of values
* AllowedPattern (regexp) verify the user input
* NoEcho (boolean)

### Reference
Used for reference resources and parameters
Parameters => returns the value of parameter
Resources => returns the physical ID of underlying resource (EC2 ID) 

Fn::Ref == !Ref

```
DbSubnet1:
  Type: AWS::EC2::Subnet
  Properties:
    VpcId: !MyVPC
```

PseudoParameters:
AWS::AccountId		1234567890
AWS::Region 		us-east-2
AWS::StackName		MyStack

### Mappings
Fixed variables (hardcoded) in template.
Used for differentiate between different environments (dev, prod), regions, AMI types etc. - when you know in advance all values that can be taken. 

```
Mappings:
  RegionMap:
    us-east-1:
      "32": "ami-5464df4g"
      "64": "ami-5564df6g"
    us-west-1:
      "32": "ami-6264df4g"
      "64": "ami-3454df6g"
```

Fn::FindInMap == !FindInMap [MapName, TopLevelKey, SecondLevelKey]

`ImageID: !FindInMap [RegionMap, !Ref "AWS::Region", 32]`


### Outputs
Optional outputs values that can be imported/exported. 
Network CF template outputs variable as VPC ID, Subnet ID to use in another template. 

Can be accessed from AWS Console or CLI. Stack cannot be deleted if its outputs are referenced in another stack. 

```
Outputs:
  StackSSHSecurityGroup:
    Description: The SSH Security Group for many projects
    Value: !Ref MyCompanyWideSSHSecurityGroup
    Export: 
      Name: SSHSecurityGroup
```

### Cross Stack Reference
Fn::ImportValue == !ImportValue

```
Resources:
  MySecureInstance:
    Type: AWS::EC2::Instance
    Properties:
      AvailabilityZone: us-east-1
      ImageId: ami-a4c7edb2
      InstanceType: t2.micro
      SecurityGroups:
        - !ImportValue: SSHSecurityGroup
```

### Conditions
Used to control the creation of resources or outputs based on a condition.

Each condition can reference another condition, parameter value or mapping. Conditions can be applied to resources/outputs/ etc.

```
Conditions:
  CreateProdResources: !Equals [!Ref EnvType, prod]
```

Logical functions:
* Fn::And
* Fn::Equals
* Fn::If
* Fn::Not
* Fn:: Or

Conditions can be applied to resources/outputs/ etc.
```
Resources:
  MountPoint:
    Type: "AWS::EC2::VolumeAttachment"
    Condition: CreateProdResources
```

### Intrisic Functions
Wewnętrzne funkcje

1. Fn::GetAtt
Used to get information about resource, eg. AZ, PrivateIP for given EC2
```
~ AWS::EC2::Volume declaration
...
		AvailabilityZone:
  			!GetAtt MyEC2Instance.AvailabilityZone
```

2. Fn::Join
Join values with a delimiter.
!Join [delimiter, [comma-delimited list of values] ]
```
!Join [":", [a,b,c]]
this creates:
"a:b:c"
```

3. Fn::Sub
Used to substitute variables from text. String must contain ${VariableName}.
[need more info]

4. !Select

```
# Select first available AZ from given region
AvailabilityZones:
  - !Select
    - 0
    - Fn::GetAZs: !Ref 'AWS::Region'
```

### UserData in EC2
Entire script must be passed through the function using Fn::Base64.
UserData script log: /var/log/cloud-init-output.log

```
Resources:
  MyInstance:
    Type: AWS::EC2::Instance
    Properties:
    ...
    UserData:
      Fn::Base64: |		# pipe is used for multi-line string
        #!/bin/bash -xe
        yum update -y
        yum install -y httpd
        systemctl start httpd
        systemctl enable httpd
        echo "Hello world" > /var/www/html/index.html
```


### cfn-init
Send UserData from external resource - special format of writing scripts (like Ansible modules)., not in Bash.  EC2 instance is querying CloudFormation service for cfn-init script.

AWS::CloudFormation::Init must be in metadata of resource.
Logs are available in `/var/log/cfn-init.log`

```
Resources:
  MyInstance:
    Type: AWS::EC2::Instance
    Properties:
    ...
    UserData:
      Fn::Base64: 
        !Sub |		# pipe is used for multi-line string
        #!/bin/bash -xe
        # Get the latest CloudFormation package
        yum update -y aws-cfn-bootstrap
        # Start cfn-init
		  /opt/aws/bin/cfn-init -s ${AWS:StackId} -r MyInstance    		  --region ${AWS::Region} ||
        error_exit 'Failed to run cfn-init'
```

Metadata - see code #4 from materials. 

### cfn-signal & WaitCondition

Script tells CloudFormation if cfn-init script succeeded or not. This can be used for completing or cancelling template creation. 

Run cfn-signal right after cfn-init.

Define WaitCondition:
* block the template until it receives a cfn-signal
* attach a CreationPolicy (works with EC2 & ASG)

```
Resources:
  MyInstance:
    Type: AWS::EC2::Instance
    Properties:
    ...
    UserData:
      Fn::Base64: 
        !Sub |		# pipe is used for multi-line string
        #!/bin/bash -xe
        # Get the latest CloudFormation package
        yum update -y aws-cfn-bootstrap
        # Start cfn-init
		  /opt/aws/bin/cfn-init -s ${AWS:StackId} -r MyInstance    		  --region ${AWS::Region} ||
        error_exit 'Failed to run cfn-init'
        # Start cfn-signal to the wait condition
	      /opt/aws/bin/cfn-signal -e $? --stack ${AWS::StackId} 
        --resource SampleWaitCondition 
        --region ${AWS::Region}
  ...
  SampleWaitCondition:
    CreationPolicy:
      ResourceSignal:
        Timeout: PT2M
    Type: AWS::CloudFormation::WaitCondition
```

Troubleshooting:
* ensure that CloudFormation helper scripts are installed: 
yum update -y aws-cfn-bootstrap
* ensure that instance has access to the internet
* verify that both cfn-init and cfn-signal run on the host machine successfully - check the logs (disable rollback on failure)

Rollbacks:
If stack creation fails everything rolls back (changes are deleted, stack gets back to the previous working state). Optionally rollback can be disabled (for troubleshoot). 

Advanced Options: Stack Creation Options - Rollback on failure - Disable.

### Nested stacks
Used to isolate repeated patterns/ common components in separate stacks and call them from other stack, eg. load balancer configuration is re-used. 
To update nested stack, parent (root) stack must be updated. 

```
Resources:
  myStack:
    Type: AWS::CloudFromation::Stack
    Properties:
      Template: https://s3.amazonaws.com/cloudformation-templates-us-east-1/LAMP_Single_Instance.template
      Parameters:
        KeyName: ~Ref SSHKey
		  DBName: 'mydb'
        ...
```

### Change Sets
Information about what will change during updating our stack - something like terraform plan.  ChangeSet will not tell if the update will be successful. 

Can be Executed after reviewing changes or deleted. 

### Drifts
When someone else changed resources (deployed by CF) using another access method (eg. console or cli).
Stack Actions - Detect Drift - View drift results

### Termination Protection
Cannot delete stack:
Actions - Termination protection - Enable

### Deletion policy
Can be set on any resource to control what happens when CF template is deleted.

```
Resources:
  MySG:
    Type: AWS::EC2::SecurityGroup
    DeletionPolicy: Retain
    ...
```

Types:
* DeletionPolicy=Delete (default)
	* S3 bucket must be empty
	* AWS::RDS::DBCluster has default policy Snapshot
* DeletionPolicy=Snapshot
	* For: EBS Volume, ElastiCache Cluster, ElastiCache ReplicationGroup, RDS DBInstance, RDS DBCluster, RedShift Cluster
* DeletionPolicy=Retain (zachować)
	* specify resources to preserve/backup
	* works on any resource

### ASG CloudFormation CreationPolicy 

To be sure, that ASG is created properly.

```
Resources:
  AutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      DesiredCapacity: '3'
      ...
    CreationPolicy:
      ResourceSignal:
        Conut: '3'
        Timeout: PT15M
```


### ASG CloudFormation UpdatePolicy 

[Update Auto Scaling groups during a stack update in AWS CloudFormation](https://aws.amazon.com/premiumsupport/knowledge-center/auto-scaling-group-rolling-updates/)

AutoScalingRollingUpdate:
```
...
CreationPolicy:
  ...
UpdatePolicy:
  AutoScalingRollingUpdate:
    MinInstanceInService: '1'
    MaxBatchSize: '2'  # max 2 ath the time will be down
    PauseTime: PT1M  # how much time to wait for the signal
    WaitOnResourceSignal: 'true'
    # we can suspend process during the update
    # SuspendProcess:
    # - list of processes...   
```
Replace instances partially (rolling update).

AutoScalingReplacingUpdate:
```
...
CreationPolicy:
  ...
UpdatePolicy:
  AutoScalingReplacingUpdate:
    WillReplace: 'true'  
```
Create completely new ASG with new Launch Configuration, and when Creation Policy passed, replace them and delete old one. 

### DependsOn

Resource shouldn’t be created if DependsOn: Resource isn’t yet exists.

```
Resources:
  Ec2Instance: 
    Type: AWS::EC2::Instance
    Properties:
      ...
    DependsOn: MyDB

  MyDB:
    Type: AWS::RDS::DBInstance
    Properties:
      ...  
```

### Stack Policies
Used to prevent updating resources form stack. 

Advanced Options - Stack policy: 
```
{
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "Update:*",
            "Principal": "*",
            "Resource": "*"
        },
        {
            "Effect": "Deny",
            "Action": "Update:*",
            "Principal": "*",
            "Resource": "LogicalResourceId/CriticalSecGroup"
        }
    ]
}
```

### Stack Sets
Deploy application in multiple regions and accounts with single operation.

Roles:
* StackSetAdministrator (created manually)
* StackSetTrustedAccount (created by stack set)


## EC2 Storage management
### EBS volumes types:
* gp2/gp3 (SSD) - general purpose, can be root volume
* io1/io2 (SSD) - highest performance SSD, for mission critical, low latency or high-throughput workloads, can be root volume
* st1 (HDD) - low cost HDD for frequently accessed, throughput intensive workloads, cannot be root volume
* sc1 (HDD) - lowest cost HDD for less frequently accessed workloads, cannot be root volume

### General Purpose
GP2:
*  1GB - 16TB
* size of volume and IOPS are linked
* small volumes max 3000 IOPS
* max 16 000 IOPS at 5TB

 GP3
* 1GB - 16TB
* baseline 3 000 IOPS and 125MiB/s
* increase up to 16 000 IOPS and 1000 MiB/s (not linked)

### Provisioned IOPS SSD:
* critical business applications with permanent IOPS performance (databases eg. )
* supports EBS multi-attach
* io1/io2 (4GiB - 16TiB)
	* PIOPS independent from storage size
	* max 32 000 IOPS (64k for Nitro EC2)
	* io2 has more IOPS with the same price
* io2 Block Express (4GiB - 64 TiB)
	* max 256 000 IOPS
	* 1000 IOPS : 1GiB dependency
	* sub-milliseconds latency

EBS multi-attach - feature for some EBS. Volume can be attached to multiple instances in the same AZ simultaneously. Used for higher application availability in clustered Linux applications. Application must manage concurrent write operations (very specific eg. Teradata). Cluster-aware filesystem must be used (GFS, VMFS, Lustre). 

### Hard Disk Volumes HDD
* cannot be a root volume
* 125 MiB to 16 TiB
* throughput optimized (st1)
	* max 500MiB/s and 500 IOPS 
	* big data, data warehouse, log processing
* cold HDD (sc1)
	* infrequent data access
	* the lowest cost
	* max 250 MiB/s and 250 IOPS

### Resizing
Volume type can be changed.
Volume size cannot be decreased. 
After increasing volume size partition must be repatriated - disk size will be increased, but partition will stay the same. 

For root volumes:
```
sudo growpart [DISK_NAME] [PARTITION_NAME]
sudo growpart /dev/xvda 1
```

Other tools:
resize2fs
xfs_growfs

### Snapshots

Amazon Data Lifecycle Manager - automate the creation, retention and deletion of EBS snapshots and EBS-backed AMIs. Schedule backups, cross-account snapshot copies, delete outdating backups. Uses resource tags. 
Can only manage snapshots created by itself (no external). 

Fast Snapshot Restore
Snapshots are stored in S3. There is a latency of I/O operations (pulling from S3) while restoration. To fast this process force the initialization of entire volume (using dd or fio) or enable FSR.

FSR - creates a volume from snapshot that is fully initalized at creation (no i/o latency). Expensive!

EBS Snapshots archive - move snapshots to an archive tier (75% cheaper, 24-72h to restore). 

Snapshot Recycle bin - can be enabled (retention 1 ay to 1 year).

Encryption of EBS
If volume is encrypted:
* data at rest is encrypted inside the volume
* all data in flight while moving between the instance and the volume is encrypted
* all snapshots are encrypted
* all volumes created form the snapshots are encrypted

Encryption of old volume:
* create the snapshot
* encrypt snapshot (copy it with encryption checked)
* create new volume from encrypted snapshot
* attach encrypted volume instead old one

### Elastic File System (EFS)

Managed NFS (v4.1) - POSIX file system. 
Can be mounted on many EC2 in many AZ. 
Highly available, expensive (3x gp2), pay per use. 
Need Security group to access control. Encryption  at rest (KMS).
Scales automatically, pay per use, no capacity planning!
10 GB/s + throughput.

Performance mode (set at creation time)
* general purpose (default) - web servers, CMS, etc.
* max I/O - higher latency, throughput - big data, media processing

Throughput mode:
* bursting (1TB = 50 MiB/s + burst up to 100 MiB/s)
* provisioned - set your throughput regardless of storage size 
(eg. 1GiB/s for 1TB)

Storage tiers:
* standard - for frequently accessed files
* infrequent access (EFS-IA) - lower price, but cost to retrieve files, can be enabled by Lifecycle Policy

Availability and durability:
* standard - regional (multi-AZ), for prod
* one zone - for dev, backup enabled by default, compatible with EFS-IA

EFS Access Points
Enforce a POSSIX user and group to use when accessing the file system.
Restrict access to a directory within the filesystem and optionally specify a different root directory. Can restrict access from NFS clients using IAM policies.

/
  /data
  /secret
  /config

Access point 1 for UID: 1001, GID 1001, path: /config
For developers users/groups `/config = /`

Access point 2 for UID: 1002, GID 1002, path: /data
For analytics users/groups `/data = /`

Operations
To change Performance mode (e.g. Max IO) or encrypt EFS AWS Data Sync must be used (replicates all file attributes and metadata). 

CloudWatch metrics:
* PercentIOLimit - how close the filesystem reaching the I/O limit (GP), if at 100%, move it to Max I/O using DataSync
* BurstCreditBalance
* StorageBytes - 15min interval

## S3
S3 is regional scope, but bucket names must be globally unique. 

### Versioning
* file uploaded before enabling versioning: version = null
* file uploaded after enabling versioning: version = [long_hash]
* file deleted with enabled versioning: versions still exists, S3 adds “delete marker” - version stamp that disable object visibility
* restore file deleted with versioning: delete “the delete marker”

### Encryption
* SSE-S3 - keys are fully handled and managed by AWS
	* Server Side Encryption
	* upload with HTTP header: “x-amz-server-side-encryption”:”AES256”
* SSE-KMS - keys are controlled by Key Management Service 
	* KMS advantages: user control + audit trail
	* upload with HTTP header: “x-amz-server-side-encryption”:”aws:kms”
* SSE-C - keys are managed by user outside AWS
	* S3 doesn’t store encryption key
	* HTTPS must be used 
	* encryption key must be provided in HTTP headers for every request
* CSE - client-side encryption - files are uploaded in encrypted version 
	* library: Amazon S3 Encryption Client
	* S3 is storing only encrypted data - doesn’t provide any encryption/decryption operations

Encryption can be set on object level or for whole bucket - “Default encryption” option. 

### S3 security
* user based
	* IAM policies - which API calls should be allowed for a specific user 
* resource based
	* Bucket policies - allows cross account
	* Object ACL - read and write permissions at object level
	* Bucket ACL

Principal “*”  = public access

*S3 default encryption*
Prevent upload objects without encryption:
Properties - Default Encryption - Enable

Default encryption using bucket policy:
```
...
"Action" : "S3:PutObject",
"Effect" : "Deny",
"Condition": {
  "Null" : {
 		"s3:x-amzn-server-side-encryption" : "true"
  }
}

...
"Action" : "S3:PutObject",
"Effect" : "Deny",
"Condition": {
  "StringNotEquals" : {
 		"s3:x-amzn-server-side-encryption" : "AES256"
  }
}
```


*Blocking public access*

Options:
* Block all public access
* from new ACLs
* from any ACLs
* from new public bucket or access point policies
* from any public bucket or access point policies

Can be set to all buckets: “Account setting for block public access”.

*VPC endpoints* - for instances in VPC without internet access.

*S3 access logs* - can be stored in ANOTHER S3 bucket. Enabling both in the bucket same will create log loop. 
API calls (authorized and denied) can be logged in AWS cloud trail.

*MFA delete* - can be required in versioned buckets to delete objects.
It forces user to generate code to do important operations on S3: permanently delete an object version, suspend versioning on the bucket. 
Operations must be executed by CLI - AWS console will not work.

To enable this feature use CLI:
```
aws s3api put-bucket-versioning --bucket [BUCKET-NAME] --versioning-configuration Status=Enabled,MFADelete=Enabled --mfa "[MFA-DEVICE-ARN] [MFA-CODE]" --profile [PROFILEN-NAME] 
```

To enable/disable this feature root account must be used. 

*Pre-signed URLs* 
Valid only for limited time, default 3600 seconds. Set by “—expires-in”. 
Generation is made by SDK or CLI (downloads only). 
Permissions are inherited from user who generated link. 

Usage:
 * premium video service for logged in users,
 * ever changing list of users to download files by generating URLs dynamically
 * temporary allow user to upload a file to a precise location in our bucket

Download link can be generated from AWS Console:
Object actions - Share with pre-signed URL 

### S3 Replication
* Cross Region Replication CRR - compliance, lower latency access, replication across accounts.
* Same Region Replication SRR - log aggregation, live replication between prod and test accounts.

Versioning must be enabled (both).
Copying is asynchronous. Version IDs are replicated. 
Buckets can be in different accounts - must give a proper IAM permissions.
Only new objects are replicated, to replicate old and failed objects use S3 Batch Replication. Delete markers can be replicated (optional), deletion with version ID (permanent) are not replicated. No replication chaining. 

Enabling: (origin bucket) 
Management - Replication rules - Create
Will ask if replicate existing objects. 

### S3 Inventory
List objects and their metadata - alternative to S3 List API operations.

Can generate daily or weekly repots in CSV, ORC or Apache Parquet. 
Data can be queried using AWS Athena, Redshift and other. 
Report can be filtered using S3 select.

Usage:
 * audit and report on the replication and encryption status
 * get the number of objects in your S3 bucket
 * identify the total storage of previous object versions

Enabling:
Bucket - Management - Inventory Configuration
Second bucket to store data must be select (in the same region).

### S3 Baseline performance

5 500 GET/HEAD requests per second per prefix
3 500 PUT/COPY/POST/DELETE requests per second per prefix

It’s good to spread files in more than 1 prefix to get higher read performance. 

KMS limitations - 5 500, 10 000 or 30 000 quota (GenerateDataKey and Decrypt KMS API calls) per second, based on region, can be increased in Service Quotas. 

Multi-part upload:
* recomended for files > 100 MB
* obligatory for files > 5GB

S3 transfer acceleration - use internal AWS network (EDGE locations), so only part of traffic is transferred using Internet. Compatible with multi-part upload.

S3 Byte-Range Fetches - GETs requests only part of file - resilience of download failures, can be used to retrieve only part of data. 

### S3 Select & Glacier Select

Server side filtering (simple SQL statements) for download only needed files - cheaper and faster. 

### S3 Event Notifications

Simple events can be managed form bucket settings or EventBridge association can be enabled: 

event (put, delete…) —> S3 bucket —> EventBridge —- rules—-> 18 AWS destinations

Advanced filtering options with JSON rules (metadata, object size, name…)
Multiple destinations ex: StepFunctions, Kinesis Streams…
EventBridge Capabilities - Archive, Replay events, Reliable delivery

### S3 Lifecycle Rules

1. Transition actions - defines when objects are transitioned to another storage class, e: move to IA or Glacier. 
2. Expiration Actions - configure objects to expire (delete) after some time, ex: logs.

Rules can be created for:
* certain prefix, ex: s3://mybucket/mp3/*
* certain objects tags, ex: Department: Finance

Analytics - setup will help determine when to transition objects from Standard to Standard IA. Report updated daily.

S3 bucket - Analytics - Add filter - Destination bucket select

### Glacier
Alternative to on-premise magnetic tape storage. Encrypted by default (AES-256), keys are managed by AWS. 

S3:			Glacier:
Bucket		Vault
Object 		Archive

Max Archive size - 40TB.

Vault operations:
* Create & delete - delete only if empty
* Retrieving metadata - creation date, numer of archives, total size, etc.
* Download inventory - list of archives in the vault

Glacier operations:
* upload - single operation or by multiparts
* download - first initiate the retrieval job for the archive, then Glacier prepares it for download - user has a limited time to download the data from staging server (expiry time)
* delete - use Glacier REST API or AWS SDK by specifying archive ID

Retrieval options:
* expedited (1 to 5 mins) - $0.03 per GB
* standard (3 to 5h) - $0.01 per GB
* bulk (5 to 12h) - $0.0025 per GB

Vault policies - each vault has ONE policy for access and one for lock.
Policies are written in JSON. 

Vault Access policy is like a bucket policy - restrict user/accounts permissions. 

Vault lock policy is used for regulatory and compliance requirements. 
Policy is immutable - it can never be changed, ex: forbid deleting an archive if less than 1 year old. Must be validated in 24h using LOCK ID, otherwise will be deleted. 

WORM - write once, read many. 

Vault Notification Configuration:
* configure a vault so, that when a job completes, a message is sent to SNS
* optionally, specify an SNS topic when you initiate a job

S3 Event Notifications:
* S3 supports the restoration of objects archived to S3 Glacier storage classes
* s3:ObjectRestore:Post => notify when object restoration initiated
* s3:ObjectRestore:Completed => notify when object restoration completed



### CORS
Cross-Origin Resource Sharing

Origin = schema:
<protocol>://<host>:<port>

Same origin:
https://example.com/APP1 & https://example.com/APP2

Different origin:
https://WWW.example.com & https://OTHER.example.com

Browser-based security:
In your web app you can make request from other origin only if the other origin allows you to make this requests. 

Correct CORS headers must be used, ex: Access-Control-Allow-Origin. 

1. Web browser sends request to origin https://example.com
2. App code needs resources from another origin https://other.com
3. Browser sends “preflight request” to cross origin:
	* OPTIONS
	* Host: https://other.com
	* Origin: https://example.com
5. Cross origin sends the “preflight response” with response headers:
	* Access-Control-Allow-Origin: https://example.com
	* Access-Control-Allow-Methods: GET, PUT, DELETE
6. Browser received CORS headers, so now it can send request to Cross origin:
	* GET /
	* Host: https://other.com
	* Origin: https://example.com

### 

### S3 CORS

Browser ———— GET index.html ————— > bucket-html (website enabled)
Browser <————————————————-—————  bucket-html (website enabled)
       
Browser ——— GET coffee.jpg ———> bucket-assets (website en, Cross origin)		ORIGIN: https://bucket-html.s3-website.eu-west-3.amazonaws.com
Browser <————————————————-_  bucket-assets (website en, Cross origin)	
    	Access-Control-Allow-Origin:
	http://bucket-html.s3-website.eu-west-3.amazonaws.com

S3 bucket options: Cross-origin resource sharing (CORS):
```
[
    {
        "AllowedHeaders": [
            "Authorization"
        ],
        "AllowedMethods": [
            "GET"
        ],
        "AllowedOrigins": [
            "<url of first bucket with http://...without slash at the end>",
			  "http://demo-s3-bucket-2022.s3-website-eu-west-1.amazonaws.com"
        ],
        "ExposeHeaders": [],
        "MaxAgeSeconds": 3000
    }
]
```


 
