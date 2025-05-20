#!/bin/sh

source /opt/freshtomato-grafana/variables.sh

cpuTemp=$(cat /proc/dmu/temperature  | grep -o '[0-9]\+')
eth1Temp=$(wl -i eth1 phy_tempsense | awk '{print $1 / 2 + 20}')
eth2Temp=$(wl -i eth2 phy_tempsense | awk '{print $1 / 2 + 20}')

echo "temp.cpu.degrees,router=$_router value=$cpuTemp $_now"
echo "temp.eth1.degrees,router=$_router value=$eth1Temp $_now"
echo "temp.eth2.degrees,router=$_router value=$eth2Temp $_now"
