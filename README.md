* This script must be run as root on a mashine that is in freifunk 
* Before the first start, you have to activate the rp_filter with 

        sysctl -w net.ipv4.conf.$INTERFACE.rp_filter=0

# Options

    --help  	show this README.md
    -v			verbose mode

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

# manual test:

    gw=10.116.152.1
    FWMARK=100
    ROUTING_TABLE=100
    ip rule add fwmark ${FWMARK} table ${ROUTING_TABLE}
    ip route add 0.0.0.0/1 via $gw table ${ROUTING_TABLE}
    ip route add 128.0.0.0/1 via $gw table ${ROUTING_TABLE}
    ip route replace unreachable default table ${ROUTING_TABLE}

    ping -m 100 -I wlp1s0 -c 2  -i .2 -W 2 -q 217.70.197.62
    
    #cleanup:
    ip route flush table ${ROUTING_TABLE}
    ip rule del fwmark ${FWMARK} table ${ROUTING_TABLE}
    
