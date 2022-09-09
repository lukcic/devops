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




