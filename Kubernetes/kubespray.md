## Ansible commands

```sh
# Delete node form cluster
ansible-playbook -i inventory -u root/debian -b ./kubespray/remove-node.yml -e "node=srv3"

# Add node to the cluster
# - add srv4's ip to the inventory file
ansible-playbook -i inventory -u root/debian -b ./kubespray/cluster.yml -l srv4

# Delete cluster
ansible-playbook -i inventory -u root/debian -b ./kubespray/reset.yml
```
