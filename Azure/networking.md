# Networking

## Network interface

Must be in the same VPC as the VM. Different NICs must be in the same VPC, only different subnets are allowed.

## Virtual network

VPC? Can have multiple CIDRs. Include subnets which are AZ independent (?).

## Subnet

Must be attached to NAT gateway to access Internet using NIC in this subnet.

## Network security groups

Firewall for NIC or subnet.
Security group like in AWS. Assigned to NIC or subnet. SG can be deleted - in this case VM is not protected at all.

If Security Group is associated with subnet, all VMs in this subnets use this SG, additionally they can have own SG'
associated with it's NIC.

If VM has subnet SG and NIC SG, then subnet filtering works first, then NIC's filtering.

Newly created Subnet SG has `AllowVnetInBound access` rule - connections between all subnets in virtual networks are
allowed by default. The same with `AllowAzureLoadBalancer` (VM nic doesn't have public IP associated in OS, all traffic
to public IP is distributed by IP Load Balancer)

To check: is network security group AZ independent?

## Public IP

Can be set or not.
