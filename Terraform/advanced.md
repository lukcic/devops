## Interpolation

### Variables

`${var.VARIABLE_NAME}`

Generate comma separated list:\
`${join(",", var.mylist)}`

### Count information
* count.FIELD
* When using the attribute count = number in a resource, you can use `${count.index}`

### Path information
* path.cwd - current directory
* path.module - module path
* path.root - root module path

### Meta information
* terraform.field
* terraform.env - shows the active workspace

### Resources

type.resource-name.attr\
`${aws_instance.name.id}`

### Data sources

data.type.resource-name.attr:\
`${data.template_file.name.rendered}`

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

## Conditionals:
```
condition ? true_val : false_val
```

If Environment is production, then count = 2, else 1.
```
count = "${var.env == "prod" ? 2 : 1 }"
```
Oparators:
* `== and !=`
* `>,<, >=, <=`
* `&&, ||, !`

## Built-in functions

### Strings

* Lower - returns lowercase of the string
    * `lower("Hello")`

* Upper - returns uppercase of the string
    * `upper("Hello")`

* Basename - returns the filename (last element of the path)
    * `basename("/home/user/file.txt")` returns `file.txt`

* Format - formats a string/list according to the given format
    * `format("server-%03d", count.index + 1)` returns `server-001`, `server-002`...

* Replace - relpace a string
    * `replace("aaab", "a", "b")` returns `"bbbb"`

* Split - split string into a list
    * `split(",", "abcd")` returns list of letters

* Substr - extract substring from a string
    * `substr("abcde", -3,3)` returns `cde`

### Lists

* List - create new list
    * `list("a","b","c")`

* Join - joins a list together with a delimiter
    * `join(",", var.AMIs)` returns "ami-123,ami-456,ami-789"

* Element - returns a single element from a list at the given index
    * `element(module.vpc.public_subnets, count.index)` in case of many resources count is number of created resource, and index is subnet in this subnets list

* Index - finds the index of given element
    * `index(aws_instance.foo.*.tags.Env, "prod")`

* Coalesce - return the first non-empty value or list
    * `coalesce("","","hello")` returns `hello`

### Maps

* Map - returns a map using key:value
    * `map("k","v", "k2","v2")` returns `{"k"="v", "k2"="v2"}`

* Values - returns values of the map
    * `values(map("k","v","k2","v2"))` returns `[ "v", "v2" ]`

* Lookup - perform a lookup on a map using "key", returns the value
    * `lookup(map("k","v"), "k", "not found")` returns `v`

* Merge - marges maps
    * `merge(map("k","v"), map("k2","v2"))` returns `{"k"="v", "k2"="v2"}`

### Others

* Timestamp - returns RFC 3339 timestamp
    * `"Server started at ${timestamp()}"` returns `Server started at
 2018-06-16T18:46:46Z`

* UUID - Returns a UUID string in RFC 4122 v4 format
    * `uuid()` returns: `65b8cf0a-685d-3295-73c1-1393ef71bcd6`

* File - returns the file content
    * `file("./mykey.pub")`

## Loops

### For loop

For loops are typically used when assigning a value to an argument:\
`security_groups = ["sg-12345", "sg-567"]`\
This could be replaced by a for loop if you need to transform the input
data.

Loop over variables, transform it and output it in different formats:\
`[for i in ["this is a", "list"] : upper(i)]`\
will upper all elements in the list.

You can loop over a list [1,2,3,4] or even a map like {"key" = "value"}.

```
variable "map1" {
  type = map(number)
  default = {
   "apple" = 5
   "pear" = 3
   "banana" = 10
   "mango" = 0
  }
```
`[for k,v in var.map1: k]` -  will return the keys\
`[for k,v in var.map1: v]` -  will return the values\
`{for k,v in var.map1: v => k}` - will return the map (inverted)\
- - - - -
`Tags = { Name = "resource name" }`\
This is a map which can be "hardcoded" or which can be the output
of a for loop:
```
variable "AWS_REGION" {
  type    = string
  default = "eu-west-1"
}
variable "project_tags" {
  type          = map(string)
  default       = {
    Component   = "Frontend"
    Environment = "Production"
  }
}
```
```
resource "aws_ebs_volume" "example" {
  availability_zone = "eu-west-1a"
  size              = 8

  tags = {for k, v in merge({ Name = "Myvolume" }, var.project_tags): k => lower(v)}
}
```
will return:
```
{
    "Component"     = "frontend"
    "Environment"   = "production"
    "Name"          = "myvolume"
}
```
---
### For each

For_each loops are not used when assigning a value to an argument, but
rather to repeat nested blocks.

```
locals {
  mymap = {
    Instance1 = "info about my instance 1"
    Instance2 = "info about my instance 2"
    Instance3 = "info about my instance 3"
  }
}

module "my_other_module" {
  for_each = local.mymap
  instance_name = each.key
  [...]
}

##############################
module.my_other_module["instance1"].resource
module.my_other_module["instance2"].resource
module.my_other_module["instance3"].resource
```

```
resource "aws_security_group" "example" {
    name = "example"

    dynamic "ingress" {
        for_each = [ 22, 443]
        content {
            from_port = ingress.value
            to_port = ingress.value
            protocol = "tcp"
        }
    }
}
```

```
variable "ports" {
  type = map(list(string))
  default = {
    "22" = [ "127.0.0.1/32", "192.168.0.0/24" ]
    "443" = [ "0.0.0.0/0" ]
  }
}

resource "aws_security_group" "example" {
  name = "example" # can use expressions here

  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port   = ingress.key
      to_port     = ingress.key
      cidr_blocks = ingress.value
      protocol    = "tcp"
    }
  }
}
```

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
## Reading JSONs

```json
{
    "users": [
        {
            "user_name": "user_1",
            "role": "admin",
            "ssh_key": "ssh-rsa [shortened]"
        },
        {
            "user_name": "user_2",
            "role": "dev",
            "ssh_key": "ssh-rsa [shortened]"
        },
        {
            "user_name": "user_3",
            "role": "read_only",
            "ssh_key": "ssh-rsa [shortened]"
        },
        {
            "user_name": "user_4",
            "role": "dev",
            "ssh_key": "ssh-rsa [shortened]"
        }
    ]
}
```
Reading:
```hcl
locals {
    # get json
    user_data = jsondecode(file("${path.module}/users.json"))

    # get all users
    all_users = [for user in local.user_data.users : user.user_name]
}

output "users" {
    value = local.all_users
}
```

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
### Count-index method
```
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr_blocks)
  vpc_id     = var.vpc_id
  cidr_block = var.public_subnet_cidr_blocks[count.index]
}

resource "aws_instance" "public_ec2" {
  count = length(var.public_subnet_ids)
  subnet_id = var.public_subnet_ids[count.index]
  ami           = var.ami_id
  instance_type = "t2.micro"
  tags = {
    Name = "PublicEC2${count.index}}"
  }
  provisioner "local-exec" {
    command = <<EOF
echo "Public EC2 ${count.index} ID is ${self.id}"
EOF
  }
}
```

### Conditionals in modules

```
module "my_module_conditional" {
  count = var.enable_my_module ? 1 : 0
  [...]
}

module "my_module_count" {
  count = ["instance1", "instance2", "instance3"]
  [...]
}
#######################################
module.my_module_count[0].resource
module.my_module_count[1].resource
module.my_module_count[2].resource
```