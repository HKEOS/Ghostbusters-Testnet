#!/bin/bash
################################################################################
#
# Script Created by http://CryptoLions.io
# Edited for Ghostbusters Testnet
#
################################################################################

SOURCES_FOLDER="$( jq -r '.SOURCES_FOLDER' "00_CONFIG.conf" )"
CONTRACTS_FOLDER="$SOURCES_FOLDER/build/contracts"


./cleos.sh set contract eosio.token $CONTRACTS_FOLDER/eosio.token -p eosio.token
./cleos.sh set contract eosio.msig $CONTRACTS_FOLDER/eosio.msig -p eosio.msig
