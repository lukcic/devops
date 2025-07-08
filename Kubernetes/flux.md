# flux

## Commands

### Installation

```sh
# Installation
curl -s https://fluxcd.io/install.sh | sudo bash -s -- 2.2.3

# or
curl -LO https://github.com/fluxcd/flux2/releases/download/v2.2.3/flux_2.2.3_darwin_arm64.tar.gz\ntar -xzf flux_2.2.3_darwin_arm64.tar.gz\nsudo mv flux /usr/local/bin/

flux --version
```

### Usage

```sh
flux get helmreleases --all-namespaces
flux get kustomizations --all-namespaces
flux get sources git -n flux-system

# Logs
flux logs
flux -n flux-system logs --kind HelmRelease --name prometheus -f

# Reconcilation
flux reconcile helmrelease coroot-operator -n monitoring
``
