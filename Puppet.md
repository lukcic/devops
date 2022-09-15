# Puppet
Puppet manifest files *.pp - declaration of tasks
/etc/puppet/code/manifests

Pupper Server (Master)
Puppet Agent

Run Puppet (standalone agent - without master):\
`puppet apply sample.pp`

### Syntax:
```
type {'title':		# resource type, unique name
	attribute1 => 'value1',
	...
	attributeN => 'avalueN',
}
```

Example:
```
package {'haproxy':
	ensure => latest
}
```
Show resources:\
`puppet resource —-types`

### Requirements between resources:
```
package {'haproxy':
	ensure => $haproxy_version,
}

service {'haproxy':
	ensure => running,
	enable => true,
	require => Package['haproxy']
}
```

 or
```
Package['haproxy']
-> Service['haproxy']
```

### Refreshing service after configuration change:
```
file {'/etc/haproxy/haproxy.cfg': # where to save
	ensure => present,
	source => '/etc/puppet/code/haproxy.cfg', 	# what to save
	notify => Service['haproxy']
}
```

### Templating config files:
```
file {'/etc/haproxy/haproxy.cfg': # where to save
	ensure => present,
	content => template('haproxy/haproxy.cfg.erb')
}
```

### Listing Facts:
`facter -p processors`

`$::facts` - variable that stores server facts

Usage:
```
# Definition
$global_maxconn = (1000 * $::facts['processors']['count'])

# Invocation
maxconn <%= @global_maxconn %>
```

### Modules:
Directory structure:
* modules
	* haproxy
		* files
		* lib
			* facter
		* manifests
		* spec
		* templates

## Classes and definitions
Used to divide manifest.
```
| Type		| Classes 		| Definitions		|
| ————————- | —————————---- | ———————————------	|
| Keyword 	| “class” 		| “define” 		    |
| Instances	|  1 instance 	| many instances	|
| Conflicts	| yes			| no				|
| Examples	| haproxy		| error page		|
|			| Apache server	| Apache vhost	    |
|			| SSH server	| SSH key		    |
```
Class - resource that can be present on host in only 1 instance.
Definition - more than 1 instance of resource on host

### Class

Main manifest in module (filename):\
`modules/haproxy/manifest/init.pp`

```
class haproxy(
	$haproxy_version = '1.8.1-1ubuntu0.3'
) {

	package {'haproxy':
		ensure => $haproxy_version,
	}

	service {'haproxy':
		ensure => running,
		enable => true,
	}

}
```

Usage:\
`class {haproxy: }`

### Definitions

`modules/haproxy/manifest/error_page.pp`:
```
define haproxy::error_page(
	$content,
	$ensure = present,
) {
	file {"/etc/haproxy/errors/${title}"
		ensure => $ensure,
		content => $content,
	}
}
```

Usage:
```
class {haproxy: }

haproxy::error_page {'500':
	content => "500 Failed hardly",
}

haproxy::error_page {'400':
	content => "400 Seems lost",
}

```

### Puppet Forge
Portal where people share their modules (like Ansible Galaxy). Modules are audited by  Puppet Labs (high quality).

### Puppet Server (Master)

Main manifest (site.pp) - always read first:\
`tree /etc/puppet/code`
* manifests
	* site.pp
* modules
	* haproxy

Connecting nodes with classes:
site.pp:
```
node /^puppet-test$/ {
	class {haproxy: }
}

node /^web01.acme$/ {		# regex
	class {nginx: }
}
```

Config of Puppet Agent - Server (Master location):

`/etc/puppet/puppet.conf`:
```
[main]
ssldir = /var/lib/puppet/ssl

[agent]
server = puppetmaster.acme.com

```

Enabling Master mode on node:\
`puppet agent -t`

Authorization:
By HTTPS, while first connection Puppet Agent - Puppet master occurs Agent sends the Certificate Sign Request.

CSR must be signed by CLI if node not exists on Auto Sign list.
Auto Sign List - list of nodes that will be authorized.

### Tips and tricks:
Run crontab every hour in different minute:
```
$cron_minute = fqdn rand(60)
notify {“Cron minute is ${cron_minute}”:}
```

