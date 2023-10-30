### Switching user to see systemd container units
```sh
export XDG_RUNTIME_DIR=/run/user/$(id -u)
systemctl --user
# all commands must be run with --user switch
``` 