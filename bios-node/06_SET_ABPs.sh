#!/bin/bash
################################################################################
#
# Script Created by Jae Chung, HKEOS and Igor Lins e Silva, EOS Rio
# For Ghostbusters testnet
#
################################################################################

accounts=(  );

for account in "${accounts[@]}"
do
  #./cleos.sh push action eosio setprods '{"schedule":[{"producer_name":"<account-name>","block_signing_key":"<prod-key>"}]}' -p eosio
done
