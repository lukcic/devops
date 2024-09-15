# Container Orchestration

- how to manage running containers?
- how much resources on host are still available?
- on which host schedule next container?
- are containers crashed or running?
- how to restart crashed containers?
- How to remove unused replicas?

# Kubernetes architecture

[ Control plane (Master) ] <-> [ Worker nodes [ pods [ multiple containers ] ] ]

1. Master node (at least 1):

- API server (entrypoint to the k8s cluster). It is a container.
- controller manager
- scheduler - decided where to deploy container
- etcd - key-value storage, handle state of nodes and containers, snapshots may be used
- virtual network

2. Worker nodes (kubelet process running)

- more resources than master to handle containers

## Components (control plane):

- kube-apiserver (master) - frontend of Kubernetes management layer. Provides contact with Kubernetes cluster. May have multiple instances.
- etcd (master) - key-value store used to storing all parameters of Kubernetes cluster.
- kube-scheduler (master) - follows creation of new pods and assign them nodes for running. Decides where to run given container.
- kube-controller-manager - (master) responsible for starting containers. Single binary contains multiple logical elements (contorollers):
  - node-controller - detects and reacts for situations when node doesn't work properly
  - replication-controller - responsible for maintaining proper amount of pods for each ReplicationController object
  - endpoints-controller - provides information to Endpoints objects (connects services and pods)
    -service account & token controllers - creates default account and API access tokens for new namespaces

## Components (nodes)

- kubelet - agent that works on each node, responsible for running containers in pod, connects to master node to process information
- kube-proxy - network proxy that works on each cluster node and assists/supports service creation
- container runtime - software which runs containers (Docker, Containerd, CRI-O and others)
- add-ons

`POD` (kadłub) - the wrapper (opakowanie) of the container (one or more). The smallest unit to configure and interact with. Usually
one pod per application, each pod got its own IP address (shared between containers inside pod). Pods communicate each other using internal network
(auto-configured). Pods are empheral, can be deleted as a containers.

`Service` - IP address of pod, used to communicate (IPs of pods changes) and loadbalancer.

### Dashboard

https://github.com/kubernetes/dashboard

### Control of Kubernetes:

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
kubectl run -it --image=busybox busybox
kubectl attach busybox -c busybox -it
```

```sh
kubectl get pods
-o wide
kubectl describe pod nginx2
```

## Pod definition

Minimal example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-name
  labels: # optionsl
    app: app-name
    type: front-end
spec:
  containers:
    - name: nginx1
      image: nginx
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
change .

## kubectl edit

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

## kubectl top

```sh
# show resources consumed by pods
kubectl top pods
kubectl top pods -n [NAMESPACE_NAME]
kubectl top pods -n [NAMESPACE_NAME] --use-protocol-buffers
```

## Limits

Resources limits for containers.

```yaml
containers:
  - name: nginx
    image: nginx:1.21.1
    resources:
      requests: # container requests below limits from node
        memory: '256Mi'
        cpu: '250m'
      limits: # container total limit
        memory: '512Mi'
        cpu: '500m' # 0,5 processor time, 1/2 of 1000m
```

## Metrics server

### Single

```sh
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# add in container args:
# - --kubelet-insecure-tls

kubectl apply -f components.yaml
```

### HA

```sh
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/high-availability.yaml
```

## kubectl exec

Pod has default container (first by default). Exec will run on default one.

```sh
kubectl exec [POD-NAME] -- [command] # if one container
kubectl exec nginx -- ps aux
kubectl exec -it nginx -- bash

kubectl exec -c [CONTAINER-NAME] -it [POD-NAME] -- [command]
kubectl exec -c nginx -it pods-multiple -- bash
```

## kubectl logs

```sh
kubectl logs [POD-NAME] [CONTAINER-NAME]
```

## Networking

Pod receives own IP address. All containers share Pod's resources (ram, ip, cpu, open ports).

## Scaling and load balancing

`Scaling` - one container in multiple instances.

`Load balancing` - distributing traffic between container instances.

`Rolling updates` - upgrading app version by replacing old version containers one after another while part of old
containers is still running to host the app.

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
    kind: Deployment # existing deployment
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

---

### Replication Controller

`Replication Controller` - older object. Monitor health of containers to redeploy it if failed on the same or different
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

List Repliction Controllers:

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

`Replica sets` - newer object (replaces Replication controller). Both elements works on pods, but they are one level up
structures. Replica set can have 0 replicas.

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

Efficient update of containers running inside pod. Uses Relppica Sets for making rolling updates.

Comparing to Replica Set only one difference in config file is `kind: Deployment`.

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

Creates new new replica set.

Downgrade app (older tag):

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

###

❯ kubectl rollout status deployment deployment-test
deployment "deployment-test" successfully rolled out
```

```sh
kubectl rollout history deployment [DEPLOYMENT-NAME]

###

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

###

kubectl rollout history deployment deployment-test

deployment.apps/deployment-test
REVISION  CHANGE-CAUSE
1         <none>
2         kubectl set image deployment deployment-test nginx=nginx:1.20 --record

❯ kubectl rollout undo deployment deployment-test
deployment.apps/deployment-test rolled back

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

Cron job - job running recursively.

Job creates pod in backgroud. Completed job cannot be run again with the same spec (file). Must be deleted or it must
run with different name.

Delete job after specific time:

```yaml
spec: # Job spec
  ttlSecondsAfterFinished: 10
```

Minikube must be started with flag: `--feature-gates="TTLAfterFinished=true"`.

Deletion Job/CronJob deletes all pods created in Job.

## Namespace

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

## Environment variables

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: env-tes
spec:
  containers:
    - name: envtest
      image: debian:latest
      command: ['env']
      env:
        - name: test
          value: true
        - name: test2
          value: testtest
  restartPolicy: Never
```

## Volumes

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
        path: /srv/test # must exists in minikube container/vm: minikube ssh
        type: Directory
```

`DirectoryOrCreate` creates directory on K8s host if it not exists:

```yaml
- name: vol-example
  hostPath:
    path: /srv/test # will be created if not exists
    type: DirectoryOrCreate
```

## Secrets

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: secret-test
data:
  user: 'cm9vdA==  ' # "dbadmin" in base 64
  pass: 'ZGJwYXNzd29yZDEyMyE=' # "dbpassword123!" in base 64
stringData: # plain text data
  dbaddress: 'localhost'
  dbname: 'test'
```

Adding the same as other kinds:

```sh
kubectl apply -f secrets.yaml
kubectl get secrets
```

Referencing secrets as envs:

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
      env: # secret value as environment variable
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: secret-test
              key: pass
      volumeMounts:
        - mountPath: '/root/secrets'
          name: dbsecrets
          readOnly: true
  volumes:
    - name: dbsecrets
      secret:
        secretName: secret-test
```

## Service

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
    - port: 80 # ClusterIP, must match container/pod port
      protocol: TCP
  selector:
    matchLabels:
      app: nginxapp
```

```sh
kubectl get svc
kubectl get services
```

### Networking

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
# K8s will choose Node's port randomly. All node IPs in cluster will work.
# Exposing deployment will create a new service

kubectl get svc
#debian@k8s-controller:~/k8s$ kubectl get svc
#NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
#deployment-test   NodePort    10.233.3.135    <none>        80:30544/TCP   8s
```

---

Service perspective:

```
User ----> 3008 [_SVC_] 80 <------> 80 [_POD_]
          NodePort     Port       targetPort
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
      port: 80
      nodePort: 30008
  selector:
    app: nginxapp # which pod/deployment
```

### LoadBalancer

```sh
kubectl expose deployment deployment-test --type=LoadBalancer
```

LoadBalancer is used for Kubernetes clusters hosted in the cloud. K8s assigns External IP provided by the provider to
the LoadBalancer service.

```sh
debian@k8s-controller:~/k8s$ kubectl get svc
# NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
# deployment-test         LoadBalancer   10.233.10.63    <pending>     80:32690/TCP   99s
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
