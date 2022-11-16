# EC2

## Metadata

To access EC2 metadata send curl request from host to:
```
http://169.254.169.254/latest/meta-data
```
Paths:
* /public-ipv4
* /ami-id
* /instance-type

## Changing instance type
* instance must be stopped
* after start will be restarted on another physical host in data-center
* data will remain the same (EBS)
* EBS Optimized - new types of EC2, better throughput

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
* launch specification
* valid: from - until
* request time: one-time, persistent

Request time:
* one-time - request is done after one cycle reservation - termination
* persistent - if instances were terminated because price, spot request is still valid and will be relaunched

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
Unified - new type, metrics and logs at the same time.
Default namespace for metrics from agent is called CWAgent.

procstat plugin - collect metrics and monitor system utilizaiton of individual processes (pid_file - pid, exe - process name, regex pattern).

Lessons 23 and 24 - configuration of agent.


## EC2 hibernate
RAM is preserved (saved on encrypted EBS) while stoping the VM. Boot is much faster. Use cases: long-running processing, saving the ram state, services that take time to initialize.

RAM less than 150GB, root volume must be EBS. Available for on-demand, reserved and spot instances. No more than 60 days!

Can be set in EC2 launch options -  “Stop - Hibernate behavior”.
For check use uptime command.

# AMI
Provides information required to launch an instance. Instance can be turned to AMI (copy of server). AMIs are regional scoped, to use AMI in any other region it must be copied there. Custom AMIs are created from EBS snapshots.

* template for the root volume (EBS snapshot or instance store template)
* launch permissions that control which AWS accounts can use teh AMI
* block device mapping that specifies the volumes to attach to the instance when it's launched

AMIs can be routinely patched by Systems Manager Automation.
AMIs are used with launch configurations (ASG).

AWS Marketplace - purchase subscriptions to vendor maintained AMIs.

### Creating AMI
By default when creating AMI from running instance, EC2 will shutdown the instance, take snapshot of existing volumes then creates and register AMI and start instance. This in the preferred way for application consistence (OS buffers are clear).

No-reboot option - must be used when creating AMI form running EC2 without shutdown. Option is not enabled by default. OS buffers are not empty while creating EBS snapshots.

How: Image and templates - Create image

### Moving Instances between AZs
* create AMI from instance
* launch instance from AMI in different AZ

Cross account AMI sharing and copying
Edit AMI permissions.

Sharing does not affect ownership of AMI. AMIs with encrypted EBS can be shared only when customer managed key was used to encryption.

Copying images - owner of source AMI must grant you privileges of backbone storage (EBS snapshots).

### Recreating AMIs
AMIs cannot be re-created or restored after deletion - new one must be created from EBS Snapshot or existing instance

## EC2 Image Builder
Automate the creation, maintain, validate and test EC2 AMIs.
Free service - you pay for underlying resources. Can be run on schedule.

EC2 Image Builder creates Builder EC2 Instance and applied Build Components (software customization) on it. New Ami is created from Builder instance that can be tested and it is distributed to region (or multiple regions).

Recipe - the document that defines how source image will be customized.

Policies used be Image Builder role:
EC2InstanceProfileForImageBuilder
EC2InstanceProfileForImageBuilderECRContainerBuilds
AmazonSSMManagedInstanceCore

AMIs verification for production
AMIs can be tagged and using IAM policy with condition users can only launch approved AMIs.
AWS Config can monitor AMIs and tag compliant AMIs for production.