#!/bin/sh                                                                                                                               

source /opt/freshtomato-grafana/variables.sh

[ ! -x $_dir/speedtest ] && exit

result=$($_dir/speedtest --accept-license -f csv 2>/dev/null)

logger -t $_tag "speedtest: $result"

down=$(echo "$result" | cut -d',' -f 6 | tr -d '"')
up=$(echo "$result" | cut -d',' -f 7 | tr -d '"')

curl -XPOST "http://$ifserver:$ifport/write?db=$ifdb" -u $ifuser:$ifpass --data-binary "speedtest.upload value=$up $_now"
curl -XPOST "http://$ifserver:$ifport/write?db=$ifdb" -u $ifuser:$ifpass --data-binary "speedtest.download value=$down $_now"
