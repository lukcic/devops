# Cloud fallacies & Design patterns

Check the complete list of Cloud Design Patterns on Azure and AWS:

<https://learn.microsoft.com/en-us/azure/architecture/patterns/>

<https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/introduction.html>

## Cloud fallacies

1. The network is reliable. This is the most critical fallacy. Networks are inherently unreliable and prone to outages, delays, and malicious attacks. Distributed systems must be designed to handle these inevitable hiccups gracefully.

    ➡️ Example: A microservices application may fail if it doesn't gracefully handle network timeouts, causing service failures.

2. Latency is zero. Every action reacts, and distributed systems are no exception. Messages take time to travel, and computations take time to complete. Ignoring latency can lead to performance bottlenecks and unpredictable behavior.

    ➡️ Example: A real-time analytics platform may deliver outdated insights if it doesn't account for data transmission delays.

3. Bandwidth is infinite. While bandwidth constantly increases, it's not unlimited. Distributed systems often generate massive amounts of data, and underestimating bandwidth constraints can lead to slowdowns and congestion.

    ➡️ Example: Streaming high-resolution video without compression can overwhelm network resources, leading to buffering and delays.

4. The network is secure. Your data is not invincible because it is spread across many machines. Distributed systems offer a larger attack surface, and security considerations must be woven into the very fabric of the design.

    ➡️ Example: Transmitting sensitive data over an unsecured network can result in data interception by malicious actors.

5. Topology doesn’t change. Networks are dynamic entities, constantly evolving as nodes are added, removed, or reconfigured. Distributed systems need to adapt to these changes without skipping a beat.

    ➡️ Example: A fixed IP address in configuration files can cause service disruptions if servers are moved or readdressed.

6. There is one administrator. In the real world, distributed systems often span many administrative domains. Understanding and coordinating across these boundaries is essential for smooth operation.

    ➡️ Example: Inconsistent firewall rules between departments can create security gaps or connectivity issues.

7. The transport cost is zero. However, sending data across a network isn't free. Each hop incurs a cost, both in time and resources. Optimizing data transfer is crucial for efficient distributed systems.

    ➡️ Example: Excessive API calls in a cloud service can inflate costs due to data egress fees.

8. The network is homogeneous, and different networks have different characteristics. What works on a local network might translate poorly to the global Internet. Distributed systems need to be flexible and adaptable to diverse network environments.

    ➡️ Example: An application optimized for high-speed wired connections may perform poorly on mobile networks.

Understanding these fallacies is the first step toward building reliable distributed systems, but also:

* Design systems with redundancy and fault tolerance.

* Put monitoring and alerting systems in place.

* Rank security best practices and data encryption.

* Optimize communication protocols for efficiency and performance.

* Choose technologies and architectures suited to the specific needs of the system.

## Cloud Design patterns

The main Cloud Design Pattern groups are:

### Data Management

The main component of cloud applications is data management, which affects most of the quality criteria. Data is hosted across many servers and locations for performance, scalability, or availability. This could pose several difficulties. For instance, data synchronization between many places is often required to ensure data consistency.

The most important patterns in this group are:

* `Cache-Aside Pattern`. Improve application performance and reduce the load on data stores by caching frequently accessed data.

* `Command and Query Responsibility Segregation (CQRS) Pattern`. Separate read and write operations to optimize performance, scalability, and security.

* `Event Sourcing Pattern`. Maintain a complete history of changes to an application's data.

* `Materialized View Pattern`. Improve query performance by precomputing and storing the results of complex queries.

* `Sharding Pattern`. Scale data storage by partitioning data across multiple databases or servers.

### Design and Implementation

Good design includes maintainability to facilitate administration and development, reusability to allow components and subsystems to be used in various applications and contexts, and consistency and coherence in component design and deployment. Decisions made during the design and implementation phase influence the quality and total cost of ownership of cloud-hosted applications and services.

The most essential patterns in this group are:

* `Strangler Fig Pattern`. Gradually migrate a legacy system by replacing specific pieces with new applications or services.

* `Anti-Corruption Layer Pattern`. This pattern protects a new system's integrity when integrating legacy or external systems with different models or paradigms.

* `Bulkhead Pattern`. Increase system resilience by isolating failures in one component from affecting others.

* `Sidecar Pattern`: Deploy a parallel component to extend or enhance a service's functionality without modifying its code.

* `The Backends for Frontends (BFF) Pattern` involves creating separate backend services tailored to the needs of different client applications (e.g., web and mobile).

### Messaging

Because cloud applications are distributed, a messaging infrastructure is needed to link the various parts and services. This infrastructure should be loosely coupled to allow for the largest scalability. Asynchronous messaging is popular and has many advantages but drawbacks, like sorting messages, managing poison messages, idempotency, and more.

The most essential patterns in this group are:

* `Queue-Based Load Leveling Pattern`. Manage varying workloads by buffering incoming requests and ensuring your system can handle load fluctuations smoothly.

* `Publisher-Subscriber Pattern`. Enable an application to broadcast messages to multiple consumers without being tightly coupled to them.

* `Competing Consumers Pattern`. Enhance scalability and throughput by having multiple consumers process messages concurrently.

* `Message Broker Pattern`. Decouple applications by introducing an intermediary that handles message routing, transformation, and delivery.

* `Pipes and Filters Pattern`. Process data through a sequence of processing components (filters) connected by channels (pipes).

### Security

Security protects information systems from hostile attacks by ensuring data confidentiality, integrity, and availability. Losing these guarantees might harm your company's operations, earnings, and reputation in the marketplace. Following accepted procedures and remaining watchful to spot and address vulnerabilities and active threats are necessary for maintaining security.

The most essential patterns in this group are:

* `Valet Key Pattern`. Provide clients with secure, temporary access to specific resources without exposing sensitive credentials.

* `Gatekeeper Pattern`. Protect backend services by validating and sanitizing requests through a dedicated host acting as a gatekeeper.

* `Federated Identity Pattern`. Simplify user authentication by allowing users to log in with existing credentials from trusted identity providers.

* `Secret Store Pattern`. Securely manage sensitive configuration data such as passwords, API keys, and connection strings.

* `Validation Pattern`. Protect applications by ensuring all input data is validated and sanitized before processing.

### Reliability

When we say reliability, we usually mean the system's availability and resiliency. The percentage of time a system is operational and operating is called availability, expressed as a percentage of uptime. In contrast, a system's resilience is its capacity to handle and bounce back from purposeful and unintentional failures.

The most essential patterns in this group are:

* `Retry Pattern`. Handle transient failures by automatically retrying failed operations to increase the chances of success.

* `Circuit Breaker Pattern`. This pattern prevents an application from repeatedly trying to execute an operation that is likely to fail, protecting system resources and improving stability.

* `Throttling Pattern`. Control the consumption of resources by limiting the rate at which an application processes requests.

* `Health Endpoint Monitoring Pattern`. Detect system failures proactively by exposing health check endpoints that monitoring tools can access.

## Schema

![Cloud Design Patterns](./cloud-design%20-patterns.png)
[Cloud Security](https://www.datadoghq.com/state-of-cloud-security/?utm_source=unknownews)
