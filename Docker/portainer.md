## Exposing Docker TCP Socket with TLS:

https://towardsaws.com/ec2-2-ways-to-expose-docker-daemon-to-the-internet-why-61e349f99744

## Generationg certificates for TLS transmission:

https://docs.portainer.io/advanced/ssl
https://github.com/AlexisAhmed/DockerSecurityEssentials/blob/main/Docker-TLS-Authentication/secure-docker-daemon.sh

### Run with Let`s encrypt certificates:

```sh
docker run -d -p 8000:8000 -p 443:9443 --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  -v /etc/letsencrypt/live/portainer.dev.bright.global:/certs/live/portainer.dev.bright.global:ro \
  -v /etc/letsencrypt/archive/portainer.dev.bright.global:/certs/archive/portainer.dev.bright.global:ro portainer/portainer-ce:latest \
  --sslcert /certs/live/portainer.dev.bright.global/cert.pem \
  --sslkey /certs/live/portainer.dev.bright.global/privkey.pem
```
