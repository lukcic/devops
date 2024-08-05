## Networks types

- bridge -isolated (from host) network for containers
- host -network for containers without isolation (host IP)
- overlay -for docker Swarm (more than one daemons), communication between container without routing
- MacVLAN -different mac for every container (looks like phisical device in network), container obtains IP from network DHCP server or static
- IPVLAN -similar to MacVLAn but uses the same MAC for all containers in network (phisical switch limitations by security reasons)
- None -no networking

## Host network

`docker run --network=host [IMAGE]:[TAG]` - Connecting created cotainer to host network - all ports the same as host
`docker network connect [OPTIONS] NETWORK CONTAINER` - connect running container to the specific network

## Docker network

Docker is using bridge interface that connects docker0 virtual interface with phisical host interface.
`Docker0` is using private subnet (free from host), containers get IPs from tis private subnet and can communicate each other.
Incoming traffic must be routed by proxy service.

Docker has internal DNS service (disabled in docker0). Containers run with the same (added) network can communicate using their names.

```sh
docker network ls #Listing docker networks
docker network inspect [NET_NAME/ID] #Show info about network

docker network create [NETWORK_NAME] #Creating new docker network
docker network create --driver bridge --subnet 192.168.3.1/24 --gateway 192.168.3.254 -name docker_isolated

docker run -it --network=[NETWORK_NAME] [IMAGE]:[TAG] #Creating container connected to given network
docker run -it --network=docker_isolated --ip 192.168.3.30 ubuntu #Creating container connected to given network
docker run --network=none [IMEGE]:[TAG] #Creating container without network (secure option)

docker network disconnect [NETWORK_NAME] [CONTAINER_NAME] #disconnection network from container

docker network prune #deletes all created networks

--network jenkins
--network-alias docker # Makes the Docker in Docker container available as the hostname docker within the jenkins network.
```

MacVLAN network with one IP address in range (from docker host network) attached to ens18 physical NIC:

```sh
docker network create -d macvlan --subnet 192.168.0.0./24 --gateway 192.168.0.1 --ip-range 192.168.0.253/32 -o parent=ens18 custommacvlan
```

https://github.com/nicolaka/netshoot
