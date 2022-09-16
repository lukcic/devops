# Route53

Managed DNS. Health checks and monitoring.

Entries types:
* A record - hostname to IPv4
* AAAA record - hostname to IPv6
* CNAME record - hostname to hostname
    * target must be a domain that have A or AAAA record
    * can't create CNAME record for the top node of DNS namespace (Zone Apex, ex: example.com)
* NS record - nameservers for hosted zone
* Alias record - hostname to AWS resource (ELB, CF, S3 websites, Elastic Beanstalk), cannot be set for EC2 DNS name, free of charge, native health check, can be used for the zone APEX

Hosted zones:
* private - contains records that specify how to route traffic within one or more VPCs
* public - contains records that specify how to route traffic on the Internet

Pricing: $0.50/month per hosted zone\
Domain: $12 per year

## Routing Policies:
* Simple Routing policy - route traffic to single resource
    * multiple values can be set to record
    * client will choose a random one
    * no health-checks

* Weighted routing policy - load-balancing based on host weights
    * you control the % of the requests that go to each resource
    * if all have 0, then traffic will be returned equally
    * DNS records must be the same name and type
    * health-checks
    * used for canary deployments

* Latency Routing policy - route traffic to instance with the lowest latency
    * creating the record - AWS region must be specified
    * client will get value from record with the nearest region

* Failover routing policy - failover instance in standby mode
    * must be associated with health-check
    * record must have failover record type set (primary/secondary)
    * active/passive - Route53 will return only active and healthy record

* GeoLocation - routing is based on users location (network)
    * specify location by continent, country or US state
    * default record should be created in case there's no match on location
    * can be associated with health-checks
    * use-cases: website localization, restrict content distribution, load-balancing

* GeoProximity - route traffic to your resources based on the geographic location of users and resources
    * its using Route53 Traffic flow feature to set coverage of the world by specific AWS regions in interactive way
    * ability to shift more traffic to regions based on the defined bias (priority)
    * for more traffic in given region (expand) set bias to positive (1 to 99), for less traffic in given region (shrink) set negative bias (-1 to -99)
    * resources can be form AWS (specify Region) or non-AWS (specify Latitude and Longitude)
    * pricing: $50 per month for a flow policy

* Multi-Value answer - route traffic to multiple resources
    * values in different records!
    * client side load balancing (that's not substitute to ELB)
    * health-checks, up to 8 healthy records to return
    * similar to simple-routing with many values, but have health-checks

## Health Checks
Automated DNS failover. Integrated with CloudWatch metrics. HTTP health-checks works only with public resources.

Health-checks can monitor:
* Endpoint - application, server, other AWS resource
    * about 15 global health-checkers
    * Healthy/Unhealthy threshold - 3 (default)
    * interval 30s (fast 10s = higher cost)
    * support: HTTP/HTTPS (status 200 and 300 is healthy), and TCP
    * If >18% of health-checkers reports the endpoint is healthy, Route53 consider it's healthy, otherwise Unhealthy
    * pass/fail based on fist 5120 bytes of the response
    * firewall must be open to traffic from checkers IP ranges
    * location can be set

* Another health-checks (Calculated Health-checks)
    * combine the results of multiple health-checks
    * conditionals: OR, AND or NOT
    * up to 256 child health-checks
    * used to perform maintenance of website without causing all health checks to fail

* CloudWatch Alarms (full control) - throttles of DynamoDB, alarms on RDS
    * used to provision health-checks on private resources (custom metric)

## S3 Website with Route53
* works only with HTTP, for HTTPS use CloudFront
* create s3 bucket with the same name as target record (acme.example.com) !!
* enable S3 website on bucket and public access
* create Route53 Alias record to the S3 website endpoint, or A record with value of S3 website endpoint

## Hybrid DNS
Every region has Route53 resolver that automatically answers DNS queries for:
* local domain names for EC2 instances
* records in private hosted zones
* records in public name servers

Hybrid DNS - resolving DNS queries between VPC (Route53 resolver) and your networks (other DNS Resolvers)
Networks can be:
* VPC itself / peered VPC
* on-prem network connected through Direct Connect or AWS VPN

### Resolver endpoints:
Managed DNS resolver for connecting on-prem and AWS DNS. Associated with one or more VPCs in the same AWS Region. Creates in two AZs for HA. Each endpoint supports 10k queries/s per IP address.

Inbound resolver:
* DNS resolvers on your network can forward DNS queries to Route53 resolver
* allows your DNS resolvers to resolve domain names for AWS resources and records in Route53 private zones

![](.pictures/resolver_inbound.jpg)

Outbound resolver:
* Route53 resolver conditionally forwards DNS queries to your DNS resolvers
* use Resolver Rules to forward DNS queries to your DNS resolvers

![](.pictures/resolver_outbound.jpg)

### Resolver rules:
Control which DNS queries are forwarded to DNS Resolvers on your network.
If multiple rules matched, Route53 resolver chooses the most specific match.

Conditional Forwarding Rules:
* Forward DNS queries for a specified domain and all its subdomains to target IP address

System Rules:
* Selectively overriding the behavior defined in forwarding Rules, ex: don't forward DNS queries for a subdomain acme.example.com

Auto-defined System Rules:
* Defines how DNS queries for selected domains are resolved, ex: AWS internal domain names, private hosted zones