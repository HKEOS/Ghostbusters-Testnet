#!/bin/bash
################################################################################
#
# Script Created by http://CryptoLions.io
# Edited for Ghostbusters Testnet
#
################################################################################

./cleos.sh push action eosio.token create '["eosio", "10000000000.0000 EOS"]' -p eosio.token
./cleos.sh push action eosio.token issue '["eosio",  "1000000000.0000 EOS", "init"]' -p eosio

#./cleos.sh push action eosio.token create '["eosio", "10000000000.0000 SYS"]' -p eosio.token
#./cleos.sh push action eosio.token issue '["eosio",  "1000000000.0000 SYS", "init"]' -p eosio
