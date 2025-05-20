#!/bin/sh

source /opt/freshtomato-grafana/variables.sh
save=$_dir/usage

if [ ! -d $save ]; then
    mkdir -p $save
fi

timespan=${1:-"hour"}

if [ $timespan = "hour" ]; then
   unit=$(date +%H)
elif [ $timespan = "day" ]; then
    unit=$(date +%d)
elif [ $timespan == "week" ]; then
    unit=$(date +%U)
elif [ $timespan == "month" ]; then
    unit=$(date +%m)
else
    echo "Unrecognized unit: $timespan.  Should be hour, day, week or month"
    exit 1
fi


for i in $wan $devices; do
    stats="$save/${i}_last_${timespan}"
    cumulative="$save/${i}_sum_${timespan}"

    if echo $wan | grep -qw $i; then
        # Get the stats from the system
        rx=/sys/class/net/$i/statistics/rx_bytes
        tx=/sys/class/net/$i/statistics/tx_bytes
        interface=1
    else
        # The counter files produced by checkBandwidthDevice.sh
        rx="$_dir/counters/$i/rx_bytes"
        tx="$_dir/counters/$i/tx_bytes"
        interface=0
    fi

    if [ ! -f $stats ]; then
        echo $now $(cat $rx $tx) > $stats
    fi
    if [ ! -f $cumulative ]; then
        echo "$unit 0 0" > $cumulative
    fi 

    # last timestamp - will use later
    last_ts=$(cut -d" " -f1 $stats)
    # the last saved hour, day, etc.
    last_unit=$(cut -d" " -f1 $cumulative)

    if [ $unit != $last_unit ]; then
        # The hour, day, week or month has changed.  Reset
        echo "$unit 0 0" > $cumulative
    fi 

    # Read current values
    rx_last=$(cut -d" " -f2 $stats)
    rx_current=$(cat $rx)
    tx_last=$(cut -d" " -f3 $stats)
    tx_current=$(cat $tx)

    # Check for counter reset from a reboot
    if [ $rx_current -lt $rx_last -o $tx_current -lt $tx_last ]; then
        logger -t $_tag "++++++ $(date) $timespan: counters reset"
        logger -t $_tag "Running with unit: $timespan"
        logger -t $_tag "rx_last, rx_current = $rx_last, $rx_current"
        logger -t $_tag "tx_last, tx_current = $tx_last, $tx_current"

        rx_cumulative=$(cut -d" " -f2 $cumulative)
        tx_cumulative=$(cut -d" " -f3 $cumulative)
        logger -t $_tag "rx_cumulative, tx_cumulative = $rx_cumulative, $tx_cumulative"

        new_rx=$(expr $rx_cumulative + $rx_last)
        new_tx=$(expr $tx_cumulative + $tx_last)
        logger -t $_tag "new_rx, new_tx = $new_rx, $new_tx"

        # Backup the last files and create new ones
        ext=$(date +"%Y%m%d%H%M%S")
        cp $stats $stats.$ext
        cp $cumulative $cumulative.$ext
        echo "$_now $rx_current $tx_current" > $stats
        echo "$unit $new_rx $new_tx" > $cumulative
    else
        # Normal case - no reset
        rx_diff=$(expr $rx_current - $rx_last)
        rx_cumulative=$(cut -d" " -f2 $cumulative)
        new_rx=$(expr $rx_cumulative + $rx_diff)

        tx_diff=$(expr $tx_current - $tx_last)
        tx_cumulative=$(cut -d" " -f3 $cumulative)
        new_tx=$(expr $tx_cumulative + $tx_diff)
    fi
 
    echo "$timespan.receive.bytes,router=$_router,device=$i value=$new_rx $_now"
    echo "$timespan.transmit.bytes,router=$_router,device=$i value=$new_tx $_now"

    # Set default values if variables are unset
    new_rx=${new_rx:-0}
    new_tx=${new_tx:-0}
    

    # Save the counters for next time
    echo "$_now $rx_current $tx_current" > $stats
    echo "$unit $new_rx $new_tx" > $cumulative
done
