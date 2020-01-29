#!/bin/sh

INSTALL_DIR=$1
DEFINES=/usr/local/model/web/pages/function/define.js
ENABLE=/mnt/HD/HD_a2/Nas_Prog/WDCrack/enable.js
ORIGINAL=/mnt/HD/HD_a2/Nas_Prog/WDCrack/original.js

# Install web icon and description (Multilanuage) file
ln -sf $INSTALL_DIR/web /var/www/WDCrack

# Backup
cp -n $DEFINES $ORIGINAL
# SET
cp -f $ENABLE $DEFINES
