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
NODE_PORT="$( jq -r '.HTTP_PORT' "00_CONFIG.conf" )"
KEOSD_PORT="$( jq -r '.WALLET_PORT' "00_CONFIG.conf" )"

CLEOS=$EOS_DIR/build/programs/cleos/cleos
$CLEOS -u http://127.0.0.1:$NODE_PORT --wallet-url http://127.0.0.1:$KEOSD_PORT "$@"
