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

EOS_DIR="$( jq -r '.EOS_SOURCE_DIR' "00_CONFIG.conf" )"
NODEOS=$EOS_DIR/build/programs/nodeos/nodeos
DATADIR=$(pwd)
$DATADIR/stop.sh
$NODEOS --data-dir $DATADIR --config-dir $DATADIR "$@" > $DATADIR/stdout.txt 2> $DATADIR/stderr.txt &  echo $! > $DATADIR/nodeos.pid
