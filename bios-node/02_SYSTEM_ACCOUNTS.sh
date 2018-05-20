#!/bin/bash
################################################################################
#
# Script Created by http://CryptoLions.io
# Edit for Ghostbusters testnet
#
#
################################################################################

EOSIO_PRODUCER_KEY="$( jq -r '.EOSIO_PRODUCER_PUB_KEY' "00_CONFIG.conf" )"

./cleos.sh create account eosio eosio.token $EOSIO_PRODUCER_KEY $EOSIO_PRODUCER_KEY -p eosio
./cleos.sh create account eosio eosio.msig $EOSIO_PRODUCER_KEY $EOSIO_PRODUCER_KEY -p eosio
