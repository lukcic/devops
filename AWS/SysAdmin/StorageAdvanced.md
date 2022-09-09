# Introduction

Types of storage:
* Block - EBS, Instance Store
* File - EFS, FSx
* Object - S3, Glacier

# Snow Family
High-secure, portable devices to collect and process data at the edge and migrate data into and out of AWS. If you need more than week to transfer data, use Snow family devices.

1. Snowcone (szyszka) - NUC PC, 8TB, online (DataSync agent) and offline, 2 CPU and 4GB RAM. AWS DataSync compatible. Data migration and edge computing.

2. Snowball Edge (kula śnieżna) - suitcase PC for TBs and PBs of data, up to 15 in cluster. Data migration and edge computing. Block or S3-compatible object storage. Long-term deployment options (1 or 3 years).

    * Storage Optimized 80TB block and S3, 40 vCPU, 80GB RAM
    * Compute Optimized 42 TB block and S3, 52 vCPU, 208 GB RAM, optional GPU, can run EC2 instances and Lambda functions (AWS IoT Greengrass)

3. Snowmobile (ciężarówka) - Exabytes of data, 100 PB of capacity per truck. To transfer more than 10 PB of data. Only data migration.
ś
4. OpsHUB - desktop software to manage SnowFamily

# FSx

3rd party managed filesystems:

1. FSx for Windows File Server (Windows native: SMB and NTFS), ACLs, user quotas, integrated with AD, single AZ (1 and 2 gen) or multi AZ (automatic failover), can be accessed from on-premise (VPS, DirectConnect).
    * SSD - latency sensitive (for DBs, media processing, data analytics)
    ś* HDD - broad spectrum of workloads (home dir, CMS)

2. FSx for Lustre (Linux + cluster) - distributed filesystem for high performance computing (ML, video processing, analytics), extremely fast. Integration with S3. Integration with on-premise servers.
    * SSD - low latency, IOPS intensive workloads, small and random file operations
    * HDD - throughput intensive workloads, large and sequential file operations

    Types:
    * Scratch File System - temporary storage, data is not replicated, high burst (6x faster, 200 MBps per TB). For short term processing

    * Persistent File System - long-term storage, data is replicated in the same AZ, usage: long-term processing, sensitive data.

3. FSx for NetApp ONTAP

# Storage Gateway

Bridge between S3 object data and on-premise (hybrid solution) used for integration on-prem and cloud data. Local cache of cloud data on own infrastructure for most frequently used data. Software works in on-prem VM (ESXi, Hyper-V, KVM or EC2). Hardware appliance can be used.

Types:
* File Gateway - configured S3 bucket are accessible using NFS or SMB. Posix compliant. Classes: Standard, IA, One Zone IA. Access using IAM roles and AD integration. Local cache of Amazon S3 on own infrastructure for most frequently used data. Can be mounted on many servers.

* Volume Gateway - block storage using iSCSI protocol backed by S3.\
EBS Snapshots which can help restore on-prem volumes:
    * Cached volumes - low latency access to most recent data
    * Stored volumes - on-prem data with scheduled backups stored in S3

* Tape Gateway - Tape Storage in the cloud. Back up data using existing tape-based process (and iSCSI interface). Virtual Tape Library is backed by S3 and Glacier.

* FSx File Gateway - native access to Amazon FSx for Windows File Server. Local cache to frequently accessed data. Useful for group file shares and home directories.

Rebooting Storage Gateway:
* File Gateway - simply restart the VM
* Volume and Tape Gateway - Stop "Storage Gateway Service" using AWS console or API, reboot the VM, start service

Storage Gateway Activation
* using the Gateway VM CLI
* making a web request to the Gateway VM on port 80 (must be opened)
(be sure, that Gateway VM has correct NTP time synchronization set)

Volume Gateway Cache efficiency:
* CacheHitPercent metric must be high
* CachePercentUsed must be low

# DataSync
Move large amount of data from on-prem to AWS (migration).\
Can synchronize to: S3 (any storage classes), EFS, FSx.\
Can synchronize from NAS or filesystems using NFS and SMB.\
Synchronization EFS - EFS between 2 regions or to encrypted volume.\
Tasks can be scheduled hourly, daily or weekly (not continuous!).\
DataSync agent must be used (TLS).\
Optional bandwidth limit. Incremental replication.

# AWS Backup
Centrally manage backups and automate backups across AWS services.\
Point in time recovery for some services (Aurora).\
Cross regions, cross accounts backup (Organizations).
On-demand and scheduled backups. Tag based backups.

Backup plans (policies):
* frequency (every 12h, daily, weekly,cron expression)
* backup window
* transition to cold storage
* retention period

Backup Vault Lock:
* enforce a WORM state for all the backups that you store in the vault.
* even root user cannot delete the backups
* protect from short retention period or malicious software