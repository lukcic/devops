Listening for source or destination IP:

```sh
sudo tcpdump dst 216.239.32.58
sudo tcpdump src 216.239.32.58
```

Listening on destination port

```sh
sudo tcpdump dst port 626 3269
```

Listening on UDP port

```sh
tcpdump -i lo udp port 8125 -vv -X
```

Listening for multicast traffic

```sh
tcpdump -i eth0 ip multicast
tcpdump -c 10 dst host 234.5.5.5 and port 5000 and multicast
```
