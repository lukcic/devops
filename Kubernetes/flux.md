# flux

`gotk` - gitops toolkit

## Usage

```sh
flux get helmreleases --all-namespaces
flux get kustomizations -A # flux kustomizatons, not k8s
flux get sources git -n flux-system

flux get images repository
flux get images policy

# Logs
flux logs
flux -n flux-system logs --kind HelmRelease --name prometheus -f

# Reconcilation
flux reconcile source git flux-system
flux reconcile helmrelease coroot-operator -n monitoring
```

## Controllers

- Source controller - communicate with Github/Gitlab and fetches the state of the repository
- Kustomize controller - use Kustomize to stich the resources into the proper configuration
- Helm controller - similar to Kustomize controller but works on Helm charts and repositories
- Notification controller - integration with e.g Slack
- Image reflector controller and image automation controller - updates the git repository when new container images are available

## Installation

### Client

```sh
# Installation
curl -s https://fluxcd.io/install.sh | sudo bash -s -- 2.2.3

# or
curl -LO https://github.com/fluxcd/flux2/releases/download/v2.2.3/flux_2.2.3_darwin_arm64.tar.gz\ntar -xzf flux_2.2.3_darwin_arm64.tar.gz\nsudo mv flux /usr/local/bin/

flux --version
```

### Bootstrap

```sh
flux bootstrap github \
  --token-auth=false \ # do not store github token in K8s secrets, use ssh deploy key-pair instead
  --owner=lukcic \
  --repository=flux-pr \
  --branch=main \
  --path=clusters/k3s-dev \
  --read-write-key=true \
  --components-extra='image-reflector-controller,image-automation-controller'
```

## Repo structure

### Monorepo

- apps
  - base
    - app1
      - deployment.yaml
      - kustomization.yaml
  - prod (base + k8s kustomization)
    - app1
      - kustomization.yaml
    - namespace.yaml
  - staging (overlay)
    - app1
      - deployment.yaml (only paths overridden from base)
      - kustomization.yaml (k8s kust, with namespace value)
    - namespace.yaml
  - dev (Helm)
    - app1
      - helmrepository.yaml
      - helmrelease.yaml
      - kustomization.yaml (k8s kust: repo + release, namespace)
    - namespace.yaml
- infrastructure
  - monitoring
  - dns
  - storage
- clusters
  - cluster1
    - flux-system
    - apps-prod.yaml (flux kustomization)
    - apps-staging.yaml (flux kustomization)
    - apps-dev.yaml (flux kustomization)

---

`kustomization.yaml` - tells flux how to assemble all of the different individual yaml files and apply them to the cluster (required)

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: prod|staging # base is without namespace
resources:
  - deployment.yaml # in apps/base/app1
  - ../../base/app1 # in apps/prod/app1 or apps/staging/app1
patches: # in overlay to override base
  - path: deployment.yaml
```

---
Flux customization - must be placed in cluster specific catalog to tell the Flux which resources should be deployed.

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: apps-prod # or staging|dev
  namespace: flux-system
spec:
  interval: 60s # run once every minute
  sourceRef:
    kind: GitRepository
    name: flux-system
  path: ./apps/prod # or staging|dev
  prune: true # if resource is deleted from the repo, then delete it form the cluster
  wait: true
```

---
Helm Repository

```yaml
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: HelmRepository
metadata:
  name: app1
  namespace: dev # can be in flux-system or in app/team ns
spec:
  interval: 10m
  url: https://app.example.io/app1
```

HelmRelease

```yaml
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: HelmRelease
metadata:
  name: app1
  namespace: dev # can be in flux-system or in app/team ns
spec:
  releaseName: app1-dev
  chart:
    spec:
      chart: app1
      sourceRef:
        kind: HelmRepository
        name: app1
        namespace: dev
  interval: 10m
  values:
    key:
      key2: "value"
```

## Image update automation

Flux controllers for images must be installed.

`infrastructure/image-repository.yaml`

```yaml
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: ImageRepository
metadata:
  name: app1
  namespace: flux-system
spec:
  image: ghcr.io/test/app1
  interval: 1m
```

`infrastructure/image-policy.yaml`

```yaml
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: ImagePolicy
metadata:
  name: app1
  namespace: flux-system
spec:
  imageRepositoryRef:
    name: app1
  policy:
    semver:
      range: ">=5.0.0"
```

```yaml
apiversion: image.toolkit.fluxcd.io/v1beta1
kind: ImageUpdateAutomation 
metadata:
  name: flux-system 
  namespace: flux-system 
spec:
    interval: 1m
    sourceRef:
      kind: GitRepository 
      name: flux-system 
      git:
        checkout:
          ref:
            branch: main
        commit:
          author:
            email: fluxcdbot@users.noreply.github.com
            name: fluxcdbot
          messageTemplate: "{{range .Updated.Images}}{{println .}}{{end}}"
        push:
          branch: flux-automated-upgrade # with merge request, if automatically use main
    update:
      path: ./
      strategy: Setters
```

For `Setters` updates deployment must include:

```yaml
image: ghcr.io/test/app1:5.0.0 # {"$imagepolicy": "flux-system:app1"}
```
