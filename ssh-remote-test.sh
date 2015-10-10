#!/bin/bash
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Copyright 2015  Ruben Barkow
#
if [ $1 == "--help" ]; then
  cat $(dirname $0)/README.md
  exit 0
fi

# List of gateways to test
echo                  "VPN0         VPN1         VPN2         VPN4"
#DEFAULT_GATEWAYS=${1:-"10.116.160.1 10.116.136.1 10.116.168.1 10.116.152.1"}
DEFAULT_GATEWAYS=${1:-"vpn0 vpn1 vpn2 vpn4"}
echo $DEFAULT_GATEWAYS
# Interface which should be used for pinging a remote host
#define your interface here, for example:
#INTERFACE=br-freifunk
INTERFACE=wlan0
# routing table which should be used to setup rules

for gateway in $DEFAULT_GATEWAYS; do
	gw="$gateway.freifunk.in-kiel.de"
	set -x
	echo check alfred on $gw
	ssh $gw "service --status-all 2>&1 | egrep '(bird|bird6|openvpn|fastd|alfred|bat|bind|isc-dhcp-server)'"
	ssh $gw "pgrep -lf '(bird|bird6|openvpn|fastd|alfred|bat|bind|dhcp)'"
done

ssh $gw "vnstat -l -i tun-anonvpn"
