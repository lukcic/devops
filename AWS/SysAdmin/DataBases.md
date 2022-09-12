> SQLELECTRON\
Schema - shape of the data

# RDS

Managed service. Cannot SSH to RDS instances! They are managed by AWS.

Types:
* MySQL/MariaDB
* PostgreSQL
* MSSQL
* Oracle
* Aurora

### Encryption
* master and read replicas can be encrypted with KMS (AES-256 encryption) while creating
* if master is not encrypted, read-replicas cannot be
* Transparent Data Encryption (TDE) for Oracle and MS SQL is possible
* SSL certificates to in-flight data (must be enabled in DB)

Encrypt existing DB:
* create a snapshots
* copy snapshot with enabling encryption
* restore DB from encrypted snapshot
* migrate apps and delete unencrypted DB

### Network security:
* RDS are usually deployed to private subnets
* RDS use SecurityGroups to control access

### Access management
* to control who can manage RDS IAM policies are used
* to log in to DB traditional login and passwords are used
* in MySQL ald PostgreSQL IAM-based authentication can be additionally used (with API token, without password)

EC2 with IAM role runs API call to RDS: Get Auth token (15mins)\
EC2 with IAM role connects to RDS using token\
SSL must be enabled.

### Backups
* enabled by default
* daily full backup of the DB (in maintenance window)
* transactions logs are backed-up every 5 mins
* ability to restore to any point in time (from oldest backup to 5 minutes ago).
* 7 days backup retention (can be increased to 35 days, or disabled - 0)
* can be use even if DB is deleted
* restoring will create new DB instance

### Snapshots
* manually trigger by user, stops DB from seconds to minutes
* retention - as long as you want (don't expire)
* in case Multi-AZ snapshot is taken from standby
* are incremental, can be copied and shared (manual)
* if encrypted snapshot is shared, kye must be shared too
* final snapshot while deleting DB can be done
* restoring will create new DB instance


### Storage Auto-Scaling
* supports all DB engines
* Maximum Storage Threshold must be set (maximum limit of storage)
* automatically modify storage if:
    * free storage is less than 10%
    * low storage lasts at least 5 min
    * 6 hours has passed since last modification

### Read replicas
* up to 5 RR
* within AZ, Cross AZ and Cross Region
* replication is ASYNC
* replica can be promoted to normal DB
* application must update connection string to leverage read replicas
* no transfer fees if both DBs in the same region
* use-case: for reporting applications to not overload master DB (only SELECTS)

### Multi-AZ:
* in different AZs, no for scaling (standby)
* SYNC replication
* one DNS name - automatic app failover by default
* increase availability, failover if loose: AZ, network, instance or storage
* no downtime when creating: snapshot, restoration in new DB, sync

### RDS proxy

Lambda by default is launched outside VPC with RDS (cannot access it).
Lambda in VPC: all VPC resources + ENI + IAM role must be created.

RDS proxy:
* can be created in public subnet and have connection with RDS in private subnet
* can be created in private subnet with RDS, but Lambdas must be created inside this VPC too
* eliminates problem with RDS "TooManyConnections" - maintains Lambda connections and creates only one connection to DB

### Parameter groups
* used to configure DB engine
* to assign parameter group instead default one ude Modify DB
* non-dynamic parameters are applied after DB reboot
* must know: `rds.force_ssl=1` for enabling SSL in PostgreSQL
* MySQL needs special SQL query

### Events and logs
* events: DB change state to running, backup done, etc.
* events can be sent to SNS (notifications) and Event Bridge
* logs: CloudWatch alarm can be send if ex: too many errors

### Metrics

Standard metrics from hypervisor:
* DatabaseConnections
* SwapUsage
* ReadOPS / WriteOPS
* ReadLatency / WriteLatency
* ReadThroughput / WriteThroughput
* DiskQueueDepth
* FreeStorageSpace

Enhanced Monitoring - gathered from agent installed on instance:
* processes and threads
* 50 additional metrics
* must be enabled in DB settings
* to switch use Monitoring tab and Monitoring list in "CloudWatch" panel

### RDS Performance Insights

Visualize DB performance and analyze issues.
Must be enabled. Doesn't' available with t2 family instances.
DBLoad - the number of active sessions for DB engine.

Load:
* by Waits - find the resource that is a bottleneck (CPU, IO)
* by SQL statements - find the statement that is a problem
* by Hosts - find client who is using DB the most
* by Users - find user who use db the most

## Aurora

* AWS database system (non-open sourced) based od MySQL or Postgres.
* Cloud Optimized, 5x faster than MySQL, 3x faster than PostgreSQL on RDS.
* Not serverless! Storage automatically grows (every 10GB)
* Costs 20% more, but is more efficient (data stripping).

### High availability:
* 6 copies of data across 3 AZs:
    * 4/6 for writes
    * 3/6 for reads
    * self healing with peer-to-peer replication
    * storage is stripped across 100s of volumes
* one instance is a master (has Writer endpoint)
* up to 15 read replicas to serve reads (auto-scaling)
* read replicas can have priorities to control the failover
* automated failover for master in less than 30s (HA native)
* Cross Region Replication

Shared storage Volume (striping) with auto expanding (10G - 64TB).\
Reader endpoint - Connection load balancing between replicas.\
RDS MySQL snapshot can be migrated to Aurora.

### Features:
* Automatic fail-over
* Backtrack - restore data in any point in time without using backups
* automated patching with zero downtime
* advanced monitoring

### Automatic backups:
* 1-35 days retention period, cannot be disabled
* Point in time restore within 5 mins of the current time
* restore to new DB cluster

### Aurora Backtracking
* rewind DB back and forth in time (up to 72h)
* doesn't create new DB cluster (in-place restore)
* only MySQL Aurora

### Aurora Database Cloning:
* creates a new DB cluster that uses the same volume as the original cluster
* uses copy-on-write protocol (use the single copy of the data and allocate storage only when changes made to the data)
* use-case: create test environment using production data

### Aurora CloudWatch metrics:
* AuroraReplicaLag - amount of lag while replicating from primary instance
* AuroraReplicaLagMaximum - max amount of lag across all DB instances in cluster
* AuroraReplicaLagMinimum - min amount of lag across all DB instances in cluster
* DatabaseConnections - current number of connections to instance
* InsertLatency - average duration of insert operations

# ElastiCache

Managed Redis or Memcached - in-memory databases with high performance and low latency.\
Helps reduce load off of databases for read intensive workloads.\
Using Elasticache involves heavy changes in application code, but can help to create stateless application.

Stateless application:
* user logs in to the app
* the app writes the session data into ElastiCache
* user hits another instance of our application
* the application retrieves the session data from ElastiCache and user is already logged in

## Redis:
* Multi-AZ with auto failover
* read replicas
* Data durability
* backup and restore features

### Cluster Mode Disabled (scaling reads):
* 1 primary node (RW), up to 5 replicas (RO)
* ASYNC replication
* one SHARD - all nodes have all the data (no data loss if node failure)
* Multi-Az enabled by default

Scaling:
* Horizontal: scale out/in by adding/removing read-replicas (max 5)
* Vertical: Scale up/down to larger/smaller instance types (new group + replication)

### Cluster Mode Enabled (scaling writes):
* data is partitioned across shards
* each shard has a primary and up to 5 replicas
* Multi-Az enabled by default
* up to 500 nodes per cluster (500 shards with single master)

Scaling:
* Two models:
    * online scaling - up and running, still serving requests without downtime
    * offline scaling - unable to serve requests, more config changes (change node type, upgrade engine version, etc)
* Horizontal - online and offline
    * resharding - scale out/in by adding/removing shards
    * shard rebalancing - equally distribute the keyspaces among the shard as possible
* Vertical - change read/write capacity (online)

### Metrics

* Evictions (eksmisje) - the number of non-expired items that cache deleted to allow space for new items (memory is overfilled). Solution:
    * choose the eviction policy to evict expires items (ex: evict least recently used items)
    * larger node type (memory) or scale out by adding more nodes
* CPUUtilizations - larger node type (memory) or scale out by adding more nodes
* SwapUsage - should not exceed 50 MiB
* CurrConnections - number of concurrent and active connections (app problem)
* DatabaseMemoryUsagePercentage - percentage of memory utilization
* NetworkBytesIn/Out % NetworksPacketsIn/Out
* ReplicationBytes - the volume of data being replicated
* ReplicationLag - how far behind the replica is from the primary node

## Memcached:
* multi-node (1-40) for partitioning data (sharding)
* no HA
* non persistent data
* no backup and restore
* multi-threaded architecture

Scaling:
* Horizontal:
    * add/remove nodes from the cluster
    * Auto-discovery allow your app to find notes
* Vertical:
    * Scale up/down to larger/smaller node type
    * Process: create new cluster with new nod type, update app to use new cluster endpoints, delete old cluster
    * Memcached clusters/nodes start out empty (no backup)

Auto Discovery:
* Typically you need to manually connect to individual cache nodes in the cluster using its DNS endpoints, Auto Discovery automatically identifies all of the nodes
* All the cache nodes in the cluster maintain a list of metadata about all other nodes
* Client connects to configuration endpoint, gets IP address of node 1, connect to it and node 1 respond of all nodes metadata, then client can connect to any node to find data.

### Metrics

* Evictions (eksmisje) - the number of non-expired items that cache evicted to allow space for new items (memory is overfilled). Solution:
    * choose the eviction policy to evict expires items (ex: evict least recently used items)
    * larger node type (memory) or scale out by adding more nodes
* CPUUtilizations - larger node type (memory) or scale out by adding more nodes
* SwapUsage - should not exceed 50 MiB
* CurrConnections - number of concurrent and active connections (app problem)
* FreeableMemory - amount of free memory on the host