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

# Amplify

Web and mobile applications development tool (like Elastic Beanstalk).
A set of tools adn services that heps you develop and deploy scalable full stack web and mobile applications: authentication, Storage, API (REST, GraphQL), CI/CD, analytics, monitoring, etc.

Developer:
* configure backend using Amplify CLI (S3, Cognito, API Gateway, Lambda, DynamoDB,...)
* connect frontend to backend using Amplify Frontend Libraries (React, Vue, Flutter)
* build using Amplify Console & deploy (Amplify Console, CloudFront)




