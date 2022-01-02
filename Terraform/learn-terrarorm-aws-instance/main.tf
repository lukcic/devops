terraform { # Terraform settings block
  required_providers {
    aws = {
      source  = "hashicorp/aws" # full name: registry.terraform.io/hashicorp/aws
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9" # version of terraform
}

provider "aws" {
  profile = "default" # profile reffers to creditentials used in awscli "default" profile
  region  = "us-east-1"
}
# components of infrastructure
resource "aws_instance" "app_server" {    # resouce type, resource name
  ami           = "ami-0b0af3577fe5e3532" # this will create "aws_instance.app_server"
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name
    #Name = "TerraformExample"
  }
}
