# Using self-hosted AWS spot runners to build projects in Git Hub Actions

1. `Script` that runs on SPOT instance

```sh
#!/bin/bash

github-user="Your GitHub Username"
github-repo="Your GitHub Repository name"
PAT="Your Super Secret PAT"

yum install jq -y
mkdir /actions-runner && cd /actions-runner

# Download the latest runner package
curl -o actions-runner-linux-x64-2.286.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.286.1/actions-runner-linux-x64-2.286.1.tar.gz
tar xzf ./actions-runner-linux-x64-2.286.1.tar.gz
chown ec2-user -R /actions-runner

# Get the runner's token
token=$(curl -s -XPOST -H "authorization: token $PAT" https://api.github.com/repos/$github-user/$github-repo/actions/runners/registration-token | jq -r .token)

# Create the runner and start the configuration experience
sudo -u ec2-user ./config.sh --url https://github.com/<github-username>/$github-user --token $token --name "spot-runner-$(hostname)" --unattended

./svc.sh install
./svc.sh start
```

2. `Launch template` for ASG with SPOT instance
```json
{
  "ImageId": "ami-001089eb624938d9f",
  "InstanceType": "t2.micro",
  "KeyName": "instance key pair name",
  "SecurityGroups": ["security group name"],
  "UserData": "user-data.sh file content encoded in base64",
  "InstanceMarketOptions": {
      "MarketType": "spot",
      "SpotOptions": {
      "MaxPrice": "0.03",
      "SpotInstanceType": "one-time",
      "InstanceInterruptionBehavior": "terminate"
      }
  }
}
```

3. ASG configuration
```json
{
    "AutoScalingGroupName": "spot-instance-asg",
    "LaunchTemplate": {
    "LaunchTemplateName": "spot-instance-launch-template"
    },
    "MinSize": 1,
    "MaxSize": 1,
    "AvailabilityZones": ["your Availability Zones"]
}
```

4. Create AWS `Security group`.

5. Encode script to base64 and paste it into `Launch template`
```sh
cat user-data.sh | base64 -w 0
```
**It includes PAT token!**

6. Create Launch template and ASSG in AWS
```sh
aws ec2 create-launch-template --launch-template-name spot-instance-launch-template --launch-template-data file://spot-instance-launch-template.json

aws autoscaling create-auto-scaling-group --cli-input-json file://spot-instance-auto-scaling-group.json

```

7. Edit workflow file in GitHub Actions to run on self hosted runner
```yaml
name: Some name
on:
  push:
  pull_request:
jobs:
  job-name:
       runs-on: self-hosted
       steps:
       ...
```
