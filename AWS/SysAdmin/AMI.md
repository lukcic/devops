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