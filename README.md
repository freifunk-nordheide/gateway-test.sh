* This script must be run as root on a mashine that is in freifunk 
* Before the first start, you have to activate the rp_filter with 

        sysctl -w net.ipv4.conf.$INTERFACE.rp_filter=0

# Options

--help  show this README.md

# Configuration

* define a list of gateways to test in the array `DEFAULT_GATEWAYS`
* define your interface which should be used for pinging a remote host for example `br-freifunk` or `wlan0`
* define a dns record you like to receive at `TARGET_DNS_RECORD` and which should resolve in `TARGET_DNS_FFKI_RECORD`

# Tests
    
* test Gateway reachability
* Gateway functionality ping
* Gateway functionality ping6
* DHCP test
* Nameserver test with `nslookup $TARGET_DNS_RECORD`
* Nameserver test for an own domain of the Community
* Check for duplicate Nameserver SOA Record
* test ping in different sizes and show the maximum package size which can be transmitted
