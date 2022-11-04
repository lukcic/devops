jq < file.json
jq . file.json
cat file.json | jq
-r - raw, without formatting

cat file.json | jq .
'.' - beginning of json tree

cat file.json | jq '.key'
cat file.json | jq '.key, .key2'

cat file.json | jq '.key[]'   # key is list
cat file.json | jq '.key[][]' # key is list with nested lists

cat file.json | jq '.key | keys'    # list keys
cat file.json | jq '.key | keys | @csv'    # list keys as csv

cat file.json | jq '.key.key2[] | select(.value>60)'
terraform show -json | jq '.values.root_module.resources[] | select(.type=="aws_subnet") | .address'

| flaten - delete keys, used to export values to csv
| del(.key)  - will delete key and value with given key, used on arrays

| length - will count elements in array
aws ec2 describe-subnets | jq  '[.Subnets[] | [.SubnetId, .CidrBlock, .AvailabilityZoneId, .Tags[] ]] | length'

| @sh'
aws ec2 describe-subnets --filter Name=vpc-id,Values=vpc-0d305a6c1a4ac2a59 --query 'Subnets[].SubnetId' | jq '. | @sh' | sed 's/"//g' | sed -e 's|["'\'']||g')

cat subnets.json | jq '{key: .Subnets[].SubnetId , value: .Subnets[].CidrBlock }'

aws ec2 describe-subnets | jq -r '.Subnets[] | [.SubnetId, .CidrBlock, .AvailabilityZoneId, .Tags[] ]'

aws ec2 describe-subnets | jq -r '[.Subnets[] | [.SubnetId, .CidrBlock, .AvailabilityZoneId, .Tags[].Value]]'

aws ec2 describe-subnets --filter Name=vpc-id,Values=vpc-0d305a6c1a4ac2a59 --query 'Subnets[]' | jq '[.[] | select(.Tags[].Key=="Name") | {.Tags[].Value : {az:.AvailabilityZone, cidr:.CidrBlock}}]'

to_entries converts an object to an array of key/value objects

aws ec2 describe-subnets --filter Name=vpc-id,Values=vpc-0d305a6c1a4ac2a59 --query 'Subnets[]' | jq '[.[]] | map({(.Tags[].Value): {cidr:.CidrBlock, az : .AvailabilityZone}  })'


prod git:(devops/terraform) ✗ cat sg.json |  jq '.SecurityGroups[]' | jq '{(.GroupName): { ingres:.IpPermissions[] | [ {protocol: .IpProtocol, port: .FromPort , cidr_block: .IpRanges[] | [.CidrIp], security_groups: "test" } ], egres:[] } } '

item in not every dictionary:
.items | .[]?
aws ec2 describe-security-groups --filter Name=vpc-id,Values=vpc-0d305a6c1a4ac2a59 --query 'SecurityGroups' | jq -r '[.[] | {(.GroupName):{desc:.Description, tags: ((.Tags[]?) // [])  }}]'