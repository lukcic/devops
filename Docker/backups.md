# Docker data backups

## Application specific

```sh
docker run --name="backups"  --link db:db -v `pwd`/backups:/backups  -d kartoza/pg-backup:$POSTGRES_MAJOR_VERSION-$POSTGIS_MAJOR_VERSION.${POSTGIS_MINOR_RELEASE}
```

## Local backup

```sh
docker volume create --name my-data-backup

docker container run --rm -it \
           -v my-data:/from \
           -v my-data-backup:/to \
           ubuntu bash -c "cd /from ; cp -av . /to"
```

## Upload to S3 with Offen

![Offen docs](https://offen.github.io/docker-volume-backup/reference/)

```sh
docker run --rm \
  -v data:/backup/data \
  --env AWS_ACCESS_KEY_ID="<xxx>" \
  --env AWS_SECRET_ACCESS_KEY="<xxx>" \
  --env AWS_S3_BUCKET_NAME="<xxx>" \
  --entrypoint backup \
  offen/docker-volume-backup:v2
```
