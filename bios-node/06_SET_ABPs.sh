#!/bin/bash
################################################################################
#
# Script created by Eric Bjork, EOS Sw/eden
# Script created by Michael Yeates, eosDAC
# Script edited by Jae Chung, HKEOS and Igor Lins e Silva, EOS Rio
# For Ghostbusters testnet
#
################################################################################

#!/bin/bash

SORUCES_FOLDER="$( jq -r '.SOURCES_FOLDER' "00_CONFIG.conf" )"

EOS_BUILD_DIR=$SOURCES_FOLDER/build

EOSIO_KEY=EOSIO_PRODUCER_KEY="$( jq -r '.EOSIO_PRODUCER_PUB_KEY' "00_CONFIG.conf" )"

PRODUCERS_JSON='{"schedule":['
while read line
do
      a=(${line//,/ })
      name="${a[0]}"
      key="${a[1]}"

        ./cleos.sh create account eosio $name $key $key
       sleep 1
        if [ "$PRODUCERS_JSON" = '{"schedule":[' ]; then
                PRODUCERS_JSON="$PRODUCERS_JSON{\"producer_name\":\"$name\",\"block_signing_key\":\"$key\"}"
        else
                PRODUCERS_JSON="$PRODUCERS_JSON,{\"producer_name\":\"$name\",\"block_signing_key\":\"$key\"}"
        fi

done < producers

PRODUCERS_JSON="$PRODUCERS_JSON"']}'

echo $PRODUCERS_JSON

#echo "./cleos.sh push action eosio setprods \"$PRODUCERS_JSON\" -p eosio"
./cleos.sh push action eosio setprods $PRODUCERS_JSON -p eosio
