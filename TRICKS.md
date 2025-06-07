

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