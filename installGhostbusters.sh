#!/bin/bash

###########################################################################
# Created by
# Bohdan Kossak, CryptoLions.io
# Edited for Ghostbusters Testnet
###########################################################################

GLOBAL_PATH=$(pwd) #GLOBAL PATH

TAG="DAWN-2018-05-16"
TESTNET="ghostbusters"

##### PARAMETERS TO BE MODIFIED ######

# EOS Source code folder, if empty - it will create the folder, download sources and compile on the specified tag
EOS_SOURCE_DIR="/path/to/eos"

# Node port definitions (avoid ports below 1024 - you shouldn't run as root)
NODE_API_PORT="<api-port>"
NODE_P2P_PORT="<p2p-port>"
# Network address, usually 0.0.0.0
NODE_NET_ADDR="<net-addr>"
# Externally accessible node address
NODE_HOST="<server-address>"

# HTTPS Settings - Leave port blank to disable
NODE_SSL_PORT=""
SSL_PRIV_KEY="/path/to/certificate-key"
SSL_CERT_FILE="/path/to/certificate-chain"

### IS A BLOCK PRODUCER ? ###
ISBP=true

### PRODUCER INFO ###
PRODUCER_PUB_KEY="<pub-key>"
PRODUCER_PRIV_KEY="";
PRODUSER_NAME="<producer-name>"
PRODUCER_AGENT_NAME="<producer-name>"

### STANDARD BLOCK PRODUCER INFO - according to https://github.com/eosrio/bp-info-standard
### Replace username with your keybase username
PRODUCER_URL="https://<username>.keybase.pub/bp_info.json"

### WALLET INFO ###
WALLET_HOST="127.0.0.1"
WALLET_PORT="<wallet-port>"

### PRE-DEFINED PEER LIST ###
PEER_LIST='
#p2p-peer-address = 192.168.10.Y:9876
p2p-peer-address = <vpn-ip-address>:<p2p-port>                         
'

### PRE-DEFINED PEER KEYS ###
PEER_KEYS='
#peer-key = EOS4tiVonwbmT6w5jZjxaWx8p1CkejsBtcwtn6YaqZRteKyYGQZAE
peer-key = <EOS-public-key>
'

### AUTO-GENERATED ###

NODE_HTTP_SRV_ADDR="$NODE_NET_ADDR:$NODE_API_PORT"
NODE_P2P_LST_ENDP="$NODE_NET_ADDR:$NODE_P2P_PORT"
NODE_P2P_SRV_ADDR="$NODE_HOST:$NODE_P2P_PORT"
NODE_HTTPS_SERVER_ADDR="$NODE_HOST:$NODE_SSL_PORT"
if [[ $ISBP == true ]]; then
TESTNET="$TESTNET-$PRODUSER_NAME"
else
TESTNET="$TESTNET-node"
fi

######################################################################################################################################################
echo -n $'\E[0;32m'
cat << "EOF"

EOF
######################################################################################################################################################
echo -n $'\E[0;37m'

# Validations

if [[ $ISBP == true ]]; then
    if [[ $PRODUSER_NAME == "<producer-name>" || $PRODUSER_NAME == "" ]]; then
        echo "Please define a producer name!";
        exit 1;
    fi
    if [[ $PRODUCER_AGENT_NAME == "<producer-name>" || $PRODUCER_AGENT_NAME == "" ]]; then
        echo "Please define an agent name!";
        exit 1;
    fi
    if [[ $PRODUCER_PUB_KEY == "<pub-key>" || $PRODUCER_PUB_KEY == "" ]]; then
        echo "Please define a producer public key!";
        exit 1;
    fi
fi

if [[ $NODE_SSL_PORT == "" ]]; then
    if [[ $NODE_API_PORT == "<api-port>" || $NODE_API_PORT == "" ]]; then
        echo "Please define a http api port!";
        exit 1;
    fi
fi

PRODUCER_PRIV_KEY_DEF="!! INSERT HERE PRIVATE KEY TO THIS PUBLIC ADDRESS !!";
TESTNET_DIR="$GLOBAL_PATH/$TESTNET"

if [[ $EOS_SOURCE_DIR == "" ]]; then
    EOS_SOURCE_DIR="$GLOBAL_PATH/eos-source"
else
    EOS_VERSION=$("$EOS_SOURCE_DIR/build/programs/nodeos/nodeos" --version)
    EOS_TARGET_VERSION="2565193790";
    echo "Current nodeos version: $EOS_VERSION";
    if [[ "$EOS_VERSION" != "$EOS_TARGET_VERSION" ]]; then
     echo "Wrong version, $EOS_TARGET_VERSION required!";
     exit 1
 fi
fi

WALLET_DIR="$GLOBAL_PATH/wallet"

# Download sources

if [[ ! -d $EOS_SOURCE_DIR ]]; then
    echo "..:: Downloading EOS Sources ::..";
    mkdir $EOS_SOURCE_DIR
    cd $EOS_SOURCE_DIR
    
    git clone https://github.com/eosio/eos --recursive .
    git checkout $TAG
    git submodule update --init --recursive
    cd $GLOBAL_PATH
fi


# Compile Sources
if [[ ! -d $EOS_SOURCE_DIR/build ]]; then
    echo "..:: Compiling EOS Sources ::..";
    cd $EOS_SOURCE_DIR
    git pull
    ./eosio_build.sh
    cd $GLOBAL_PATH
fi

# Creating Wallet Folder and files
if [[ ! -d $WALLET_DIR ]]; then
    echo "..:: Creating Wallet Dir: $WALLET_DIR ::..";
    mkdir $WALLET_DIR

    echo "..:: Creating Wallet start.sh ::..";
    # Creating start.sh for wallet
    echo "#!/bin/bash" > $WALLET_DIR/start.sh
    echo -ne "################################################################################\n#\n# Script Created by http://CryptoLions.io\n# Modified for EOS Ghostbusters testnet\n#\n# https://github.com/CryptoLions/\n#\n################################################################################\n\n" >> $WALLET_DIR/start.sh
    echo "DATADIR=$WALLET_DIR" >> $WALLET_DIR/start.sh
    echo "\$DATADIR/stop.sh" >> $WALLET_DIR/start.sh
    echo "$EOS_SOURCE_DIR/build/programs/keosd/keosd --data-dir \$DATADIR --http-server-address $WALLET_HOST:$WALLET_PORT \"\$@\" > $WALLET_DIR/stdout.txt 2> $WALLET_DIR/stderr.txt  & echo \$! > \$DATADIR/wallet.pid" >> $WALLET_DIR/start.sh
    echo "echo \"Wallet started\"" >> $WALLET_DIR/start.sh
    chmod u+x $WALLET_DIR/start.sh


    # Creating stop.sh for wallet
    echo "#!/bin/bash" > $WALLET_DIR/stop.sh
    echo -ne "################################################################################\n#\n# Scrip Created by http://CryptoLions.io\n# For EOS Junlge testnet\n#\n# https://github.com/CryptoLions/\n#\n################################################################################\n\n" >> $WALLET_DIR/stop.sh
    echo "DIR=$WALLET_DIR" >> $WALLET_DIR/stop.sh
    echo '
    if [ -f $DIR"/wallet.pid" ]; then
        pid=$(cat $DIR"/wallet.pid")
        echo $pid
        kill $pid
        rm -r $DIR"/wallet.pid"

        echo -ne "Stopping Wallet"

        while true; do
            [ ! -d "/proc/$pid/fd" ] && break
            echo -ne "."
            sleep 1
        done
        echo -ne "\rWallet stopped. \n"

    fi
    ' >>  $WALLET_DIR/stop.sh
    chmod u+x $WALLET_DIR/stop.sh

fi

#start Wallet
echo "..:: Starting Wallet ::.."
if [[ ! -f $WALLET_DIR/wallet.pid ]]; then
    $WALLET_DIR/start.sh
fi

#################### TESTNET #################################

# Creating TestNet Folder and files
if [[ ! -d $TESTNET_DIR ]]; then
    echo "..:: Creating Testnet Dir: $TESTNET_DIR ::..";

    mkdir $TESTNET_DIR

    # Creating node start.sh 
    echo "..:: Creating start.sh ::..";
    echo "#!/bin/bash" > $TESTNET_DIR/start.sh
    echo -ne "################################################################################\n#\n# Scrip Created by http://CryptoLions.io\n# For EOS Junlge testnet\n#\n# https://github.com/CryptoLions/\n#\n################################################################################\n\n" >> $TESTNET_DIR/start.sh
    echo "NODEOS=$EOS_SOURCE_DIR/build/programs/nodeos/nodeos" >> $TESTNET_DIR/start.sh
    echo "DATADIR=$TESTNET_DIR" >> $TESTNET_DIR/start.sh
    echo -ne "\n";
    echo "\$DATADIR/stop.sh" >> $TESTNET_DIR/start.sh
    echo -ne "\n";
    echo "\$NODEOS --data-dir \$DATADIR --config-dir \$DATADIR \"\$@\" > \$DATADIR/stdout.txt 2> \$DATADIR/stderr.txt &  echo \$! > \$DATADIR/nodeos.pid" >> $TESTNET_DIR/start.sh
    chmod u+x $TESTNET_DIR/start.sh


    # Creating node stop.sh 
    echo "..:: Creating stop.sh ::..";
    echo "#!/bin/bash" > $TESTNET_DIR/stop.sh
    echo -ne "################################################################################\n#\n# Scrip Created by http://CryptoLions.io\n# For EOS Junlge testnet\n#\n# https://github.com/CryptoLions/\n#\n################################################################################\n\n" >> $TESTNET_DIR/stop.sh
    echo "DIR=$TESTNET_DIR" >> $TESTNET_DIR/stop.sh
    echo -ne "\n";
    echo '
    if [ -f $DIR"/nodeos.pid" ]; then
        pid=$(cat $DIR"/nodeos.pid")
        echo $pid
        kill $pid
        rm -r $DIR"/nodeos.pid"

        echo -ne "Stopping Nodeos"

        while true; do
            [ ! -d "/proc/$pid/fd" ] && break
            echo -ne "."
            sleep 1
        done
        echo -ne "\rNodeos stopped. \n"

    fi
    ' >>  $TESTNET_DIR/stop.sh
    chmod u+x $TESTNET_DIR/stop.sh


    # Creating cleos.sh 
    echo "..:: Creating cleos.sh ::..";
    echo "#!/bin/bash" > $TESTNET_DIR/cleos.sh
    echo -ne "################################################################################\n#\n# Scrip Created by http://CryptoLions.io\n# For EOS Junlge testnet\n#\n# https://github.com/CryptoLions/\n#\n################################################################################\n\n" >> $TESTNET_DIR/cleos.sh
    echo "CLEOS=$EOS_SOURCE_DIR/build/programs/cleos/cleos" >> $TESTNET_DIR/cleos.sh
    echo -ne "\n"
    if [[ $NODE_SSL_PORT != "" ]]; then
     echo "\$CLEOS -u https://127.0.0.1:$NODE_SSL_PORT --wallet-url http://127.0.0.1:$WALLET_PORT \"\$@\"" >> $TESTNET_DIR/cleos.sh
     echo "#\$CLEOS -u http://127.0.0.1:$NODE_API_PORT --wallet-url http://127.0.0.1:$WALLET_PORT \"\$@\"" >> $TESTNET_DIR/cleos.sh
 else
     echo "\$CLEOS -u http://127.0.0.1:$NODE_API_PORT --wallet-url http://127.0.0.1:$WALLET_PORT \"\$@\"" >> $TESTNET_DIR/cleos.sh
     echo "#\$CLEOS -u https://127.0.0.1:$NODE_SSL_PORT --wallet-url http://127.0.0.1:$WALLET_PORT \"\$@\"" >> $TESTNET_DIR/cleos.sh


 fi
    chmod u+x $TESTNET_DIR/cleos.sh
    
    # schema.json
    echo "..:: Downloading schema.json ::..";
    curl https://raw.githubusercontent.com/eosrio/bp-info-standard/master/schema.json > schema.json

    # bp_info_sample.json
    echo "..:: Downloading bp_info_sample.json ::..";
    curl https://raw.githubusercontent.com/eosrio/bp-info-standard/master/bp_info_sample.json > bp_info_sample.json
    
    # autolaunch.sh
    echo "..:: Downloading autolaunch.sh ::..";
    curl https://raw.githubusercontent.com/jchung00/Ghostbusters-Testnet/master/autolaunch.sh > $TESTNET_DIR/autolaunch.sh
    chmod u+x $TESTNET_DIR/autolaunch.sh
    
    # setupAutoLaunch.sh
    echo "..:: Downloading setupAutoLaunch.sh ::..";
    curl https://raw.githubusercontent.com/jchung00/Ghostbusters-Testnet/master/setupAutoLaunch.sh > $TESTNET_DIR/setupAutoLaunch.sh
    chmod u+x $TESTNET_DIR/setupAutoLaunch.sh
    


# config.ini 
echo -ne "\n\n..:: Creating config.ini ::..\n\n";
if [[ $ISBP == true && $PRODUCER_PRIV_KEY -eq "" ]]; then 
	echo -n $'\E[0;33m'
	echo "!!! PRIV KEY SECTION !!! You can enter your private key here and it will be imported in wallet and inserted in config.ini. I can skip this step (Enter) and do it manually before start"
	echo -ne "PRIV KEY (Enter skip):"
	read PRODUCER_PRIV_KEY
	echo -n $'\E[0;37m'
fi

if [[ $ISBP == true ]]; then
	if [[ $PRODUCER_PRIV_KEY == "" ]]; then 
		PRODUCER_PRIV_KEY=$PRODUCER_PRIV_KEY_DEF
	else 
		if [[ ! -f $WALLET_DIR/default.wallet ]]; then
	     WALLET_LOG=$( $TESTNET_DIR/cleos.sh wallet create)
	     echo "$WALLET_LOG" > wallet_pass.txt
	 fi
 fi

 $TESTNET_DIR/cleos.sh wallet import $PRODUCER_PRIV_KEY	
fi


echo "### EOS Ghostbusters Testnet Config file. Autogenerated by script." > $TESTNET_DIR/config.ini
echo '
get-transactions-time-limit = 3
genesis-json = "'$TESTNET_DIR'/genesis.json"
block-log-dir = "'$TESTNET_DIR'/blocks"

http-server-address = '$NODE_HTTP_SRV_ADDR'
p2p-listen-endpoint = '$NODE_P2P_LST_ENDP'
p2p-server-address = '$NODE_P2P_SRV_ADDR'
access-control-allow-origin = *

' >> $TESTNET_DIR/config.ini

if [[ $NODE_HTTPS_SERVER_ADDR != "" ]]; then
    echo '
    # SSL
    # Filename with https private key in PEM format. Required for https (eosio::http_plugin)
    https-server-address = '$NODE_HTTPS_SERVER_ADDR'
    # Filename with the certificate chain to present on https connections. PEM format. Required for https. (eosio::http_plugin)
    https-certificate-chain-file = '$SSL_CERT_FILE'
    # Filename with https private key in PEM format. Required for https (eosio::http_plugin)
    https-private-key-file = '$SSL_PRIV_KEY'

    ' >> $TESTNET_DIR/config.ini
else
    echo '
    # SSL
    # Filename with https private key in PEM format. Required for https (eosio::http_plugin)
    # https-server-address =
    # Filename with the certificate chain to present on https connections. PEM format. Required for https. (eosio::http_plugin)
    # https-certificate-chain-file =
    # Filename with https private key in PEM format. Required for https (eosio::http_plugin)
    # https-private-key-file =

    ' >> $TESTNET_DIR/config.ini

fi


echo '
allowed-connection = specified

log-level-net-plugin = info
max-clients = 120
connection-cleanup-period = 30
network-version-match = 1
sync-fetch-span = 2000
enable-stale-production = false
required-participation = 33

plugin = eosio::chain_api_plugin
plugin = eosio::history_plugin
plugin = eosio::history_api_plugin
plugin = eosio::chain_plugin

#plugin = eosio::net_plugin
#plugin = eosio::net_api_plugin

agent-name = '$PRODUCER_AGENT_NAME'

' >> $TESTNET_DIR/config.ini

if [[ $ISBP == true ]]; then
    echo '
    plugin = eosio::producer_plugin
    private-key = ["'$PRODUCER_PUB_KEY'","'$PRODUCER_PRIV_KEY'"]
    producer-name = '$PRODUSER_NAME'
    peer-private-key = ["'$PRODUCER_PUB_KEY'","'$PRODUCER_PRIV_KEY'"]
    ' >> $TESTNET_DIR/config.ini
else 
    echo '
    #plugin = eosio::producer_plugin
    #private-key = ["'$PRODUCER_PUB_KEY'","'$PRODUCER_PRIV_KEY'"]
    #peer-private-key = ["'$PRODUCER_PUB_KEY'","'$PRODUCER_PRIV_KEY'"]
    #producer-name = '$PRODUSER_NAME'
    ' >> $TESTNET_DIR/config.ini

fi

echo "$PEER_LIST" >> $TESTNET_DIR/config.ini

echo "$PEER_KEYS" >> $TESTNET_DIR/config.ini

fi

###############################
# Register Producer

echo '..:: Creating your registerProducer.sh ::..'

echo "#!/bin/bash" > $TESTNET_DIR/bp01_registerProducer.sh
echo -ne "################################################################################\n#\n# Script Created by CryptoLions, HKEOS and EOS Rio\n# For EOS Ghostbusters Testnet\n#\n# https://github.com/CryptoLions/\n#\n################################################################################\n\n" >> $TESTNET_DIR/bp01_registerProducer.sh
echo "./cleos.sh system regproducer $PRODUSER_NAME $PRODUCER_PUB_KEY \"$PRODUCER_URL\" -p $PRODUSER_NAME" >> $TESTNET_DIR/bp01_registerProducer.sh
chmod u+x $TESTNET_DIR/bp01_registerProducer.sh

# UnRegister Producer

echo '..:: Creating your unRegisterProducer.sh ::..'

echo "#!/bin/bash" > $TESTNET_DIR/bp06_unRegisterProducer.sh
echo -ne "################################################################################\n#\n# Script Created by CryptoLions, HKEOS and EOS Rio\n# For EOS Ghostbusters Testnet\n#\n# https://github.com/CryptoLions/\n#\n################################################################################\n\n" >> $TESTNET_DIR/bp06_unRegisterProducer.sh
echo "./cleos.sh system unregprod $PRODUSER_NAME -p $PRODUSER_NAME" >> $TESTNET_DIR/bp06_unRegisterProducer.sh
chmod u+x $TESTNET_DIR/bp06_unRegisterProducer.sh


# Stake Coins
echo '..:: Creating Stake script  stakeTokens.sh ::..'

echo "#!/bin/bash" > $TESTNET_DIR/bp02_stakeTokens.sh
echo -ne "################################################################################\n#\n# Script Created by CryptoLions, HKEOS and EOS Rio\n# For EOS Ghostbusters Testnet\n#\n# https://github.com/CryptoLions/\n#\n################################################################################\n\n" >> $TESTNET_DIR/bp02_stakeTokens.sh
echo "#./cleos.sh system delegatebw $PRODUSER_NAME $PRODUSER_NAME \"1000.0000 EOS\" \"1000.0000 EOS\" -p $PRODUSER_NAME" >> $TESTNET_DIR/bp02_stakeTokens.sh
echo "./cleos.sh push action eosio delegatebw '{\"from\":\"$PRODUSER_NAME\", \"receiver\":\"$PRODUSER_NAME\", \"stake_net_quantity\": \"1000.0000 EOS\", \"stake_cpu_quantity\": \"1000.0000 EOS\", \"transfer\": true}' -p $PRODUSER_NAME" >> $TESTNET_DIR/bp02_stakeTokens.sh

chmod u+x $TESTNET_DIR/bp02_stakeTokens.sh

# Unstake Coins
echo '..:: Creating UnStake script  unStakeTokens.sh ::..'

echo "#!/bin/bash" > $TESTNET_DIR/bp05_unStakeTokens.sh
echo -ne "################################################################################\n#\n# Script Created by CryptoLions, HKEOS and EOS Rio\n# For EOS Ghostbusters Testnet\n#\n# https://github.com/CryptoLions/\n#\n################################################################################\n\n" >> $TESTNET_DIR/bp05_unStakeTokens.sh
echo "./cleos.sh system undelegatebw $PRODUSER_NAME $PRODUSER_NAME \"1000.0000 EOS\" \"1000.0000 EOS\" -p $PRODUSER_NAME" >> $TESTNET_DIR/bp05_unStakeTokens.sh
chmod u+x $TESTNET_DIR/bp05_unStakeTokens.sh


# Vote Producer
echo '..:: Creating Vote script  voteProducer.sh ::..'

echo "#!/bin/bash" > $TESTNET_DIR/bp03_voteProducer.sh
echo -ne "################################################################################\n#\n# Script Created by CryptoLions, HKEOS and EOS Rio\n# For EOS Ghostbusters Testnet\n#\n# https://github.com/CryptoLions/\n#\n################################################################################\n\n" >> $TESTNET_DIR/bp03_voteProducer.sh
echo "./cleos.sh system voteproducer prods $PRODUSER_NAME $PRODUSER_NAME -p $PRODUSER_NAME" >> $TESTNET_DIR/bp03_voteProducer.sh
echo "#./cleos.sh system voteproducer prods $PRODUSER_NAME $PRODUSER_NAME tiger lion -p $PRODUSER_NAME" >> $TESTNET_DIR/bp03_voteProducer.sh
chmod u+x $TESTNET_DIR/bp03_voteProducer.sh

# Claim rewards
echo '..:: Creating ClaimReward script claimReward.sh ::..'

echo "#!/bin/bash" > $TESTNET_DIR/bp04_claimReward.sh
echo -ne "################################################################################\n#\n# Script Created by CryptoLions, HKEOS and EOS Rio\n# For EOS Ghostbusters Testnet\n#\n# https://github.com/CryptoLions/\n#\n################################################################################\n\n" >> $TESTNET_DIR/bp04_claimReward.sh
echo "./cleos.sh system claimrewards $PRODUSER_NAME -p $PRODUSER_NAME" >> $TESTNET_DIR/bp04_claimReward.sh
chmod u+x $TESTNET_DIR/bp04_claimReward.sh

# FINISH

FINISHTEXT="\n.=================================================================================.\n"
FINISHTEXT+="|=================================================================================|\n"
FINISHTEXT+="|˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙...::: INSTALLATION COMPLETED :::...˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙|\n"
FINISHTEXT+="|˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙|\n"
FINISHTEXT+="|˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙- Ghostbusters Testnet Node Info -˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙|\n"
FINISHTEXT+="| ˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙|\n"
FINISHTEXT+="\_-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-_/\n"
FINISHTEXT+="\n"
FINISHTEXT+="\n"
FINISHTEXT+="Your wallet password was stored in the file wallet_pass.txt. Please use it to unlock your wallet:\n"
FINISHTEXT+="./cleos.sh wallet unlock\n"
FINISHTEXT+="\n"
FINISHTEXT+="All scripts to manage your node are located in $TESTNET_DIR folder:\n"
FINISHTEXT+="  start.sh - start your node. If you inserted your private key, then everything is ready. So start and please wait until synced.\n"
FINISHTEXT+="  stop.sh - stop your node\n"
FINISHTEXT+="  bp01_registerProducer.sh - register producer. Use it to register in the system contract.\n"
FINISHTEXT+="  bp02_stakeTokens.sh - stake tokens. Use it to stake tokens before voting.\n"
FINISHTEXT+="  bp03_voteProducer.sh - vote example. This example will vote only in yourself. You can add other producers manually in script.\n"
FINISHTEXT+="  bp04_claimReward.sh - claim producer rewards.\n"
FINISHTEXT+="  bp05_unStakeTokens.sh - unstake tokens.\n"
FINISHTEXT+="  bp06_unRegisterProducer.sh - unregister producer.\n"
FINISHTEXT+="  stderr.txt - node logs file\n"
FINISHTEXT+="\n"
FINISHTEXT+="\n"
FINISHTEXT+="To start/stop wallet use start.sh/stop.sh scripts in wallet folder. This installation script will start wallet by default.\n"
FINISHTEXT+="\n"
FINISHTEXT+="Installation script was disabled. To run again please chmod:\n"
FINISHTEXT+="chmod u+x $0\n"
FINISHTEXT+="\n"
FINISHTEXT+=". - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n"

echo -n $'\E[0;32m'
echo -ne $FINISHTEXT
echo -ne $FINISHTEXT > ghostbusters.txt

echo ""
echo "This info was saved to ghostbusters.txt file"
echo ""
read -n 1 -s -r -p "Press any key to continue"


chmod 644 $0
