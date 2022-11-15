# Installation
Debian:
```sh
sudo apt-add-repository https://cli.github.com/packages
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key 23F3D4EA75716059
sudo apt update && sudo apt install gh
```

MacOS:
```sh
brew install sh
```

# Usage

## Log-in
```
gh auth login
```

## Creating repo
```
gh repo create [name] --public --enable-issues
```

## Issues
```
gh issue list
gh issue create -t "Title" -b "Issue body"
```

## Pull request
```
gh pr list
gh pr create -B master -t "My first pull request" -b "Lorem ipsum"
```