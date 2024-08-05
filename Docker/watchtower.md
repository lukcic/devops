# Watchtower

Docker container which updates all other containers to the new versions. Works in schedule.

Watchtower updates only containers with tag `latest`. Will not change containers with specific version on container with that has label `watchtower.enable=false`.

## Installation

```sh
docker run -d --name watchtower -v /var/run/docker.sock:/var/run.docker.sock containerrr/watchtower [PARAMS]
--run-once # running once (without scheduler)
--debug
--cleanup # will delete old (unused) docker images
--schedule "cronexpression" # 6 digit, "0 30 4 \* \* \*" -30 min, 4hour, everyday, everyweek, every month

docker run --name=watchtower -d -v /var/run/docker.sock:/var/run/docker.sock --restart=always containrrr/watchtower --cleanup --schedule "_ 30 4 _ \* \*"

```

## Running container excluded from updating:

```sh
docker run --name=nginx --label=com.centurylinklabs.watchtower.enable=false -d ninx
```
