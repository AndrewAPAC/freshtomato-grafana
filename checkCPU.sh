#!/bin/sh

source /opt/freshtomato-grafana/variables.sh

cpu=$(cat /proc/stat | head -n1 | sed 's/cpu //')
user=$(echo $cpu | awk '{print $1}')
nice=$(echo $cpu | awk '{print $2}')
system=$(echo $cpu | awk '{print $3}')
idle=$(echo $cpu | awk '{print $4}')
iowait=$(echo $cpu | awk '{print $5}')
irq=$(echo $cpu | awk '{print $6}')
softirq=$(echo $cpu | awk '{print $7}')
steal=$(echo $cpu | awk '{print $8}')
guest=$(echo $cpu | awk '{print $9}')
guest_nice=$(echo $cpu | awk '{print $10}')

echo "cpu.user,router=$_router value=$user $_now"
echo "cpu.nice,router=$_router value=$nice $_now"
echo "cpu.system,router=$_router value=$system $_now"
echo "cpu.idle,router=$_router value=$idle $_now"
echo "cpu.iowait,router=$_router value=$iowait $_now"
echo "cpu.irq,router=$_router value=$irq $_now"
echo "cpu.softirq,router=$_router value=$softirq $_now"
echo "cpu.steal,router=$_router value=$steal $_now"
echo "cpu.guest,router=$_router value=$guest $_now"
echo "cpu.guest_nice,router=$_router value=$guest_nice $_now"
