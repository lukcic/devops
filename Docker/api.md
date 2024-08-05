https://docs.docker.com/engine/api/latest

```sh
/var/run/docker.sock` # Docker socket used to comminicate with docker API
```

## Listing containers using API (curl)

```sh
curl --unix-socket /var/run/docker.sock http:/1.34/containers/json

# Run with argument:
curl --unix-socket /var/run/docker.sock http:/1.34/containers/json?all=true | python3 -m json.tool
```

## Listing containers using API (env)

```sh
export DOCKER_HOST=ssh://ubuntu@192.168.1.1
docker ps
```

## Getting logs from given container:

```sh
curl --unix-socket /var/run/docker.sock --output - 'http://1.37/containers/23e89a2c5e54/logs?follow=true&stdout=true&stderr=true'
```

## Connecting another docker server by API:

```sh
curl http://[IP]:[PORT]/container/json
curl http://192.168.1.30:2376/containers/json
```

## Stoping container on remote host:

```sh
curl -X POST http://192.168.1.30:2376/containers/NAME/stop
```
