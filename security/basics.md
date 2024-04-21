### Ping

ICPM packet size:

```sh
ping -s [SIZE] [IP]
ping -s 1300 192.168.254.254
```

Flood:

```
ping -s [SIZE] [IP] -f
ping -s 1300 192.168.254.254 -f
```

### hping3

Ping to specific destination port. If port is closed it will fail.

```
hping3 -s -V --destport [PORT] [IP]
hping3 -s -V --destport 80 192.168.254.3
```

Traceroute:

```
# with ICPM
sudo hping3 --traceroute -V -1 localadmin.pl
sudo hping3 --traceroute -V -1 [IP/address]

#with port 80 TCP
hping3 --traceroute -V -p 80 -S localadmin.pl
hping3 --traceroute -V -p 80 -S [IP/address]
```

### ptunnel

Send TCP over ICMP packets. Ex. ssh to host with port 22 blocked.

```
ptunnel -p [IP] -lp 8000 -da [IP] -dp 22

```

### iftop

Will show live interface statistics.

```
iftop -i [INTERFACE]
```

### nmap

```
nmap -sL [NETWORK/MASK]
# scan network for DNS names

nmap -A [IP]
# full scan

nmap -f [IP]
# scan with fragmented packets (harder to block)

nmap --source-port 53 [IP]
# scan with source port (pretend to be DNS)

nmap -d RND:10 [NETWORK/MASK]
# scan with decoys - generate different source IPs

nmap -sV [IP]
# service discovery

nmap -O [IP]
# OS detection

nmap -Pn [IP]
# avoid scan blocking

namp --script vuln [IP]
# scan host for vulnerabilities

namp --script malware [IP]
# scan host for malware
```

### masscan

Scan like nmap with multiple simultaneous connections.

```
masscan -p80,443,22 [NETWORK/MASK] --rate=1000
masscan -p0-65535 [NETWORK/MASK] --rate=10000 --randomize-hosts
```

### whois

```
whois [domainname]
```

### whatweb

```
whatweb [domainname]
```

### wpscan

Needs api key for any voulnerabilities scan.

```
wpscan --url [DOMAIN] --random-user-agent --enumerate u
# scan with enumerate users

wpscan --url [DOMAIN] --enumerate p
# scan with enumerate plugins

wpscan --url [DOMAIN] --enumerate vp,vt --plugins-detection aggresive
# scan with enumerate plugins

```

### gobuster

Tool for searching for directories and files on the web-server.

### sublist3r

Subdomain enumeration.

### amass

Subdomain enumeration.

### setuid on bash

Will give user possibility to run bash with root priviledges.

```
sudo chmod +s /bin/bash
bash -p
whoami #root
```
