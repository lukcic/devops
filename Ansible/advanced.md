# Ansible advanced

Check `async` and `pool` in shell module.
`debops` collection - Debian in Enterprise

## Connections to other systems

Device:           Controller:   Node:
Linux             Python        Python
Windows           Python        PowerShell
Network Devices   Python        None! (all actions run locally from controller)

### Connection to Network Devices

- local - ssh, new connection for every task, old method
- network_cli - ssh, persistant connection, new method
- netconf - like network_cli, but xml optimised
- httpapi - new, not used yet

`cli_config`, `cli_command` - vendor agnostic modules for network_cli based devices.

## Tricks

### answering command questions (to check)

```yaml
shell: 'yes | command'

```

### tags in non-idempotent modules

Modules like `command` or `shell` don't work with `dry_run`. To allow task running in dry_run add `check_mode: no`.

### List tags without run

```sh
ansible-playbook main.yml --list-tasks
ansible-playbook main.yml --list-tags
```

### omit filter - skip if value not exists

```yml
id: "{{ omit if item.id is not defined else item.id }}"
```
equivalent

```yml
id: "{{ item.id if item.id is defined else ''}}"
```

### variables for different distros

```yml
- include_vars: '{{ item }}'
  with_first_found:
    - "../vars/{{ ansible_distributon }}-{{ ansible_distributon_major_version | int }}.yml"
    - "../vars/{{ ansible_distributon }}.yml"
    - "../vars/{{ ansible_os_family }}.yml"
    - "../vars/package_default.yml"
```

### loop with grep

```yaml
loop: "{{ variable | select('match', '^172\\.16\\.0\\..*') | list }}"

```

### url_split

```yaml
parts: '{{ "http://user:password@www.acme.com:9000/dir/index.html?query=term#fragment" | urlsplit }}'
# =>
#   {
#       "fragment": "fragment",
#       "hostname": "www.acme.com",
#       "netloc": "user:password@www.acme.com:9000",
#       "password": "password",
#       "path": "/dir/index.html",
#       "port": 9000,
#       "query": "query=term",
#       "scheme": "http",
#       "username": "user"
#   }

hostname: '{{ "http://user:password@www.acme.com:9000/dir/index.html?query=term#fragment" | urlsplit("hostname") }}'
# => 'www.acme.com'

query: '{{ "http://user:password@www.acme.com:9000/dir/index.html?query=term#fragment" | urlsplit("query") }}'
# => 'query=term'

path: '{{ "http://user:password@www.acme.com:9000/dir/index.html?query=term#fragment" | urlsplit("path") }}'
# => '/dir/index.html'
```

## Project structure

- environments
  - stage
  - prod
- ansible.cfg
- requirements.yml
- service_app.yml
- service_db.yml

`group-vars` - environment variables for groups, like app version
`host-vars` - definitions how to access hosts from inventory file, like username and ssh key location

### Roles

- role-name
  - README.md
  - defaults (vars that should be overridden by site like versions, default credentials etc)
  - handlers
  - meta (dependencies, author info)
  - tasks
    - configure.yml
    - install.yml
    - main.yml
  - templates
  - tests
    - Vagrantfile
    - ansible.cfg
    - inventory.yml
    - main.yml
    - requirements.yml (Ansible Galaxy)
  - vars (vars that shouldn't be overridden)
  - README.md
  - .ansible-lint
  - .yamllint
  - .gitignore
  - LICENSE

### Inventory

#### Dynamic inventory on AWS

https://github.com/ansible/ansible/tree/devel/contrib/inventory

Tags:

Key:		    Value:
Space       AnotherAwesomeProject
Setup 		  dev/stg/prod
Name        Cassandra
Cassandra 	Seed/NonSeed
versions    3.11
Release   	1.3.2
State   		Init/Active/InActive/Terminate

## Not only ansible-playbook

`ansible-core` - Ansible-playbook with only builtin

### EE - execution environments

Ansible in container (with addtional tools like ansible-lint, collections).

### ansible-navigator

TUI (text user interface) tool for Ansible. Commands similar to vi. Interaction with Ansible output. Wrapper to all Ansible commands. By default works with EE.

Running a playbook in Navigator

```sh
ansible-navigator run main.yml
```

--mode stdout|interactive - interactive prodeces artifacts

--ee
--execution-environment true|false

--eei
--execution-environment-image $image-full-path

--pp
--pull-policy always|missing|never|tag

--enable promtps
Prompts won't work in interactive mode, enabling them swithces to std_output mode and disables artifacts creation.

#### Artifacts 

Saved output from run in json format. Can be used with `replay` to review play history. 

```
ansible-navigator --ee=false replay log.json --mode=stdout
```

### ansible-builder

Tool for building EE. By default uses RHEL distributions so, for Debian some changes must be done. 

`execution-environment.yml` - config file for image

- source image
- python version
- ansible-core version
- ansible-runner version
- collections with version tags
- distro pakages
- pip modules
- addtional elements by hooks and additonal_build_steps

```sh
ansible-builder build --file execution-environment.yml
# builds image

ansible-builder create --file execution-environment.yml
# only creates docker/podman file to add changes
```

### ansible-doc

https://www.educba.com/ansible-doc/

```sh
ansible-doc $module_name
ansible-doc uri

ansible-doc -t $type -l
# list specific type docs

ansible-doc -t keyword -l
# lists all keywords

ansoble-doc -t filter -l
# lists all filter

ansible-doc -t keyword when
# details about specific keyword
```

### ansible-runner

Run Ansible automations (playbooks and roles) on remote hosts. CLI and python interface. 

```sh
ansible-runner transmit . -p main.yml | pv | ssh 192.168.1.100 /home/user/.local/bin/ansible-runner worker --private-data-dir /tmp/Ansible/ | ansible-runner process .

```

more details:
https://www.youtube.com/watch?v=C4zg3mSeQEg
https://dariusz.puchalak.net/Ansible/

### ansible-debugger

```yml
- hosts: localhost
  debugger: on_failed, on_skip
  vars:
    var1: value1
  tasks:
    - name: wrong var
      ping: data={{ var2 }}
```

Fail will start debugger mode.

List all variables with values:

```sh
p task_vars
```

Troubleshooting:

```sh
p task.args
task.args['data'] = '{{ var1 }}'
redo
```

### ansible-config

```sh
ansible-config list
# shows all possible config options

ansible-config dump
# compares our config vs defaults
```

`RETRIES_FILES_ENABLED` - generates file with list of failed nodes to re-apply playbook limited to this list

### ansible-galaxy

```sh
ansible-galaxy collection list
# shows all available collections
```

#### requirements.yml

```yml
- name: nginx
  src: git+git@git.example.com:ansible/roles/nginx.git
  version: origin/release1.2.1
```

#### Installation

```sh
ansible-galaxy install --role-file=requirements.yml --roles-path=roles
```
