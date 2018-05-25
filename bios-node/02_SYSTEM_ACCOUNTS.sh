#!/bin/bash
################################################################################
#
# Script Created by http://CryptoLions.io
# Edit for Ghostbusters testnet
#
#
################################################################################

EOSIO_PRODUCER_KEY="$( jq -r '.EOSIO_PRODUCER_PUB_KEY' "00_CONFIG.conf" )"
cmd="./cleos.sh create account eosio";

echo "Creating system accounts...";

accounts=( eosio.bpay eosio.msig eosio.names eosio.ram eosio.ramfee eosio.saving eosio.stake eosio.token eosio.vpay );

for a in "${accounts[@]}"
do
echo -e "\n creating $a \n";
$cmd $a $EOSIO_PRODUCER_KEY;
sleep 1;
done
