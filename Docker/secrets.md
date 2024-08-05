## Listening secrets

```sh
docker secret ls
```

## Creating secrets

```sh
# will use standard input for reading secret value
docker secret create name-of-secret -

# create secret via script
printf "my super secret password" | docker secret create my_secret -

# create secret from a file
docker secret create my_secret ./secret.json
```

## Using secrets in Docker Swarm

```yml
version: '3.7'
services:
  db:
    image: postgres:15.1-alpine
    volumes:
      - pgdata:/var/lib/postgresql/data
    environment:
      - PGUSER=postgres
      - POSTGRES_PASSWORD_FILE=/run/secrets/postgres-passwd
    secrets:
      - postgres-passwd
    healthcheck:
      test: ['CMD-SHELL', 'pg_isready']
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - backend
secrets:
  postgres-passwd:
    external: true
```

```js
databasePassword =
  process.env.POSTGRES_PASSWORD ||
  fs.readFileSync(process.env.POSTGRES_PASSWORD_FILE, 'utf8');
```

## Docs

https://docs.docker.com/reference/cli/docker/secret/
