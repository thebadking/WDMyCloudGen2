#!/bin/sh

INSTALL_DIR=$1
DEFINES=/usr/local/model/web/pages/function/define.js
ORIGINAL=/mnt/HD/HD_a2/Nas_Prog/WDCrack/original.js

# RESTORE
cp -f $ORIGINAL $DEFINES

rm -f /var/www/WDCrack
rm -rf $INSTALL_DIR



