| Alias | Command | Description |
|--|--|--|
| g init | git init | Initialize a local Git repository |
| g clone \<repo\> [\<path\>] | git clone <repo> [\<path\>] | Create a local copy of a remote repository |
| gst | git status | Check status |
| gaa | git add --all | Add all new and changed files to the staging area |
| grh | git reset | Removes all files from staging area |
| ga <file> | git add <file> | Add a file to the staging area |
| gru <file> | git reset -- <file> | Remove a file from staging area |
| gcmsg "<message>" | git commit -m "<message>" | Commit changes with message description |
| gcam "<message>" | git commit -a -m "<message>" | Add all new files and commit changes with message description |
| gsta -m <name> | git stash push -m <name> | Create stash with name |
| gstall -m <name> | git stash --all -m <name> | Create stash with all files, including untracked and ignored files with name |
| gstl | git stash list | List down all your stashes |
| gstaa stash@{n} | git stash apply stash@{n} | To apply a stash and keep it in the stash stack |
| gstp stash@{n} | git stash pop stash@{n} | To apply a stash and remove it from the stash stack |
| gstd | git stash drop | Remove a single stash entry from the list of stash entries |
| gstc | git stash clear | Remove all stashed entries |
| gb | git branch | List branches (the asterisk denotes the current branch) |
| gba | git branch -a | List all branches (local and remote) |
| gb <branch-name> | git branch <branch-name> | Create new branch |
| gbd <branch-name> | git branch -d <branch-name> | Delete a branch |
| gcb <branch-name> | git checkout -b <branch-name> | Create a new branch and switch to it |
| gco <branch-name> | git checkout <branch-name> | Switch to a branch |
| gco - | git checkout - | Switch to previous branch |
| gra origin <path> | git remote add origin <path> | Add a remote repository |
| grset origin <path> | git remote set-url origin <path> | Set remote repository |
| gf | git fetch | Gets status of 'origin'. Does not change your working directory or local repository |
| gf <repo> <branch-name> | git fetch <repo> <branch-name> | Get status of remote on |
| gfa | git fetch --all --prune | Fetch all remote branches, delete branch if upstream is gone |
| gl | git pull | Incorporates changes from 'origin' into local repo |
| gl <repo> <branch-name> | git pull <repo> <branch-name> | Incorporates changes from remote on into local repo |
| gp | git push | Incorporates changes from local repo into 'origin' |
| gpsup | git push --set-upstream origin <currentbranch> | Set upstream current branch |
| gp <repo> <branch-name> | git push <repo> <branch> | Incorporates changes from local repo into remote on |
| gp -d <remote> <branch> | git push -d <remote> <branch> | Delete remote branch |
| gd <source-branch> <target-branch> | git diff <source-branch> <target-branch> | Preview changes before merging |
| gm <branch-name> | git merge <branch-name> | Merge a branch into the active branch |
| gm <source-branch> <target-branch> | git merge <source-branch> <target-branch> | Merge a branch into a target branch |
| gma | git merge --abort | Cancel the whole merge process |
| glog | git log --oneline --decorate --graph | View changes |
| gc! | git commit -v --amend | I need to change the message on my last commit |
| gcn! | git commit -v --no-edit --amend | I committed and immediately realized I need to make one small change. |
