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
	IdentityFile ~/.ssh/lukcic_id_ed25519.pem
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
	email = lukcic@int.pl
```
Host must be the same as in `~/.ssh/config` file!
And username defined in config must be added to url (after colon)!

Cloning repo from second account:
```sh
GIT_SSH_COMMAND="ssh -i ~/.ssh/lukcic_id_ed25519.pem" git clone git@github.com:lukcic/scripts.git
```