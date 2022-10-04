#!/bin/bash
set -eu

VPC_ID="vpc-0d305a6c1a4ac2a59"

#SUBNETS=$(aws ec2 describe-subnets --filter Name=vpc-id,Values=vpc-0d305a6c1a4ac2a59 --query 'Subnets[].SubnetId' | jq '. | @sh' | sed 's/"//g' | sed -e 's|["'\'']||g')
SUBNETS=( $(aws ec2 describe-subnets --filter Name=vpc-id,Values="${VPC_ID}" --query 'Subnets[].SubnetId' | jq -r '.[] '))

for i in "${SUBNETS[@]}"  # without quotes for loop will divide string by separators but will not use it like an array
do
    #SUBNET_TAG=$(aws ec2 describe-subnets --filter Name=vpc-id,Values=vpc-0d305a6c1a4ac2a59 --filter Name=subnet-id,Values=$i  --query 'Subnets[].Tags[].Value' | jq '. | @sh' | sed 's/"//g' | sed -e 's|["'\'']||g')
    SUBNET_TAG=($(aws ec2 describe-subnets --subnet-ids "$i" --filter Name=vpc-id,Values="${VPC_ID}"  --query 'Subnets[].Tags[]' | jq -r '.[] | select(.Key=="Name") | .Value' ))

    RESOURCE_NAME="resource \"aws_subnet\" \"${SUBNET_TAG}\" {}"
    echo "${RESOURCE_NAME}" >> vpc.tf

    if [ $? -eq 0 ]; then
        terraform import "aws_subnet.${SUBNET_TAG}" "$i"
        #echo "terraform import aws_subnet.${SUBNET_TAG} $i"

        SUBNET_PROPERTIES=$(terraform state show -no-color aws_subnet."${SUBNET_TAG}")
        #sed -i "/${RESOURCE_NAME}/d" vpc.tf
        awk "!/${RESOURCE_NAME}/" vpc.tf > tmpfile && mv tmpfile vpc.tf

        IFS=$'\n'
        FULL_STATE=($(terraform state show -no-color aws_subnet."${SUBNET_TAG}"))

        for i in "${FULL_STATE[@]}"
        do
            echo "$i" | awk '/resource "aws_subnet"/' >> vpc.tf
            echo "$i" | awk '/cidr_block/' >> vpc.tf
            echo "$i" | awk '/vpc_id/' >> vpc.tf
        done

        echo -e "\t\ttags                                           = {"  >> vpc.tf
        echo -e "\t\t\t\t\"Name\" = \"${SUBNET_TAG}\""  >> vpc.tf
        echo -e "\t\t}" >> vpc.tf
        echo -e "}\n" >> vpc.tf
    fi
done


terraform plan