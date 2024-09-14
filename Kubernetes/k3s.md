# k3s

Alternative to Kubespray. Simplified installation of Kubernetes.

# Installation

One-node cluster:

```sh
curl -sfL https://get.k3s.io | sh -

systemctl status k3s
k3s kubectl get nodes
```

Kubectl admin config: `/etc/rancher/k3s/k3s.yaml`.

## Adding nodes

```sh
# cluster's node-token is needed

curl -sfL https://get.k3s.io | K3S_URL=[MASTER_IP]:6443 K3S_TOKEN=$(cat /var/lib/rancher/k3s/server/node-token) sh -
```

# MetalLB

https://metallb.universe.tf/installation/

```sh
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml
```
