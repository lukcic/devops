Containers are not virtual machines. You can understand them as boxes that isolates Unix processes. 
Processes in containers are just processes in docker server - they use the same instance of Linux kernel.
Containers are ephemeral- can be build and deleted very quickly, even after finish one task.
One process for one container.

Docker Machine - Creating Docker hosts in cloud. Standard docker commands will take effect in remote docerd.
Docker Compose - Light orchestration. Connecting many containers in service (Wordpress + mySQL). Making local developer environments. Using yaml. Installed by pip.

Portainer - GUI for docker.
Rancher - Kubernetes managment (pilot).
_________________________________________________________________________

docker version    #Show server & client versions
docker info       #Infos about server
_________________________________________________________________________

Listing running containers:
docker ps 
docker container ls

Listing all containers:
docker ps -a
docker container ls -a

docker ps -a -l [VALUE]         #Searching for containers with given label

docker port [NAME/ID]           #Will show container ports redirection
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

docker run = docker create + docker start

Running containers:
docker container run -it -p 80:80 nginx
-it                              #Interactive mode with tty. Interactive - stdin will be open, tty -pseudoterminal. 
-p 80:80     --public 80:80      #Host port, container port
-P                               #All ports all published

docker container run -d -p 8080:80 --name [NAME] [IMAGE_NAME]        #Without name parameter docker will assign random name
-d                               #detach (running in background) 
-l [VALUE]                       #Adding label to container
-w [DIR]                         #Change working directory of container
--hostname="VALUE"               #Creating own hostname for container
--read-only=true                 #Read only container - processes inside container cannot write on container filesystem. Used with mounted volume for logs (for example)
--user [USERNAME]                #Container is working as a given user

docker container run -d -p 3306:3306 --name MyMySQL --env MYSQL_ROOT_PASSWORD=13456 mysql
--env                                #environment variable

docker run --entrypoint /bin/bash    #starting container with different first command (entrypoint)

docker run --rm -it ubuntu:latest    #Container will be removed after stop working
docker run --help                    #Help for given command          
- - - - - - - - - - - - - - - - - - - - - - - -

Stop running container:
docker container stop [NAME/ID]                    #Docker sends SIGTERM signall
-t 25                                              #If container will not response for SIGTERM, Docker will send SIGKILL after 25sec

docker kill [NAME/ID]                              #Docker will send SIGKILL imidiately

docker pause [NAME/ID]                             #Pausing container - docker will not allocate processor to process
docker unpause [NAME/ID]
- - - - - - - - - - - - - - - - - - - - - - - -

Starting not-running container:
docker container start [NAME/ID]
- - - - - - - - - - - - - - - - - - - - - - - -

Attaching detached (running) container:
docker container exec [-it] [NAME/ID] bash
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Removing container:
docker container rm [-f] [NAME/ID]
-f  (forced)

docker rm -f $(docker ps -aq)       #Removes all containers

docker system prune -a              #Will destroy all containers, networks, images and cache
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

docker container update             #Updating container settings
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

docker run --restart="VALUE" [NAME]:[TAG]
#Restarting container by scheduler, values: no, always, on-failure i unless-stopped. Container will restart after crash.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

docker inspect [NAME/TAG]           #Show detailed info about container, works with containers, images, volumens and networks.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Interaction with running container:

Docker exec:
```shell
docker exec [NAME/TAG] [COMMAND]                                    # Will execute command in container (bash) terminal.
docker exec -it -u root 6dg6dg7 /bin/bash                           # Will execute command as given user (--user root)
docker exec -it -w / 6dg6dg7 ls                                     # -w / will change workdir to /
docker exec -e TEST=true -it 6dg6dg7 /bin/bash -c 'echo $TEST'      #-c will send argument as string
--privileged
```                                                        # will run container without some docker demons limitations, used for routing tables modifications, promiscious mode etc.

nsenter (Namespace Enter)
This Linux package give possibility to enter in any linux namespace. You can enter inside container even if it not responding (docke exec fails).

sudi apt install util-linux
docker run --rm -v /usr/local/bin:/target jpetazzo/nsenter #installation nsenter without package manager

Connecting to container namespace:
PID=$(docker inspect --format \{{.State.Pid\}} [CONTAINER_ID])      #Check linux PID of running container and assign it to PID variable 
sudo nsenter --target $PID --mount --uts --ipc --net --pid          #Connect to namespace of given container

the same effect:
docker exec -it [CONTAINER_ID] /bin/bash
_________________________________________________________________________

Filesystems:
https://docs.docker.com/storage/volumes/

Bind-mouted directories - used for provisioning files to container, but container cannot do any changes in host filesystem (takes a own copy). Need absolute host path when using -v.
docker run -v [HOST_VOLUME_PATH]:[CONTAINER_VOLUME_PATH] [IMAGE]:[TAG]        #
docker container run -d -p 8080:80 -v $(pwd):/usr/share/nginx/html nginx      #Host path can be variable
[CONTAINER_VOLUME_PATH]:ro                                                    #Read only volume

Volumes - special type of containers that are mounted in containers and data created by container is stored inside. Can be mouned using --mount or -v [VOLUME_NAME]:/PATH.
docker volume create [VOLUME_NAME]  #Creating volume
docker volume ls                    #Listing volumes
docker volume inspect [NAME/ID]     #View info about volume

docker run --mount source=[VOLUME_NAME],target=[PATH] [IMAGE][TAG]      #creating container with mounting exist volume 

docker run --tmpfs [CONTAINER_VOLUME_PATH] [IMAGE]:[TAG]                #Creating tempolary volume (files deleted while closing container), can be used with --read-only
_________________________________________________________________________
Docker network:
Docker is using bridge interface that connects docker0 virtual interface with phisical host interface. 
Docker0 is using private subnet (free from host), contoainers get IPs from tis private subnet and can communicate each other. 
Incoming traffic must be routed by proxy service. 

Docker has internal DNS service (disabled in docker0). Containers run with the same (added) network can communicate using their names.

docker network ls                            #Listing docker networks
docker network inspect [NET_NAME/ID]         #Show info about network

docker network create [NETWORK_NAME]                     #Creating new docker network
docker run -it --netowrk=[NETWORK_NAME] [IMAGE]:[TAG]    #Creating container connected to given network

docker run --network=host [IMAGE]:[TAG]            #Connecting created cotainer to host network - all ports the same as host
docker run --network=none [IMEGE]:[TAG]            #Creating container without network (secure option)

Overlay - networks between many docker server demons.
_________________________________________________________________________
Statistics & processes:

docker stats #statistics of all containers
docker container stats [NAME/ID]    #statiscics of given container (live)
--no-stream                   #only from given moment
--format "{{}.CPUPerc}"       #just procentage use of procesor (live)

docker container top [NAME/ID]  #Shows processes running in container (the same process id are listed in host ps)
_________________________________________________________________________     
Logs:

docker logs [NAME/ID]   #Shows container logs
-t   #shows logs with timestamps
-f    #Live mode -appending new logs
--tail "10"   #Shows last 10 log lines, may be used with -f
--since "2021-07-21T11:21:00"   #Shows logs from given timestamp
--until "2021-07-21T21:21:00"   #Shows logs to givem timestamo. May be used with since.
_________________________________________________________________________
Hardware limits:

docker run --cpus="0.2"             #Limiting container to max 20% of processor
docker run --cpuset-cpus=0,3        #Container will use only 0 and 3 cores
docker run --cpu-period="10000000"  #Container will take 1/10000000 cpu cycle, default 100us 
docker run --cpu-quota="50000"      #50% of cpu usage quota

docker run --memory="200m"          #Limiting RAM memory to 200 MiB

docker run --blkio-weight 300       #Limiting in/out disk operations
docker run --blkio-weight-device "/dev/sda:10"  #Limiting io disk operations for given disk
_________________________________________________________________________

