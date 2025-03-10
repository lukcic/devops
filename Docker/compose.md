# Docker Compose - light orchestration

Connecting many containers in service (Wordpress + mySQL). Making local developer environments. Using yaml. Installed by pip.

https://docs.docker.com/compose

## Installation:

pip3 install docker-compose

docker-compose.yml

```yml
version: '3.3' #version of compose api

services:
  db: #container to database
    image: mysql:5.7
    container_name: db #container_name is needed to force naming (connection in dedicated docker network)
    volumes:
      - db_data:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: somewordpress
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress
  wordpress: #container for wodpress
    depends_on: #will run after db - db
    image: wordpress:latest
    container_name: wordpress
    ports: - "8000:80"
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
    volumes:
      db_data:
```

```yml
services:
  web:
    build: . #this replace 'image', will use 'Dockerfile' from local directory
    ports: - "8080:80"
    volumes: - websitedata:/usr/dataweb
    volumes:
    websitedata: {}
```

## Commands

```sh
docker-compose up               #will run service (containers) if docker-compose.yml file is present
docker-compose -f [FILE.yml] up [OPTIONS]   #run with given file, can use -d and other docker parameters (options)
-d                              #detached mode

docker-compose ps           #list running containers in services
docker-compose [COMPOSE_FILE.yml] ps           #list running containers in services

docker-compose logs #wil show container logs
docker logs --tail=0 --follow

docker-compose top  #top of running containers

docker-compose help -listing of docker-compose commands
build
config
create
```

Creating image with ssh server:

```dockerfile
FROM ubuntu:latest

RUN apt-get update && apt-get upgrade -y

RUN apt-get install openssh-server -y

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN echo 'root:test123' | chpasswd

RUN useradd -ms /bin/bash demouser

RUN echo 'demouser:test123' | chpasswd

RUN service ssh start

EXPOSE 22

CMD ["/usr/sbin/sshd","-D"]
```

## Production

Why not to use Docker-compose in production:

- No way to deploy without downtime
- No option to rollback
- No way to handel credentials
- Can be used only with single host
- Historical reasons:
  - no health-checks
  - Docker-compose was a separate binary
