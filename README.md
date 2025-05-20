# freshtomato-grafana

## Please note that this fork is still a work in progress and not the final version

Scripts to display metrics from routers running FreshTomato. This is forked from tomato-grafana (https://github.com/ch604/tomato-grafana) but my changes were significant enough to not allow reintegration.

## Dashboard Preview

### The top third of the router dashboard that shows bandwidth and hostorical usage
![Router Dashboard](https://i.imgur.com/0iORuQg.png)
### The lower part of the dashboard with hardware stats
![Router Dashboard - CPU](https://i.imgur.com/YQ1fmVC.png)
### Each configurable device has bandwidth, usage and health stats displayed
![Device Dashboard](https://i.imgur.com/nooSGsC.png)

# Requirements

- Router running FreshTomato
- Server running Grafana
- Server running InfluxDB (=< 1.8)

# Installation

Optionally enable auth on InfluxDB (on my apt-based debian install, this was at /etc/influxdb/influxdb.conf) and configure a user and password. The router scripts will expect auth for depositing data.

Set up a blank InfluxDB database for storage (after installing influxdb-client, auth into influx from the command line, and run "CREATE DATABASE tomato", or whatever you would like to call it).

Connect Grafana to InfluxDB as a data source using the same username and password you set up for influx auth.

On to the router. Connect and mount a disk to /opt (USB Drive, SD Card, external HDD/SSD. If you already installed Entware, skip this step).

If you want to use JFFS instead, Enable JFFS support on Tomato under Administration -> JFFS

## /opt
Upload all shell scripts to /opt/tomato-grafana/. 

## /jffs
Upload all shell scripts to /jffs/tomato-grafana/. 
Before, or after uploading the scripts, run the following command in the scripts folder to replace /opt with /jffs
`find . -type f -exec sed -i 's#/jffs/#/opt/#g' {} +`


Modify the IP, port, password, and username of your influxdb server in variables.sh. Also add any additional mount points you may want to monitor in this file as well, space-delimited. Scripts do not have to be executable.

For speedtest results, download the Ookla ARM CLI tool from https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-armel.tgz and place its contents into a folder called /opt/speedtest/. The core speedtest binary should be executable.

Add the following three commands under Administration -> Scheduler as custom cron jobs:
```
sh /opt/tomato-grafana/collector.sh >/dev/null 2>&1
sh /opt/tomato-grafana/collector20.sh >/dev/null 2>&1
sh /opt/tomato-grafana/collector40.sh >/dev/null 2>&1
```
or, for jffs : 
```
sh /jffs/tomato-grafana/collector.sh >/dev/null 2>&1
sh /jffs/tomato-grafana/collector20.sh >/dev/null 2>&1
sh /jffs/tomato-grafana/collector40.sh >/dev/null 2>&1
```
These should all run every 1 minute on every day of the week. The collectors will now run every 20 seconds. Additionally, add this cron for the speedtest:
```
sh /opt/tomato-grafana/speedTest.sh >/dev/null 2>&1
```
or, for jffs : 
```
sh /opt/tomato-grafana/speedTest.sh >/dev/null 2>&1
```

Run this every 30 minutes, or as often as you would like results recorded.

Import the Grafana dashboard via json file or from this dashboard code: https://grafana.com/grafana/dashboards/14237

Enjoy!
