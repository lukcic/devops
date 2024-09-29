# Ingress controller

## Traefik

Traefik installed as k8s service, should be type of `LoadBalancer`.

### Ingress route

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: dashboard
  namespace: traefik
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`traefik.example.com`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))
      kind: Rule
      services:
        - name: api@internal
          kind: TraefikService
```

### Middleware

Config for connection modification. Middleware is an add-on that extends the capabilities of `IngressRoute`.

#### StripPrefix

Remove the specified prefixes from the URL path.

Config:

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: nginx-stripprefix
spec:
  stripPrefix:
    prefixes: 
      - /test1
      - /test2
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
        - name: nginx-deploy-test3
          port: 80
    - match: Host(`nginx.example.com`) && Path(`/test1`)
      kind: Rule
      middlewares:
        - name: nginx-stripprefix
      services:
        - name: nginx-deploy-test1
          port: 80
    - match: Host(`nginx.example.com`) && Path(`/test2`)
      kind: Rule
      middlewares:
        - name: nginx-stripprefix
      services:
        - name: nginx-deploy-test2
          port: 80
```

#### BasicAuth

Base64 generation:

```sh
apt install apache2-utils -y
htpasswd -nb user password | base64
dXNlcjokYXByMSRMSHp4QW9oNyQ3SHhWYU84RGY2aUlCcE5XOG40TEYwCgo=
```

Traefik dashboard protection:

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: dashboard-basicauth
  namespace: traefik
spec:
  basicAuth:
    secret: dashboardsecret
---
apiVersion: v1
kind: Secret
metadata:
  name: dashboardsecret
  namespace: traefik
data:
  users: |
    dXNlcjokYXByMSRMSHp4QW9oNyQ3SHhWYU84RGY2aUlCcE5XOG40TEYwCgo=    
---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: dashboard
  namespace: traefik
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`traefik.example.com`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))
      kind: Rule
      middlewares:
        - name: dashboard-basicauth
      services:
        - name: api@internal
          kind: TraefikService
```
