#!/bin/bash
#######################################################
##                                                   ##
## Script Created by CryptoLions, HKEOS and EOS Rio  ##
## For EOS Ghostbusters Testnet                      ##
##                                                   ##
## https://github.com/CryptoLions                    ##
## https://github.com/eosrio                         ##
## https://github.com/HKEOS/Ghostbusters-Testnet     ##
##                                                   ##
#######################################################

DIR=$(dirname "$0")

    if [ -f $DIR"/nodeos.pid" ]; then
    	pid=$(cat $DIR"/nodeos.pid")
    	echo $pid
    	kill $pid
    	rm -r $DIR"/nodeos.pid"

    	echo -ne "Stopping Nodeos"

    	while true; do
    		[ ! -d "/proc/$pid/fd" ] && break
    		echo -ne "."
    		sleep 1
    	done
    	echo -ne "\rNodeos stopped. \n"

    fi
