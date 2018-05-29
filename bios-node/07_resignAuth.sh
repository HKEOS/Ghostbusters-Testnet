#!/bin/bash
################################################################################
#
# Script Created by Jae Chung, HKEOS and Igor Lins e Silva, EOS Rio
# For Ghostbusters testnet
#
################################################################################

echo -e "\n changing permissions for bios account \n";

abps=();
for abp in "${abps[@]}"
do
  echo -e "\n changing permissions for $abp \n";
    ./cleos.sh push action eosio updateauth '{"account": "eosio", "permission": "owner", "parent": "", "auth":{"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "abp", "permission": active}}]}} -p eosio@active
    ./cleos.sh push action eosio updateauth '{"account": "eosio", "permission": "active", "parent": "owner", "auth":{"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "abp", "permission": active}}]}} -p eosio@active
    sleep 1;
done


accounts=( eosio.bpay eosio.msig eosio.names eosio.ram eosio.ramfee eosio.saving eosio.stake eosio.token eosio.vpay );

for account in "${accounts[@]}"
do
  echo -e "\n changing permissions for $account \n";
  ./cleos.sh push action eosio updateauth '{"account": "account", "permission": "owner", "parent": "", "auth":{"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio", "permission": active}}]}} -p eosio@owner
  ./cleos.sh push action eosio updateauth '{"account": "account", "permission": "active", "parent": "owner", "auth":{"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio", "permission": active}}]}} -p eosio@active
  sleep 1;
done
