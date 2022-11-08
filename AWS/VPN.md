REGION!

1. Create Virtual Private Gateway.
Amazon default ASN.
Attach it to VPC.

2. Create Customer gateway.
Add BGP ASN, IP address (router).

3. Enable route propagation in route table.

4. Create Site-to-site VPN connection.
Type name, select VPG and CGW.
Set static routing. 

Local IPv4 network CIDR - LAN of router
Remote IPv4 network CIDR - LAN of VPC
Static IP prefixes - LANs (local) which needs to have access to VPC

Add tags, rest as default.

5. Download config for router. Set VPN, static route and Policies.

6. Enable route propagation for every subnet in AWS Route tables. 

[VPN Setup](https://medium.com/dlt-labs-publication/how-do-you-set-up-an-aws-site-to-site-vpn-connection-674605c019f6)