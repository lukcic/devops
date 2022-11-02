## CDK:
* App
	* Stack
		* Construct
			* AWS Resource (Lambda)
			* AWS Resource (Bucket)
	* Stack
		* Construct
			* AWS Resource (Any)
		* Construct	

Docs
[API Reference · AWS CDK](https://docs.aws.amazon.com/cdk/api/v2/docs/aws-construct-library.html)
[What is the AWS CDK? - AWS Cloud Development Kit (AWS CDK) v2](https://docs.aws.amazon.com/cdk/v2/guide/home.html)

### CDK App:
App s special root construct. Orchestrates the lifecycle of the stacks and resources within it.

App lifecycle:
Construct -> Prepare -> Validate -> Synthesize -> Deploy

### CDK Stack 
* CDK Stack becomes a CloudFormation stack.
* Multiple Stack can be within app.
* Stacks within the same App can share resources.
* CDK Nested Stacks generate CloudFormation nested stacks (stacks with stacks as resources).

### CDK Constructs

Basic building blocks of AWS CDK Apps. Represents a cloud Component and encapsulates everything.

* Level 0 -Basic resources (no Type)
* Level 1 - CloudFormation resource (1:1)
	* these are prefixed with `Cfn` in the CDK API
	* no defaults, no helper functions
	* ex: AccessAnalyzer
* Level 2 - Improved L1 constructs
	* no prefix
	* provided by the CDK team
	* extended L1 constructs with sensible defaults
	* include helper methods
	* ex: DynamoDB table
* Level 3 - Combination of constructs
	* created at the individual organisation level or community level
	* provided as libraries
	* sources:
		* CDKPatterns.com
		* AWS Solutions Constructs (npm library)  https://docs.aws.amazon.com/solutions/latest/constructs
		* Construct HUB https://constructs.dev
		* Inner/Open Source Constructs
	* ex: notifying bucket (S3 bucket with SNS topic to send notifications when object creation event occurs)

Most frequently L2/L3 constructs are used.
___
### First project:

`node --version` - check node version (16)
`npm install -g aws-cdk` - will install CDK packages in system
`cdk --version` - check cdk version

In project directory:
! Check AWS profile.

`cdk init app --language typescript` - initialize project, will create git repo and all necesarry files

`cdk list` - list all the stacks, creates cdk.out directory with CFn templates

`cdk diff` - compare code changes with current resources, like terraform plan

`ckd synth` - convert cdk code to CFn template

`cdk deploy [STACK_NAME]` - deploy stack (like terraform apply)
`cdk destroy` - destroy stack

#### Files and directories

`package.json` - node project settings and dependencies, and starting-point

```json
  “bin”: {
    “project1”: “bin/project1.ts”
  },

```
`/bin` - entry-point of project

Declaration of app and stacks:

bin/project1.ts
```ts
const app = new cdk.App();
new Project1Stack(app, 'Project1Stack', {

});
```

Importing stack file to entrypoint:
bin/project1.ts
```ts
import { Project1Stack } from '../lib/project1-stack';
```

Stack definition:
../lib/project1-stack.ts
```ts
import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
// import * as sqs from 'aws-cdk-lib/aws-sqs';

export class Project1Stack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // The code that defines your stack goes here

    // example resource
    // const queue = new sqs.Queue(this, 'Project1Queue', {
    //   visibilityTimeout: cdk.Duration.seconds(300)
    // });
  }
}

```

`/lib/` - directory to organize the stacks

Adding constructs to Stack:
`npm i @aws-cdk/aws-s3` - install construct library, this will add library s3 to `package.json` in `dependencies`

../lib/project1-stack.ts
```ts
import * as S3 from '@aws-cdk/aws-s3';

//export class Project1Stack extends cdk.Stack {
  //constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    //super(scope, id, props);
		
		new S3.Bucket(this,'MyBucket', {
			bucketName: 'my-bucket-unique-name',
		})

  }
}
```

___

### Synthezis

`cdk synth` - generates the CloudFormation Template. 
It traverses the app tree and invokes the synthesize method on all constructs.
Generates unique IDs for CloudFormation resources and generates respective YAML along with any assets that are needed. 

#### Assets 
Files bundled into CDK apps:
* Lambda handler code
* Docker images

Assets can represent any artifact that the app needs to operate. When you synthesize or deploy a CDK app, these typically end up in `cdk.out`folder on local machine.

### Bootstrapping

`cdk bootstrap` - deploys a CDKToolkit CloudFormation stack.
Creates an S3 bucket (and various permissions) to store Assets in AWS account. Required for using assets and CloudFormation templates > 50 kB.

For CDK2 administrator access is needed to create the roles that CDK toolkit stack needs. After CDK is bootstrapped administrator access is no longer need. 

### Deploy

App is initalized or constructed into an app tree. 

After that methods of all Constructs are called in series:
* prepare
* validate
* synthesize

Deployment Artifacts are uploaded to CDKToolkit.
CloudFormation Deployment begins, rest is done in CloudFormation. 