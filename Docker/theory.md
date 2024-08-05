## Namespaces

pl: `przestrzenie nazw`

Feature of Linux kernel that allows isolation and virtualization of system resources. Multiple groups of namespaces can
exist on the same Linux server without conflicting each other. They "dont't know" about other namespaces existence.

They makes possible
total isolation of resources like:

- networks
- mounts
- PIDs
- time
- users
- uts (hostname and domain name)
- cgroups
- IPC (systemV POSIX messages)

Container's root user can be mapped as host non-privileged user.

## Control groups (cgroups)

Linux kernel feature which allow processes to be organized into hierarchical groups whose usage of various types of
resources can then be limited and monitored.

With cgroups, a container runtime is able to specify that a container should be able to use (for example):

- Use up to XX% of CPU cycles (cpu.shares)
- Use up to YY MB Memory (memory.limit_in_bytes)
- Throttle reads to ZZ MB/s (blkio.throttle.read_bps_device)

## Union filesystem

Allows files and directories of separate file systems (branches) to be transparently overlaid (nałozone), forming single
coherent filesystem. Contents of directories which have the same path within th merged branches will be seen together in
a single merged directory within the new, virtual filesystem.

Overlay\
Upper\
Lower

Benefit - lower space usage when using multiple copies of docker image.

File from lower layer can be removed in upper layer and will not be available in overlay layer.

## Docker Desktop architecture

Client:

- docker cli (docker command)
- GUI
- docker credential helpers
- extensions

Server:

- docker api
- docker daemon (dockerd)
- containers
- local images
- k8s cluster (optional)

Registry:

- public images
- private images

Docker engine - open source core of Docker (cli, api, daemon).

## Registries

- Dockerhub
- Github Container Registry (ghcr.io)
- Google Container Registry (gcr.io)
- Amazon Elastic Container Registry (ECR)
- Azure Container Registry (ACR)
- NExus
- Harbor...

Docker CLI can use basic auth or leverage credential helpers.

```sh
echo "FROM scratch" > Dockerfile
docker build --tag empty-image .
docker login
docker tag empty-image hubuser/empty-image:tagname
docker push hubuser/empty-image
```

### Docker run options

```sh
--cap-add, --cap-drop
--cgroup-parent
--cpu-shares
--cpuset-cpus (pin execution to specific CPU cores)
--device-cgroup-rule,
--device-read-bps, --device-read-iops, --device-write-bps, --device-write-iops
--gpus (NVIDIA Only)
--health-cmd, --health-interval, --health-retries, --health-start-period, --health-timeout
--memory , -m
--pid, --pids-limit
--privileged
--read-only
--security-opt
--userns
```
