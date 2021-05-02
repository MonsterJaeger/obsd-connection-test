#!/bin/sh

# destroys alle vlan interfaces configured

for i in $(ifconfig vlan | grep -e "^vlan" | awk -F ":" '{print $1}'); do ifconfig $i destroy; done
