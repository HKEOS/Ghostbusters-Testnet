#!/bin/bash

## DEFINE TARGET BTC BLOCK
TARGET_BLOCK=522935;

get_seeded_random()
{
	seed="$1"
	openssl enc -aes-256-ctr -pass pass:"$seed" -nosalt < /dev/zero 2> /dev/null
}

build_genesis()
{

	if [[ ! -f ./cleos.sh ]]; then
		echo "cleos.sh not found!";
		exit 1;
	fi

	echo "Generating key pair...";
	./cleos.sh create key > bios_keys;

	echo "Key pair saved to bios_keys file!";

	public_key=$(cat bios_keys | grep 'Public key: ' | cut -f 3 -d ' ');

    ## Create folder for bios node
    mkdir -p BiosNode;
    cp config.ini ./BiosNode/config.ini;

    genesis='{
    	"initial_timestamp": "'$(date -I)'T'$(date +"%H:%M")':00.000",
    	"initial_key": "'$public_key'",
    	"initial_configuration": {
    		"max_block_net_usage": 1048576,
    		"target_block_net_usage_pct": 1000,
    		"max_transaction_net_usage": 524288,
    		"base_per_transaction_net_usage": 12,
    		"net_usage_leeway": 500,
    		"context_free_discount_net_usage_num": 20,
    		"context_free_discount_net_usage_den": 100,
    		"max_block_cpu_usage": 100000,
    		"target_block_cpu_usage_pct": 500,
    		"max_transaction_cpu_usage": 100000,
    		"base_per_transaction_cpu_usage": 512,
    		"base_per_action_cpu_usage": 1024,
    		"base_setcode_cpu_usage": 2097152,
    		"per_signature_cpu_usage": 102400,
    		"cpu_usage_leeway": 2048,
    		"context_free_discount_cpu_usage_num": 20,
    		"context_free_discount_cpu_usage_den": 100,
    		"max_transaction_lifetime": 3600,
    		"deferred_trx_expiration_window": 600,
    		"max_transaction_delay": 3888000,
    		"max_inline_action_size": 4096,
    		"max_inline_action_depth": 4,
    		"max_authority_depth": 6,
    		"max_generated_transaction_count": 16
    	},
    	"initial_chain_id": "0000000000000000000000000000000000000000000000007472696e6974790b"
    }';

    echo "$genesis" > ./BiosNode/genesis.json;
}

## Check KBFS mount point
echo -e "--------------- VERIFYING KEYBASE FILE SYSTEM ---------------\n";
KBFS_MOUNT=$(keybase status | grep mount | cut -f 2 -d:);

## Restart Keybase if needed
if [ -d "$KBFS_MOUNT" ]; then
	echo "kbfs is not running...";
	run_keybase
	sleep 3
else
	echo -e "KBFS mounted at $KBFS_MOUNT\n";
fi

echo -e "--------------- VERIFYING BITCOIN STATE ---------------\n";

matches=0;

echo -e "Target Launch BTC Block = $TARGET_BLOCK \n";

echo "Checking source 1: https://blockchain.info/latestblock";

API1="https://blockchain.info/latestblock";
BTC_DATA1=$(curl -s $API1);
BTC_HASH1=$(echo "$BTC_DATA1" | jq .hash | sed 's/"//g');
BTC_HEAD1=$(echo "$BTC_DATA1" | jq .height | sed 's/"//g');
BTC_TIME1=$(echo "$BTC_DATA1" | jq .time | sed 's/"//g');

echo "Current Time: $BTC_TIME1";
echo "Current Bitcoin Block is: $BTC_HEAD1";
echo "Block Hash: $BTC_HASH1";

echo -e "\n";

echo "Checking source 2: https://api.blockcypher.com/v1/btc/main";

API2="https://api.blockcypher.com/v1/btc/main";
BTC_DATA2=$(curl -s $API2);
BTC_HASH2=$(echo "$BTC_DATA2" | jq .hash | sed 's/"//g');
BTC_HEAD2=$(echo "$BTC_DATA2" | jq .height | sed 's/"//g');
BTC_TIME2=$(echo "$BTC_DATA2" | jq .time | sed 's/"//g');

echo "Current Time: $BTC_TIME2";
echo "Current Bitcoin Block is: $BTC_HEAD2";
echo "Block Hash: $BTC_HASH2";

echo -e "\n";

echo "Checking source 3: https://api.blockchair.com/bitcoin/mempool/blocks";

API3="https://api.blockchair.com/bitcoin/mempool/blocks";
BTC_DATA3=$(curl -s $API3);
BTC_HASH3=$(echo "$BTC_DATA3" | jq .data[0].hash | sed 's/"//g');
BTC_HEAD3=$(echo "$BTC_DATA3" | jq .data[0].id | sed 's/"//g');
BTC_TIME3=$(echo "$BTC_DATA3" | jq .data[0].time | sed 's/"//g');

echo "Current Time: $BTC_TIME3";
echo "Current Bitcoin Block is: $BTC_HEAD3";
echo "Block Hash: $BTC_HASH3";

echo -e "\n";

latestblock=0;
selectedAPI="";
selectedAPI_code=0;

if (( $BTC_HEAD1 == $BTC_HEAD2 )); then
	matched=$(($matched + 1));
	if (( $BTC_HEAD1 > $latestblock )); then
		latestblock="$BTC_HEAD1";
		selectedAPI="$API1";
		selectedAPI_code=1;
	fi
fi

if (( $BTC_HEAD2 == $BTC_HEAD3 )); then
	matched=$(($matched + 1));
	if (( $BTC_HEAD2 > $latestblock )); then
		latestblock="$BTC_HEAD2";
		selectedAPI="$API2";
		selectedAPI_code=2;
	fi
fi

if (( $BTC_HEAD1 == $BTC_HEAD3 )); then
	matched=$(($matched + 1));
	if (( $BTC_HEAD3 > $latestblock )); then
		latestblock="$BTC_HEAD3";
		selectedAPI="$API3";
		selectedAPI_code=3;
	fi
fi

if (( $matched > 0 )); then
	echo "Latest block = $latestblock";
	echo "Using data from: $selectedAPI";

	if (($TARGET_BLOCK <= $latestblock)); then
		echo "Ready to launch!";
	else
		remaining_blocks=$(($TARGET_BLOCK - $BTC_HEAD2));
		time_r=$(($remaining_blocks * 10));
		echo "Not there yet! $remaining_blocks blocks remaining, about $time_r minutes...";
		exit 1;
	fi
else
	echo "No source consensus! Exiting...";
	exit 1;
fi

BTC_HASH=null;

if (( $selectedAPI_code == 1 )); then
	BTC_HASH=$(curl -s "https://blockchain.info/block-height/$TARGET_BLOCK?format=json" | jq .blocks[0].hash | sed 's/"//g');
fi

if (( $selectedAPI_code == 2 )); then
	BTC_HASH=$(curl -s "https://api.blockcypher.com/v1/btc/main/blocks/$TARGET_BLOCK?txstart=1&limit=1" | jq .hash | sed 's/"//g');
fi

if (( $selectedAPI_code == 3 )); then
	BTC_HASH=$(curl -s 'https://api.blockchair.com/bitcoin/blocks?q=id($TARGET_BLOCK)' | jq .data[0].hash | sed 's/"//g');
fi

echo "Target hash = $BTC_HASH";

keybase_username=$(keybase status | grep Username: | cut -f2- -d: | sed -e 's/^\s*//' -e '/^$/d');

keybase team list-members eos_ghostbusters -j | grep username | cut -d'"' -f 4 | sort > users.txt;

SELECTED_USER=$(shuf -n 1 --random-source=<(get_seeded_random $BTC_HASH) users.txt);

if [[ "$SELECTED_USER" == "$keybase_username" ]]; then
	echo "You have been chosen as bios!";
	build_genesis;
	cp ./BiosNode/genesis.json /keybase/public/$keybase_username/genesis.json;
else
	echo "Selected User: $SELECTED_USER";
	echo "Waiting for genesis... 30s";
	sleep 30;
	cp /keybase/public/$SELECTED_USER/genesis.json genesis.json;
	echo "Genesis ready! Restart the node!";
fi
