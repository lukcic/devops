# Unifi SSH Commands
We are going to start with the most commonly used Unifi SSH Commands, later on, I will organize them by device or function.

Command	Example	Function
info	info	Displays device information
set-default	set-default	Factory reset device
set-inform	set-inform http://192.168.1.1:8080/inform	Set URL of the controller for adoption. More info
upgrade	upgrade https://<firmware-url>.bin	Upgrade firmware – More info
fwupdate	fwupdate --url https://<firmware-url>.bin	Update firmware
reboot	reboot	Reboot the device
poweroff	poweroff	Shutdown device
uptime	uptime	Shows device uptime
Unifi SSH Commands
Network related SSH Commands
The following Unifi SSh Commands can really help you with finding network-related issues with your Unifi Device.

Command	Example	Function
ifconfig	ifconfig	Show network interface information
ip address add	ip address add 192.168.1.143/24 dev br0	Set static IP Address
ip route	ip route	Display current gateway
ip router add	ip route add default via 192.168.1.1	Set default gateway
echo "nameserver 192.168.1.1" > /etc/resolv.conf	Set DNS Server
ping	ping 1.1.1.1	Check network connection to device
arp	arp -a	Show arp table
ip neigh	ip neigh	Show IPv6 neighbors
Unifi OS SSH Commands
When you connect to your UDM Pro (or another controller that is running Unifi OS), then you will have a couple of other options:

Command	Example	Function
ubnt-systool help	ubnt-systool help	Show all commands
ubnt-systool cputemp	ubnt-systool cputemp	Show CPU Temp
ubnt-systool cpuload	ubnt-systool cpuload	Show CPU load
ubnt-systool portstatus	ubnt-systool portstatus	Show port status
ubnt-systool hostname	ubnt-systool hostname <newname>	Set new hostname
ubnt-systool reboot	ubnt-systool reboot	Reboot device
ubnt-systool poweroff	ubnt-systool poweroff	Shutdown device
ubnt-systool reset2defaults	ubnt-systool reset2defaults	Factory reset device
ubnt-device-info summary	ubnt-device-info summary	Show system information
ubnt-tools ubnt-discover	ubnt-tools ubnt-discover	Show Unifi devices in the network
cat /mnt/data/udapi-config/dnsmasq.lease	cat /mnt/data/udapi-config/dnsmasq.lease	Show DHCP Leases
cat /mnt/data/udapi-config/unifi	cat /mnt/data/udapi-config/unifi	Show configuration
/etc/init.d/S95unifios restart	/etc/init.d/S95unifios restart	Restart Unifi OS Web interface
Unifi Log files
There are a lot of log files that you can access to help you debug any Unifi related problem:

Command	Function
cat /var/log/messages	Output the error log
tail -f /var/log/messages	Monitor log file
cat /mnt/data/unifi-os/unifi-core/config/settings.yaml	Server settings
cat /mnt/data/unifi-os/unifi-core/logs/discovery.log	Discovery log
cat /mnt/data/unifi-os/unifi-core/logs/system.log	System log
cat /mnt/data/unifi-os/unifi/logs/server.log	Server log
cat /mnt/data/unifi-os/unifi-core/logs/errors.log	Http errors