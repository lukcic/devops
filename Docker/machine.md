# Docker Machine

Creating Docker virtual hosts in providers (AWS, VirtualBox). Standard docker commands will take effect in remote docker machine.

## Instalation:

https://docs.docker.com/machine/install-machine/

## Create remote docker server in AWS:

- Generate IAM (Identify and access management) key in AWS Account.
- Add user (programatic Access, aws management console access, administrator).
- Copy access key:

```
mkdir .aws
vim .aws/credentials:
```

```toml
[default]
aws_access_key_id = dkjfkjsdnkjsnkj
aws_secret_access_key = alkjsakfjaksf
```

```sh
docker machine create --driver amazonec2 --amazonec2-region=eu-central-1 NazwaMaszyny

docker-machine env NazwaMaszyny #paste given script that export env variables to your host shell
```

- Open ports in AWS Security group!
