#!/bin/bash
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation/ either version 3 of the License/ or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful/
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not/ see <http://www.gnu.org/licenses/>.
#
# Copyright 2012-2014 Daniel Ehlers
#
if [ "$1" == "--help" ]; then
  cat $(dirname $0)/README.md
  exit 0
fi

VERBOSE="FALSE"
if [ "$1" == "-v" ]; then
  VERBOSE="TRUE"
  echo verbose mode $VERBOSE
fi

# Interface which should be used for pinging a remote host
#define your interface here/ for example: eth0/ wlan0 or br-freifunk (default auto)
INTERFACE=auto
#INTERFACE=wlp1s0
#INTERFACE=enx00e04c681b58

# routing table which should be used to setup rules
ROUTING_TABLE=100
# the number which should be used for marking packets
FWMARK=100

# the host we like to ping/ ip addr
TARGET_HOST=217.70.197.62

COMMUNITY_TLD=ffnord

# Detect Top Level Domain of your community
echo -n "automatic tld detection."
for tld in ffki ffhh fffl ffnord fmdk ffe; do
  echo -n "."
  dig $tld|grep -q NOERROR
  if [ "$?" == "0" ]; then
    COMMUNITY_TLD=$tld
    break
  fi
done

echo " $COMMUNITY_TLD"

# the dns record we like to receive
TARGET_DNS_RECORD=www.google.de

declare -A GWLIST

if [ $COMMUNITY_TLD = ffhh ]; then # Hamburg
    # List of gateways to test
    GWLIST="\
gw01/10.112.1.11/2a03:2267::202
gw02/10.112.42.1/2a03:2267::201
gw03/10.112.1.3/2a03:2267::301
gw05/10.112.1.5/2a03:2267::d01
gw08/10.112.1.8/2a03:2267::b01
gw09/10.112.1.9/2a03:2267::901
gw12/10.112.1.12/2a03:2267::501"
    #more GATEWAYS: 10.112.1.3 10.112.1.9 10.112.1.12
    TARGET_DNS_COMMUNITY_TLD_RECORD=gw01.$COMMUNITY_TLD
elif [ $COMMUNITY_TLD = fmdk ]; then #Freemesh Denmark:
    # List of gateways to test
    # name/ip/ip6
    GWLIST="\
vpn0/10.212.0.1/fd35:f308:a922::ff00"
    TARGET_DNS_COMMUNITY_TLD_RECORD=gw0.$COMMUNITY_TLD
    # external 136.243.214.222
elif [ $COMMUNITY_TLD = ffki ]; then #Kiel: 
    # List of gateways to test
    # name/ip/ip6
#vpn0/10.116.160.1/fda1:384a:74de:4242::ff00
    GWLIST="\
vpn1/10.116.136.1/fda1:384a:74de:4242::ff01
vpn2/10.116.168.1/fda1:384a:74de:4242::ff02
vpn3/10.116.144.1/fda1:384a:74de:4242::ff03
vpn5/10.116.176.1/fda1:384a:74de:4242::ff05
vpn6/10.116.184.1/fda1:384a:74de:4242::ff06
vpn7/10.116.192.1/fda1:384a:74de:4242::ff07"
    TARGET_DNS_COMMUNITY_TLD_RECORD=vpn0.$COMMUNITY_TLD
#vpn4/10.116.152.1/fda1:384a:74de:4242::ff04"
elif [ $COMMUNITY_TLD = fffl ]; then #Flensburg:
    GWLIST="\
snowden.mesh/10.129.1.1/fddf:bf7:10:1:1::1
gw01/10.129.1.5/fddf:bf7:10:1:1::5
gw02/10.129.1.2/fddf:bf7:10:1:1::2"
    TARGET_DNS_COMMUNITY_TLD_RECORD=gw02.$COMMUNITY_TLD
#vpn4/10.116.152.1/fda1:384a:74de:4242::ff04"
elif [ $COMMUNITY_TLD = ffki_external ]; then #Kiel: 
    # List of gateways to test
    # name/ip/ip6
    GWLIST="\
vpn0/89.27.152.8/fda1:384a:74de:4242::ff00
vpn1/176.9.100.90/fda1:384a:74de:4242::ff01
vpn2/176.9.128.83/fda1:384a:74de:4242::ff02
vpn4/213.239.220.106/fda1:384a:74de:4242::ff03"
    TARGET_DNS_COMMUNITY_TLD_RECORD=none
elif [ $COMMUNITY_TLD = open ]; then # Open gateways for development: 
    # List of gateways to test
     GWLIST="\
google/8.8.8.8/2001:4860:4860::8888
High Kiez/144.76.203.42/2001:4860:4860::8888"
    TARGET_DNS_COMMUNITY_TLD_RECORD=none
elif [ $COMMUNITY_TLD = ffe ]; then # Essen
    # List of gateways to test
    GWLIST="\
gw01/10.228.8.1/2a03:2267::202
gw02/10.228.16.1/2a03:2267::201
gw03/10.228.24.1/2a03:2267::201
gw04/10.228.32.1/2a03:2267::b01"
    TARGET_DNS_COMMUNITY_TLD_RECORD=gw01.$COMMUNITY_TLD
elif [ $COMMUNITY_TLD = ffnord ]; then # Freifunk Nord
    # List of gateways to test
    GWLIST="\
vpn0/10.187.160.1/2a03:2267:4e6f:7264::fd00
vpn1/10.187.150.1/2a03:2267:4e6f:7264::fd01
vpn2/10.187.136.1/2a03:2267:4e6f:7264::fd02
vpn3/10.187.170.1/2a03:2267:4e6f:7264::fd03
vpn4/10.187.180.1/2a03:2267:4e6f:7264::fd04
vpn5/10.187.190.1/2a03:2267:4e6f:7264::fd05
vpn6/10.187.200.1/2a03:2267:4e6f:7264::fd06
vpn7/10.187.210.1/2a03:2267:4e6f:7264::fd07
vpn8/10.187.220.1/2a03:2267:4e6f:7264::fd08
vpn9/10.187.230.1/2a03:2267:4e6f:7264::fd09
vpn10/10.187.240.1/2a03:2267:4e6f:7264::fd10
vpn11/10.187.249.1/2a03:2267:4e6f:7264::fd11
vpn12/10.187.100.1/2a03:2267:4e6f:7264::fd12
vpn13/10.187.110.1/2a03:2267:4e6f:7264::fd13
vpn14/10.187.120.1/2a03:2267:4e6f:7264::fd14
vpn15/10.187.140.1/2a03:2267:4e6f:7264::fd15"
    TARGET_DNS_COMMUNITY_TLD_RECORD=vpn0.$COMMUNITY_TLD
fi

if [ $INTERFACE = "auto" ]; then
  INTERFACE=$(ip r | grep default | cut -d ' ' -f 5)
  if [ "$INTERFACE" = "auto"  -o "$INTERFACE" = "" ]; then 
      echo "'INTERFACE=auto' cannot be resolved, wlp1s0 chosen"
      INTERFACE=wlp1s0
  fi
fi
echo Using interface $INTERFACE for testing community $COMMUNITY_TLD

if [ "$VERBOSE" == "TRUE" ]; then
  set -x
fi

: "###Check if rp_filter is activated"
if [ ! "$(cat /proc/sys/net/ipv4/conf/$INTERFACE/rp_filter)" = "0" ]; then
  echo ERROR: Please deactivate rp_filter on device $INTERFACE with:
  if [[ $EUID -ne 0 ]]; then echo -n "sudo "; fi
  echo sysctl -w net.ipv4.conf.$INTERFACE.rp_filter=0
  exit 2
fi

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

clean_up() {
  ip route flush table ${ROUTING_TABLE}
  ip rule del fwmark ${FWMARK} table ${ROUTING_TABLE}
  exit
}

: "### Be sure we clean up"
trap clean_up SIGINT

ip rule add fwmark ${FWMARK} table ${ROUTING_TABLE}

: "### show default route"
echo -n "using gateway route: "
ip r | grep default

GATEWAY_SOA=()

cat <<< "$GWLIST" | while IFS=/ read name gw gw_ip6; do
  : "### clean routing table"
  ip route flush table ${ROUTING_TABLE}
  : "### setup routing table"
  ip route add 0.0.0.0/1 via $gw table ${ROUTING_TABLE}
  ip route add 128.0.0.0/1 via $gw table ${ROUTING_TABLE}
  ip route replace unreachable default table ${ROUTING_TABLE}
   
  echo -n "Testing $name ($gw $gw_ip6) ."

  : "###### Gateway reachability"
  # -m mark         use mark to tag the packets going out
  # -I interface    interface is either an address or an interface name
  # -W timeout      Time to wait for a response in seconds
  # -s packetsize   Specifies the number of data bytes to be sent.  The default is 56
  if ping6 -c 2 -i .2 -W 2 -q $gw_ip6 > /dev/null 2>&1; then
    echo -n "."
  else
    echo " Failed - IPv6 unreachable"
    continue
  fi
  
  if ping -c 2 -i .2 -W 2 -q $gw > /dev/null 2>&1; then
    echo -n "."
  else
    echo " Failed - IPv4 unreachable"
    continue
  fi


  : "###### Gateway functionality ping"
  if ping -m 100 -I ${INTERFACE} -c 2  -i .2 -W 2 -q $TARGET_HOST > /dev/null 2>&1; then
    echo -n "."
  else
    echo " ping throught the gateway FAILED"
    continue
  fi

  : "###### DHCP test"
  if dhcping -q -i -s "$gw"; then
    echo -n "."
  else
    echo " dhcp request test FAILED"
    continue
  fi

  : "###### Nameserver test"
  if nslookup ${TARGET_DNS_RECORD} ${gw} > /dev/null 2>&1 ; then
    echo -n "."
  else
    echo " cannot resolve domain via gateway FAILED"
    continue
  fi

  : "###### Nameserver test (own domain)"
  if nslookup ${TARGET_DNS_COMMUNITY_TLD_RECORD} ${gw} > /dev/null 2>&1 ; then
    echo -n "."
  else
    echo " cannot resolve ${COMMUNITY_TLD} domain via gateway FAILED"
    continue
  fi

  : "###### Nameserver SOA Record"
  GATEWAY_SOA+=($(dig "@${gw}" ${COMMUNITY_TLD} SOA))
  echo -n "."

  echo " Success"
done

if [ "$VERBOSE" == "TRUE" ]; then
  set +x
fi

: "###### ping with differing packagesizes"
cat <<< "$GWLIST" | while IFS=/ read name gw gw_ip6; do
  
  # clean routing table
  ip route flush table ${ROUTING_TABLE}
  # setup routing table
  ip route add 0.0.0.0/1 via $gw table ${ROUTING_TABLE}
  ip route add 128.0.0.0/1 via $gw table ${ROUTING_TABLE}
  ip route replace unreachable default table ${ROUTING_TABLE}
  
  #### Gateway reachability
  echo
  echo -n "reachability ping Test $name $gw ."
  LAST=0
  for i in {50..100..10} {100..1000..100} {1000..1350..10} {1350..1400..1} {1400..1450..10} {1450..1500..1}; do
    if ssh ping -c 4 -i .01 -W 2 -q $gw > /dev/null 2>&1; then
      if [ $LAST -eq 1 ]; then
        echo " until $i"
        LAST=0
      fi
      echo -n "."
    else
      if [ $LAST -eq 0 ]; then
        echo
        echo -n " no ping from packagesize $i"
        LAST=1
      fi
      #continue 2
    fi
    trap "echo; exit;" SIGINT SIGTERM
  done
  
  #### Gateway functionality ping
  if [ ! $TARGET_DNS_COMMUNITY_TLD_RECORD = "none" ]; then
      echo
      echo -n "functionality ping Test $name $gw ."
      LAST=0
      for i in {50..100..10} {100..1000..100} {1000..1350..10} {1350..1400..1} {1400..1450..10} {1450..1500..1}; do
        if ping -m 100 -I ${INTERFACE} -c 4 -i .01 -W 2 -q $TARGET_HOST > /dev/null 2>&1; then
         if [ $LAST -eq 1 ]; then
            echo " until $i"
            LAST=0
          fi
          echo -n "."
        else
          if [ $LAST -eq 0 ]; then
            echo
            echo -n " no ping throught the gateway from packagesize $i"
            LAST=1
          fi
          #continue 2
        fi
        trap "echo; exit;" SIGINT SIGTERM
      done
  fi
done

echo

#### Compare SOA records
echo "SOA records"
IFS=$'\n'
UNIQ_SOA=$(echo -n "${GATEWAY_SOA[*]}" | sort | uniq)
if [ ${#UNIQ_SOA[@]} -gt 1 ] ; then
  echo "WARN: none unique SOA record"
fi

echo done/ cleaning up...
clean_up
echo done
