#!/bin/bash

GLOBAL_PATH=$(pwd)
croncmd="bash $GLOBAL_PATH/autolaunch.sh >> $GLOBAL_PATH/autolaunch.log";
cronjob="0,10,20,30,40,50 * * * * $croncmd";
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
echo "AutoLaunch Ready! Wait for the target BTC block.";
