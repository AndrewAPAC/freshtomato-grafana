#!/bin/sh

source /opt/freshtomato-grafana/variables.sh

clients=$(arp -an | grep -v vlan2 | wc -l)

echo "client.count,router=$_router value=$clients $_now"
