## Images commands

### List images

```sh
docker image ls [-a]
docker images
--no-trunc  # full image id
```

---

### Serching for docker images

```sh
docker search 'name'
docker search --filter is-officiall=true 'name'
# official images

docker search -filter stars=500 'name'
# images with given amount of stars
```

---

### Downloading images

```sh
docker pull [image]:][tag]
# docker pull ubuntu:16.04

--disale-content-trust
# disable content veryfication

-q #quiet

-a -all [images of given name]
# docker pull -a ubuntu
```

---

### Removing images

```sh
docker image rm [id/name]
# must be off, -f (force)

docker rmi [IMAGE_NAME]
# will remove image
```

---

### Tagging images

```sh
docker tag [IMAGE_NAME]:[TAG] [MY_NAME]:[MY_TAG]
docker tag mongo:3.0 myimage:latest
```

---

### Creating image from working container

```sh
docker commit [CONIATNER_NAME] [IMAGE_NAME]
# will save container state (all changes made in interactive mode) as docker image
```

---

### Saving and loading images from/to files (saved state etc)

```sh
docker image save -o [FILENAME.tar] [IMAGE_NAME]
# will compress image to tar file - may be moved to another host

docker save [IMAGE_NAME] | gzip -c > [FILE.tar.gz]
# saving to compressed file

docker image load -i [IMAGE_FILE.tar]
# will load image from given file
```

---

### Check how given image was created

```sh
docker history [IMAGE]
# All commands used while building this image
```

---

## Creating images - Dockerfile

`Dockerfile` - a text document that contains all the commands a user could call on the command line to assemble an
image.

`Build context` - directory on host that contains source code. May be URL (GitHub repo). Image must be build from own folder, because while building image, all files (context) will be added to image.

`.dockerignore` - ignore certain files or directories during copying data into image ex. node_modules from host (may be
different architecture).

### Application recipe

1. Start with OS
2. Install programming language runtime
3. Install application dependencies
4. Set up execution environemt
5. Run application

### Directives (layers)

```dockerfile
ARG version=3.6-alpine
# Build argument (optional), may be used with FROM - must be written on the beginning: FROM python:${version}. It's only available during build time, not in runtime. Is available in image metadata, so cannot pass the credentials.

FROM python3:3.6-alpine
# base (first) layer of container taken from https://dockerhub.com
# avoid using 'latest' tag

RUN pip install Flask==1.0.2
# Running process inside container (while building from image).

RUN apt update && apt install python3-pip -y
# After installation updated apt cache should be deleted: rm -rf /var/lib/apt/lists/\*

COPY [FILE_FROM_HOST] [PATH_IN_CONTAINER]
# Copying files from host

COPY . .
# will copy all context files into image.

RUN npm install
# will install node dependencies

RUN /bin/bash -c "command"
#-c convert argument to string

VOLUME [PATH]
# Only name of the volume

EXPOSE 80/tcp
# In this container port 80 will be service port. This will give random host port while creating container with -P (from image)

ENV title="Hello world"
# Export given environment variable in container

ENV FLASK_APP=/main.py
ENV USERNAME=ubuntu

RUN useradd -ms /bin/bash $USERNAME
# creating non-root user, -m -home directory, -s [SHELL]

USER ${USERNAME}
# will login to given account after run; will take username from env

WORKDIR [PATH]
# set working directory within the image before running commands. It's default directory in the filesystem where commands in the build process to be run or the command at the end to be run (entrypoint).

ENTRYPOINT [COMMAND, ARGUMENTS]
# First process (command) that starts just after building container, not ignore running parameters (CMD ignore)

ENTRYPOINT ["flask", "run", "-h", "0.0.0.0", "-p", "80"]
# Will run: flask run -h 0.0.0.0 -p 80

CMD [ARGUMENTS]
# Will run command or add given arguments to container entrypoint (the same as args after image name in run command)

CMD ["-h","0.0.0.0","-p","80"]
# arguments send to ENTRYPOINT if: ENTRYPOINT ["flask", "run"]

ADD [URL] [PATH_IN_CONTAINER]
# Downloading files from internet. Can unzip archives too.
```

### Build

```sh
docker build .
# building image from Dockerfile in working directory

-t [TAG]
#tag -name of the builded container

--no-cache=true
# always rebuild image layers (cache off)

--build-arg version=3.5
# Build args may be used while building, if more arguments then always --build-arg

docker build -t mynewflaskapp --build-arg USER=localadmin .
```

`RUN` - is running command while building.\
`CMD` - is running command inside builded container, can be used instead ENTRYPOINT only if app runs always with the
same set of arguments.\
`ENTRYPOINT` - first command that runs after starting container. It allows users to append arguments via the command at
runtime when
`buildx` -allows to build multi-architecture images

```sh
docker buildx build --platform linux/amd64,linux/arm64 -t nginx:latest
```

#### Mounting cache

Sharing cache between builds:

```Dockerfile
RUN --mount=type=cache,target=/usr/src/app/.npm \
    npm set cache /usr/src/app.npm && \
    npm ci --only=production
```

This is the feature of buildkit, to use it set `DOCKER_BUILDKIT=1`

### Multi-stage build

Multiple individual stages in one single
Dockerfile that are building separate container images. It's great for compiled apps because it doesn't include
dependencies form the build stage into production image - app binary has statically linked dependencies. Additionally
production image can be based on mininmal base image as alpine where any large image can be used to build process
(includes all compilers etc).

```Dockerfile
FROM node:19.6-bullseye-slim AS base
...
FROM base AS production
```

```dockerfile
FROM node:19.4-bullseye as build

WORKDIR /usr/src/app

COPY package*.json ./

RUN --mount=type=cache,target=/usr/src/app/.npm \
    npm set cache /usr/src/app/.npm && \
    npm ci

COPY . .

RUN npm run build

###
FROM nginx:1.22-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
# copy server config from host

COPY --from=build usr/src/app/dist/ /usr/share/nginx/html
# copy app data from builder

EXPOSE 80
```

---

#### Node.js

```Dockerfile
FROM node:19.6-alpine

WORKDIR /usr/src/app
# copy files here (instead the root directory) and run commands here

ENV NODE_ENV production
# set environment to run app NOT in dev mode

COPY package*.json ./
# do avoid cache miss copy package.json before npm install and the rest of code
# that way, cache will be revalidated only if dependencies change

RUN npm ci --only=production
#instead 'npm install' run 'npm ci' to have 'clean' install (removes existing node_modules), and will always use versions form package.lock
## --only=production - do not install dev dependencies

USER node
# use non-root user to run the app

COPY --chown=node:node ./src .
# copy only source code to the WORKDIR with changing files owner

EXPOSE 3000
# it's only documentation for users, port must be published for container

CMD ["node","index.js"]
```

#### Golang

```Dockerfile
FROM golang:1.19-buster as build
# build stage

WORKDIR /app

RUN useradd -u 1001 nonroot

COPY go.mod go.sum ./

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go mod download

COPY . .

RUN go build \
    -ldflags="-linknode external -extldflags -static" \
    -tags netgo \
    -o app-name

###
FROM scratch
# totally empty image -no binaries, only root fs

COPY --from=build /etc/passwd /etc/passwd
# copy non-root user definition

COPY --from=build /app/app-name app-name
# copy binary from the build image

USER nonroot

EXPOSE 8080

CMD ["/app-name"]
```

### Best practices

- Pin specific versions [🔒 👁️]
  - Base images (either major+minor OR SHA256 hash) [🔒 👁️]
  - System Dependencies [🔒 👁️]
  - Application Dependencies [🔒 👁️]
- Use small + secure base images [🔒 🏎️]
  - size
  - language support (libc)
  - ergonomics (package managers, utilities)
  - security (number of CVEs, attack surface area)
- Protect the layer cache [🏎️ 👁️]
  - Order commands by frequency of change [🏎️]
  - COPY dependency requirements file → install deps → copy remaining source code [🏎️]
  - Use cache mounts [🏎️]
  - Use COPY --link [🏎️]. It allows you to improve cache behavior in certain situations by copying files into an independent image layer not dependent on its predecessors.
  - Combine steps that are always linked (use heredocs to improve tidiness) [🏎️ 👁️]
- Be explicit [🔒 👁️]
  - Set working directory with WORKDIR [👁️]
  - Indicate standard port with EXPOSE [👁️]
  - Set default environment variables with ENV [🔒 👁️]
- Avoid unnecessary files [🔒 🏎️ 👁️]
  - Use .dockerignore [🔒 🏎️ 👁️]
  - COPY specific files [🔒 🏎️ 👁️]
- Use non-root USER [🔒]
- Install only production dependencies [🔒 🏎️ 👁️]
- Avoid leaking sensitive information [🔒]
- Leverage multi-stage builds [🔒 🏎️]

#### Parser directives

Can be used with newer feature where dockerfile version must be set, etc.

```Dockerfile
syntax=docker/dockerfile:1.5
escape=\
# ^ OPTIONAL "directives" (must be at top if used)
```

#### Labels

Metadata for manifest (remote repos).

```Dockerfile
LABEL org.opencontainers.image.authors="sid@devopsdirective.com"
```

#### Heredoc syntax

Multiple commands across multiple lines interpreted as the single line to store it as single layer in the container image.

```Dockerfile
RUN <<EOF
apt update
apt install iputils-ping -y
EOF
```

#### Mounting

`--mount` allows for mounting additional files into the build context

```Dockerfile
# RUN --mount=type=bind ...
# RUN --mount=type=cache ...
# RUN --mount=type=ssh ...
RUN --mount=type=secret,id=secret.txt,dst=/container-secret.txt \
  echo "Run the command that requires access to the secret here"
# host local file stores secret string which can be mounted into filesystem of the container. It will be present only in build time and not in the final artifact.
```

Secret - lets avoiding leaks of secrets during build.

### Remote repositories

#### Sending image to Docker Hub

```sh
docker login
docker login --username=[USER]

docker push [USERNAME]/[IMAGE_NAME]
```

---

### Downloading image from Docker Hub:

```sh
docker pull [USERNAME]/[IMAGE_NAME]
```
