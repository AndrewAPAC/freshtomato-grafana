#!/bin/sh

source /opt/freshtomato-grafana/variables.sh

base=/sys/class/net

for i in $(ls -A $base); do
    rx=$(cat $base/$i/statistics/rx_bytes)
    tx=$(cat $base/$i/statistics/tx_bytes)

    if [ "$rx" -gt 0 ] || [ "$tx" -gt 0 ]; then
        echo "network.$i.receive.bytes,router=$_router value=$rx $_now"
        echo "network.$i.transmit.bytes,router=$_router value=$tx $_now"
    fi
done

# Calculate the total LAN traffic
lan_ifaces=$(brctl show $bridge 2>/dev/null | tail -n +2 | awk '{print $NF}')
lan_ifaces="$lan_ifaces $bridge"

# Write to temp file to avoid shell math
temp_file="/tmp/lan_stats.$$"
> "$temp_file"

for i in $lan_ifaces; do
    rx_file="$base/$i/statistics/rx_bytes"
    tx_file="$base/$i/statistics/tx_bytes"

    if [ -f "$rx_file" ] && [ -f "$tx_file" ]; then
        rx=$(cat "$rx_file")
        tx=$(cat "$tx_file")
        echo "$i $rx $tx" >> "$temp_file"
    fi
done

# Use awk to safely sum 64-bit integers
read lan_rx lan_tx <<EOF
$(awk '{rx+=$2; tx+=$3} END {print rx, tx}' "$temp_file")
EOF

rm -f "$temp_file"

# Output the aggregated LAN traffic
echo "network.lan.receive.bytes,router=$_router value=$lan_rx $_now"
echo "network.lan.transmit.bytes,router=$_router value=$lan_tx $_now"

