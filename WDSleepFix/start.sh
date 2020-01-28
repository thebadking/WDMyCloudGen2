#!/bin/sh
ACTION="stop"
/etc/init.d/atop $ACTION 2>&1 >/dev/null &
/etc/init.d/cmmgrd $ACTION 2>&1 >/dev/null &
/etc/init.d/wdmcserverd $ACTION 2>&1 >/dev/null &
/etc/init.d/wdphotodbmergerd $ACTION 2>&1 >/dev/null &
/etc/init.d/onbrdnetloccommd $ACTION 2>&1 >/dev/null &
/etc/init.d/wdnotifierd $ACTION 2>&1 >/dev/null &
/etc/init.d/wddispatcherd $ACTION 2>&1 >/dev/null &
#/etc/init.d/restsdk-served $ACTION 2>&1 >/dev/null &
killall crond 2>&1 >/dev/null &
mount -o remount,noatime,nodiratime /dev/root /
