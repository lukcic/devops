# GIT

```sh
* git commit -am

git commit -p?
partial add

* git commit --amend -m "New commit message" 
# update commit message from last commit

git commit --amend --no-edit
@ update last commit without changing commit message

git push origin master --force
@ update remote repo with state of your local repo - will overwrite someones changes

.git/hooks
# directory to save hooks, code that will run on some git events happen, ex: validate/lint code before commit

# Override local code with remote code:
git fetch origin
git reset --hard origin/master

git clean -df
# swill clean repository from untracked files
```

## Tagi

Oznaczenie commitu, wskazujące na ukończenie wersji aplikacji.

https://semver.org


```sh
git tag
# listuje tagi

git tag v1.0
# dodaje nowy tag do bieżącego commitu
# -d usuwa tag lokalnie, do zdalnych dodać origin
# -a dodaje autora
# -m dodaje komentarz

git tag v1.1 [commit-hash]
# dodaje tag do wskazanego commitu

git show v1.0
# wyświetla info na temat commitu o danym tagu

git push --tags
# pushuje tagi do zdalnego repo
```

`Release` - może być utworzony na podstawie tagu (dodatkowe pliki mogą być dołączone do wydania).

`REFLOG` - wyświetla w jaki sposób zmieniała się pozycja wskaźnika HEAD.

`GIT RESET` - do pracy na lokalnym repo

## Usunięcie ostatniego commitu

- kopiujemy PRZEDostatni commit hash i robimy reset
```sh
git reset [PRZEDostatni-commit]
```
> zmiany z usuniętego commitu trafią do katalogu roboczego (untracked)

`--hard` - usuwa commit i zmiany

**Do pracy na zdalnym tylko GIT REVERT!**

> Tworzy nowy commit odwracający zmiany z revertowanego commita.

## rebase 

Proces zmiany commitu na podstawie którego został utworzony dany branch. Commity zostają usunięte, ale ich zawartość zostaje kopiowana do nowych (z noymi ID). Kopiowanie odbywa sie w taki sposób, żeby zmiany skopiowane na branchu zawierały zmiany z późniejszych commitów mastera. 

Na gałęzi feature:
```sh
git rebase master 
```

Potem na gałęzi master:

```sh
git checkout master
git merge feature
```

Dokonuje łączenie zmian w trybie FastForward (nie został żaden dodatkowy commit) - merge przesuwa HEAD na najnowszy commit. 

W przypadku wystąpienia konfliktu, rozwiązać, zapisać plik, dodać go do indexu, potem:

```sh
git rebase --continue

git rebase --skip
# pomininęcie commitu, który stwarza problem

git reabse --abort
# anulowanie polecenia rebase

git rebase master -i
# przeprowadzenie rebase w trybie interaktywnym
```
