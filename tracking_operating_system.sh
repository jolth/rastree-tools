#!/usr/bin/env bash

#===============================================================================
# Copyright (c) 2018 Dev Microsystem
# Author: Jorge A Toro <jorge.toro at devmicrosystem.com><jolthgs at gmail.com>
# URL: http://devmicrosyste.com
# License: MIT
#
# usage: ./tracking_operating_system.sh
# it should be used with crontab. Not forget put your email
#===============================================================================

count=0
for l in $(df -h|awk '{print $5}'|sed s/%//g); do
  if (( count == 0 )); then
    count=$((count + 1))
    continue
  fi
  
  if (( l > 95 )); then
    used_disk=$(printf "used %s of the disk\n" $l)
    echo $used_disk|mail -s "[alert] hard disk www.rastree.com" jorge.toro@devmicrosystem.com
  fi
  count=$((count + 1))
done


