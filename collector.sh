#!/bin/sh

source /opt/freshtomato-grafana/variables.sh

$_dir/checkDisk.sh > $_datafile 
$_dir/checkBandwidthInterface.sh >> $_datafile
$_dir/checkBandwidthDevice.sh >> $_datafile
$_dir/checkConnections.sh >> $_datafile
$_dir/checkLoad.sh >> $_datafile
$_dir/checkCPUTemp.sh >> $_datafile
$_dir/checkMem.sh >> $_datafile
$_dir/checkCPU.sh >> $_datafile
$_dir/checkClients.sh >> $_datafile
$_dir/checkUsage.sh hour >> $_datafile
$_dir/checkUsage.sh day >> $_datafile
$_dir/checkUsage.sh week >> $_datafile
$_dir/checkUsage.sh month >> $_datafile
$_dir/pingGoogle.sh >> $_datafile

curl -XPOST "http://$ifserver:$ifport/write?db=$ifdb" -u $ifuser:$ifpass --data-binary @$_datafile

rm -f $_datafile
