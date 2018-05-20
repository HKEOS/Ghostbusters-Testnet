#!/bin/bash
################################################################################
#
# Script Created by http://CryptoLions.io
# Edited for Ghostbusters testnet
#
#
################################################################################


SOURCES_FOLDER="$( jq -r '.SOURCES_FOLDER' "00_CONFIG.conf" )"
CONTRACTS_FOLDER="$SOURCES_FOLDER/build/contracts"

EOSIO_PRODUCER_KEY="$( jq -r '.EOSIO_PRODUCER_PUB_KEY' "00_CONFIG.conf" )"

./cleos.sh set contract eosio $CONTRACTS_FOLDER/eosio.bios -p eosio

# only eosio initial producer..
./cleos.sh push action eosio setprods '{"schedule":[{"producer_name":"eosio","block_signing_key":"'$EOSIO_PRODUCER_KEY'"}]}' -p eosio
