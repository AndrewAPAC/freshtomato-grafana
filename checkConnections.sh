#!/bin/sh

source /opt/tomato-grafana/variables.sh

connections=$(cat /proc/net/nf_conntrack)
tcp=$(echo "$connections" | grep ipv4 | grep tcp | wc -l)
udp=$(echo "$connections" | grep ipv4 | grep udp | wc -l)
icmp=$(echo "$connections" | grep ipv4 | grep icmp | wc -l)
total=$(echo "$connections" | grep ipv4 | wc -l)

echo "connections.tcp.number,router=$_router value=$tcp $_now"
echo "connections.udp.number,router=$_router value=$udp $_now"
echo "connections.icmp.number,router=$_router value=$icmp $_now"
echo "connections.total.number,router=$_router value=$total $_now"
