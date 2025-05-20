# freshtomato-grafana

Scripts to display metrics from routers running FreshTomato on 
[Grafana](https://www.grafana.com). This is forked from tomato-grafana 
(https://github.com/ch604/tomato-grafana) but my changes were significant 
enough to make integration near impossible.

# Additional Features

* Consistent timestamp
* Monitoring of selected devices
* Enhanced grafana dashboards
* Temperature monitoring
* Reduced calls to influx (one per collection)
* Saves between router reboots
* Output to `stdout` for easier debugging of individual scripts

## Dashboard Preview

### The top third of the router dashboard that shows bandwidth and hostorical usage
![Router Dashboard](https://i.imgur.com/0iORuQg.png)
### The lower part of the dashboard with hardware stats
![Router Dashboard - CPU](https://i.imgur.com/YQ1fmVC.png)
### Each configurable device has bandwidth, usage and health stats displayed
![Device Dashboard](https://i.imgur.com/nooSGsC.png)

# Requirements

- Router running FreshTomato - it may work on other variants with some tweaking
- Server running Grafana
- Server running InfluxDB (=< 1.8)

# Installation

Optionally enable auth on InfluxDB in `/etc/influxdb/influxdb.conf`) and 
configure a user and password. The router scripts will use authentication
if it is set up.

Set up a blank InfluxDB database for storage:
```
CREATE DATABASE tomato
CREATE RETENTION POLICY "180d" ON "tomato" DURATION 180d DEFAULT
```
I would recommend 180 days as the dashboard shows monthly data for 
6 months

Connect Grafana to InfluxDB as a data source using the same username and 
password you set up for influx auth.  

`ssh` access to the router is required which can be set up using the
web administration page and out of scope for this document.

For storage, the best option is to use a USB thumb drive or similar, with 
an `ext4` formatted partition and mount on `/opt`

Optionally, but recommended is to install `entware` and a comprehensive
guide for this and above can be found on the [Entware gitgub home](https://github.com/Entware/Entware/wiki/Install-on-TomatoUSB-and-FreshTomato#entware-on-freshtomato-and-other-tomatousb-forks)

First clone this repository to your computer. If you can do it directly
to the router then it is also an option but usually `ssh` on tomato is
not capable of doing this.  Then copy all files to the `/opt` partition
of your router.

```
git clone git@github.com:AndrewAPAC/freshtomato-grafana.git
rsync -av freshtomato-grafana router:/opt
```
`ssh` to your router and navigate to `/opt/tomato`.  Copy 
`variables.sh.tmpl` to `variables.sh` and edit the top section as per
the comments.

A major enhancement is the addition of `devices`.  This collects 
bandwidth and usage stats for each device listed. Personally, I include
items like televisions, phones and tablets as well as the usual laptops
and desktops. Setting up a static IP address for each device is a good 
idea for consistent results.

For speedtest results, download the Ookla ARM CLI tool from 
https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-armel.tgz 
and place its contents into `/opt/freshtomato-grafana`.
The core speedtest binary should be executable.  The other files can be
removed if you like.

```
ssh router
cd /opt/freshtomato-grafana
wget https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-armel.tgz
tar xvfz ookla-speedtest-1.2.0-linux-armel.tgz
chmod 755 /opt/freshtomato-grafana/speedtest 
```

Add cron jobs through the web administration interface: 
`Administration` -> `Scheduler`. If you would like to run the collectors
every 20 seconds, add the following three commands under 
 as custom cron jobs:
```
/opt/freshtomato-grafana/collector.sh >/dev/null 2>&1
/opt/freshtomato-grafana/collector20.sh >/dev/null 2>&1
/opt/freshtomato-grafana/collector40.sh >/dev/null 2>&1
```
For every 30 seconds, use the following instead:
```
/opt/freshtomato-grafana/collector.sh >/dev/null 2>&1
/opt/freshtomato-grafana/collector30.sh >/dev/null 2>&1```
```

These should all run every 1 minute on every day of the week. The 
collectors will now run every 20 (or 30) seconds.

The speedtest does not need to run every minute and can be set up
separately to run every half hour or hour"

```
/opt/freshtomato-grafana/speedTest.sh >/dev/null 2>&1
```

For the dashboards, import the `json` files included
in the dowload. Once everything has stabilised, I will add 
the dashboards to https://www.grafana.com/dashboards.  If you
can let me know of any changes you need to make to anything,
please let me know so I can update the repository.




