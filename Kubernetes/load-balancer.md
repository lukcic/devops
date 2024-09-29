# Load Balancers

## MetalLB

TODO with k3s!

## Installation

![MetalLB installation](https://metallb.universe.tf/installation/)

```sh
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/main/config/manifests/metallb-native.yaml
kubectl get pods -n metallb-system
```

### IP address pool

`metallb-config.yaml`

```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: pool
  namespace: metallb-system
spec:
  addresses:
    - 192.168.254.180-192.168.254.185
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2-advertisement
  namespace: metallb-system
spec:
  ipAddressPools:
    - pool
```

```sh
kubectl apply -f metallb-config.yml
```

#### Test

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: demo-apps
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginxapp
  template:
    metadata:
      labels:
        app: nginxapp
    spec:
      containers:
        - name: nginx
          image: nginx:1.21.1
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: demo-nginx
  namespace: demo-apps
  labels:
    app: demo-nginx
spec:
  type: LoadBalancer
  ports:
    - port: 8088
      targetPort: 80
      protocol: TCP
  selector:
    app: nginxapp
```

`kubectl describe svc demo-nginx -n demo-app` should show LoadBalancer Ingress address!

## Traefik

### Weighted Round Robin

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: TraefikService
metadata:
  name: nginx-wrr
  namespace: default
spec:
  weighted:
    services:
     - name: nginx-deploy-test1 # disabled
       port: 80
       weight: 0
     - name: nginx-deploy-test2
       port: 80
       weight: 3
     - name: nginx-deploy-test3
       port: 80
       weight: 1
---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: nginx
  namespace: default
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`nginx.example.com`)
      kind: Rule
      services:
        - name: nginx-wrr
          kind: TraefikService
```
