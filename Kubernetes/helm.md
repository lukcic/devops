# helm

## Commands

```sh
helm list -a
# show all releases

helm show -A 
# show releases from all namespaces

helm list -n namespace
# show releases from given namespaces

helm repo add stable https://charts.helm.sh/stable

helm search repo -l prometheus-community/kube-prometheus-stack

helm install release_name chart_name
# helm install TEST_RELEASE stable/nginx
# install chart
--debug
--dry-run

helm upgrade release_name chart_name
# upgrade release

helm rollback release_name number
# rollback to previous release

helm uninstall release_name
# uninstall release

helm template chart_name
# render and display manifests
```

```sh
helm create chart_name
# create chart

helm lint chart_name
# lint with values

helm repo index .
# create index file

helm package DIRECTORY
# create helmchart package
```

```sh
helm show values prometheus-community/kube-prometheus-stack > values.yml

helm upgrade --install --namespace prometheus-stack --create-namespace --atomic --debug --timeout 300s --values values.yml prometheus-stack prometheus-community/kube-prometheus-stack
```
