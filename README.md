# obsd-connection-test

## nact.sh

switch/l2 connection test script using an [OpenBSD](https://www.openbsd.org/) host with dynamically created vlan interfaces and rdomains

## delete-vlans.sh

delete **ALL** vlan interfaces

## setup

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
