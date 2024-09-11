## Minikube

VM or container that runs Kubernetes cluster on the one host.

## Commands

Minikube commands:

```sh
minikube start
minikube status
minikube pause
minikube stop

minikube ssh # connect kubernetes vm/container via ssh
```

```sh
# Create service
minikube service nginx
```

## Kubectl config

Kubectl config file: `~/.kube/config`

```yaml
apiVersion: v1
clusters:
  - cluster:
      certificate-authority: /home/lukcic/.minikube/ca.crt
      extensions:
        - extension:
            last-update: Thu, 29 Aug 2024 21:20:53 UTC
            provider: minikube.sigs.k8s.io
            version: v1.33.1
          name: cluster_info
      server: https://192.168.49.2:8443
    name: minikube
contexts:
  - context:
      cluster: minikube
      extensions:
        - extension:
            last-update: Thu, 29 Aug 2024 21:20:53 UTC
            provider: minikube.sigs.k8s.io
            version: v1.33.1
          name: context_info
      namespace: default
      user: minikube
    name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
  - name: minikube
    user:
      client-certificate: /home/lukcic/.minikube/profiles/minikube/client.crt
      client-key: /home/lukcic/.minikube/profiles/minikube/client.key
```
