## Resource groups
Logical groups of resources that share the same tags. Regional service.
Can be made on CloudFormation stack.

Tag “Name” will set EC2 name on instances list.

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



# ElasticSearch -> OpenSearch

Amazon ES - managed version of ElasticSearch. Need to run on servers (not serverless).

Use-cases:
* Log analytics
* RealTime application monitoring
* Security Analytics
* Full text search
* Click-stream analytics
* Indexing

ElasticSearch patterns

DynamoDB
```
---> CRUD ---> DynamoDB Table ---> DynamoDB Stream ---> Lambda Function ---> Amazon ES

            EC2 ---> Amazon ES (API to search items), then
            EC2 ---> DynamoDB Table (API to retrieve items)

```

ElasticSearch Access Policy - IP based policy access to given IP.

Kibana Authentication
* no support for IAM
* HTTP Basic Auth
* SAML - 3rd party identify providers
* Amazon Cognito (MS AD integration)

ElasticSearch Production Setup:
* Domain deployed across 3 AZ
* 3 dedicated master nodes in different AZs (1 active, 2 backups)
* at least 2 data nodes per AZ
* at least 1 replica for each index in the cluster

# X-Ray

Visual analysis of application. Graph that show connections between micro-services and average response time. Debugging in Production.

Use-case:
* Troubleshooting performance (bottlenecks)
* review requested behavior
* Dependencies between micro-services
* Checking SLA

Integration:
* S3 - to trace upstream requests
* Lambda - Lambda runs the X-Ray daemon and records a segment with details about the function invocation and execution
* API Gateway - trace and analyze user requests as they travel through your APIs to the underlying services. API Gateway supports X-Ray tracing for all API Gateway endpoint types: Regional, edge-optimized, and private.

Application Load balancers do not send data to X-Ray!

# Amplify

Web and mobile applications development tool (like Elastic Beanstalk).
A set of tools adn services that heps you develop and deploy scalable full stack web and mobile applications: authentication, Storage, API (REST, GraphQL), CI/CD, analytics, monitoring, etc.

Developer:
* configure backend using Amplify CLI (S3, Cognito, API Gateway, Lambda, DynamoDB,...)
* connect frontend to backend using Amplify Frontend Libraries (React, Vue, Flutter)
* build using Amplify Console & deploy (Amplify Console, CloudFront)

# OpsWorks
Configuration Management. Service that provides fully-managed instances for Chef and Puppet. Alternative SSM.

OpsWorks allows you to clearly define the layers of your stack, ex:
* Load Balancer
* Application
* Database

## OpsWorks Stacks
* managed version of Chef (11 and 12)
* define your application as a stack which has layers, instances and app
* easily upgrade Amazon Linux 1 to 2
* can attach a load balancer
* can define container layers and RDS layers
* set IAM user permissions to control stack operations
* schedule EC2 instance to run on a schedule
* set EC2 instances to run auto scaling base on CPU usage

>Stack - the container (box) for entire stack\
>Layers -a blueprint for a set of EC2 instances\
>Instances - represents a server\
>Apps - code stored in a repository that you want to install on application server instances\

Each layer has a set of five lifecycle events, each of which has an associated set of Chef recipes.
Lifecycle events:
* Setup - occurs after a started instance has finished booting
* Configure - occurs on all of the stack's instances when one of the following occurs:
    * instance enters/leaves the online state
    * Elastic IP address associate/disassociate from the instances
    * ELB attach/detach to layer
* Deploy - occurs when you run a deploy command
* Undeploy - occurs when you delete an app or run an undeploy command to remove the app from set of app server instances
* Shutdown - occurs after you direct OpsWorks Stacks to shut an instance down but before the associated EC2 instance is actually terminated

Run commands - perform manual operations:
* Update custom cookbooks
* Execute recipes
* setup
* configure
* upgrade OS

Rest skipped