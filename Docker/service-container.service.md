# Container as Linux service

Container must have `--restart always` flag.

## Local service

`/etc/systemd/system/myservicecontainer.service`:

```toml
[Unit]
Description=My first container as a service
After=docker.service
Wants=network-online.target docker.socket
Requires=docker.socket

[Service]
Restart=Always
ExecStart=/usr/bin/docker start -a my_ubuntu
ExecStop=/usr/bin/docker stop -t 10 my_ubuntu

[Install]
WantedBy=multi-user.target
```

```sh
systemctl start myservicecontainer.service
systemctl enable myservicecontainer.service
```

## Remote docker service in Ubuntu

### Create `daemon.json` file in `/etc/docker`

```json
{ "hosts": ["tcp://0.0.0.0:2375", "unix:///var/run/docker.sock"] }
```

### Add `/etc/systemd/system/docker.service.d/override.conf`:

```toml
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd
```

### Reload the systemd daemon

```sh
systemctl daemon-reload
```

### Restart docker

```sh
systemctl restart docker.service
sudo ss -tulpn
```

### Connection to other host

```
docker -H tcp://[IP]:2375 ps
```

### Add cert connection (Amazon Linux):

Edit `/usr/lib/systemd/system/docker.service`:

```toml
# change:
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock $OPTIONS $DOCKER_STORAGE_OPTIONS $DOCKER_ADD_RUNTIMES

#to:
ExecStart=/usr/bin/dockerd -H fd:// -H=tcp://0.0.0.0:2375 $OPTIONS $DOCKER_STORAGE_OPTIONS $DOCKER_ADD_RUNTIMES
```

### Restart service

```sh
sudo systemctl daemon-reload
sudo systemctl restart docker.service
```
