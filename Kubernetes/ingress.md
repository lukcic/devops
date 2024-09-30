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

#### HTTPS with Cert Manager

[https://cert-manager.io/docs/](https://cert-manager.io/docs/)

Self issued certificates:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: myissuer
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: nginx.example.com
  namespace: default
spec:
  dnsNames:
    - nginx.example.com
  secretName: nginx.example.com
  issuerRef:
    name: myissuer 
    kind: ClusterIssuer
```

Testing:

```sh
kubectl get clusterissuer
kubectl get certificates
```

Usage:

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: nginx-redirect-scheme
spec:
  redirectScheme:
    scheme: https
    permanent: true
    port: "443"
---
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: nginx-basicauth
spec:
  basicAuth:
    secret: authsecret
---
apiVersion: v1
kind: Secret
metadata:
  name: authsecret
data:
  users: |
    dXNlcjokYXByMSRMSHp4QW9oNyQ3SHhWYU84RGY2aUlCcE5XOG40TEYwCgo=    
---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: nginx-http
  namespace: default
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`nginx.example.com`)
      kind: Rule
      middlewares:
        - name: nginx-redirect-scheme
      services:
        - name: nginx-deploy-test
          port: 80
---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: nginx-https
  namespace: default
spec:
  entryPoints:
    - websecure
  routes:
    - match: Host(`nginx.example.com`)
      kind: Rule
      middlewares:
        - name: nginx-basicauth
      services:
        - name: nginx-deploy-test
          port: 80
  tls:
      secretName: nginx.example.com
```

Let's encrypt:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-production
  namespace: cert-manager
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    # server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: info@example.com
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-production
    # Enable the HTTP-01 challenge provider
    solvers:
    - http01:
        ingress:
          class: traefik
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: traefik.example.com
  namespace: traefik
spec:
  dnsNames:
    - traefik.example.com
  secretName: traefik.example.com
  issuerRef:
    name: letsencrypt-production
    kind: ClusterIssuer
```

Testing:

```sh
kubectl get clusterissuer
kubectl get certificates
```

Usage:

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: traefik-redirect-scheme
  namespace: traefik
spec:
  redirectScheme:
    scheme: https
    permanent: true
    port: "443"
---
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
  name: dashboard-http
  namespace: traefik
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`traefik.example.com`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))
      kind: Rule
      middlewares:
        - name: traefik-redirect-scheme
      services:
        - name: api@internal
          kind: TraefikService
---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: dashboard-https
  namespace: traefik
spec:
  entryPoints:
    - websecure
  routes:
    - match: Host(`traefik.example.com`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))
      kind: Rule
      middlewares:
        - name: dashboard-basicauth
      services:
        - name: api@internal
          kind: TraefikService
  tls:
      secretName: traefik.example.com
```

Cluster Issuer with DNS challenge:

```yaml
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt-production
  namespace: cert-manager
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: info@example.com
    privateKeySecretRef:
      name: letsencrypt-production
    solvers:
    - dns01:
        digitalocean:
            tokenSecretRef:
                name: digitalocean-dns
                key: access-token
```

DNS challenge is necessary for wildcard certificates.
