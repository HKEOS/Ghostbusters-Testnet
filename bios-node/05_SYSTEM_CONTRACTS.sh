#!/bin/bash
################################################################################
#
# Script Created by http://CryptoLions.io
# Edited for Ghostbusters testnet
#
################################################################################

SOURCES_FOLDER="$( jq -r '.SOURCES_FOLDER' "00_CONFIG.conf" )"
CONTRACTS_FOLDER="$SOURCES_FOLDER/build/contracts"

./cleos.sh set contract eosio $CONTRACTS_FOLDER/eosio.system -x 1000 -p eosio
./cleos.sh push action eosio setpriv '["eosio.msig",1]' -p eosio
