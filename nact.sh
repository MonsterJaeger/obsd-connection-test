#!/bin/sh

# set -x

# get vlan
vlan=$1

# check for vlan, if empty set 11
if [ "X"$vlan == "X" ]; then vlan="11"; else vlan=$1; fi

# get zone and cidr netmask
## XXX: fix fixed zone and cidr
nsz="ts"  # NSZ
cidr="/24"  # netmask

# get dns info from resolv.conf
## DHCP or config required
ns=$(grep nameserver /etc/resolv.conf | awk -F " " '{print $2}')  # nameserver
psd=$(grep search /etc/resolv.conf | awk -F " " '{print $2}')  # primary search domain

# debug print
# echo "vlan="$vlan
# echo "nameserver="$ns
# echo "primary search domain="$psd
# echo "zone="$nsz

# host specific part - test interfaces
## management via em0
t1if="em1"
t2if="em2"

# set test ifs up
ifconfig $t1if up > /dev/null
ifconfig $t2if up > /dev/null

# set test vrds
## vrd 0 == host management
t1rd="1"
t2rd="2"

# get IPs from DNS server
## must be configured in zone
## must be in specific form [gw|t1|t2]-[$zone]-[$vlanid].zone.tld
## example: t1-ts-11.test.local
gateway=$(dig +short @$ns gw-$nsz-$vlan.$psd)
test1=$(dig +short @$ns t1-$nsz-$vlan.$psd)
test2=$(dig +short @$ns t2-$nsz-$vlan.$psd)

# get netmask from TXT record
## XXX: TODO
## netmask=$(dig +short -t txt @$ns | grep netmask | awk -F "=" '{print $2}')
## example MS of google.com
netmask=$(dig +short -t txt google.com | grep MS | awk -F "=" '{print $2}')

# debug print
# echo "gateway ip="$gateway
# echo "test ip1="$test1
# echo "test ip2="$test2
# echo "netmask="$netmask

# configure test1 interface
ifconfig vlan1$vlan destroy > /dev/null 2>&1
ifconfig vlan1$vlan create
ifconfig vlan1$vlan parent $t1if vnetid $vlan rdomain $t1rd
ifconfig vlan1$vlan $test1$cidr
ifconfig vlan1$vlan up
# ifconfig vlan1$vlan

# configure test2 interface
ifconfig vlan2$vlan destroy > /dev/null 2>&1
ifconfig vlan2$vlan create
ifconfig vlan2$vlan parent $t2if vnetid $vlan rdomain $t2rd
ifconfig vlan2$vlan $test2$cidr
ifconfig vlan2$vlan up
# ifconfig vlan2$vlan

# ping waittime
waittime="1"

# ping tests
## ping test2 ip from test1 vrd
ping -V $t1rd -c 1 -w $waittime $test2 > /dev/null 2>&1
result1=$?
## ping gw from test1 vrd
ping -V $t1rd -c 1 -w $waittime $gateway > /dev/null 2>&1
resultgw1=$?
## ping test1 ip from test2 vrd
ping -V $t2rd -c 1 -w $waittime $test1 > /dev/null 2>&1
result2=$?
## ping gw from test2 vrd
ping -V $t2rd -c 1 -w $waittime $gateway > /dev/null 2>&1
resultgw2=$?

# destroy vlans (optional)
# ifconfig vlan1$vlan destroy > /dev/null 2>&1
# ifconfig vlan2$vlan destroy > /dev/null 2>&1

# print results
echo -n "result1="$result1
echo -n ", "
echo -n "resultgw1="$resultgw1
echo -n ", "
echo -n "result2="$result2
echo -n ", "
echo -n "resultgw2="$resultgw2
echo
