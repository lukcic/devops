# Dashboard

## Installation

```sh
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard
helm repo update
helm search repo -l kubernetes-dashboard/kubernetes-dashboard | head -3

#NAME                                            CHART VERSION   APP VERSION     DESCRIPTION
#kubernetes-dashboard/kubernetes-dashboard       7.12.0                          General-purpose web UI for Kubernetes clusters
#kubernetes-dashboard/kubernetes-dashboard       7.11.1                          General-purpose web UI for Kubernetes clusters
```

Edit values by adding:

```yaml
  ingress:
    enabled: true
    hosts:
      - dashboard.k8s-dev.lukcic.net
    ingressClassName: nginx
```

Install:

```sh
helm upgrade --install --debug --namespace dashboard --create-namespace --values values.yml --version 7.12.0 kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard
```

### Service token

Apply:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dashboard-user
  namespace: dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: dashboard-user
  namespace: dashboard
---
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: dashboard-user-token
  namespace: dashboard
  annotations:
    kubernetes.io/service-account.name: "dashboard-user"
```

Retrieve and decode token value:

```sh
kubectl get secret dashboard-user-token -n dashboard -o json | jq -r .data.token | base64 -d
```

Paste it in the token field on the web page (without trailing %).

