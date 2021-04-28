#!/bin/sh

# delete all vlan ifs
# for i in $(ifconfig vlan | grep -e "^vlan" | awk -F ":" '{print $1}'); do ifconfig $i destroy; done

# get vlan and zone and cidr
vlan=$1  # VLAN
nsz="ts"  # NSZ
cidr="/24"

# get dns info from resolv.conf (DHCP or configrequired)
ns=$(grep nameserver /etc/resolv.conf | awk -F " " '{print $2}')  # nameserver
psd=$(grep search /etc/resolv.conf | awk -F " " '{print $2}')  # primary search domain

# debug print
# echo "vlan="$vlan
# echo "nameserver="$ns
# echo "psd="$psd
# echo "nsz="$nsz

# host specific
mgmtif="em0"
t1if="em1"
t2if="em2"

# set test ifs up
ifconfig $t1if up > /dev/null
ifconfig $t2if up > /dev/null

# set test vrds
t1rd="1"
t2rd="2"

# get IPs from dns
gateway=$(dig +short @$ns gw-$nsz-$vlan.$psd)
test1=$(dig +short @$ns t1-$nsz-$vlan.$psd)
test2=$(dig +short @$ns t2-$nsz-$vlan.$psd)

# get netmask from TXT record
# netmask=$(dig +short -t txt @$ns | grep netmask | awk -F "=" '{print $2}')
# example MS of google.com
netmask=$(dig +short -t txt google.com | grep MS | awk -F "=" '{print $2}')

# debug print
# echo "gateway="$gateway
# echo "test1="$test1
# echo "test2="$test2
# echo $netmask

# configure test1
ifconfig vlan1$vlan destroy > /dev/null 2>&1
ifconfig vlan1$vlan create
ifconfig vlan1$vlan parent $t1if vnetid $vlan rdomain $t1rd
ifconfig vlan1$vlan $test1$cidr
ifconfig vlan1$vlan up
# ifconfig vlan1$vlan

# configure test2
ifconfig vlan2$vlan destroy > /dev/null 2>&1
ifconfig vlan2$vlan create
ifconfig vlan2$vlan parent $t2if vnetid $vlan rdomain $t2rd
ifconfig vlan2$vlan $test2$cidr
ifconfig vlan2$vlan up
# ifconfig vlan2$vlan

# exit

waittime="1"

# ping test2 from test1
ping -V $t1rd -c 1 -w $waittime $test2 > /dev/null 2>&1
result1=$?
# ping gw from test1
ping -V $t1rd -c 1 -w $waittime $gateway > /dev/null 2>&1
resultgw1=$?
# ping test1 from test2
ping -V $t2rd -c 1 -w $waittime $test1 > /dev/null 2>&1
result2=$?
# ping gw from test2
ping -V $t2rd -c 1 -w $waittime $gateway > /dev/null 2>&1
resultgw2=$?

ifconfig vlan1$vlan destroy > /dev/null 2>&1
ifconfig vlan2$vlan destroy > /dev/null 2>&1

echo -n "result1="$result1
echo -n ", "
echo -n "resultgw1="$resultgw1
echo -n ", "
echo -n "result2="$result2
echo -n ", "
echo -n "resultgw2="$resultgw2
echo

# return "result1=""$result1, "result2="$result2, "resultgw1="$resultgw1, "resultgw2="$resultgw2
