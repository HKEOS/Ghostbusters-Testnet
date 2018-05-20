#!/bin/bash
################################################################################
#
# Script Created by http://CryptoLions.io
# Edited for Ghostbusters Testnet
#
################################################################################

./cleos.sh push action eosio.token create '["eosio", "2500000000.0000 EOS", 0, 0, 0]' -p eosio.token
./cleos.sh push action eosio.token issue '["eosio",  "1000000000.0000 EOS", "init"]' -p eosio
