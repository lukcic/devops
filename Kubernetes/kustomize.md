# Kustomize

https://www.youtube.com/watch?v=LWbbL3jZcgo

Problem - templating is not a part of Kubernetes specification. Helm and similar tools are not native from K8s API. In Helm almost every specific parameter must be templated.

Kustomize is K8s native tool. Works with `kubectl`.

```sh
kubectl apply -k environments/production
```

Base - directory with set of K8s resources + `kustomization.yaml`

Overlay - directory with environment specific changes.

Updating values in config map will not apply the rolling update. Write approcah is to create a new configMap and replace it in the deployment. Kustomize will automate this process by creating a new configMap with different name suffix and trigers new rolling update.

## Overlay

- example1
  - base
    - deployment.yaml
    - kustomization.yaml
  - environments
    - staging
      - kustomization.yaml
    - production
      - deployment.yaml
      - namespace.yaml
      - kustomization.yaml

---

`base/kustomization.yaml`

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization # optional if standard name
metadata:
  name: example
resources: # what files will be used as a base (shared between environments)
  - deployment.yaml 
```

`environments/staging/kustomization.yaml`

```yaml
---
namespace: staging # will override namespace from deployment.yaml (default) and deploy resources in staging ns
resources:
  - ../../base
```

`environments/production/deployment.yaml`

```yaml
---
apiVersion: apps/v1 # no need to be complete object, just overridden paths
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 20
```

`environments/production/kustomization.yaml`

```yaml
---
namespace: production
namePrefix: pr-
resources:
  - ../../base
  - namespace.yaml
patchesStrategocMerge: # merge both deployments: base + production
  - deployment.yaml
```

## configMap generator

- example2
  - base
    - deployment.yaml
    - kustomization.yaml
  - environments
    - staging
      - kustomization.yaml
    - production
      - deployment.yaml
      - namespace.yaml
      - kustomization.yaml

---

`base/deployment.yaml`

```yaml
...
    env:
    - name: ENV
    valueFrom:
        configMapKeyRef:
        name: config
        key: env
```

`base/kustomization.yaml`

```yaml
---
resources: # configMap is not needed in the base directory
  - deployment.yaml
```

`environments/staging/kustomization.yaml`

```yaml
---
resources:
  - ../../base
configMapGenerator:
  - name: config
    literals:
      - env=staging
```
