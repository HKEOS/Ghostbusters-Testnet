#!/usr/bin/env bash

##########################################
## Autolaunch Tool                      ##
## Created by                           ##
## Igor Lins e Silva, EOS Rio           ##
## Jae Chung, HKEOS                     ##
##########################################

# Change to local directory based on producer name
cd "$(dirname "$0")"

#Find the keybase daemon socket
logfile=$(ps aux | grep [k]eybase | grep 'log-file' | cut -f2 -d'=' | cut -f1 -d' ')
sock=$(grep -P -m 1 -oh "(\/.*?\.sock)" "$logfile")
kb="keybase -F --socket-file $sock";

## DEFINE TARGET BTC BLOCK
LAUNCH_DATA=$(curl -sL -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/HKEOS/Ghostbusters-Testnet/master/launch_data.json);

TARGET_BLOCK=$(echo "$LAUNCH_DATA" | jq -r .btc_block);

CHAIN_ID=$(echo "$LAUNCH_DATA" | jq -r .initial_chain_id);

CURRENT_BLK=$(curl -sL -H 'Cache-Control: no-cache' https://blockchain.info/latestblock | jq .height);

if ! which keybase > /dev/null; then
   echo -e "Keybase not installed. Exiting..."
   exit 1;
fi

if ! which jq > /dev/null; then
   echo -e "jq not found! Install? (y/n) \c"
   read
   if [[ "$REPLY" == "y" ]]; then
      sudo apt install jq
   else
   	exit 1;
   fi
fi

if ! which svn > /dev/null; then
   echo -e "svn not found! Install? (y/n) \c"
   read
   if [[ "$REPLY" == "y" ]]; then
      sudo apt-get install subversion
   else
   	exit 1;
   fi
fi

## Check KBFS mount point
echo -e "\n--------------- VERIFYING KEYBASE FILE SYSTEM ---------------\n";

KBFS_MOUNT=$(eval "$kb status" | awk '/mount/ {print $2}');

# Restart Keybase if needed
if [ ! -d "$KBFS_MOUNT" ]; then
        echo "kbfs is not running...";
        run_keybase
        sleep 3;
else
        echo -e "KBFS mounted at $KBFS_MOUNT\n";
fi

keybase_username=$(eval "$kb status -j" | jq -r .Username);

join() {
	eval "$kb chat create-channel eos_ghostbusters bios_$TARGET_BLOCK";
	eval "$kb chat join-channel eos_ghostbusters bios_$TARGET_BLOCK";
}

leave() {
	eval "$kb chat leave-channel eos_ghostbusters bios_$TARGET_BLOCK";
}

if [[ "$1" == "" ]]; then
	echo
	echo " > Hello $keybase_username,";
	echo
	echo " > Welcome to the Ghostbusters Launch Tool.";
	echo
	echo " > This network is set to launch when the Bitcoin blockchain reach $TARGET_BLOCK blocks!";
	echo
	if (($TARGET_BLOCK >= $CURRENT_BLK)); then
        	remaining_blocks=$(($TARGET_BLOCK - $CURRENT_BLK));
        	MINS_TO_LAUNCH=$(($remaining_blocks * 10));
		echo " > We are on block $CURRENT_BLK, so launch is estimated in about $MINS_TO_LAUNCH mins";
                echo -e "\n > Do you want to be eligible as the bios node? (y/n) \c"
                read
        	if [[ "$REPLY" == "y" || "$1" == "bios" ]]; then
                        echo -e "\n > Your node will be flagged as bios-ready to others!\n";
                        join;
                        flag="bios";
        	else
                	leave;
                	flag="node";
        	fi
	else
		echo " > We are on block $CURRENT_BLK, launch time is already due.";
		echo -e " > Proceeding to sorting phase...\n"
	fi
else
	flag="$1"
fi

build_genesis()
{
	if [[ ! -f ./cleos.sh ]]; then
		echo "cleos.sh not found! Exiting...";
		exit 1;
	fi
	echo "Generating key pair...";
	./cleos.sh create key > bios_keys;
	echo "Key pair saved to bios_keys file!";
	public_key=$(cat bios_keys | grep 'Public key: ' | cut -f 3 -d ' ');
	genesis='{
	"initial_timestamp": "'$(date -u -I)'T'$(date -u +"%H:%M")':00.000",
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
	}
}';

    echo "$genesis" > ./genesis.json;
}

if [[ ! -f ~/autolaunch.path ]]; then
	GLOBAL_PATH=$(pwd)
	echo "$GLOBAL_PATH" > ~/autolaunch.path;
else
	GLOBAL_PATH=$(cat ~/autolaunch.path);
fi

croncmd="$GLOBAL_PATH/autolaunch.sh $flag >> $GLOBAL_PATH/autolaunch.log";
cronjob="*/2 * * * * $croncmd";

add_cronjob()
{
	( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
}

remove_cronjob()
{
	( crontab -l | grep -v -F "$croncmd" ) | crontab -
	rm ~/autolaunch.path
}

if eval "$kb fs read /keybase/public/$keybase_username/genesis.json" > /dev/null 2>&1; then
	echo "Removing old genesis.json...";
	eval "$kb fs rm /keybase/public/$keybase_username/genesis.json";
fi

echo -e "--------------- VERIFYING BITCOIN STATE ---------------\n";

echo -e "Target Launch BTC Block = $TARGET_BLOCK \n";

if (($TARGET_BLOCK <= $CURRENT_BLK)); then
        echo "Ready to launch!";
else
        remaining_blocks=$(($TARGET_BLOCK - $BTC_HEAD2));
        time_r=$(($remaining_blocks * 10));
        echo "Not there yet! $remaining_blocks blocks remaining, about $time_r minutes...";
	# Add script to CRON and quit!
        add_cronjob;
	exit 1;
fi
# Fecth block hash
BTC_HASH=$(curl -s "https://blockchain.info/block-height/$TARGET_BLOCK?format=json" | jq .blocks[0].hash | sed 's/"//g');

echo "Target hash = $BTC_HASH";
echo

# Extract current members of the bios channel
eval "$kb chat list-members eos_ghostbusters bios_$TARGET_BLOCK" | awk 'NR > 2' | sort > bios_list.txt;

announce_bios() {
	user="$1";
	timestamp=$(date -u);
	msg='*autolaunch* :: _'"$timestamp"'_ :: \`'"$keybase_username"'\` is reporting that \`'"$user"'\` was sorted as bios!';
	eval "$kb chat send --channel '#_autolaunch' eos_ghostbusters \"$msg\"";
}

# Shuffle according to the btc hash
RANDOM="$BTC_HASH"
list=($(cat bios_list.txt));
num=${#list[*]}
SELECTED_USER=$(echo ${list[$((RANDOM%num))]});

if [[ -f abp_list ]]; then
        rm abp_list;
fi

eval "$kb fs ls -l /keybase/team/eos_ghostbusters/mesh" 2> /dev/null > files

echo "--------";
echo "$files";
echo "---------"

while read entry; do
	line=$(echo "$entry" | cut -d":" -f2 | cut -f2 -d" ");
	kbuser=$(echo "$line" | sed -e 's/\(.*\).peer_info.signed*/\1/');
#	eval "$kb fs read /keybase/team/eos_ghostbusters/mesh/$line" | $kb verify -S "$kbuser" &>output;
#       out=$(<output);
#       err=$(echo "$out" | grep "ERR");
#       if [[ "$err" == "" ]]; then
        peerdata=$(eval "$kb fs read /keybase/public/$kbuser/bp_info.json");
        acc=$(echo "$peerdata" | jq -r ".producer_account_name");
        pubkey=$(echo "$peerdata" | jq -r ".producer_public_key");
        echo "$kbuser :: $acc :: $pubkey";
        if [[ $acc != "" ]] && [[ $pubkey != "" ]]; then
           echo "$acc,$pubkey" >> abp_list
        fi
#       fi
done <files

echo -e "\n >> ABP List is ready!";

cat abp_list | sort | uniq > uniq_abp;

echo -e "\n\n--------- RANDOM 21 ABP LIST -------------";
cat abp_list;
echo -e "---------------------------------------------\n";

echo -e "\n\n >> Randomizing";

if [[ -f randomized_abps ]]; then
        rm randomized_abps
fi

RANDOM="$BTC_HASH"

list=($(cat uniq_abp));

num=${#list[*]}

abp_count=0;

while read entry; do
	if (( abp_count <= 21 )); then
		((abp_count++))
		ABP=$(echo ${list[$((RANDOM%num))]});
                echo "ABP Count: $abp_count - $ABP";
		echo "$ABP" >> randomized_abps
	fi
done <abp_list;

echo -e "\n\n--------- RANDOM 21 ABP LIST -------------";
cat randomized_abps;
echo -e "---------------------------------------------\n";
# Announce on Keybase channel
if ((($CURRENT_BLK - $TARGET_BLOCK) > 1)); then
        echo "You have passed the time limit to launch automatically. Please receive the genesis file through the team and launch your node";
        exit 1;
else
	announce_bios "$SELECTED_USER";
fi

# Prevent this script from auto starting in the next minute!
remove_cronjob;

start_node() {
	# Stop node if running
	./stop.sh
	# Remove old chain data
	rm -rf blocks/ state/
	# Start node
	nodeos --config-dir ./ --data-dir ./ --delete-all-blocks --genesis-json genesis.json
}

exit 1;

if [[ "$SELECTED_USER" == "$keybase_username" ]]; then
	echo "You have been chosen as bios!";
	wall "EOS Launch Time: You have been chosen as bios! - press enter to continue...";
	build_genesis;
	eval "$kb fs cp ./genesis.json /keybase/public/$keybase_username/genesis.json";
	# Download bios scripts into bios-files folder
	curl -sL https://raw.githubusercontent.com/HKEOS/Ghostbusters-Testnet/master/bios-node/getScripts.sh | bash -
	# Copy files to the bios-files folder
	cp bios_keys ./bios-files/bios_keys;
	cp ./genesis.json ./bios-files/genesis.json
else
	echo "Selected User: $SELECTED_USER";
	echo
	# Send message to any available terminal
	wall "EOS Launch Time! $SELECTED_USER was chosen as bios node! - press enter to continue...";
	echo "Waiting for genesis... 15s";
	echo
	# Wait some time for network deployment
	sleep 15;
	if ! eval "$kb fs stat /keybase/public/$SELECTED_USER/genesis.json" > /dev/null; then
		echo -e "Genesis is not ready yet - please verify this url on your browser:\n >> https://$SELECTED_USER.keybase.pub/genesis.json << \n\n";
	else
		# Download new genesis from Bios public folder
		eval "$kb fs cp /keybase/public/$SELECTED_USER/genesis.json genesis.json";
		echo "Genesis ready! Node will start now...";
		start_node;
		echo "Nodeos should have started!";
		sleep 1;
		echo "Please verify logs on stderr.txt";
		echo "----------- LAST 20 Lines --------------";
		echo
		tail -n 20 stderr.txt;
		echo
		echo "------------- END OF LOG ---------------";
	fi
fi
