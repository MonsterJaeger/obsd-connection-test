# obsd-connection-test

## nact.sh

Switch/l2 connection test script using an [OpenBSD](https://www.openbsd.org/) host with dynamically created vlan interfaces and rdomains.

Script will configure two [vlan](https://man.openbsd.org/vlan) interfaces on the two interfaces in two different virtual routing domains (VRD) using the VLAN ID provided. IPs fetched from DNS will be used to ping the other IP and a gateway IP. Results will be printed.

usage: call with vlan number
```bash
$ nact.sh 11
result1=0, resultgw1=0, result2=0, resultgw2=0
```

## delete-vlans.sh

delete **ALL** vlan interfaces - useful for cleanup

Caution: If there are other vlan interfaces (i.e. for management) those will be deleted too!

## setup overview 

```bash
switch1 ---interconnect--- switch2
  |                          |
 em1/vrd1              em2/vrd2
 ------------------------------
 | OpenBSD box                |
 ------------------------------
 em0/vrd0
  |
 management
```
