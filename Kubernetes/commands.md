# Commands

```sh
# Cluster
kubectl cluster-info

# Resources list
kubectl api-resources
kubectl api-version

# Explain - help
kubectl explain pod

# Nodes
kubectl get nodes
kubectl describe node NODE1
kubectl label nodes k3s-node1 disktype=ssd

# All
kubectl get all
kubectl get all -n TEST_NAMESPACE

# Namespaces
kubectl get ns
kubectl get namespaces
kubectl create namespace TEST_NAMESPACE
kubectl delete namespace TEST_NAMESPACE

# Pods
kubectl get pods
kubectl get pods -o wide # additional info
kubectl get pods --namespace TEST_NAMESPACE
kubectl get pods -n TEST_NAMESPACE
kubectl describe pod TEST_POD
kubectl describe pod -n TEST_NAMESPACE TEST_POD
kubectl run TEST_POD --image nginx
kubectl delete pod TEST_POD
kubectl annotate pods TEST_POD description="example pod"

# Deployments
kubectl get deployments
kubectl get deployments -n TEST_NAMESPACE
kubectl create deployment TEST_DEPLOYMENT --image=nginx
kubectl delete deployment TEST_DEPLOYMENT

# Services
kubectl get services
kubectl get svc
kubectl expose deployment TEST_DEPLOYMENT --type=LoadBalancer --name=TEST_SVC --port=3001
kubectl delete service TEST_SVC

# ConfigMaps (ENVs)
kubectl get configmaps
kubectl create configmap TEST_CONFIGMAP --from-literal=KEY1=VALUE1 --from-literal=KEY2=VALUE2
kubectl delete configmap TEST_CONFIGMAP

# Secrets
kubectl get secrets
kubectl create secret generic TEST_SECRET --from-literal=USERNAME=ADMIN --from-literal=PASSWORD=SECRET123!
kubectl delete secret TEST_SECRET

# Scaling apps
kubectl scale deployment TEST_DEPLOYMENT --replicas=3

# Copying data
kubectl cp index.html httpd-test-1112233:/usr/local/apache2/htdocs/
kubectl cp namespace/container-name:/usr/local/apache2/logs/ . -c http

# Rollout status
kubectl rollout status deployment/TEST_DEPLOYMENT

# Rollback deployment
kubectl rollout undo deployment/TEST_DEPLOYMENT
kubectl rollout status deployment/TEST_DEPLOYMENT

# Editing
kubectl edit deployment test
kubectl set image deployment/TEST_DEPLOYMENT nginx=nginx:1.19.1
kubectl set env deployment/test -c ubuntu EXIT_CODE=0

# Logs
kubectl logs TEST_POD
kubectl logs TEST_POD --previous

# Events
kubectl get events

# Debug
kubectl debug TEST_POD --image=busybox -it

# Cordon - mark node as unschedulable (do not deploy on it)
kubectl cordon NODE1
kubectl uncordon NODE1

# Drain node - safely evicts all pods from a node before maintenance
kubectl drain NODE1
kubectl drain NODE1 --ignore-daemonsets

# SSL certificates
kubectl get certificaterequests
kubectl describe certificaterequest TEST

# Helm
helm list
helm repo add stable https://charts.helm.sh/stable
helm install TEST_RELEASE stable/nginx
helm upgrade TEST_RELEASE stable/nginx
helm uninstall my-release

# Autocompletion [Tab]
kubectl completion -h
source <(kubectl completion zsh)
# paste it to .zshrc
```

## Renew certificates

```sh
kubeadm certs check-expiration
kubeadm certs renew all

# export admin certs 
# restart cluster to reload new certificates
```
