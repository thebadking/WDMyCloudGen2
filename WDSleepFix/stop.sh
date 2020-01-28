#!/bin/sh

ACTION="start"

/etc/init.d/wdmcserverd $ACTION 2>&1 >/dev/null &
/etc/init.d/wdphotodbmergerd $ACTION 2>&1 >/dev/null &
/etc/init.d/convert $ACTION 2>&1 >/dev/null &
/etc/init.d/wdnotifierd $ACTION 2>&1 >/dev/null &
/etc/init.d/wddispatcherd $ACTION 2>&1 >/dev/null &
/etc/init.d/atop $ACTION 2>&1 >/dev/null &

crond 2>&1 >/dev/null &
