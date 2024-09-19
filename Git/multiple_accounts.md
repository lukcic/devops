# Github Multiple accounts

## Multiple SSH Keys settings for different github account

Modify the ssh config:

```sh
vim ~/.ssh/config
```

add:

```sh
Host github.com-lukcic
 HostName github.com
 User git
 IdentityFile ~/.ssh/id_ed25519.pem
```

Modify repo settings:

```sh
vim .git/config
```

add:

```toml
[remote "origin"]
    url = git@github.com-lukcic:lukcic/terraform-moduels.git
    fetch = +refs/heads/*:refs/remotes/origin/*

[user]
    name = lukcic
    email = lukcic@email.pl
```

Host must be the same as in `$HOME/.ssh/config` file!
And username defined in config must be added to url (after colon)!

Cloning repo from second account:

```toml
GIT_SSH_COMMAND="ssh -i $HOME/.ssh/id_ed25519.pem" git clone git@github.com:lukcic/scripts.git
```

## Using .gitconfig

`$HOME/.gitconfig`

```toml
[user]
    name = Łukasz Cichecki
    email = lukasz.cichecki@work-email.com

[credential]
    username = lukcic-work

[includeIf "gitdir:~/lukcic/projects/"]
    path = ~/lukcic/projects/.gitconfig-lukcic
```

`.gitconfig-lukcic`

```toml
[user]
    name = lukcic
    email = lukcic@mail.pl

[credential]
    username = lukcic

[core]
  sshCommand = "ssh -F /dev/null -i $HOME/.ssh/id_ed25519.pem"
```
