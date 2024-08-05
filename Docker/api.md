https://docs.docker.com/engine/api/latest

```sh
/var/run/docker.sock` # Docker socket used to comminicate with docker API
```

## Listing containers using API (parameter)

```sh
docker -H tcp://[IP]:2375 ps
```

## Listing containers using API (env)

```sh
export DOCKER_HOST=ssh://ubuntu@192.168.1.1
docker ps
```

## Listing containers using API (curl)

```sh
curl --unix-socket /var/run/docker.sock http:/1.34/containers/json

# Run with argument:
curl --unix-socket /var/run/docker.sock http:/1.34/containers/json?all=true | python3 -m json.tool
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

## Protecting docker socket by TLS

1. Generate certificates

```sh
set -eu

#set -x ; debugging

cd ~
echo "you are now in $PWD"

if [ ! -d ".docker/" ]
then
    echo "Directory ./docker/ does not exist"
    echo "Creating the directory"
    mkdir .docker
fi

cd .docker/
echo "type in your certificate password (characters are not echoed)"
read -p '>' -s PASSWORD

echo "Type in the server name you’ll use to connect to the Docker server"
read -p '>' SERVER

# 256bit AES (Advanced Encryption Standard) is the encryption cipher which is used for generating certificate authority (CA) with 2048-bit security.
openssl genrsa -aes256 -passout pass:$PASSWORD -out ca-key.pem 2048

# Sign the the previously created CA key with your password and address for a period of one year.
# i.e. generating a self-signed certificate for CA
# X.509 is a standard that defines the format of public key certificates, with fixed size 256-bit (32-byte) hash
openssl req -new -x509 -days 365 -key ca-key.pem -passin pass:$PASSWORD -sha256 -out ca.pem -subj "/C=TR/ST=./L=./O=./CN=$SERVER"

# Generating a server key with 2048-bit security
openssl genrsa -out server-key.pem 2048

# Generating a certificate signing request (CSR) for the the server key with the name of your host.
openssl req -new -key server-key.pem -subj "/CN=$SERVER"  -out server.csr

# Sign the key with your password for a period of one year
# i.e. generating a self-signed certificate for the key
openssl x509 -req -days 365 -in server.csr -CA ca.pem -CAkey ca-key.pem -passin "pass:$PASSWORD" -CAcreateserial -out server-cert.pem

# For client authentication, create a client key and certificate signing request
# Generate a client key with 2048-bit security
openssl genrsa -out key.pem 2048
# Process the key as a client key.
openssl req -subj '/CN=client' -new -key key.pem -out client.csr

# To make the key suitable for client authentication, create an extensions config file:
sh -c 'echo "extendedKeyUsage = clientAuth" > extfile.cnf'

# Sign the (public) key with your password for a period of one year
openssl x509 -req -days 365 -in client.csr -CA ca.pem -CAkey ca-key.pem -passin "pass:$PASSWORD" -CAcreateserial -out cert.pem -extfile extfile.cnf

echo "Removing unnecessary files i.e. client.csr extfile.cnf server.csr"
rm ca.srl client.csr extfile.cnf server.csr

echo "Changing the permissions to readonly by root for the server files."
# To make them only readable by you:
chmod 0400 ca-key.pem key.pem server-key.pem

echo "Changing the permissions of the client files to read-only by everyone"
# Certificates can be world-readable, but you might want to remove write access to prevent accidental damage
# these are all x509 certificates aka public key certificates
# X.509 certificates are used in many Internet protocols, including TLS/SSL, which is the basis for HTTPS.
chmod 0444 ca.pem server-cert.pem cert.pem
```

2. Replace line in `/usr/lib/systemd/system/docker.service`:

```toml
ExecStart=/usr/bin/dockerd --tlsverify --tlscacert=/usr/share/portainerTLS/ca.pem --tlscert=/usr/share/portainerTLS/server-cert.pem --tlskey=/usr/share/portainerTLS/server-key.pem -H fd:// -H=tcp://0.0.0.0:2375 $OPTIONS $DOCKER_STORAGE_OPTIONS $DOCKER_ADD_RUNTIMES
```

```sh
restart docker.service
```

3. Add cert and key file in client (Portainer).
