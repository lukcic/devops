# Docker containers

Containers are not virtual machines. You can understand them as boxes that isolates Unix processes.
Processes in containers are just processes in docker server - they use the same instance of Linux kernel.
Containers are ephemeral- can be build and deleted very quickly, even after finish one task.
One process for one container.

Portainer - GUI for docker\
Rancher - Kubernetes management (pilot).

```sh
docker version
# Show server & client versions

docker info
# Infos about server
```

## Basic usage

### Listing running containers

```sh
docker ps
docker container ls
```

### Listing all containers

```sh
docker ps -a
docker container ls -a

docker ps -a -l [VALUE]
# Searching for containers with given label

docker port [NAME/ID]
# Will show container ports redirection
```

### Running containers

`docker run` = `docker create` + `docker start`

```sh
docker container run -it -p 80:80 nginx
# -it - interactive mode with tty.
# Interactive - stdin will be open, tty -pseudoterminal.

-p 80:80     --public 80:80
# Host port, container port
-P
# Publish service on random port (docker proxy)

docker run -dt ubuntu
# detached with terminal in background (will no exit)

docker container run -d -p 8080:80 --name [NAME] [IMAGE_NAME]
# Without name parameter docker will assign random name

-d                      # detach (running in background)
-l [VALUE]              # Adding label to container
-w [DIR]                # Change working directory of container
--hostname="VALUE"      # Creating own hostname for container
--read-only=true        # Read only container - processes inside container cannot write on container filesystem.
--user [USERNAME]       # Container is working as a given user
--init                  # for processes that are not designed to run with PID 1 (default in containers), with --init docker will run own initialization script with pid 1, so process that have to run in container will be a subprocess of docker init

docker container run -d -p 3306:3306 --name MyMySQL --env MYSQL_ROOT_PASSWORD=13456 mysql
--env                                #environment variable

docker run --entrypoint /bin/bash    #starting container with different first command (entrypoint)

docker run --rm -it ubuntu:latest    #Container will be removed after stop working
docker run --help                    #Help for given command
```

### Advanced flags

```sh
--cap-add, --cap-drop   # add or remove Linux capabilities from the container (security feature) - what is allowable within the context of the container
--cgroup-parent         # specify which cgroup ID your container should be associated with
--cpu-shares            # what percentage of the processor should container be able to access
--cpuset-cpus           # pin execution to specific CPU cores
--device-cgroup-rule    #
--device-read-bps, --device-read-iops, --device-write-bps, --device-write-iops
--gpus                  # use GPU (NVIDIA Only)
--health-cmd, --health-interval, --health-retries, --health-start-period --health-timeout        # healthcheck options
--memory                # limit memory, -m
--pid, --pids-limit     # how many subprocesses container should be allowed to manage
--privileged            # overrides all limits, gives container all priviledges
--read-only             # container layer is read only
--security-opt          # app armor or set comp profiles
--userns
```

### Stop running container

```sh
docker container stop [NAME/ID]
# Docker sends SIGTERM signall
-t 25
# If container will not response for SIGTERM, Docker will send SIGKILL after 25sec

docker kill [NAME/ID]
# Docker will send SIGKILL imidiately

docker pause [NAME/ID]
# Pausing container - docker will not allocate processor to process
docker unpause [NAME/ID]
```

### Starting not-running container

```sh
docker container start [NAME/ID]
```

### Restarting container

```sh
docker restart [NAME/ID]
```

### Attaching detached (running) container

Stdout will show the logs:

```sh
docker attach [NAME/ID]
# to quit use ^P or ^Q
```

Attach to container shell:

```sh
docker container exec [-it] [NAME/ID] bash
```

### Removing container

```sh
docker container rm [-f] [NAME/ID]
-f (forced)
```

## Cleaning host

```sh
docker rm -f $(docker ps -aq)
# Removes all containers

docker volume rm $(docker volume ls -q)
# Removes all volumes

docker system prune -a
# Will destroy all containers, networks, images and cache

docker rm -f $(docker ps -aq) && docker volume rm $(docker volume ls -q)
docker rm -f $(docker ps -aq) && docker volume rm $(docker volume ls -q) && docker network prune -f
```

## Cleaning images

Dangling images are layers that have no relationship to any tagged images. They no longer serve a purpose and consume disk space.

```sh
docker images -f dangling=true
docker image prune
```

<https://bulldogjob.pl/readme/jak-odzyskac-przestrzen-dyskowa-zajeta-przez-dockera>

### Updating containers

```sh
docker container update
# Updating container settings

docker run --restart="VALUE" [NAME]:[TAG]
# Restarting container after crash (or server restart), values: no, always, on-failure i unless-stopped.
```

---

### Getting container information

```sh
docker inspect [NAME/TAG] #Show detailed info about container, works with containers, images, volumens and networks.
--format='{{.VARIABLE}}' #Getting value of given docker inspect attribute (variable): docker inspect --format='{{.DockerVersion}}' NAME

docker inspect --format='{{.LogPath}}' my-app
```

---

### Interaction with running container

Docker exec:

```sh
docker exec [NAME/TAG] [COMMAND]
# Will execute command in container (bash) terminal.

docker exec -it -u root 6dg6dg7 /bin/bash
# Will execute command as given user (--user root)

docker exec -it -w / 6dg6dg7 ls
# -w / will change workdir to /

docker exec -e TEST=true -it 6dg6dg7 /bin/bash -c 'echo $TEST'
#-c will send argument as string

--privileged
# will run container without some docker demons limitations, used for routing tables modifications, promiscious mode etc.
```

#### nsenter (Namespace Enter)

This Linux package give possibility to enter in any linux namespace. You can enter inside container even if it not responding (docke exec fails).

```sh
sudo apt install util-linux
docker run --rm -v /usr/local/bin:/target jpetazzo/nsenter
#installation nsenter without package manager
```

Connecting to container namespace:

```sh
PID=$(docker inspect --format \{{.State.Pid\}} [CONTAINER_ID])
#Check linux PID of running container and assign it to PID variable

sudo nsenter --target $PID --mount --uts --ipc --net --pid
# Connect to namespace of given container
```

the same effect:

```sh
docker exec -it [CONTAINER_ID] /bin/bash
```

---

## Volumes

Special type of directories that are managed by docker engine and mounted inside containers. Data created by container are stored inside volume.
Can be mouned using `--mount` or `-v [VOLUME_NAME]:/PATH`

Docker images create two types of volumes:
Persistent - after container stops data are stored (mysql)
Empheral - deletes data after container stop (ubuntu)

```sh
docker volume create [VOLUME_NAME]
# Creating local volume

docker volume ls
# Listing volumes

docker volume inspect [NAME/ID]
# View info about volume

docker run -it -v /[PATH_IN_CONTAINER] [IMAGE][TAG]
# running container with volume creation (random name)

docker run --name [NAME] -v [VOLUME_NAME]:/[PATH_IN_CONTAINER] [IMAGE][TAG]
# running container with mounting existed volume

docker run --mount source=[VOLUME_NAME],target=[PATH] [IMAGE][TAG]
# creating container with mounting exist volume (00mount need existed volume)
```

Host path that volumes are stored locally:
`/var/lib/docker/volumes`
Docker use volumes drivers to store volumes in remote directories.

Read only volume:

```sh
-v [VOLUME_NAME]:/[PATH_IN_CONTAINER]:ro

docker run --tmpfs [CONTAINER_VOLUME_PATH] [IMAGE]:[TAG]
# Creating temporary volume (files deleted while closing container), can be used with --read-only
```

### Plugins

```sh
docker container run --name [NAME] --mount type=volume,volume-driver=[DRIVER_FULL_NAME],source=[VOLUME_NAME],destination=[PATH_IN_CONTAINER] [IMAGE]:[TAG]
# creating container with creation volume using plugin
```

### Export

Exporting container to file (entire filesystem backup):

```sh
docker export CONTAINER_NAME  > archive.tar

tar -tf archive.tar
# will test archive for errors

docker export CONTAINER_NAME | gzip > archive.tar
# with compression
```

Exporting docker image to file (to access layered filesystem):

```sh
docker save -o archive.tar image:tag
```

### Backup volumes data

```sh
docker run --rm --volumes-from portainer -v $(pwd):/backup busybox tar cvf /backup/backup-poratiner-data.tar /data
```

<https://github.com/xcad2k/cheat-sheets/blob/main/infrastructure/docker.md>

### Restore

```sh
docker run --rm --volumes-from [CONTAINER] -v $(pwd):/backup busybox bash -c "cd [CONTAINERPATH] && tar xvf /backup/backup.tar --strip 1"
```

### NFS volumes

```sh
docker volume create --driver local --opt type=nfs --opt o=addr=192.168.254.100,rw --opt device=:/tubearchivist ta-nfs
docker run -it --mount
'type=volume,dst=/mnt,volume-driver=local,volume-opt=type=nfs,volume-opt=device=:/tubearchivist,"volume-opt=o=addr=192.168.254.100,rw,nfsvers=4"'
debian:latest
```

<https://docs.docker.com/storage/volumes>

---

### Bind-mounted directories

Used for mounting hosts files or directories into container. BM dirs are not managed by docker engine. Needs absolute host path, where volume needs name or empty sign (docker will create volume).

```sh
docker run -v [HOST_VOLUME_PATH]:[CONTAINER_VOLUME_PATH] [IMAGE]:[TAG]
# -v will create dirs

docker container run -d -p 8080:80 -v $(pwd):/usr/share/nginx/html nginx
# Host path can be variable

docker run -it --name example --mount type=bind,source="$(pwd)"/test,target=/data_from_host [IMAGE]:[TAG]
```

---

## Statistics & processes

Docker stats give us information about containers usage of: cpu, mem, hdd io and network.

```sh
docker stats
# statistics of all containers

docker container stats [NAME/ID]
# statiscics of given container (live)

--no-stream
# only from given moment

--format "{{}.CPUPerc}"
# just percentage use of processor (live)

docker container top [NAME/ID]
# shows processes running in container (the same process id are listed in host ps)
```

### Logs

Docker by default use json-file mechanism to storing container logs. May be changed for given container or permanently. Docker can use ony one logging plugin at once.
Available plugins: syslog, fluentd, journald, gelf, awslogs, splunk, etwlogs, gcplogs, logentries.

```sh
docker run --log-driver=syslog [IMAGE]
# creating container with syslog connection, this disable docker logs command

--log-opt syslog-address=udp://192.168.42.42:123
# sending logs to remote syslog server

--log-driver=none
# disabling log mechanism

docker logs [NAME/ID]
# shows container logs

-t #shows logs with timestamps

-f #Live mode -appending new logs

--tail "10" #Shows last 10 log lines, may be used with -f

--since "2021-07-21T11:21:00"
# Shows logs from given timestamp

--until "2021-07-21T21:21:00"
# Shows logs to givem timestamo. May be used with since.
```

### Alternatives

- `Daemon svlogd` - installed inside of container can grab logs from stdout & stderr and send them to remote logging servers using udp.
- `Syslog redirector` - compiled app that grab stdout and stderr of one process from inside of container: <https://github.com/spotify/syslog-redirector>
- `Logspout` - container that connects with docker service and grabs logs from other containers: <https://github.com/progrium/logspout>

---

## Hardware limits

```sh
docker run --cpus="0.2"
# Limiting container to max 20% of processor

docker run --cpuset-cpus=0,3
# Container will use only 0 and 3 cores

docker run --cpu-period="10000000"
# Container will take 1/10000000 cpu cycle, default 100us

docker run --cpu-quota="50000"
# 50% of cpu usage quota

docker run --memory="200m"
# Limiting RAM memory to 200 MiB

docker run --blkio-weight 300
# Limiting in/out disk operations

docker run --blkio-weight-device "/dev/sda:10"
# Limiting io disk operations for given disk
```

---

## Linking containers

```sh
docker run -dt --name mysql_client --link mysql_server:mysql_client ubuntu
# will link server`s IP address in clients /etc/host to communicate with it
```

---

## docker:dind

Docker-in-Docker, also known as DinD, is just what it says: running Docker inside a Docker container.
This implies that the Docker instance inside the container would be able to build containers and also run them.

Used in:

- Continuous Integration (CI) pipeline
- Sandboxed Docker environments

DinD in CI pipelines is the most common use case. It shows up when a Docker container is tasked with building or running Docker containers. For example, in a Jenkins pipeline, the agent may be a Docker container tasked with building or running other Docker containers. This requires Docker in Docker.
But CI is not the only use case. Another common use case is developers that want to play around with Docker containers in a sandboxed environment, isolated from their host environment where they do real work. In this case Docker-in-Docker is a great solution.

---

## Moving data root path

Edit the file `/etc/docker/daemon.json` and add or modify the “data-root” entry. If you configuration is empty, the file will look like this:

```json
{
    “data-root”: “/new/data/root/path”,
    "mtu": 1450
}
```

Restart the docker daemon!
