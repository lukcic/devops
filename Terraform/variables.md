# Variables:

* terraform apply -var-file example.tfvars
  * apply changes with overriding variable file

* terraform apply -var "instance_name=myOwnName"
  * apply changes with overriding variable

## Basic variables
Commonly used.
### String
```
variable "myvar" {
    type = "string"
    default = "hello terraform"
}

var.myvar
"${var.myvar}"
```
### Number
```
variable "this-is-a-number" {
    type = number
}
```

### Booleean
```
variable "true-or-false" {
    type = bool
}
```

### List
A list is always ordered, it’ll always return 0,1,5,2 and not 5,1,2,0.
```
variable "mylist" {
    type = list
    default = [1,2,3]
}

var.mylist
var.mylist[0]
element(var.mylist, 0)
```
### Map
```
variable "mymap" {
    type = map(string)
    default = {
        mykey = "myvalue"
    }
}

var.mymap
var.mymap["mykey"]
```

## Usage:
```
variable "AWS_REGION" {
    type = string
    default = "eu-west-1"
}

variable "AMIs" {
    type = map(string)
    default = {
        us-east-1 = "ami-13be557e"
        us-west-2 = "ami-06b94666"
        eu-west-1 = "ami-0d729a60"
    }
}

resource "aws_instance" "example" {
    ami             = var.AMIs[var.AWS_REGION]
    instance_type   = "t2.micro"
}
```
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
## Complex variables
Sporadically used.

### Set
A "set" is like a list, but it doesn’t keep the order you put it in, and can only
contain unique values

A list that has [5, 1, 1, 2] becomes [1,2,5] in a set (when you output it,
terraform will sort it)

### Object
An object is like a map, but each element can have a different type:
```
variable "myobject" {
    type = object
    default = {
        firstname = "John"
        housenumber = 10
    }
}
```

### Tuple
An tuple is like a list, but each element can have a different type:
```
variable "mytuple" {
    type = typle
    default = [0, "string", false]
}

```
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

subnet_prefix = [{cidr_block = "10.0.10.0/24", name = "subnet1"}, {cidr_block = "10.0.20.0/24", name = "subnet2"}]
cir_block = var.subnet_prefix[0].cidr_block
subnet_name = var.subnet_prefix[0].name

