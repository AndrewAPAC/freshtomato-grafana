#!/bin/sh

source /opt/tomato-grafana/variables.sh

load=$(cat /proc/loadavg)
load1=$(echo "$load" | awk '{print $1}')
load5=$(echo "$load" | awk '{print $2}')
load15=$(echo "$load" | awk '{print $3}')
proc_run=$(echo "$load" | awk '{print $4}' | awk -F '/' '{print $1}')
proc_total=$(echo "$load" | awk '{print $4}' | awk -F '/' '{print $2}')
uptime=$(cat /proc/uptime | awk '{print $1}')

echo "load.load_one.number,router=$_router value=$load1 $_now"
echo "load.load_five.number,router=$_router value=$load5 $_now"
echo "load.load_fifteen.number,router=$_router value=$load15 $_now"
echo "load.proc_run.number,router=$_router value=$proc_run $_now"
echo "load.proc_total.number,router=$_router value=$proc_total $_now"
echo "load.uptime,router=$_router value=$uptime $_now"
