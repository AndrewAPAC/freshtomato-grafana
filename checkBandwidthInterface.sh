#!/bin/sh

source /opt/tomato-grafana/variables.sh

for i in `\ls -A /sys/class/net/`; do
    rx=$(cat /sys/class/net/$i/statistics/rx_bytes)
    tx=$(cat /sys/class/net/$i/statistics/tx_bytes)

    echo "network.$i.receive.bytes,router=$_router value=$rx $_now"
    echo "network.$i.transmit.bytes,router=$_router value=$tx $_now"
done

# Additionally calculate the total LAN traffic
# Get the bridge interfaces (the members of br0)

lan_interfaces=$(brctl show br0 2>/dev/null | tail -n +2 | awk '{print $4}' | grep -v "^$")
lan_interfaces="$lan_interfaces $(brctl show br0 2>/dev/null | tail -n +3 | awk '{print $1}' | grep -v "^$")"

# Sum the traffic across all LAN interfaces
lan_rx_total=0
lan_tx_total=0

for iface in $lan_interfaces; do
    if [ -f "/sys/class/net/$iface/statistics/rx_bytes" ]; then
        iface_rx=$(cat /sys/class/net/$iface/statistics/rx_bytes)
        iface_tx=$(cat /sys/class/net/$iface/statistics/tx_bytes)
        
        lan_rx_total=$((lan_rx_total + iface_rx))
        lan_tx_total=$((lan_tx_total + iface_tx))
    fi
done

# Output the aggregated LAN traffic
echo "network.lan.receive.bytes,router=$_router value=$lan_rx_total $_now"
echo "network.lan.transmit.bytes,router=$_router value=$lan_tx_total $_now"

