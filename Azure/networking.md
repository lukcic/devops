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

Can be set or not. It's assigned to IP load balancer, not to VM.

## Bastion

VM -> Connect -> RDP/SSH/Bastion

Allow connection to VMs which don't have public IP. Connection is made by Azure web portal (HTTPS). Username and
password must be set (Windows/Linux) or SSH key (Linux). Works similar to TeamViewer or SSM agent (Instance connect).

`AzureBastionSubnet` - reserved name for Bastion's subnet in Virtual Network. Can be created manually, but must be minimum /26.

Pricing - NOT FREE! Around $0,19 per hour for basic + transfer. Can be disabled, enabling takes some time.

Basic - only Azure Web Portal. Single session.
Standard - multiple sessions, native client (CLI), allows file transfers (host - VM) for RDP.

```sh
az account set --subscription "Azure subscription1"

# RDP
az network bastion rdp --name MyBastionHost --resource-group MyResourceGroup --target-resource-id "/subscriptions/[UUID]/resourceGroups/ResourceGroupName/provides/Microsoft.Compute/virtualMachines/vm1"

# SSH (Windows)
az network bastion tunnel --name MyBastionHost --resource-group MyResourceGroup --target-resource-id "/subscriptions/[UUID]/resourceGroups/ResourceGroupName/provides/Microsoft.Compute/virtualMachines/vm2" --resource-port "22" --port "54321"

ssh user@127.0.0.1 -p 54321
scp -P 54321 f:\file.txt user@127.0.0.1:c:\testdir
```

## DNS

### Private zones

'Łącza sieci prywatnej` - przyłączenie strefy do określonej sieci wirtualnej.

Enforce virtual networks use of created private DNS zone.
`Enable automatic registration` - vm instances created in virtual network will automatically create FQDN DNS entry in
private DNS zone based on vm instance name.

## Load balancer

### Basic load0balancer

- free?
- vms in the backend pool have to be in availability set or scale set
- health probes - TCP, HTTP
- no SLA
- no availability zones

### Standard load0balancer

- paid per hour
- vms can be individual (standalone), must be connected to the same virtual network
- health probes also with HTTPS
- availability zones
- SLA: 99,99%

### Gateway

- advanced
