# Docker Swarm (Rój)

Docker Orchestration module. Lighter than Kubernetes (orchestration for smaller environments). Need Swarm master. Rest are Swarm worker.

## Commands

```sh
docker swarm init
# Initialization of Swarm (on master). Will return command with token to add workers to swarm.

docker swarm join --token [TOKEN] [IP_ADDRESS]:2377
# Adding worker to swarm. Should be run on worker (new server). Command given after initialization on master.

docker swarm join-token worker|manager
# Generating token for worker/manager

docker swarm leave
# Leaving swarm

docker node ls
# show all nodes in swarm

docker node inspect [NODE_ID]
# show information about given node

docker node promote [WORKER_NAME]
# will set 'manager' flag on worker -it will replace master if it fails

docker node demote [WORKER_NAME]
# will unset 'manager' flag on worker

manager status - leader means master,
reachable means- this node is replacing master when it fils

docker node rm -f [NODE_ID]
# will delete node from swarm
```

`Service = container in swarm`

```sh
docker ps
docker service ls # Show services, or show given service with [NAME/ID]

docker service create [IMAGE]:[TAG]
# creating new service from image

docker service create --replica 1 --name helloworld alpine ping google.com # Service - task run on manager host or workers (replicable and scalable)

docker service inspect [NAME/ID]
# Service inspection

docker service logs [NAME/ID]
# Show logs of service (container)
```

## Service Scaling:

More than 1 instance of aplication for fail immune.

```sh
docker service scale helloworld=3 #Will create 3 instances of service (3 containers), for one on every node, named helloworld.1, helloworld.2 etc

docker service update [OPTION] [PARAMETER] [NAME/ID] #Changes in service, f.eg. changing image for running service (all instances)
docker service update --image alpine:3.4 helloworld
```

## Constrains (ograniczenia):

Services with given labels can be run on choosen nodes.

```sh
docker node update --label-add super=true [NODE_ID] #Adding label "super" to given node
docker service update --constraint-add "node.labels.super == true" helloworld #All running instances of service (containers) will dock on node with given label
```

## Swarm with compose

```sh
docker stack deploy --compose-file docker-compose.yml
# Running services from Docker Compose file
```

```yml
version: '3.7'
services:
  nginx:
    image: test:latest
    deploy:
      mode: replicated
      replicas: 1
      update_config: # service version update behavior
        order: start-first # start new container before destroying old one (rolling updates)
    init: true
    networks:
      - frontend
    ports:
      - 80:8080
    healthcheck:
      test: ['CMD', 'curl', '-f', 'http://localhost:8080/ping']
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s
```

### Constraints in Docker Compose file

```yml
deploy:
  replicas: 2
  placement:
    constraints: [node.labels.super == true]
```

## Drain mode

Node may be turned off from swarm to eg. mainenance.

```sh
docker node update --availability drain [NAME/ID]
# active | pause | drain
```

## Networking

Swarm is using `overlay` network called `ingress`, that can manage multiple nodes in swarm (with transmission encryption).\
Network for data is called `docker_gwbridge`.

## Plugins

```sh
docker plugin install [NAME] #plugin installation

docker volume create -d [PLUGIN_FULL_NAME] --name [VOLUME_NAME]
# Creating docker volume with using given plugin not local
```

## Load balancing:

Swarm has included load balancer module.

```sh
docker service create --name nginx --published=8080,target=80 --replicas 3 nginx
# Creating service with 3 instances of nginx, load balancing is working automatically.
```

### HaProxy

```sh
sudo apt install haproxy
```

edit `/etc/haproxy/haproxy.cfg`

```
frontend http_front
bind \*:80
stats uri /haproxy?stats
default_backend http_back
backend http_back
balance roundrobin
server node1 192.168.1.29:8080 check
server node2 192.168.1.30:8080 check
server node3 192.168.1.31:8080 check
```

```sh
service haproxy restart
```
