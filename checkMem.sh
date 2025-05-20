#!/bin/sh

source /opt/tomato-grafana/variables.sh

mem=$(cat /proc/meminfo)
total=$(echo "$mem" | grep ^MemTotal | awk '{print $2}')
free=$(echo "$mem" | grep ^MemFree | awk '{print $2}')
used=$(echo $(( $total - $free )))
buffers=$(echo "$mem" | grep ^Buffers | awk '{print $2}')
cached=$(echo "$mem" | grep ^Cached: | awk '{print $2}')
active=$(echo "$mem" | grep ^Active: | awk '{print $2}')
inactive=$(echo "$mem" | grep ^Inactive: | awk '{print $2}')

echo "mem.total.kilobytes,router=$_router value=$total $_now"
echo "mem.free.kilobytes,router=$_router value=$free $_now"
echo "mem.used.kilobytes,router=$_router value=$used $_now"
echo "mem.buffers.kilobytes,router=$_router value=$buffers $_now"
echo "mem.cached.kilobytes,router=$_router value=$cached $_now"
echo "mem.active.kilobytes,router=$_router value=$active $_now"
echo "mem.inactive.kilobytes,router=$_router value=$inactive $_now"
