#!/bin/sh
#
# Keep a count of all data from the device to the WAN
# (vlan2) interface.  To do this, an iptables rule is
# created to count the bytes
#
# Note that the device must have a static IP address
# and should be in variables.sh:devices
#
# You can also pass a space delimited list of hosts
# on the command line
#
# Passing -d as the first argument will delete all
# iptables rules for the given devices

source /opt/freshtomato-grafana/variables.sh

target=ACCEPT
delete=0

# Safety check - ensure we have basic connectivity rules
ensure_basic_rules() {
    # Allow established connections
    iptables -C INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || \
        iptables -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    
    # Allow SSH (adjust port if needed)
    iptables -C INPUT -p tcp --dport 22 -j ACCEPT 2>/dev/null || \
        iptables -I INPUT -p tcp --dport 22 -j ACCEPT
    
    # Allow local network access
    iptables -C INPUT -i br0 -j ACCEPT 2>/dev/null || \
        iptables -I INPUT -i br0 -j ACCEPT
}

if [ ! -z "$1" ]; then
    if [ "$1" = "-d" ]; then
        delete=1
        shift
    fi
    if [ ! -z "$1" ]; then
        devices=$*
    fi
fi

wan=$(nvram get wan_iface)

delete_rules() {
    local ip=$1
    logger -t $_tag "Deleting iptable rule $ip <-> $wan"
    
    # Delete rules
    logger -t $_tag "iptables -D FORWARD -s \"$ip\" -o \"$wan\" -j \"$target\""
    iptables -D FORWARD -s "$ip" -o "$wan" -j "$target"
    
    logger -t $_tag "iptables -D FORWARD -d \"$ip\" -i \"$wan\" -j \"$target\""
    iptables -D FORWARD -d "$ip" -i "$wan" -j "$target"
}

create_rules() {
    local ip=$1
    
    # Check if rules already exist
    if ! iptables -C FORWARD -s "$ip" -o "$wan" -j "$target" 2>/dev/null; then
        logger -t $_tag "Creating iptable rule $ip -> $wan"
        logger -t $_tag "iptables -I FORWARD -s \"$ip\" -o \"$wan\" -j \"$target\""
        iptables -I FORWARD -s "$ip" -o "$wan" -j "$target"
    fi
    
    if ! iptables -C FORWARD -d "$ip" -i "$wan" -j "$target" 2>/dev/null; then
        logger -t $_tag "Creating iptable rule $wan -> $ip"
        logger -t $_tag "iptables -I FORWARD -d \"$ip\" -i \"$wan\" -j \"$target\""
        iptables -I FORWARD -d "$ip" -i "$wan" -j "$target"
    fi
}

# Ensure basic connectivity rules are in place
ensure_basic_rules

for i in $devices; do
    save="$_dir/counters/$i"
    ip=$(nslookup $i | grep Address | tail -1 | cut -d: -f2 | cut -d" " -f2)

    if [ -z "$ip" ]; then
        echo "Could not determine the ip address of $i" >&2
        continue
    fi

    if [ ! -d "$save" ]; then
        mkdir -p "$save"
    fi

    if [ $delete -eq 1 ]; then
        delete_rules "$ip"
        continue
    fi
    create_rules "$ip"

    # Get current counters with error checking
    rx=$(iptables -L FORWARD -v -x -n | grep -w "$ip" | grep -w "$wan" | head -1 | awk '{print $2}')
    tx=$(iptables -L FORWARD -v -x -n | grep -w "$ip" | grep -w "$wan" | tail -1 | awk '{print $2}')

    # Validate counter values
    rx=${rx:-0}
    tx=${tx:-0}

    # echo the data for influx
    echo "network.receive.bytes,router=$_router,device=$i value=$rx $_now"
    echo "network.transmit.bytes,router=$_router,device=$i value=$tx $_now"

    # Quick check to see if the device is up and the latency
    up=0
    latency=0
    if grep -qw "$ip" /proc/net/arp; then # | awk '{print $3}' | grep -v 0x0; then
        # If the flags are 0x0 then it means the device is not available
	ping=$(ping -c 1 -W 1 $ip)
        if [ $? -eq 1 ]; then
            up=0
        else
            up=1
            latency=$(echo $ping | awk -F/ '{print $4}')
        fi
    fi
    echo "network.up.boolean,router=$_router,device=$i value=$up $_now"
    echo "ping.latency.milliseconds,router=$_router,device=$i value=$latency $_now"

    # Save the counters
    echo "$rx" > "$save/rx_bytes"
    echo "$tx" > "$save/tx_bytes"
done
