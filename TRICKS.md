# tricks

## git

```sh
git commit --amend --no-edit # amend without message
git clean -df  # clean repository from untracked files
```

## curl

```sh
# Override DNS entries
curl --resolve "www.example.com:80:172.0.0.1" -i https://example.com
```

## nginx

```sh
nginx -t            # check config
nginx -s reload     # reload config without restarting the service
```

## ssh

### jumphost

```sh
ssh -J username@public_ip username@private_ip
```

## postgres

```sh
sudo -u postgres psql
```

```sql
CREATE DATABASE name;
CREATE USER username WITH PASSWOD 'mypassword';
ALTER DATABASE database OWNER TO username;
\connect database;
GRANT CREATE ON SCHEMA public TO username;
\q
```

## redis

```sh
apt install -y redis-server
redis-cli ping
```