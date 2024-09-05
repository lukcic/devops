```sh
git-crypt init
git-crypt export-key git-crypt-key
```

```sh
code .gitattributes
# secret.yml filter=git-crypt diff=git-crypt
git add .gitattributes
git commit -m "gitcrypt"
```

```sh
git-crypt status
git-crypt lock
git-crypt unlock git-crypt-key
```
