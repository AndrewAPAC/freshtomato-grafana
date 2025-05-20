#!/bin/sh

source /opt/tomato-grafana/variables.sh

for i in $disks; do
    df=$(df $i | tail -1)
    used=$(echo $df | awk '{print $3}')
    free=$(echo $df | awk '{print $4}')
    pct=$(echo $df | awk '{print $5}' | sed 's/%//')

    echo "disk.$i.used,router=$_router value=$used $_now"
    echo "disk.$i.free,router=$_router value=$free $_now"
    echo "disk.$i.percent,router=$_router value=$pct $_now"
done
