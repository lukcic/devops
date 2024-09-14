## Multiple SSH Keys settings for different github account

Modify the ssh config:

```sh
vim ~/.ssh/config
```

add:

```
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

```
[remote "origin"]
	url = git@github.com-lukcic:lukcic/terraform-moduels.git
	fetch = +refs/heads/*:refs/remotes/origin/*

[user]
	name = lukcic
	email = lukcic@email.pl
```

Host must be the same as in `~/.ssh/config` file!
And username defined in config must be added to url (after colon)!

Cloning repo from second account:

```sh
GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519.pem" git clone git@github.com:lukcic/scripts.git
```

# Using .gitconfig

`~/.gitconfig`

```toml
[includeIf "gitdir:~/lukcic/projects/"]
    path = ~/lukcic/projects/.gitconfig-lukcic

[includeIf "gitdir:~/projects/"]
    path = ~/projects/.gitconfig-work

[filter "lfs"]
	clean = git-lfs clean -- %f
	smudge = git-lfs smudge -- %f
	process = git-lfs filter-process
	required = true
```

`~/projects/.gitconfig-work`

```toml
[user]
	name = Name
	email = company@email.com

[credential]
    username = lukcic-work
```

`.gitconfig-lukcic`

```toml
[user]
	name = lukcic
	email = lukcic@mail.pl

[credential]
    username = lukcic

[core]
  sshCommand = "ssh -F /dev/null -i ~/.ssh/id_ed25519.pem"
```
