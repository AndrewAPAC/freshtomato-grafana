#!/bin/sh

source /opt/freshtomato-grafana/variables.sh

googleping=$(ping -c 3 www.google.com | tail -2)
packet=$(echo "$googleping" | tr ',' '\n' | grep "packet loss" | grep -o '[0-9]\+')
google=$(echo "$googleping" |grep "round-trip" | cut -d " " -f 4 | cut -d "/" -f 1)

echo "ping.google.packetloss.percent,router=$_router value=$packet $_now"
echo "ping.google.latency,router=$_router value=$google $_now"
