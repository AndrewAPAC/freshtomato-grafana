#!/bin/sh
sh /opt/tomato-grafana/checkDisk.sh &
sh /opt/tomato-grafana/checkBandwidthInterface.sh &
sh /opt/tomato-grafana/checkConnections.sh &
sh /opt/tomato-grafana/pingGoogle.sh &
sh /opt/tomato-grafana/checkLoad.sh &
sh /opt/tomato-grafana/checkCPUTemp.sh &
sh /opt/tomato-grafana/checkMem.sh &
sh /opt/tomato-grafana/checkCPU.sh &
sh /opt/tomato-grafana/checkClients.sh &
