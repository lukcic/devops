## Links:
https://learn.hashicorp.com/terraform?utm_source=terraform_io\
https://learn.hashicorp.com/collections/terraform/cli\
https://learn.hashicorp.com/collections/terraform/configuration-language\
https://learn.hashicorp.com/tutorials/terraform/resource?in=terraform/configuration-language\
https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9\
Using maps:
https://www.youtube.com/watch?v=UFEhJFIj9gY

## Infrastructure as a Cloud (IaaC) in Terraform:
* infrastructure can be deployed on multiple cloud providers
* human readable configuration
* state allows to track changes in infrastructure
* configuration can be managed using version control

Terraform plugins to manage different cloud operators are called providers.
Resources are individual units of infrastructure (VMs, private networks etc.).
Terraform configurations are called modules.
Configuration language is declarative - describes desired state of resource.
Providers calculate dependencies between resources and create or destroy needed.

>Scope       - identify the infrastructure for your project\
>Author      - write the config\
>Initialize  - installing plugins\
>Plan        - preview the changes\
>Apply       - make the planned changes

Terraform keeps state of infrastructure in state file. This file is used to determine changes to do.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
## Installation

Installation in Ubuntu:
```
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

terraform -install-autocomplete
```

Installation in MacOS:
```
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
## Using AWS stored credentials:
```
~/.aws/credentials
[default]
aws_access_key_id = AKIAWAXFM....YFOGXOZ
aws_secret_access_key = ...
```
To work with multiple profiles change profile name to default and add next profile below.
To set current profile to use:
```
export AWS_PROFILE=lukcic
```

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

## Terraform Commands

* terraform init
  * initialize the project, which downloads a plugins

* terraform fmt
  * check and correct formatting of terraform file

* terraform validate
  * check and correct syntax of terraform file

* terraform plan
  * will show the changes that will be applied on infrastructure

* terraform plan -out=[filename.plan]
  * will output plan to file

* terraform apply
  * apply planned changes

* terraform apply [filename.plan]
  * apply changes saved in tf plan file

* terraform apply -targed aws_instance.name.id ???
  * will apply only given resource

* terraform apply -auto-approve
  * will skip the confirmation

* terraform apply -var-file example.tfvars
  * apply changes with overriding variable file

* terraform apply -var "instance_name=myOwnName"
  * apply changes with overriding variable

* terraform show
  * inspect created resources

* terraform output
  * returns values of output variables saved in configuration

* terraform destroy
  * destroy the resources created in this apply

* terraform destroy -target aws_instance.name.id
    * will destroy only given resource

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
## First module

main.tf:
```
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.15.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.latest
  name  = "tutorial"
  ports {
    internal = 80
    external = 8000
  }
}
```

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
## Terraform registry:
Here are definitions of terraform providers

[https://registry.terraform.io]()

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

## Terraform state
terraform.tfstate - in this file terraform stores state of created infrastructure.

Has sensitive data, so should be managed as a secret.
```
terraform state         # advanced state management
terraform state list    # list resources handle by state file

terraforn state show [resource_name]  # will show detailed information about resource

terrafrom force-unlock [LOCK_ID]      # will delete lock
```
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

## Workspaces:

Terraform workspaces allow you to store your Terraform state in multiple, separate, named workspaces.
Terraform starts with a single workspace called “default” and if you never explicitly specify a workspace, then the default workspace is the one you’ll use the entire time.

`terraform workspace list`                      # will show all workspaces\
`terraform workspace show`                      # show current workspace\
`terraform workspace new [NEW_WORKSPACE_NAME]`  # create new workspace\
`terraform workspace select default`            # will change workspace to default\

Switching to a different workspace is equivalent to changing the path where your state file is stored.

```
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = (
    terraform.workspace == "default"    # for default workspace terraform will create t2.medium instance, for other workspaces will create t2.micro
    ? "t2.medium"
    : "t2.micro"
  )
}
```


- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

## Variables:

to use wit given value:
terraform apply -var 'location=eastus'

Variable as a list:

ip_address = ["10.0.10.0/24", "10.0.20.0/24"]
var.ip_address[0]

subnet_prefix = [{cidr_block = "10.0.10.0/24", name = "subnet1"}, {cidr_block = "10.0.20.0/24", name = "subnet2"}]
cir_block = var.subnet_prefix[0].cidr_block
subnet_name = var.subnet_prefix[0].name

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
## For loop
```
variable "names" {
  type = list(string)
  default = ["one", "two", "three"]
}

output "upper_names" {
  value =  [for name in var.names: upper(name)]   # upper letters
}
```
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

## Conditionals:
```
condition ? true_val : false_val
```

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
## Dynamic Blocks:

.tfvars:
```
log_bucket              = false
/*log_bucket = {
    bucket          = "bitwww-dev-log-files.s3.amazonaws.com"
    prefix          = "dev-preview"
}*/
```

.tf
```
variable "log_bucket" {
  //type = map(string)
  description = "Cloudfront log configuration: bucket name, including cookies, prefix"
}

resource "aws_cloudfront_distribution" "bitwww_static" {
  origin {
    domain_name = var.s3_bucket_rdn  //origin domain
    origin_id   = var.s3_bucket_rdn  //origin name
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.bitwww_static.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = "${var.prefix}-cloudfront"
  aliases             = var.domain_names

  dynamic logging_config {
    for_each = var.log_bucket == true ? [1] : []
    content {
      include_cookies = false
      bucket          = var.log_bucket.bucket
      prefix          = var.log_bucket.prefix
    }
  }
(...)
}
```