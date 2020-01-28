#!/bin/sh
/etc/init.d/atop stop 2>&1 >/dev/null &
/etc/init.d/commgrd stop 2>&1 >/dev/null &
/etc/init.d/onbrdnetloccommd stop 2>&1 >/dev/null &
/etc/init.d/restsdk-serverd stop 2>&1 >/dev/null &
/etc/init.d/wddispatcherd stop 2>&1 >/dev/null &
/etc/init.d/wdmcserverd stop 2>&1 >/dev/null &
/etc/init.d/wdnotifierd stop 2>&1 >/dev/null &
/etc/init.d/wdphotodbmergerd stop 2>&1 >/dev/null &
killall crond 2>&1 >/dev/null &
mount -o remount,noatime,nodiratime /dev/root /
