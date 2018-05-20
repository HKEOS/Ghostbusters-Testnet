#!/bin/bash
################################################################################
#
# Script Created by http://CryptoLions.io
# Edited For Ghostbusters testnet
#
################################################################################

WALLET_PASS="$( jq -r '.WALLET_PASSWD' "00_CONFIG.conf" )"
EOSIO_PRIV="$( jq -r '.EOSIO_PRODUCER_PRIV_KEY' "00_CONFIG.conf" )"

./cleos.sh wallet unlock --password $WALLET_PASS

./cleos.sh wallet import $EOSIO_PRIV
