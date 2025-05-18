# Prometheus operator

https://github.com/prometheus-operator/prometheus-operator?tab=readme-ov-file

## Installation

```sh
# Add helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm search repo -l prometheus-community/kube-prometheus-stack | head -3

#NAME                                            CHART VERSION   APP VERSION     DESCRIPTION
#prometheus-community/kube-prometheus-stack      72.5.0          v0.82.2         kube-prometheus-stack collects Kubernetes manif...
#prometheus-community/kube-prometheus-stack      72.4.0          v0.82.2         kube-prometheus-stack collects Kubernetes manif...

helm show values prometheus-community/kube-prometheus-stack --version 72.5.0 > values.yml
```

Edit values file:
- ingress for prometheus, grafana, alertmanager
  - enabled
  - ingressClassName
  - hosts

```sh
helm upgrade --debug --install --namespace monitoring --create-namespace --atomic --timeout 300s --values values.yml prometheus-stack prometheus-community/kube-prometheus-stack --version 72.5.0 
```

Get Grafana password:

```sh
kubectl --namespace monitoring get secrets prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo

#prom-operator
```

Override DNS:

```sh
# Check IP address:
kubectl get ingress -n monitoring

echo "192.168.254.180 grafana.k8s-dev.lukcic.pl" | sudo tee --append /etc/hosts 
```