#!/bin/sh                                                                                                                               

source /opt/tomato-grafana/variables.sh

[ ! -x /opt/speedtest/speedtest ] && exit

result=`/opt/speedtest/speedtest -f csv`
down=`echo "$result" | awk -F\" '{print $12}'`
up=`echo "$result" | awk -F\" '{print $14}'`

curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'speedtest.upload value='$up
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'speedtest.download value='$down
