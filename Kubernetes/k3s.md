# k3s

Alternative to Kubespray. Simplified installation of Kubernetes.

## Installation

One-node cluster:

```sh
curl -sfL https://get.k3s.io | sh -

systemctl status k3s
k3s kubectl get nodes
```

Kubectl admin config: `/etc/rancher/k3s/k3s.yaml`.

```sh
sudo chmod 0644 /etc/rancher/k3s/k3s.yaml
#KUBECONFIG="~/.kube/config:/etc/rancher/k3s/k3s.yaml"
mkdir ~/.kube && ln -s /etc/rancher/k3s/k3s.yaml ~/.kube/config
```

```sh
sudo systemctl edit --full k3s.service
# Add in ExecStart
# ExecStart=/usr/local/bin/k3s \
    server --write-kubeconfig-mode 644 --disable servicelb\
```

## Adding nodes

```sh
# cluster's node-token is needed
# sudo cat /var/lib/rancher/k3s/server/node-token

curl -sfL https://get.k3s.io | K3S_URL=[MASTER_IP]:6443 K3S_TOKEN=[MASTER_TOKEN] sh -
```

## Patching

Used to run stuck services

```sh
kubectl patch service [SERVICE_NAME] -n [NAMESPACE_NAME] -p '{"metadata":{"finalizers":null}}'
```
