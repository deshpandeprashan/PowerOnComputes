#!/bin/bash

osd_node_up_count() {
    threshold=$1
    osd_total=$(sudo ceph osd stat | grep osdmap | awk -F: '{ print $2 }' | cut -f2 -d" ")
    osd_up=$(sudo ceph osd stat | grep osdmap | awk -F: '{ print $3 }' | cut -f2 -d" ")
    echo "$osd_up < $osd_total * $threshold" | bc -l
}

check_ceph_health() {
    ceph_health=$(sudo ceph health | grep -o -P "HEALTH_OK|HEALTH_WARN")
    echo $ceph_health
}

#while  [ $(osd_node_up_count) != 0 ]; do date; sleep 10s; done
timeout=$1
#threshold=$2
#while  [[ $(check_ceph_health) != "HEALTH_OK" && $(check_ceph_health) != "HEALTH_WARN" && "$timeout" -lt 60 ]]; do date; sleep 10s; timeout=$((timeout+10));done
#while  [[ $(check_ceph_health) != "HEALTH_OK"  && "$timeout" -gt 0 ]]; do date; sleep 10s; timeout=$((timeout-10));done
while  [[ $(osd_node_up_count $2) != 0 && "$timeout" -gt 0 ]]; do date; sleep 10s; timeout=$((timeout-10));done
if [[ "$timeout" -le 0 ]]; then 
    echo "Timeout $1 seconds expired"
    exit 1
fi
