# K8s security

## Security context

### Linux capabilities - CAP

<https://man7.org/linux/man-pages/man7/capabilities.7.html>

Permissions for processes. One process should be allowed to write files, deleting them, etc, but it shouldn't have
access to the network. When process needs to to similar job, must ask kernel for that. Capabilities is the setting that
allow process to communicate with kernel (it's specific parts responsible for ex. network).

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
