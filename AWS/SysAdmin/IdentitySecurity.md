# IAM
Policies types
* managed policies
* customer managed policies
* inline policies (directly attached to the user)

### IAM Credentials report
Account level. Lists all account's users and the status of their various credentials.

### IAM Access Advisor
User level. Shows the service permissions granted to a user and when those service were last accessed. This information can be used to revise existing policies.

### IAM Access Analyzer

Find out which resources are shared externally.
Define `Zone of Trust` which is AWS Account or AWS Organization. All resources with access outside Zone of trust if a finding. Free to enable.

* S3 buckets
* IAM roles
* KMS keys
* Lambda functions and layers
* SQS Queues
* Secret Manager secrets

---
# Identity Federation

Federation lets users outside of AWS to assume temporary role for accessing AWS resources (they don't have IAM account).

User logs in to 3rd party service that is Trusted by us and this 3rd party service gives him access to AWS resources.

Federation assumes a form of 3rd party authentication:
* LDAP
* Microsoft AD (~= SAML)
* Single SignOn
* Open ID
* Cognito

Using Federation you don't need to create IAM users. User management is outside of AWS.

### SAML Federation

For enterprises, to integrate Active Directory/ADFS with AWS (or any SAML 2.0). Provides access to AWS Console or CLI (through temporary credentials).

SAML CLI access
![SAML CLI access](https://docs.aws.amazon.com/IAM/latest/UserGuide/images/saml-based-federation.diagram.png)

SAML Console access
![SAML Console Access](https://docs.aws.amazon.com/IAM/latest/UserGuide/images/saml-based-sso-to-console.diagram.png)

### Custom Identity Broker

Use only if identity provider is no compatible with SAML 2.0.
Identity broker must determine the appropriate IAM policy.
A lot of work must be done to enable Custom identity broker.

## Cognito
For public applications. Provide direct access to AWS resources from the client side (users of the app).

* Log in to federated identity provider - or remain anonymous.
* Get temporary AWS credentials back from the `Federated Identity Pool` (Cognito)
* These credentials come with a pre-defined IAM policy stating their permissions.

Ex: provide (temporary) access to write to S3 bucket using Facebook login.

Accessing AWS services using an identity pool:
![](https://docs.aws.amazon.com/cognito/latest/developerguide/images/scenario-cup-cib.png)

### Cognito User Pools (CUP) - user features
* Create a serverless database of users for your web and mobile app
* Simple login (username/password), MFA
* Password reset
* Federated Identities: users from Facebook, Google, SAML
* Feature: block users if their credentials are compromised anywhere
* Login sends back a JSON Web Token (JWT)
* custom the hosted UI for authentication
* can trigger the Lambda during the authentication flow (ex: analytics)

Integrations:
* API Gateway
    * user authenticate in Cognito and retrieve the token
    * connect to API gateway using token
    * API gateway connect to cognito to verify the token
    * API gateway gives permissions to backend
* Application Load balancer
    * using Listeners and Rules

### Cognito Identity Pools (Federated Identities)
* Get identities for users to obtain temporary AWS credentials
* Your identity pool can include:
    * public providers (Amazon, Facebook, Google, Apple)
    * users in Cognito Users Pool
    * OpenID Connect Providers & SAML Identity Providers
    * Developer Authenticated Identities (custom login server)
* Cognito Identity Pools allow to unauthenticated (guest) access
* Users can access AWS services directly or through API Gateway
    * The IAM policies applied to the credentials are defined in Cognito
    * they can be customized based on the `user_id` for the grained control

Accessing AWS resources:
* user logged in and retrieved JWT token
* Cognito after verification exchange this token to temporary AWS credentials
* direct access to resources with STS token and IAM policy

IAM roles:
* default IAM roles for authenticated and guest users
* define rules to choose the role for each user based on the user's ID
* you can partition your user's access using policy variables - row based (DynamoDB) or prefix-based (S3) security
* IAM credentials are obtained by Cognito Identity Pools trough STS
* the roles must have a trust policy of Cognito Identity Pools

## AWS IAM Identity Center
Past name: `AWS Single SignOn (SSO)`

Centrally manage Single SignOn to access multiple accounts and 3rd party business applications. Centralized permission management, integrated with AWS Organizations, integration with on-premise AD. Supports SAML 2.0. Auditing with CloudTrail.

Wy log in to SSO, it checks our login (can be in AD) and then we have access to AWS, 3rd party applications and SAML integrated software.

---
# STS - Security Token Service

Create temporary, limited credentials to access AWS resources.\
Token is valid up to 1h (must be refreshed).

### AssumeRole:
* within your own account: for enhanced security
* cross account access - assume role in the target account to perform actions here

Using STS to assume role:
* define an IAM role within your account or cross-account
* define which principals can access this IAM role (users or roles)
* use STS to retrieve credentials and impersonate the IAM role you have access to (AssumeRole API)
* temporary credentials can be valid between 15min to 1h

![](https://docs.aws.amazon.com/IAM/latest/UserGuide/images/roles-usingroletodelegate.png)

>Never share credentials across accounts - instead creating the user and sending credentials is better to create a role, and sure the user assume that role and STS will return you role credentials that are temporary, so if they will be loosen its much safer.

### AssumeRoleWithSAML:
* return credentials for users logged with SAML

### GetSessionToken:
* for MFA - from a user or AWS account root user
* anytime when users hav MFA, they have to use GetSessionToken to access console or CLI

---
# DDoS Protection

Services used to protect:
* Shield Standard - free, activated for everyone (3,4 layer attacks)\
* Shield Advanced - paid ($3000) 24/7 premium, response team, higher fees pays AWS
* WAF - filter specific requests based on rules
* CloudFront and Route53 - availability protection by using global edge network
* ASG - be ready to scaling

Architecture:
Users --- Route53 (with Shield) --- CloudFront (with Shield) + WAF --- ELB in public network (with Shield) --- ASG (in private network)

# WAF

Filter specific requests based on a rules (7 layer)

Can be deployed on:
* App Load Balancer
* API Gateway
* CloudFront
* AppSync

No for EC2!

Web ACL for WAF
* Rules can include:
    * IP address rules
    * HTTP Headers
    * HTTP body
    * URI strings
* Protects from:
    * SQL injection
    * Cross-Site Scripting (XSS)
* Other features:
    * geo-match (block countries)
    * rate based rules (DDoS)

# Penetration testing

Allowed without approval:
* EC2, NAT Gateways, ELB
* RDS
* CloudFront
* Aurora
* API Gateways
* Lambda & Lambda@Edge
* LightSail
* ElasticBeanstalk Environments

Prohibited:
* simulated DDoS
* DNS zone walking
* port flooding
* protocol flooding
* request flooding

# Inspector

Automated security Assessments (ratings).\
Continuous scanning of the infrastructure (if enabled). Database of CVE.

For EC2:
* OS vulnerabilities (database of CVE)
* unintended network accessibility
* network reachability

SSM agent must be installed and configured properly on EC2 instance to work with inspector.

For ECR Container: inspect images while pushing for known package vulnerabilities.

Reporting to AWS Security HUB and EventBridge.

Pricing: 15 days free trial. Expensive service!

# GuardDuty

Intelligent Threat discovery to protect AWS account.
Protect account with anomaly detection powered by machine learning and 3rd party data.

Input data:
* CloudTrail logs - unusual API calls, unauthorized deployments
    * CloudTrail Management Events - create VPC, etc
    * CloudTrail S3 Data Events - get object, list objects, etc.
* VPC FlowLogs - unusual internal traffic, unusual IP address
* Kubernetes AuditLogs - suspicious activities and potential EKS Cluster compromises
* DNS logs - compromised EC2 instances sending encoded data within DNS queries
* cryptocurrency attacks module

Integration with CloudWatch Event -> Lambda or SNS

Pricing: 30 days trial, must be enabled.

# Macie

Discover and protect sensitive (PII - Personally Identifiable Information) data (form S3) in AWS using machine learning and pattern matching. Fully managed service. Export to CloudWatch Events.

# Trusted Advisor (doradca)

High level account recommendations. Weekly email notification.

Analyze your AWS account - works on defined checks (passed or not)

Trusted advisor is based on AWS support plans.

Basic and developer support plan (7 checks):
* Cost optimization
    * instances low utilization, idle load balancers, under-utilized EBS
    * reserved instances and saving plans optimizations
* performance
    * high utilized instances, CloudFront optimizations
    * EC2 to EBS throughput optimizations, alias records recommendations
* security
    * MFA on root account, IAM key rotation, public exposed access keys
    * S3 bucket permissions for public access, security groups with unrestricted ports
* fault tolerance
    * EBS snapshots age, Availability Zone balance
    * ASG Multi-AZ, RDS Multi-AZ, ELB configuration
* service limits

Business and enterprise Support plan:
* full check based on all 5 categories
* set CloudWatch alarms when limits reached
* AWS support API (programmatic access)
* Weekly Email notifications Option!!!

---
# Encryption

## Key Management Service (KMS)

>CloudTrail, Glacier and Storage Gateway are encrypted by default!

Keys types:
* symetric (AES-256)
    * single key to encrypt/decrypt
    * used by AWS services integrated with KMS
    * cannot access unencrypted key - must call KMS API to use

* asymtric (RSA & ECC key pairs)
    * public key to encrypt and private key to decrypt
    * used to sign/verify
    * public key is downloadable, but cannot access private key in unencrypted form
    * use-case:  encryption outside AWS, by users who can't call the KMS API

KMS keys:
* AWS managed keys (free): aws/rds, aws/ebs…
* Customer managed keys created in KMS ($1 per key)
* Customer managed keys imported ($1 per key): must be 256-bit symetric
* Custom key stores HSM (expensive)

Pricing: $0.03 per 10 000 calls

>The same KMS key cannot live in 2 different regions.
For copying EBS volume encrypted with KMS, encrypted snapshot must be created, then snapshot after copying will be re-encrypted with different key from target region (AWS will handle this).

>EBS volume encryption key cannot be changed - create new volume using snapshots and specify the new KMS key.

### Key rotation
* AWS-managed KMS keys: automatic rotation every 1 year
* Customer-managed KMS keys: automatic rotation every 1 year (must be enabled)
* Imported KMS key: only manual rotation using alias

#### Automatic key rotation
* always for 1 year
* previous key is kept to decrypting old data
* new key has the same ID (only key is changed)

#### Manual key rotation
* when you want rotate keys more often than once a year
* new key has different ID
* keep the previous keys active, so you can decrypt old data
* better to use aliases in this case (to hide the key ID changes)

### KMS key deletion
* deletion can be scheduled with a waiting period of 7 - 30 days
* during `pending deletion` status key can't be used for any cryptographic operations, key is not rotated even if was planned
* deletion during waiting period can be cancelled
* when key in pending deletion is tried to use, you can specify notification (CloudTrail, CloudWatch Alarms, SNS) using metric filter `in pending deletion`

### KMS key policies

Control access to KMS keys like S3 bucket policies:
* Default KMS Key policy
    * created if ou don't provide own KMS key policy
    * complete access to the key to the root user = entire AWS account

* Custom KMS key policy
    * define users or roles that can access the KMS key
    * define who can administer the key
    * useful for cross-account access to the kys

>Copying Snapshots across accounts:
>* create a snapshot encrypted with won KMS key (customer managed)
>* attach a KMS Key policy to authorize cross-account access
>* share the encrypted snapshot
>* Create a copy of the Snapshot (in target), encrypt it with a CMK in your account.

Example of encrypting/decrypting file using AWS keys (with API calls):

```bash
# 1) encryption
aws kms encrypt --key-id alias/tutorial --plaintext fileb://ExampleSecretFile.txt --output text --query CiphertextBlob  --region eu-west-2 > ExampleSecretFileEncrypted.base64

# base64 decode for Linux or Mac OS
cat ExampleSecretFileEncrypted.base64 | base64 --decode > ExampleSecretFileEncrypted

# 2) decryption

aws kms decrypt --ciphertext-blob fileb://ExampleSecretFileEncrypted   --output text --query Plaintext > ExampleFileDecrypted.base64  --region eu-west-2

# base64 decode for Linux or Mac OS
cat ExampleFileDecrypted.base64 | base64 --decode > ExampleFileDecrypted.txt
```
### Hardware Security Module (CloudHSM)
AWS provision dedicated encryption hardware, we are managing keys entirely.
Supports both symetric and asymetric keys. HMS clusters are spread across Multi AZ (HA).

---

# AWS Artifact

On-demand access to AWS compliance documentation and agreements.
For audit and compliance.

---

# ACM - AWS Certificate Manager

Provision, manage ad deploy SSL/TlS certificates.
Supports private and public certificates.
Free of charge for public TLS certificates.
Automatic certificate renewal.

Integration:
* ELB
* CF Distribution
* APIs on the API gateway

---

# Secrets Manager

Capability to force rotation of secrets every X days.
Automate generation of secrets (using Lambda).
Secrets rotation events details are registered in CloudTrail. Combined with CloudWatch Alarms gives possibility to notify users.
Strong integration with RDS (MySQL, PostrgreSQL, Aurora) for storing DB credentials.
Other DBs: Redshift, DocumentDB, other). Can generate API keys.
Secrets are encrypted using KSM.

Pricing:
* 30 days trial demo
* $0.40 per secret per month
* $0.05 per 10,000 API calls

### Differences between Parameter Store:
* simple API
* no parameter rotation
* KMS encryption is optional in Parameter Store
* Parameter Store has CloudFormation integration
* can pull secret (from Secret Manager) using the SSM Parameter Store API

CLI:\
`aws secretsmanager describe-secret --secret-id "secret/name"`\
will show secret details

`aws secretsmanager get-secret-value --secret-id "secret/name" --version-stage AWSCURRENT`\
will show last version of secrets value

---
# Check for later:
>https://learn.cisecurity.org/benchmarks

```
Using EC2 roles
Admin creates role that grants access to the photos bucket.
Developer launches an instance with the role
App retrieves role credentials from the instance
App gets photos using the role credentials


Roles between different accounts

First account want to have access to resource on second account:
On second account role is created.
From first account make AssumeRole call
On second account we need give permissions for the first account

Dropdown from console - we don’t need to have user in second account.
Both accounts can be accessed from one console.


Credentials
Hashicorp vault
Credash - open source in dynamo
parameter store
secrets manager

Iam access to DB (STS)

SG referring SG
Instead opening one subnet to another we can use SG for giving access for subnet only for part of another subnet.

Golden AMI - one image that is a base for others. Create snapshot after hardening instance. Plus system manager.

System updates during bootstrapping (cloud-init).

AWS Inspector - checks instance regularly for vulnerabilities and old packages. Creates reports and notifications.


Guard duty
 - analyze VPC flow logs and reports information about attack tries

AWS CIS security benchmark
by AWS Security HUB
https://learn.cisecurity.org/benchmarks
```


