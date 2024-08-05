# SNMP - Simple Network Management Protocol

Ports 161 and 162 UDP.

Modes:

- polling - server asks (at regular intervals) device about specific parameters.
- traps - device sends snmp trap (alert) to the monitoring server

SNMP is able to change device settings (in rw mode).

### Versions

- SNMPv1
- SNMPv2c - works with communities like v1
- SNMPv3 - uses users instead communities, optional authentication and encryption

### Management Information Base (MIB)

`OID` - Object Identifier. Address of each individual element of information, hierarchial, dotted decimal number.

OID have names, eg. hostname: 1.3.6.1.2.1.1.5.0 = system.sysName.0

`community string` -password needed to access information.\
public - for read only information\
private - for read-write

```bash
/etc/snmp/snmp.conf

rocommunity [PASSWORD] # read only
rwcommunity [PASSWORD] # read write
```

### snmpwalk

Application for viewing snmp communicates

```bash
snmpwalk -v2c -c [COMMUNITY_STRING] [HOSTNAME/IP] [OID]
# -c - community string
# -v version

```

### Packages

- net-snmp -server (snmpd)
- net-snmp-utils -utilities for performing queries and making changes

```bash
/etc/snmp/snmpd.conf

com2sec notConfigUser default public
#change to:
com2sec notConfigUser default [PASSWORD]

agentaddress 127.0.0.1 #interface to listen
agentaddress udp:161 # listen on udp 161 on all interfaces

```

### Commands

smnpget localhost -v 2c -c [PASSWORD] sysName.0
snmpwalk localhost -v 2c -c [PASSWORD] system
