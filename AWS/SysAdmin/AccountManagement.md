# AWS Personal Health Dashboard
* Global service
* programmatically accessible using AWS Health API
* aggregations from multiple account using Organizations

Health Event Notifications
* sue EventBridge (CloudWatch Events) to react to changes for AWS HEalth events,
ex: receive email notification when the EC2 instances in your account are scheduled for updates
* CloudWatch Events can invoke:
    * Lambda
    * SNS
    * SQS
    * Kinesis Data Stream

```
AWS Personal Health Dashboard ---> CloudWatch Events ---> Lambda ---> Slack
```

# Organizations
* Global service
* allow to manage multiple AWS Accounts, separation per:
    * department
    * cost center
    * environment
    * logging account
    * higher limits
    * account for client
* master account cannot be changed
* member account can be part of only one organization (can be migrated)
* master account can be migrated after deleting organization
* consolidated billing across all accounts
* pricing benefits (aggregated usage)
* API for account creation automation
* Sharing reserved instances and Saving plans between accounts (in the same AZ), can be disables
* Tagging strategies for billing purposes
* `aws:PrincipalOrgID` condition key can be used in resource-based policies
to restrict access to IAM principals from accounts in Organization

Master Account
  Project OU
      Project Account
  Project OU
      Project Account
      Project Account

Policies:
* All services opt-out policies (AI)
* Backup policies
* Service Control Policies
* TAG policies

### Service Control Policies (SCP)
* restriction of account privileges - policy defines, which services account can use or which not
* whitelist or blacklist IAM actions
* applied on OU or Account level - to all users and roles of the account (including root)
* does not apply do master account
* deny have higher priority than allow
* SCP doesn't affect service-linked roles (other AWS services integration with Organizations)
* doesn't allow anything by default (allow must be set)

Use-cases:
* restrict access to certain services
* enforce PCI compliance by disabling given services

### TAG policies
* you defined keys and allowed values
* prevent any non-compliant tagging operations on specified services and resources
* helps with AWS Cost Allocation tags
* non-compliant/tagged resources reports
* use CloudWatch Events to monitor non-compliant tags

# Control Tower

Set-up and govern multi-account AWS environment based on best practices.\
Upper than AWS Organizations, setups it and manage.\
Creates separated accounts for log archive, audits etc., implement SCPs.

Benefits:
* automate setup of your environment in a few clicks
* automate outgoing policy management using Guardrails
* detect policy violations and remediate them
* monitor compliance through an interactive dashboard
* using SSO to log-in to all accounts with one credentials

### Guardrails

Governance rules to enable on OU:
* disallow deletion of log archive,
* disallow changes of CloudTrial configuration
* enable encryption for log archive etc.

# AWS Service Catalog

Quick self-service portal to launch of set of authorized products pre-defined by admins.\
Include: virtual machines, databases, storage options.
Portal to managing project infrastructure by your client without AWS knowledge (based on CloudFormation).

Admin tasks:
* create Products (CloudFormation templates)
* create Portfolio (Collection of products)
* Control (IAM permissions to access Portfolios)

User tasks:
* Product list - authorized by IAM ---> launch
* Provisioned products - reade to use properly configured and tagged

Share portfolios with individual AWS accounts or Organizations.
There is a possibility to add products from the imported portfolio to the local portfolio.

Sharing Options:
* share a reference of the portfolio, then import the shared portfolio
into the recipient account - stay in sync with the original portfolio,
* deploy a copy of the portfolio into the recipient account (must re-deploy any updates)

TagOption - key-value pair used to create AWS Tag, Can be associated with Products and Portfolios.
Can be shared with other AWS accounts and Organizations.

# Billing Alarm

Overall actual cost. Simple alarm, not so powerful as AWS Budgets.\
Actual metrics for overall AWS are stored in CloudWatch us-east-1.

1. Enable usage monitoring:
Account ---> My Billing Dashboard ---> Billing preferences ---> Receive Billing Alerts

2. Create alarm:
Us-east-1 ---> CloudWatch ---> Alarms ---> Billing ---> Create alarm --->
---> Select Metric ---> Billing ---> Total estimated charges

# Cost Explorer
* visualize, understand and manage AWS costs and usage over time
* create custom reports that analyze cost and usage data
* analyze your data at high level: total cost, and usage across all accounts
* monthly and hourly resource level granularity
* enable an optimal Savings Plan
* forecast usage up to 12 months based on previous usage

# AWS Budgets
Creates a budget and alarms when costs exceeded the budget.
Up to 5 SNS notifications per budget, extensive filtering.
2 budgets are free, rest 0,02$/day.

Types:
* Usage
* Cost
* Reservation
* Savings Plan

For Reserved Instances:
* track utilization
* supports EC2, ElastiCache, RDS, RedShift

# Cost Allocation Tags

Used to track AWS costs on a detailed level. Tag must be activated in Billing Dashboard - Cost Allocation Tags.

Types:
* AWS Generated tags - automatically attached to resources, starts with `aws:`
* User defined tasks - starts by `user:`

Examples:
* aws:createdBy
* aws:cloudformation:stack-id
* user:Environment
* user:Name

# Cost and Usage Reports

The most comprehensive set of AWS cost and usage data available.
Includes additional metadata about AWS services, pricing and reservations.
Reports can be configured for daily exports to S3 and analyze by Athena or Redshift.

List AWS usage for each:
* service category used by an account
* in hourly or daily line items
* any tags that you have activated for cost allocation purposes

# Compute Optimizer

Helps to choose optimal configuration and right-size for your workloads (over/under provisioned).
Uses ML to analyze your resources configuration and their utilization ClodWatch metrics.
Can lower costs up to 35%, recommendations can be sent to S3.

Supported resources:
* EC2 instances
* EC2 ASG
* EBS volumes
* Lambda Functions.