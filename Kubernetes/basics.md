# Kubernetes

## Container Orchestration

- how to manage running containers?
- how much resources on host are still available?
- on which host schedule next container?
- are containers crashed or running?
- how to restart crashed containers?
- How to remove unused replicas?

## Kubernetes architecture

[ Control plane (Master) ] <-> [ Worker nodes [ pods [ multiple containers ] ] ]

### Control plane

Master node:

- API server (entrypoint to the k8s cluster). Pod.
- controller manager
- scheduler - decided where to deploy container
- etcd - key-value storage, handle state of nodes and containers, handles secrets,  snapshots may be used
- virtual network

#### HA Control plane

Minimum 3 master nodes. One master is always `Leader` and other are `Followers`. Amount of master nodes must be odd (3, 5, 7...).

It is caused by fact that `etcd` database must have `Quorum` - (n/2)+1 nodes.  

For cluster with 3 nodes Quorum: (3 / 2) + 1 = 1 + 1 = 2

With 4 masters, when network problem appears, then we have a `deadlock` - cannot say which site of
cluster should take Leadership.

### Data plane

Worker nodes (`kubelet` process running).

- more resources than master to handle containers

### Components (master node)

- `apiserver` (master) - frontend of Kubernetes management layer. Provides contact with Kubernetes cluster. May have multiple instances.
- `etcd` (master) - key-value store used to storing all parameters of Kubernetes cluster.
- `scheduler` (master) - follows creation of new pods and assign them nodes for running. Decides where to run given container.
- `controller-manager` - (master) responsible for starting containers. Single binary contains multiple logical elements
  (controllers). Works as a loop, checking cluster state (via api) and trying to ensure desired state of cluster.
  - `node-controller` - detects and reacts for situations when node doesn't work properly
  - `replication-controller` - responsible for maintaining proper amount of pods for each ReplicationController object
  - `endpoints-controller` - provides information to Endpoints objects (connects services and pods)
  - `service account & token controllers` - creates default account and API access tokens for new namespaces
- `cloud-controller-manager` - responsible for managing cloud provider resources. Specific for given provider.

### Components (worker node)

- `kubelet` - agent that works on each worker node, responsible for running containers in pod, connects to master node to process information
- `kube-proxy` - network proxy that works on each cluster node and assists/supports service creation
- `container runtime` - software which runs containers (Docker, Containerd, CRI-O and others)
- `add-ons`

`POD` (kadłub) - the wrapper (opakowanie) of the container (one or more). The smallest unit to configure and interact with. Usually
one pod per application, each pod got its own IP address (shared between containers inside pod). Pods communicate each other using internal network
(auto-configured). Pods are empheral, can be deleted as a containers.

`Service` - IP address of pod, used to communicate (IPs of pods changes) and loadbalancer.

`coredns` - internal (Cluster) DNS system used for pods communication.

`metrics-server` - collets CPU and memory usage. Necessary for auto-scalling and top.

### Control of Kubernetes

- cli (kubectl)
- UI
- API

Check nodes:

```sh
kubectl get nodes
kubectl get services
```

Testing:

```sh
kubectl create deployment nginx --image=nginx:latest
kubectl expose deployment nginx --type=NodePort --port=80
kubectl get services nginx
```

```sh
kubectl run -it --image=busybox --restart=Never busybox 
# restart flag is used to avoid creation of Deployment

kubectl attach busybox -c busybox -it
```

```sh
kubectl get pods
-o wide
kubectl describe pod nginx2
```

### Dashboard

[Kubernetes Dashboard repo](https://github.com/kubernetes/dashboard)

### Metrics server

#### Single

```sh
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

## add in container args:
##- --kubelet-insecure-tls

kubectl apply -f components.yaml
```

#### HA

```sh
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/high-availability.yaml
```

### Principles

1. Never use single pod or replica set (except debugging). Use Deployments and StatefulSets - single pods can be killed
   by controller.
2. Clearly separate stateful and stateless resources.
3. Separate secrets and non secret data (ConfigMaps).
4. Enable automatic scaling to ensure capacity management - Horizontal Pod Auto-scaler (HPA). For StatefulSets disable
   automatic scaling down process.
5. Define PostStart and PreStop hooks to carry out inform the other components of the new existence of an instance or of
   its impending termination.
6. Configure Liveness, Readiness and Startup Probes.
7. Set up Pod resource requests and limits to use with Horizontal Pod Autoscaler and Cluster Autoscaler.
8. Reserve capacity and prioritize Pods, use namespace resource quotas and reserved compute resources.
9. Force co-location of or spreading out Pods. Pod Topology Spread Constraints as well as affinity and anti-affinity
   rules are a great way to express whether you want to co-locate Pods (for network traffic efficiency) or spread them
   out (for redundancy) across your cloud region and availability zones.
10. Pod Disruption Budget specifies how many of a set of Pods (e.g. in a Deployment) are allowed to be voluntarily
    disrupted (i.e., due to a command of yours, not failures), at a time. Helps with maintenance of cluster nodes.
11. Choose blue/green or canary deployments over stop-the-world deployments. Use tools like ArgoCD.
12. Run your containers as a non-root user. Only use the root in your container build process to install dependencies,
    then make a non-root user and have that run your application.
13. Set and enforce the strictest Pod Security Policy or Pod Security Standard.
14. Use Network Policies to limit what other Pods your Pod can connect to. The default free-for-all network traffic in Kubernetes is a security nightmare, because then, an attacker just needs to get into one Pod to have direct access to all others.
15. Disable the default service account from being exposed to your application. Unless you specifically need to interact with the Kubernetes API, you should not have the default service account token mounted into it.

## kubectl

### Config file

```sh
# Location
~/.kube/config
```

### Environment variable `KUBECONFIG`

```sh
export KUBECONFIG=/path/to/the/file
```

## Resource definitions

### Namespace

Isolates pods. The same `Deployment` can be deployed in multiple NameSpaces (for testing).

```sh
kubectl get ns
kubectl create ns my-namespace
```

Namespace can be also created by yaml definition:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: my-namespace
```

Listening pods from specified Namespace:

```sh
kubectl get pods -n my-namespace
kubectl get pods --all-namespaces
```

Running Deployment in specified Namespace:

```sh
kubectl apply -f [FILENAME] -n [NAMESPACE-NAME]
```

Specifying Namespace in config file:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-test
  nameSpace: my-namespace
spec:
  replicas: 5
  selector:
```

**Deleting Namespace will destroy all Pods inside!!!**

### Pod

Minimal example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-name
  labels: # optional
    app: app-name
    type: front-end
spec:
  containers:
    - name: nginx1
      image: nginx
      # command: ["sleep", "inf"] # for images without entrypoint
```

Running:

```sh
kubectl create -f pod-example.yaml
# Create container based on file

kubectl apply -f pod-example.yaml
# Apply changes in environment based of changes in file (will create if not exists)

```

Delete pod based on config

```sh
kubectl delete -f pod-example.yaml
```

Updates in pod config may create new container inside pod, run it and delete old one. Restart parameter of pods will
change.

Pod receives own IP address. All containers share Pod's resources (ram, ip, cpu, open ports).

#### Init containers

Containers that runs before main container starts. Used for: initializing main container, prepare data for container -
download it from resource that need authentication, wait for another resource, etc. Changes in main container will
re-run init containers. If errors, all pod will try to redeploy - all init containers will run again.

Example:

```yaml
spec:
  initContainers:
    - name: clean-and-download
      image: cirrusci/wget
      command: ["sh", "-c", "rm -rf /www/* && wget https://example.com/example-file.png -O /www/example.png"]
      volumeMounts: 
        - name: http-content
          mountPath: /www
  containers:
    - name: nginx
      image: nginx
      volumeMounts: 
        - name: http-content
          mountPath: /usr/share/nginx/html/
```

### Labels and selectors

#### Labeling nodes

```sh
kubectl label node k3s1 withGpu=true
kubectl get nodes --selector withGpu=true
kubectl get nodes -l withGpu=true
kubectl get nodes --show-labels
```

#### Node selector

```yaml
...
spec:
  containers:
  - image: nginx
    name: nginx
  nodeSelector:
    withGpu: true   # label
```

### Limits

Resources limits for containers.

```yaml
containers:
  - name: nginx
    image: nginx:1.21.1
    command: ["/bin/sh", "-c"]
    args: ["sleep 10"]
    resources:
      requests: # container requests below limits from node
        memory: '256Mi'
        cpu: '250m'
      limits: # container total limit
        memory: '512Mi'
        cpu: '500m' # 0,5 processor time, 1/2 of 1000m
```

### Scaling and load balancing

`Scaling` - one container in multiple instances.

`Load balancing` - distributing traffic between container instances.

`Rolling updates` - upgrading app version by replacing old version containers one after another while part of old
containers is still running to host the app.

### Environment variables

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: env-tes
spec:
  containers:
    - name: env-test
      image: debian:latest
      command: ['env']
      env:
        - name: test
          value: true
        - name: test2
          value: test-test
        - name: test3
          value: "2" # Number must be presented as string
  restartPolicy: Never
```

## Storage

### Volumes

Like Docker's bind mount. Path on host must be assigned. Scope of node - shouldn't be used with multi-node environment.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: vol-test
spec:
  containers:
    - name: vol-test
      image: debian:latest
      command:
        - '/bin/bash'
        - '-c'
        - 'echo test >> /vol/logs'
      env:
        - name: test
          value: test
      volumeMounts: # mounting volume inside container
        - mountPath: /vol
          name: vol-example
  restartPolicy: Never
  volumes: # definition for creating volume
    - name: vol-example
      hostPath:
        path: /srv/test # must exist in minikube container/vm
        type: Directory
```

#### hostPath

Allows connect file or directory which exist on cluster node that pod is deployed.

- `Directory` - directory must be present on the node
- `DirectoryOrCreate` - creates directory on K8s host if it not exists
- `File` - file must be present on the node
- `FileOrCreate` - creates file on K8s host if it not exists

```yaml
- name: vol-example
  hostPath:
    path: /srv/test # will be created if not exists
    type: DirectoryOrCreate
```

### PersistentVolume (PV)

Like Docker's volume. Scope of Cluster, defines where shared storage is present. Managed by Kubernetes, host path is not
needed. Can have storage limits.

Access modes:

- ReadWriteOnce (RWO) - the volume can be mounted as read-write by a single node
- ReadOnlyMany (ROX) - the volume can be mounted as read-only by many nodes
- ReadWriteMany (RWX) - the volume can be mounted as read-write by many nodes
- ReadWriteOncePod (RWOP) - the volume can be mounted as read-write by a single Pod. Use ReadWriteOncePod access mode if you want to ensure that only one pod across the whole cluster can read that PVC or write to it

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs
spec:
  capacity:
    storage: 500Mi
  accessModes:
    - ReadWriteMany
  storageClassName: nfs
  nfs:
    server: 192.168.1.1
    path: "volume1/test"
```

#### PersistentVolumeClaim

Claim - *PL: roszczenie*. Allows pod storing data on Persistent Volume.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs
spec:
  accessModes:
    # - ReadWriteOnce
    - ReadWriteMany
  # storageClassName: local-path
  storageClassName: nfs
  resources:
    requests:
      storage: 100Mi
```

Mounting:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: vol-test
spec:
  containers:
    - name: vol-test
      image: nginx:latest
      volumeMounts:
        - name: volume1
          mountPath: /usr/share/nginx/html
  volumes:
    - name: volume1
      persistentVolumeClaim:
        claimName: nfs
```

### Replication Controller

`Replication Controller` - older object (historical). Shouldn't be used. Monitor health of containers to redeploy it if failed on the same or different
node if current node fails. Works on pods, but it's one level up in structure.

Using kind of `ReplicationController` minimal configuration needed is amount of replicas and template of pods to create (the same
details as standalone pod but without apiVersion and kind)

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: rc-test
spec:
  replicas: 4
  template:
    metadata:
      name: nginx-test
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
```

List Replication Controllers:

```sh
kubectl get rc
```

Replication controllers watch pods and recreate failed ones:

```sh
❯ kubectl get pods
NAME            READY   STATUS    RESTARTS   AGE
rc-test-95fhl   1/1     Running   0          40s
rc-test-fm5pl   1/1     Running   0          40s
rc-test-qmhbx   1/1     Running   0          40s
rc-test-srq55   1/1     Running   0          40s

❯ kubectl delete pod rc-test-srq55
pod "rc-test-srq55" deleted

❯ kubectl get pods
NAME            READY   STATUS    RESTARTS   AGE
rc-test-95fhl   1/1     Running   0          5m47s
rc-test-9jtgv   1/1     Running   0          6s
rc-test-fm5pl   1/1     Running   0          5m47s
rc-test-qmhbx   1/1     Running   0          5m47s
```

### Replica set

`Replica sets` - newer object (replaces Replication Controller). Both elements works on pods, but they are one level up
structures. Replica set can have 0 replicas. RS if barely used directly - `Deployment` is used instead.

Replica set requires (in compare to Replication Controller):

- apiVersion: apps/v1
- selector - which pods should be managed by ReplicaSet

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: rs-test
spec:
  replicas: 4
  selector:
    matchLabels:
      app: nginxapp
  template:
    metadata:
      name: nginx-test
      labels:
        app: nginxapp
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
```

Listing Replica Sets:

```sh
kubectl get rs
```

Changing replicas amount:

CLI:

```sh
kubectl scale rs --replicas=[NEW-AMOUNT] [REPLICA-SET-NAME]
kubectl scale rs --replicas=2 rs-test
```

File:

- update yaml definition file
- `kubectl apply -f [FILENAME]`

Details:

```sh
kubectl describe replicaset [NAME]
```

### Deployment

Main role of Deployment is efficient update of containers running inside pod. Use Replica Sets for making rolling updates.

`[Deployment [Replica set [Pod]]]`

Comparing to Replica Set only one difference in config file is `kind: Deployment`.

Example:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpd-dep
  labels:
    app: httpd-app
spec:
  # maxSurge: 90%
  # maxUnavailable: 90%
  replicas: 5
  selector:
    matchLabels:
      app: httpd-app
  template:
    metadata:
      labels:
        app: httpd-app
    spec:
      containers:
        - name: httpd
          image: httpd
          ports:
            - containerPort: 80
```

Commands:

```sh
kubectl get deployments
kubectl describe deployment [DEPLOYMENT-NAME]

kubectl get all # shows all infos about cluster
```

Structure of pod name is:
`[DEPLOYMENT-NAME]-[DEPLOYMENT-RANDOM-SUFFIX-REPLICASET-RANDOM-SUFFIX]`

```sh
❯ kubectl get pods
NAME                               READY   STATUS    RESTARTS   AGE
deployment-test-5897965cdf-6sbt6   1/1     Running   0          16s
deployment-test-5897965cdf-nqcjs   1/1     Running   0          16s
deployment-test-5897965cdf-qlvxm   1/1     Running   0          16s
deployment-test-5897965cdf-rmf7s   1/1     Running   0          16s
deployment-test-5897965cdf-stp9k   1/1     Running   0          16s

❯ kubectl get rs
NAME                         DESIRED   CURRENT   READY   AGE
deployment-test-5897965cdf   5         5         5       3m53s
```

#### Rolling update

While updating app (`kubectl apply -f` or `helm update`) K8s creates new Replica Set. Both RS' work and each one is
managing own app version. Pods with old version are gradually replaced by these with new version. Internal load balancer
is responsible for managing incoming traffic. Old replica set is not deleted, it's replica counter is set to 0 to
make possible instant rollback.

Update process:

By CLI:

```sh
kubectl set image deployment [DEPLOYMENT-NAME] [CONTAINER-NAME]=[NEW-IMAGE] --record
kubectl set image deployment deployment-test nginx=nginx:1.20 --record
```

`record` saved change details

#### Rolling strategy

Default: `RollingUpdateStrategy:  25% max unavailable, 25% max surge` - 25% of running pods in every step cannot be
stopped.

#### Rollout status and history

```sh
kubectl rollout status deployment [DEPLOYMENT-NAME]
```

```sh
kubectl rollout status deployment deployment-test
deployment "deployment-test" successfully rolled out
```

```sh
kubectl rollout history deployment [DEPLOYMENT-NAME]
```

```sh
kubectl rollout history deployment deployment-test

deployment.apps/deployment-test
REVISION  CHANGE-CAUSE
1         <none>
2         kubectl set image deployment deployment-test nginx=nginx:1.20 --record
```

#### Rollout undo

Undo rollout one step (in history) backwards.

```sh
kubectl rollout undo deployment [DEPLOYMENT-NAME]
```

```sh
kubectl rollout history deployment deployment-test

deployment.apps/deployment-test
REVISION  CHANGE-CAUSE
1         <none>
2         kubectl set image deployment deployment-test nginx=nginx:1.20 --record
```

```sh
kubectl rollout undo deployment deployment-test
deployment.apps/deployment-test rolled back
```

```sh
kubectl rollout history deployment deployment-test
deployment.apps/deployment-test
REVISION  CHANGE-CAUSE
2         kubectl set image deployment deployment-test nginx=nginx:1.20 --record
3         <none>
```

#### Changing replicas

```sh
kubectl scale --replicas=[NEW-AMOUNT] deployment [DEPLOYMENT-NAME]
kubectl scale --replicas=10 deployment deployment-test
```

### Jobs

Single run of container. Something similar to batch jobs. Container has to do the job and after that it is deleted.
Service instead runs all the time.

Job creates pod in background. Completed job cannot be run again with the same spec (file). Must be deleted or it must
run with different name.

Delete Job pod after specific time (to clean up):

```yaml
spec: # Job spec
  ttlSecondsAfterFinished: 10
```

Minikube must be started with flag: `--feature-gates="TTLAfterFinished=true"`.

Deletion Job/CronJob deletes all pods created in Job.

#### CronJobs

CronJob - job running recursively.

Example:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cron-job-test
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec: 
      template:
        spec:
          restartPolicy: Never
          containers:
            - name: count-container
              image: debian:latest
              command: 
                - "/bin/bash"
                - "-c"
                - "apt-get update; apt-get install curl -y; curl -s http://wttr.in/Wroclaw"
```

Listing:

```sh
kubectl get cj
```

### Secrets

Secret in specific (encoded) example of ConfigMap.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: secret-test
data:                             # encoded
  user: 'cm9vdA=='                # "dbadmin" in base 64
  pass: 'ZGJwYXNzd29yZDEyMyE='    # "dbpassword123!" in base 64
stringData:                       # plain text data
  dbaddress: 'localhost'
  dbname: 'test'
```

Encoding:

```sh
echo -n 'dbpassword123!' | base64
ZGJwYXNzd29yZDEyMyE=
```

Apply:

```sh
kubectl apply -f secrets.yaml
kubectl get secrets
```

Secrets can be referenced in Pods in 2 ways: as environment variable and as volume.

Referencing secret as env:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: database
spec:
  containers:
    - name: db
      image: mysql:5.7.34
      env: # environment variable created based on K8s secret
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: secret-test
              key: pass # secret can have multiple key:value entries
```

Referencing secret as volume:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-test
spec:
  containers:
    - name: secret-test
      image: mysql:5.7.34
      command: ['env']
      volumeMounts:
        - mountPath: '/root/secrets'
          name: dbsecrets
          readOnly: true
  volumes:
    - name: dbsecrets
      secret:
        secretName: secret-test
```

MySQL container must know path to password file (env).

#### Secret types

- opaque - any, arbitrary user-defined data
- kubernetes.io/basic-auth - credentials for basic authentication
- kubernetes.io/ssh-auth - credentials for SSH authentication
...

#### Secret file

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: nginx-secret
type: Opaque
stringData:
  server-cert.pem: |
    -----BEGIN CERTIFICATE-----
    ...
    -----END CERTIFICATE-----    
  server-key.pem: |
    -----BEGIN PRIVATE KEY-----
    ...
    -----END PRIVATE KEY    
```

#### Editing secrets

Editing shows secret's value (base64 encoded).

```sh
kubectl edit secret [SECRET_NAME]
```

### Service

IP of pod inside cluster is dynamic. Service name should be used for communication between pods.

Service must know which port it has to be connected (selector).

```yaml
apiVersion: v1
kind: Service
metadata:
  name: service-test
  labels:
    app: nginx
spec:
  ports:
    - port: 80 ##ClusterIP, must match container/pod port
      protocol: TCP
  selector:
    matchLabels:
      app: nginxapp
```

```sh
kubectl get svc
kubectl get services
```

### Pod Auto Scaler

Will create multiple replicas based on given metric.
Requires metric server.

`auto.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: demo-apps
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21.1
        resources:
          requests:
            cpu: "500m"
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
  namespace: demo-apps
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment ##existing deployment
    name: nginx-deployment
  minReplicas: 1
  maxReplicas: 50
  targetCPUUtilizationPercentage: 50
```

Check:

```sh
$ kubectl get hpa -n demo-apps
NAME        REFERENCE                     TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
nginx-hpa   Deployment/nginx-deployment   cpu: 0%/50%   1         50        1          48s
```

```sh
watch -n 2 'kubectl top pods -n demo-apps --use-protocol-buffers'
```

## Commands

### kubectl edit

Edit configuration of working workload.

```sh
kubectl edit pod [PODNAME]
kubectl edit service [SERVICE_NAME] -n [NAMESPACE_NAME]
```

Will open pod configuration file (yaml).

`CrashLoopbackOff` - container has nothing to do, needs command as entrypoint.

```yaml
command: ['sleep', 'inf']
```

### kubectl top

```sh
##show resources consumed by pods
kubectl top pods
kubectl top pods -n [NAMESPACE_NAME]
kubectl top pods -n [NAMESPACE_NAME] --use-protocol-buffers
```

### kubectl exec

Pod has default container (first by default). Exec will run on default one.

```sh
kubectl exec [POD-NAME] -- [command] ##if one container
kubectl exec nginx -- ps aux
kubectl exec -it nginx -- bash

kubectl exec -c [CONTAINER-NAME] -it [POD-NAME] -- [command]
kubectl exec -c nginx -it pods-multiple -- bash
```

### kubectl logs

```sh
kubectl logs [POD-NAME] [CONTAINER-NAME]
```

## Networking

### CNI - Container Network Interface

Every node within cluster can communicate with other nodes. Every pod within cluster can communicate with other pods.
Every pod have own unique IP.

Kubernetes does not manage network communication. It is managed by external services - `CNI Plugins`. They are created based
on CNI plugins specification and libraries. Thanks of that we separate running containers from networking. By default
Pod does not have network interface. NIC is created/deleted and addressed by CNI plugin. It also manages network
communication between Pods.

CNI Plugins:

- kubenet - simple plugin for Linux
- Calico
- Weave
- Azure CNI
- Amazon CNI
- and many more

### Port forward

Container must have `containerPort` declared. Port will be accessible only at `localhost` interface of kubectl host (not
host where container is deployed). Process is running in foreground.

```sh
#kubectl port-forward [CONTAINER_NAME] [HOST_PORT]:[CONTAINER_PORT]
kubectl port-forward deployment-test-5897965cdf-7b87z 8080:80
```

### Endpoints

Used for mapping service name to IP (dynamic). Allows DNS communication between pods, inside the cluster, not from outside.

```sh
kubectl get endpoints
```

### ClusterIP

`ClusterIP` - basic, ip for deployed pod/service.\
Used for communication between containers inside Deployment.

### NodePort

Forward node's port to service/deployment port. Node ports range is: 30000-32767. Used to access service from outside od cluster.

```sh
kubectl expose deployment deployment-test --type=NodePort
##K8s will choose Node's port randomly. All node IPs in cluster will work.
##Exposing deployment will create a new service

kubectl get svc
#debian@k8s-controller:~/k8s$ kubectl get svc
#NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
#deployment-test   NodePort    10.233.3.135    <none>        80:30544/TCP   8s
```

---

Service perspective:

```sh
User ----> [_NODE:3008_] [_SVC:8088_] <------> [ _POD:80_ ]
              NodePort       Port               targetPort
```

If only port is defined, K8s assumes that targetPort and Port have the same value.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: service-nodeport-test
spec:
  type: NodePort
  ports:
    - targetPort: 80
      port: 8088
      nodePort: 30008
  selector:
    app: nginxapp ##which pod/deployment
```

### Network policies

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-nginx
  namespace: my-namespace
spec:
  podSelector:
    matchLabels:
      app: nginx
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
```

Apply:

```sh
kubectl apply -f network-policy.yaml
```

### LoadBalancer

```sh
kubectl expose deployment deployment-test --type=LoadBalancer
```

LoadBalancer is used for Kubernetes clusters hosted in the cloud. K8s assigns External IP provided by the provider to
the LoadBalancer service.

```sh
debian@k8s-controller:~/k8s$ kubectl get svc
##NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
##deployment-test         LoadBalancer   10.233.10.63    <pending>     80:32690/TCP   99s
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: service-nodeport-test
spec:
  type: LoadBalancer
  ports:
    - targetPort: 80
      port: 80
      nodePort: 30008
  selector:
    app: nginxapp
```

## Ingress controller

User --> LoadBalancer --> Node --> Ingress Controller Pod --> Service (ClusterIP) --> Pod

`IngressController` - ReverseProxy deployed in Cluster (in form of a Pod). LoadBalancer with public IP forwards
connection to IngressController which forwards traffic to the specific Service (Pod) based on `Host` header.

[K8s docs](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)

### Ingress Manifest

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  labels:
    app: nginx
spec:
  type: ClusterIP # default!
  ports:
    - port: 80
      protocol: TCP
  selector:
    app: nginx
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations: # custom parameters
    traefik.ingress.kubernetes.io/router.entrypoints: web # HTTP only
spec:
  rules:
    - host: nginx.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginx-service
                port:
                  number: 80
```

## ConfigMap

Allows providing/setting up environment variables or config files to containers.

Creating ConfigMap from file:

```sh
kubectl create configmap [NAME] --from-file [FILENAME]
```

## Manifest

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-cm
data:
  # key: value
  # filename: |
  #   content
  # ---
  nginx.conf: |
    user nginx;
    worker_processes 1;
    events {
      worker_connections  1024;
    }
    http {
      server {
        listen 80;
        server_name example.com;
        location / {
          root   /usr/share/nginx/html;
          index  index.html index.htm index.php;
        }
        location /test {
          return 401;
        }
      }
    }    
```

Usage example:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:.
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - name: web
          containerPort: 80
        volumeMounts:
        - name: nginx-cm # name of config map volume
          mountPath: /etc/nginx # path where config map (config file) will be mounted
        - name: wolumin1
          mountPath: /usr/share/nginx/html
      volumes:
      - name: nginx-cm
        configMap: # volume based on config map
          name: nginx-cm
      - name: wolumin1
        hostPath:
          path: /var/nginx
          type: DirectoryOrCreate
```

## DeamonSet and StatefulSet

Alternatives to the deployment.

### StatefulSet

Used for databases. Pod (in the scope of Node) must have unique and persistent name and must be attached to specific
Persistent Volume. StatefulSet creates replicated pod names with increasing numbers instead random suffix like
Deployment.

StatefulSet uses `Volume Claim templates` to assign and persistently link pods to their Persistent Volumes.

Volumes:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nfs-pv0
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 100Mi
  accessModes:
    - ReadWriteOnce
  nfs:
    server: 192.168.100.179
    path: "/kubenfs/pv0"
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nfs-pv1
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 200Mi
  accessModes:
    - ReadWriteOnce
  nfs:
    server: 192.168.100.179
    path: "/kubenfs/pv1"
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nfs-pv2
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 200Mi
  accessModes:
    - ReadWriteOnce
  nfs:
    server: 192.168.100.179
    path: "/kubenfs/pv2"
```

StatefulSet:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-sts-service
  labels:
    run: nginx-sts
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    run: nginx-sts
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: nginx-sts
spec:
  serviceName: "nginx-sts-service"
  replicas: 3
  podManagementPolicy: Parallel # how to run pods, parallel- run all at once
  selector:                     # by default pods start ony after another
    matchLabels:
      run: nginx-sts
  template:
    metadata:
      labels:
        run: nginx-sts
    spec:
      containers:
      - name: nginx
        image: nginx
        volumeMounts:
        - name: www
          mountPath: /var/www/
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      storageClassName: manual
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 20Mi
```

StatefulSet requires `Headless` service - `clusterIP: None`.

#### STS Commands

```sh
kubectl delete sts [STS_NAME]
# will delete all pods WITHOUT StatefulSet and volumes 

kubectl scale sts [STS_NAME] --replicas=0
# scale to 0 if delete command doesn't work
```

### DaemonSet

Run `Pod` automatically on every node of the cluster. Used for services like Traefik. Works only in multi-node environment.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-daemonset
spec:
  selector:
    matchLabels:
      app: nginx-daemonset-app
  template:
    metadata:
      labels:
        app: nginx-daemonset-app
    spec:
      containers:
      - image: nginx
        name: nginx
```

#### DaemonSet commands

```sh
kubectl get daemonset
```

## Resource quotas and limits

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-resources
  namespace: my-namespace
spec:
  hard:
    pods: "10"
    requests.cpu: "4"
    requests.memory: 16Gi
    limits.cpu: "10"
    limits.memory: 32Gi
```

Apply:

```sh
kubectl apply -f quota.yaml
```

## CustomResources and CRDs

### Custom resource definition

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: crontabs.stable.example.com
spec:
  group: stable.example.com
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                cronSpec:
                  type: string
                image:
                  type: string
                replicas:
                  type: integer
  scope: Namespaced
  names:
    plural: crontabs
    singular: crontab
    kind: CronTab
    shortNames:
    - ct
```

Apply:

```sh
kubectl apply -f crd.yaml
```

### Custom resource

```yaml
apiVersion: stable.example.com/v1
kind: CronTab
metadata:
  name: my-new-cron-object
  namespace: my-namespace
spec:
  cronSpec: "* * * * */5"
  image: my-cron-image
  replicas: 3
```

Apply:

```sh
kubectl apply -f custom-resource.yaml
```

## Helm

Package manager for K8s.

### Installation

[https://helm.sh/docs/intro/install/](https://helm.sh/docs/intro/install/)

```sh
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

### Charts

[Charts repository](https://artifacthub.io/)

### Use

First repo must be added where package is hosted.

Repos

```sh
helm repo ls
# listing repos

helm repo add [REPO_NAME] [REPO_URL]
# adding repo

helm repo remove [REPO_NAME] [REPO_URL]
# removing repo

helm search repo [PACKAGE_NAME]
# searching for chart in the installed repos
```

Packages

```sh
helm ls
# show installed packages

helm install [LABEL_NAME] [PACKAGE_NAME]
# installing package using helm

helm uninstall [LABEL_NAME] [PACKAGE_NAME]
# uninstalling package using helm
```

Templates

Charts have templates for customizing deployments. Default variables values can be overridden using yaml config. See
`default values` for the chart to get list of all variables, then create config file to override what you need.

```sh
helm install [LABEL_NAME] [PACKAGE_NAME] --values=/path/to/the/yaml
# installation with overriding default values
```

Upgrades & Rollbacks

```sh
helm upgrade [LABEL_NAME] [PACKAGE_NAME] --values=/path/to/file
# upgrading package using helm

helm history [LABEL_NAME]
# list package history

helm rollback [LABEL_NAME] [REVISION_NUMBER]
# rollback package to previous version
# rollback creates new revision
```

## Multi-master

HA Control-Plane.

Virtual IP - 10.0.0.100\
Master1 - 10.0.0.10\
Master2 - 10.0.0.11\
Master3 - 10.0.0.12

LB1 - HaProxy1 + KeepAliveD\
LB2 - HaProxy2 + KeepAliveD

### LB Installation

```sh
sudo apt install keepalived haproxy -y
```

### Check script

Keepalived checks if K8s API is available and responds (via HaProxy address).

Change `localhost` to Virtual IP address.

```sh
#!/bin/sh

errorExit() {
  echo "*** $@" 1>&2
  exit 1
}

curl --silent --max-time 2 --insecure https://localhost:6443/ -o /dev/null || errorExit "Error GET https://localhost:6443/"
if ip addr | grep -q 192.168.101.111; then
  curl --silent --max-time 2 --insecure https://192.168.101.111:6443/ -o /dev/null || errorExit "Error GET https://172.16.16.100:6443/"
fi
```

### `keepalived.conf`

```pwsh
vrrp_script checkapi {
  script "/etc/keepalived/checkapi.sh"    # above script
  interval 2                              # run script every 2s
  timeout 5                               # wait 5s before mark failure
  fall 3                                  # return FAULT when script returns non-zero 3x
  rise 3                                  # return SUCCESS when script returns zero 3x
  weight -10                              # if FAULT set priority -10
}

vrrp_instance VI_1 {
    state ACTIVE        # ACTIVE for master, BACKUP for slave
    interface enp0s3    # NIC id
    virtual_router_id 1
    priority 101        # 100 for BACKUP (slave)
    advert_int 2
    authentication {
        auth_type PASS
        auth_pass mypass  # authentication
    }
    virtual_ipaddress {
        192.168.101.111   # Virtual IP
    }
    track_script {
        checkapi
    }
}
```

### `haproxy.cfg`

```ini
frontend kubernetes-frontend
  bind *:6443
  mode tcp
  option tcplog
  default_backend kubernetes-backend

backend kubernetes-backend
  option httpchk GET /healthz
  http-check expect status 200
  mode tcp
  option ssl-hello-chk
  balance roundrobin
    server kmaster1 10.0.0.11:6443 check fall 3 rise 2
    server kmaster2 10.0.0.12:6443 check fall 3 rise 2
    server kmaster3 10.0.0.11:6443 check fall 3 rise 2
```

Enable and restart services.

### K3s installation

If masters have `etcd` role, then odd amount of masters must be set (non-even).

First master:

```sh
swapoff -a; sed -i '/swap/d' /etc/fstab
curl -sfL https://get.k3s.io | sh -s server --cluster-init --token "xxx"
```

Next masters:

```sh
curl -sfL https://get.k3s.io | K3S_TOKEN="xxx" sh -s server --server https://[FIRST-MASTER-IP]:6443
```

Workers:

```sh
curl -sfL https://get.k3s.io | K3S_URL=https://[VIRTUAL-IP]:6443 K3S_TOKEN="xxx" sh -
```
