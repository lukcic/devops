# K8s security

## Security context

### Linux capabilities - CAP

<https://man7.org/linux/man-pages/man7/capabilities.7.html>

Permissions for processes. One process should be allowed to write files, deleting them, etc, but it shouldn't have
access to the network. When process needs to do similar job, must ask kernel for that. Capabilities is the setting that
allow process to communicate with kernel (it's specific parts responsible for ex. network). This way we can limit root user permissions or add permissions to non-root users.

K8s allows to set Linux capabilities to Pods and Containers.

Pods by default do not have network capabilities, this will fail:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: vlan-test-failed
  labels:
    app: vlan-test
spec:
  containers:
    - name: ubuntu
      image: ubuntu
      command: ["ip link add link eth0 name vlan200 type vlan id 2000"] 
```

```sh
RTNETLINK answers: Operation not permitted.
```

Adding capabilities:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: vlan-test-succeed
  labels:
    app: vlan-test
spec:
  containers:
    - name: ubuntu
      image: ubuntu
      command: ["ip link add link eth0 name vlan200 type vlan id 2000"]
      securityContext:
        capabilities:
            add: ["NET_ADMIN"]
```

Removing capabilities:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: vlan-test-succeed
  labels:
    app: vlan-test
spec:
  containers:
    - name: ubuntu
      image: ubuntu
      command: ["ip link add link eth0 name vlan200 type vlan id 2000"]
      securityContext:
        capabilities:
            add: ["NET_ADMIN"]
            drop: ["CHOWN"]
```

Even if container user is root, will be unavailable to change file owners.

Drop all capabilities:

```yaml
...
securityContext:
    capabilities:
        drop:
        - all
```

#### pscap

List capabilities of processes.

```sh
apt install libcap-ng-utils -y

# Other method
cat /proc/1/status | grep Cap
```

## User ID

Can be set for the entire Pod or for specific container inside Pod.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: vlan-test-succeed
  labels:
    app: vlan-test
spec:
  securityContext:
    runAsUser: 1000
  containers:
    - name: ubuntu
      image: ubuntu
      command: ["ip link add link eth0 name vlan200 type vlan id 2000"]
      securityContext:
        capabilities:
            add: ["NET_ADMIN"]
```

## AppArmor

Default security module for Debian and Suse based distros. AppArmor works on profiles which allows process to access files. In K8s we can create profile per container in pod.

## SELinux

Similar to AppArmor, for Red Hat based distros. Works on polices which restrict to objects in filesystem. In Kubernetes it is enabled by default?

## Seccomp

SecureComputing - restricts syscalls (interface between process and kernel). K8s uses default profiles created for given runtime (eg. ContainerD). Also own profiles can be created.

```yaml
securityContext:
  seccompProfile:
   type: localhost
   localhostProfile: my-seccom-profile.json 
```

## AllowPrivilegeEscalation

In Linux kerner syscall `execve` can give child process higher privileges than it's parent. We can disable it settint `allowPrivilegeEscalation: false` (no_new_privs flag). Works from kernel v3.5.

## PrivilegedContainers

Privileged container can have access to the resources (network interfaces, sockets or hardware) on the host (worker node). In this kind of containers there's no isolation between container nad host.

## ReadOnly filesystem

You can disable write access to the container's root filesystem. Stateless containers - all data should be stored outside container. This helps protect app against modifying container filesystem - attacker cannot download malware, override binaries, etc. Logs should be written to STDOUT. Mechanism is disabled by default. If process need to write some data, you can use `emptyDir` volume mounted in RAM (memory volume).

## sysctl

Linux interface for kernel parameters configuration.

## procMount

/proc catalog is masked and not mounted inside container. It should be default setting??