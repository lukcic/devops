# Troubleshooting

## EKS node limit

Check pod limits on EKS nodes:

```sh
printf "%-30s %s\n" "NODE_NAME" "POD_ALLOCATION"
for node in $(kubectl get nodes -o name); do
  count=$(kubectl get pods --all-namespaces --field-selector spec.nodeName=$(echo $node | cut -d/ -f2) -o json | jq '.items | length')
  capacity=$(kubectl get $node -o jsonpath="{.status.capacity.pods}")
  printf "%-30s %s/%s\n" "$(echo $node | cut -d/ -f2)" "$count" "$capacity"
done
``` 
