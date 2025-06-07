# Dev Containers
https://github.com/devcontainers/images

VSCode Commands:
add dev container configuration files 
reopen in container
rebuild container

Dockerfile:
https://containers.dev/guide/dockerfile

Field definitions:
https://containers.dev/implementors/json_reference/#image-specific
https://containers.dev/implementors/json_reference/#compose-specific

Prebuilds:
https://github.com/craiglpeters/kubernetes-devcontainer
https://github.com/marketplace/actions/dev-container-bDevContainersDuild-and-run-action

npm install -g @devcontainers/cli
devcontainer build --workspace-folder . --push true --image-name ghcr.io/username/projectname:latest 