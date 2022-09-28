# CloudFront
Improves read performance, content is cached in the edge:
* Content Delivery Network CDN
* 216 Points of Presence (EDGE locations)
* DDoS protection: integration with AWS Shield, AWS WAF
* GeoRestriction feature (3rd party IP database)

### Origin types:
* S3 bucket (with OAI)
* S3 website
* Application Load Balancer (SG must be open for edge locations IPs)
* EC2 instance (SG must be open for edge locations IPs)
* any http backend (must work on HTTP protocol)

### Caching
The cache lives at each edge location. Cache hit rate should be as high as possible, to minimize amount of requests to the origin. TTL is set using Cache-Control or Expires header. Cache can be delete using CreateInvalidation.

Cache is based on:
* Headers
* Session Cookies
* Query String Parameters

Cache behavior for Headers:
1. Forward all headers to origin (no caching, all to origin)
2. Forward a whitelist of headers (caching based on values in all the specified headers)
3. None - no caching based on request headers, best caching performance

Cache behavior for Cookies
1. Default - do not process the cookies. Caching is not based on cookies, they are not forwarded to origin.
2. Forward a whitelist of cookies - caching based on values in all the specified cookies.
3. Forward all cookies - worst caching performance.

Cache behavior for Query Strings
1. Default - do not process the query strings. Caching is not based on query strings, parameters are not forwarded.
2. Forward a whitelist of query strings - caching based on the parameter whitelist.
3. Forward all query strings - caching based on all parameters.

### CloudFront vs S3 Cross Region Replication

CloudFront:
* Global Edge network
* files are cached for TTL
* great for static content that must be available everywhere
* can be used as ingress, to upload files to S3

S3 Cross Region Replication:
* must be set up for each region
* files are updated in near real-time
* read only
* great for dynamic content that needs to be available at low latency in few regions

### CloudFront Reports
* Cache statistics report
* Popular Objects report
* Top referrers report
* Usage reports
* Viewers report

Reports are based on Access Logs (no need send logs to S3).

### Errors and logging

4xx - user doesn't have access to the underlying bucket (403) or the object that user is requesting is not found (404).

Standard logging must be enabled with S3 bucket and prefix choose.

### CloudFront Origin Headers vs Cache behavior

Origin Custom Headers - origin-level setting. Set a constant header/header value for all requests to the origin.

Behavior settings - cache-related setting, constrains the whitelist of headers to forward.

### Maximize cache hits

1. Monitor the CloudWatch metric: CacheHitRatio
2. specify how long to cache your objects: Cache-Control max-age header.
3. Specify the minimally required: cookies, headers and parameters.
4. Separate content type for static and dynamic, use 2 origins:
* Static requests: no headers, session, caching rules - required for maximizing caching hits.

* Dynamic requests: cache based on correct headers and cookies, dynamic content served from REST or HTTP server

### CloudFront with ALB Sticky Sessions

Must forward/whitelist the cookie that controls  the session affinity to the origin to allow the session affinity to work.
Set a TTL to value lesser than when the authentication cookie expires.

Request:
```
GET /orders/all HTTP/1.1
...
CookieL AWSALB=value1
```

To the CloudFront with "AWSALB" cookie whitelisted -> forward to

Application Load balancer, that will always send request with given value to the same target (EC2).

### CloudFront Origin Access Identity
Can be set only with S3 bucket, not S3 website (it's custom origin). Custom headers an be set to restrict access to website only for CloudFront.