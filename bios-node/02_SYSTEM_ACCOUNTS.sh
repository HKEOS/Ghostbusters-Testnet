#!/bin/bash
GREEN='\033[0;32m'
NC='\033[0m' # No Color

################################################################################
#
# Script Created by http://CryptoLions.io
# Edit for Ghostbusters testnet
#
################################################################################

EOSIO_PRODUCER_KEY="$( jq -r '.EOSIO_PRODUCER_PUB_KEY' "00_CONFIG.conf" )"
cmd="./cleos.sh create account eosio";

echo "\n${GREEN}Creating system accounts...";

accounts=( eosio.bpay eosio.msig eosio.names eosio.ram eosio.ramfee eosio.saving eosio.stake eosio.token eosio.vpay );

for account in "${accounts[@]}"
do
  echo -e "\n creating $account \n";
  $cmd $account $EOSIO_PRODUCER_KEY;
  sleep 1;
done
