#!/bin/bash

##########################################
## Created by                           ##
## Bohdan Kossak, CryptoLions.io        ##
##                                      ##
## Edited for Ghostbusters Testnet by   ##
## Igor Lins e Silva, EOS Rio           ##
## Jae Chung, HKEOS, EOSBIXIN           ##
##########################################

source "$(dirname $0)/params.sh"

NODE_HTTP_SRV_ADDR="$NODE_NET_ADDR:$NODE_API_PORT"
NODE_P2P_LST_ENDP="$NODE_NET_ADDR:$NODE_P2P_PORT"
NODE_P2P_SRV_ADDR="$NODE_HOST:$NODE_P2P_PORT"
NODE_HTTPS_SERVER_ADDR="$NODE_HOST:$NODE_SSL_PORT"

if [[ ! $USE_DOCKER ]]; then
    if [[ $ISBP == true ]]; then
        TESTNET="$TESTNET-$PRODUCER_NAME"
    else
        TESTNET="$TESTNET-node"
    fi
    TESTNET_DIR="$GLOBAL_PATH/$TESTNET";
fi

echo "$TESTNET" > testnet.name;

BASE_CONFIG=$GLOBAL_PATH/base_config.ini;

echo "Work directory: $TESTNET";

# Validations

if [[ $ISBP == true ]]; then
    if [[ $PRODUCER_NAME == "<producer-name>" || $PRODUCER_NAME == "" ]]; then
        echo "Please define a producer name!";
        exit 1;
    fi
    if [[ ${#PRODUCER_NAME} != 12 ]]; then
        echo "Producer name must be exactly 12 characters long!";
        exit 1;
    fi
    if [[ $AGENT_NAME == "<producer-name>" || $AGENT_NAME == "" ]]; then
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

if [[ ! $USE_DOCKER && $EOS_SOURCE_DIR == "" ]]; then
    EOS_SOURCE_DIR="$GLOBAL_PATH/eos-source"
fi

# Download sources

if [[ ! $USE_DOCKER && ! -d $EOS_SOURCE_DIR ]]; then
    echo "..:: Downloading EOS Sources ::..";
    mkdir $EOS_SOURCE_DIR
    cd $EOS_SOURCE_DIR

    git clone https://github.com/eosio/eos --recursive .
    git checkout $TAG
    git submodule update --init --recursive
    ex -sc '16i|set( CORE_SYMBOL_NAME "EOS" )' -cx CMakeLists.txt
    cd $GLOBAL_PATH
fi


# Compile Sources
if [[ ! $USE_DOCKER && ! -d $EOS_SOURCE_DIR/build ]]; then
    echo "..:: Compiling EOS Sources ::..";
    cd $EOS_SOURCE_DIR
    git pull
    ./eosio_build.sh
    cd $GLOBAL_PATH
fi

if [[ ! $USE_DOCKER ]]; then
    # Check version
    EOS_GIT_BRANCH=$(git -C $EOS_SOURCE_DIR branch | grep '*' | cut -f 5 -d' ' | cut -f1 -d')');
    echo "Source code at branch $EOS_GIT_BRANCH";
    EOS_VERSION=$("$EOS_SOURCE_DIR/build/programs/nodeos/nodeos" --version)

    echo "Current nodeos version: $EOS_VERSION";
    if [[ "$EOS_VERSION" != "$EOS_TARGET_VERSION" ]]; then
        echo "Wrong version, $EOS_TARGET_VERSION required!";
        exit 1
    fi
fi

# Creating Wallet Folder and files

signature='#!/bin/bash
#######################################################
##                                                   ##
## Script Created by CryptoLions, HKEOS and EOS Rio  ##
## For EOS Ghostbusters Testnet                      ##
##                                                   ##
## https://github.com/CryptoLions                    ##
## https://github.com/eosrio                         ##
## https://github.com/HKEOS/Ghostbusters-Testnet     ##
## https://github.com/eosbixin                       ##
##                                                   ##
#######################################################\n\n';

if [[ ! -d $WALLET_DIR ]]; then
    echo "..:: Creating Wallet Dir: $WALLET_DIR ::..";
    mkdir $WALLET_DIR

    echo "..:: Creating Wallet start.sh ::..";
    # Creating start.sh for wallet
    echo -ne "$signature" > $WALLET_DIR/start.sh
    echo "DATADIR=$WALLET_DIR" >> $WALLET_DIR/start.sh
    if [[ $USE_DOCKER ]]; then
        echo "( cd $DOCKER_PATH" >> $WALLET_DIR/start.sh
        echo "sudo docker-compose stop $KEOSD_SNAME" >> $WALLET_DIR/start.sh
        echo "sudo docker-compose up -d $KEOSD_SNAME )" >> $WALLET_DIR/start.sh
        echo "echo \$! > \$DATADIR/wallet.pid" >> $WALLET_DIR/start.sh
    else
        echo "\$DATADIR/stop.sh" >> $WALLET_DIR/start.sh
        echo "$EOS_SOURCE_DIR/build/programs/keosd/keosd --data-dir \$DATADIR --http-server-address $WALLET_HOST:$WALLET_PORT \"\$@\" > $WALLET_DIR/stdout.txt 2> $WALLET_DIR/stderr.txt  & echo \$! > \$DATADIR/wallet.pid" >> $WALLET_DIR/start.sh
    fi
    echo "echo \"Wallet started\"" >> $WALLET_DIR/start.sh
    chmod u+x $WALLET_DIR/start.sh


    # Creating stop.sh for wallet
    echo -ne "$signature" > $WALLET_DIR/stop.sh
    echo "DIR=$WALLET_DIR" >> $WALLET_DIR/stop.sh
    if [[ $USE_DOCKER ]]; then
        echo "( cd $DOCKER_PATH" >> $WALLET_DIR/stop.sh
        echo "sudo docker-compose stop $KEOSD_SNAME)" >> $WALLET_DIR/stop.sh
        echo "rm -r \$DIR/wallet.pid" >> $WALLET_DIR/stop.sh
        echo "echo \"Wallet stopped\"" >> $WALLET_DIR/stop.sh
    else
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
    fi

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
    echo -ne "$signature" > $TESTNET_DIR/start.sh
    echo "DATADIR=$TESTNET_DIR" >> $TESTNET_DIR/start.sh
    echo -ne "\n";
    if [[ $USE_DOCKER ]]; then
        echo "( cd $DOCKER_PATH" >> $TESTNET_DIR/start.sh
        echo "sudo docker-compose stop $NODEOSD_SNAME" >> $TESTNET_DIR/start.sh
        echo "sudo docker-compose up -d $NODEOSD_SNAME )" >> $TESTNET_DIR/start.sh
        echo "echo \$! > \$DATADIR/nodeos.pid" >> $TESTNET_DIR/start.sh
    else
        echo "NODEOS=$EOS_SOURCE_DIR/build/programs/nodeos/nodeos" >> $TESTNET_DIR/start.sh
        echo "\$DATADIR/stop.sh" >> $TESTNET_DIR/start.sh
        echo -ne "\n";
        echo "\$NODEOS --data-dir \$DATADIR --config-dir \$DATADIR \"\$@\" > \$DATADIR/stdout.txt 2> \$DATADIR/stderr.txt &  echo \$! > \$DATADIR/nodeos.pid" >> $TESTNET_DIR/start.sh
    fi
    chmod u+x $TESTNET_DIR/start.sh


    # Creating node stop.sh
    echo "..:: Creating stop.sh ::..";
    echo -ne "$signature" > $TESTNET_DIR/stop.sh
    echo "DIR=$TESTNET_DIR" >> $TESTNET_DIR/stop.sh
    echo -ne "\n";
    if [[ $USE_DOCKER ]]; then
        echo "( cd $DOCKER_PATH" >> $TESTNET_DIR/stop.sh
        echo "sudo docker-compose stop $NODEOSD_SNAME )" >> $TESTNET_DIR/stop.sh
        echo "rm -r \$DIR/nodeos.pid" >> $TESTNET_DIR/stop.sh
        echo "echo \"rNodeos stopped\"" >> $TESTNET_DIR/stop.sh
    else
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
    fi
    chmod u+x $TESTNET_DIR/stop.sh


    # Creating cleos.sh
    echo "..:: Creating cleos.sh ::..";
    echo -ne "$signature" > $TESTNET_DIR/cleos.sh
    if [[ $USE_DOCKER ]]; then
        echo "( cd $DOCKER_PATH" >> $TESTNET_DIR/cleos.sh
        echo $DOCKER_CLEOS_CMD >> $TESTNET_DIR/cleos.sh
        echo ")" >> $TESTNET_DIR/cleos.sh
    else
        echo "CLEOS=$EOS_SOURCE_DIR/build/programs/cleos/cleos" >> $TESTNET_DIR/cleos.sh
        echo -ne "\n"
        if [[ $NODE_SSL_PORT != "" ]]; then
            echo "\$CLEOS -u https://$NODE_HTTP_SRV_ADDR:$NODE_SSL_PORT --wallet-url http://127.0.0.1:$WALLET_PORT \"\$@\"" >> $TESTNET_DIR/cleos.sh
        else
            echo "\$CLEOS -u http://$NODE_HTTP_SRV_ADDR:$NODE_API_PORT --wallet-url http://127.0.0.1:$WALLET_PORT \"\$@\"" >> $TESTNET_DIR/cleos.sh
        fi
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
    curl https://raw.githubusercontent.com/HKEOS/Ghostbusters-Testnet/master/autolaunch.sh > $TESTNET_DIR/autolaunch.sh
    chmod u+x $TESTNET_DIR/autolaunch.sh

    # setupAutoLaunch.sh
    echo "..:: Downloading setupAutoLaunch.sh ::..";
    curl https://raw.githubusercontent.com/HKEOS/Ghostbusters-Testnet/master/setupAutoLaunch.sh > $TESTNET_DIR/setupAutoLaunch.sh
    chmod u+x $TESTNET_DIR/setupAutoLaunch.sh



# config.ini
echo -ne "\n\n..:: Creating config.ini ::..\n\n";
if [[ $ISBP == true && $PRODUCER_PRIV_KEY == "" ]]; then
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

if [[ $PEER_PUB_KEY == "" ]]; then
    PEER_PUB_KEY="$PRODUCER_PUB_KEY";
fi

if [[ $PEER_PRIV_KEY == "" ]]; then
    PEER_PRIV_KEY="$PRODUCER_PRIV_KEY";
fi

echo "### EOS Ghostbusters Testnet Config file. Autogenerated by script." > $BASE_CONFIG
echo '
get-transactions-time-limit = 3
genesis-json = "'$TESTNET_DIR'/genesis.json"
block-log-dir = "'$TESTNET_DIR'/blocks"

http-server-address = '$NODE_HTTP_SRV_ADDR'
p2p-listen-endpoint = '$NODE_P2P_LST_ENDP'
p2p-server-address = '$NODE_P2P_SRV_ADDR'
access-control-allow-origin = *
' >> $BASE_CONFIG

if [[ $NODE_SSL_PORT != "" ]]; then
    echo '
# SSL
# Filename with https private key in PEM format. Required for https (eosio::http_plugin)
https-server-address = '$NODE_HTTPS_SERVER_ADDR'
# Filename with the certificate chain to present on https connections. PEM format. Required for https. (eosio::http_plugin)
https-certificate-chain-file = '$SSL_CERT_FILE'
# Filename with https private key in PEM format. Required for https (eosio::http_plugin)
https-private-key-file = '$SSL_PRIV_KEY'
    ' >> $BASE_CONFIG
else
    echo '
# SSL
# Filename with https private key in PEM format. Required for https (eosio::http_plugin)
# https-server-address =
# Filename with the certificate chain to present on https connections. PEM format. Required for https. (eosio::http_plugin)
# https-certificate-chain-file =
# Filename with https private key in PEM format. Required for https (eosio::http_plugin)
# https-private-key-file =
    ' >> $BASE_CONFIG
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

#plugin = eosio::chain_api_plugin
#plugin = eosio::history_plugin
#plugin = eosio::history_api_plugin

#plugin = eosio::net_plugin
#plugin = eosio::net_api_plugin

agent-name = '$AGENT_NAME'
' >> $BASE_CONFIG

echo 'peer-private-key = ["'$PEER_PUB_KEY'","'$PEER_PRIV_KEY'"]' >> $BASE_CONFIG;

if [[ $ISBP == true ]]; then
    echo 'private-key = ["'$PRODUCER_PUB_KEY'","'$PRODUCER_PRIV_KEY'"]' >> $BASE_CONFIG;
    echo "producer-name = $PRODUCER_NAME" >> $BASE_CONFIG;
    echo "plugin = eosio::producer_plugin" >> $BASE_CONFIG;
else
    echo '# private-key = ["'$PRODUCER_PUB_KEY'","'$PRODUCER_PRIV_KEY'"]' >> $BASE_CONFIG;
    echo "# producer-name = $PRODUCER_NAME" >> $BASE_CONFIG;
    echo "# plugin = eosio::producer_plugin" >> $BASE_CONFIG;
fi
echo "$PEER_LIST" >> $BASE_CONFIG
echo "$PEER_KEYS" >> $BASE_CONFIG
fi

########### NODE SCRIPTS #################
# Register Producer

echo '..:: Creating your registerProducer.sh ::..'
echo -ne "$signature" > $TESTNET_DIR/bp01_registerProducer.sh
echo "./cleos.sh system regproducer $PRODUCER_NAME $PRODUCER_PUB_KEY \"$PRODUCER_URL\" -p $PRODUCER_NAME" >> $TESTNET_DIR/bp01_registerProducer.sh
chmod u+x $TESTNET_DIR/bp01_registerProducer.sh

# UnRegister Producer

echo '..:: Creating your unRegisterProducer.sh ::..'
echo -ne "$signature" > $TESTNET_DIR/bp06_unRegisterProducer.sh
echo "./cleos.sh system unregprod $PRODUCER_NAME -p $PRODUCER_NAME" >> $TESTNET_DIR/bp06_unRegisterProducer.sh
chmod u+x $TESTNET_DIR/bp06_unRegisterProducer.sh


# Stake EOS Tokens
echo '..:: Creating Stake script  stakeTokens.sh ::..'
echo -ne "$signature" > $TESTNET_DIR/bp02_stakeTokens.sh
echo "#./cleos.sh system delegatebw $PRODUCER_NAME $PRODUCER_NAME \"1000.0000 EOS\" \"1000.0000 EOS\" -p $PRODUCER_NAME" >> $TESTNET_DIR/bp02_stakeTokens.sh
echo "./cleos.sh push action eosio delegatebw '{\"from\":\"$PRODUCER_NAME\", \"receiver\":\"$PRODUCER_NAME\", \"stake_net_quantity\": \"1000.0000 EOS\", \"stake_cpu_quantity\": \"1000.0000 EOS\", \"transfer\": true}' -p $PRODUCER_NAME" >> $TESTNET_DIR/bp02_stakeTokens.sh

chmod u+x $TESTNET_DIR/bp02_stakeTokens.sh

# Unstake EOS Tokens
echo '..:: Creating Unstake script  unStakeTokens.sh ::..'
echo -ne "$signature" > $TESTNET_DIR/bp05_unStakeTokens.sh
echo "./cleos.sh system undelegatebw $PRODUCER_NAME $PRODUCER_NAME \"1000.0000 EOS\" \"1000.0000 EOS\" -p $PRODUCER_NAME" >> $TESTNET_DIR/bp05_unStakeTokens.sh
chmod u+x $TESTNET_DIR/bp05_unStakeTokens.sh


# Vote Producer
echo '..:: Creating Vote script  voteProducer.sh ::..'
echo -ne "$signature" > $TESTNET_DIR/bp03_voteProducer.sh
echo "./cleos.sh system voteproducer prods $PRODUCER_NAME $PRODUCER_NAME -p $PRODUCER_NAME" >> $TESTNET_DIR/bp03_voteProducer.sh
echo "#./cleos.sh system voteproducer prods $PRODUCER_NAME $PRODUCER_NAME tiger lion -p $PRODUCER_NAME" >> $TESTNET_DIR/bp03_voteProducer.sh
chmod u+x $TESTNET_DIR/bp03_voteProducer.sh

# Claim rewards
echo '..:: Creating ClaimReward script claimReward.sh ::..'
echo -ne "$signature" > $TESTNET_DIR/bp04_claimReward.sh
echo "./cleos.sh system claimrewards $PRODUCER_NAME -p $PRODUCER_NAME" >> $TESTNET_DIR/bp04_claimReward.sh
chmod u+x $TESTNET_DIR/bp04_claimReward.sh

# This script will generate the ghostbusters.conf and my-peer-info files
cd $GLOBAL_PATH
umask 077

#generate wiregaurd keys and set source
if [ ! -f privatekey ] && [ ! -f publickey ]; then
  echo -e "Generating wireguard keys..."
  wg genkey | tee privatekey | wg pubkey > publickey
fi

#generate ghostbuster.conf
echo -e "Generating ghostbuster.conf..."
echo -e "[Interface]\nPrivateKey = $(cat privatekey)\nSaveConfig = true\nDNS = 1.1.1.1" > ghostbusters.conf
echo -e "ListenPort = $WIREGUARD_PORT" >> ghostbusters.conf
echo -e "Address = $WIREGUARD_PRIVATE_IP/22" >> ghostbusters.conf
sudo cp ghostbusters.conf /etc/wireguard/.

#Wireguard
echo -e "Generating my-peer-info file..."
echo -e "#Wireguard" >> my-peer-info
echo -e "[Peer]" > my-peer-info
echo -e "PublicKey = $(cat publickey)" >> my-peer-info
echo -e "AllowedIPs = $WIREGUARD_PRIVATE_IP/32" >> my-peer-info
echo -e "Endpoint = $NODE_PUBLIC_IP:$WIREGUARD_PORT" >> my-peer-info
echo -e "PersistentKeepAlive = 20" >> my-peer-info
echo -e "\n" >> my-peer-info
echo -e "\n" >> my-peer-info
echo -e "#EOS" >> my-peer-info
echo -e "[EOS]" >> my-peer-info
echo -e "p2p-peer-address = $WIREGUARD_PRIVATE_IP:$EOS_P2P_PORT" >> my-peer-info
echo -e "peer-key = \"$EOS_PUBLIC_KEY\"" >> my-peer-info

# FINISH MESSAGE
FINISHTEXT="\n .====================================================================.\n"
FINISHTEXT+=" |====================================================================|\n"
FINISHTEXT+=" |˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙...::: INSTALLATION COMPLETED :::...˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙|\n"
FINISHTEXT+=" |˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙|\n"
FINISHTEXT+=" |˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙- Ghostbusters Testnet Node Info -˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙|\n"
FINISHTEXT+=" | ˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙|\n"
FINISHTEXT+=" \_-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-_/\n"
FINISHTEXT+="\n"
FINISHTEXT+="\n"
FINISHTEXT+="  Your wallet password was stored in the file wallet_pass.txt\n"
FINISHTEXT+="  Please use it to unlock your wallet: ./cleos.sh wallet unlock\n"
FINISHTEXT+="\n  _____________________________________________________________________\n"
FINISHTEXT+=" |\n"
FINISHTEXT+=" | All scripts to manage your node are\n"
FINISHTEXT+=" | located in $TESTNET_DIR folder:\n"
FINISHTEXT+=" |\n"
FINISHTEXT+=" | start.sh.....................start your node\n"
FINISHTEXT+=" |\n"
FINISHTEXT+=" | stop.sh......................stop your node\n"
FINISHTEXT+=" |\n"
FINISHTEXT+=" | bp01_registerProducer.sh.....register producer\n"
FINISHTEXT+=" | .............................Use it to register in\n"
FINISHTEXT+=" | .............................the system contract\n"
FINISHTEXT+=" |\n"
FINISHTEXT+=" | bp02_stakeTokens.sh..........stake tokens\n"
FINISHTEXT+=" | .............................Use it to stake tokens before voting\n"
FINISHTEXT+=" |\n"
FINISHTEXT+=" | bp03_voteProducer.sh.........vote example\n"
FINISHTEXT+=" | .............................It will vote only in yourself.\n"
FINISHTEXT+=" | .............................You can add other producers\n"
FINISHTEXT+=" | .............................manually editing the script\n"
FINISHTEXT+=" |\n"
FINISHTEXT+=" | bp04_claimReward.sh..........claim producer rewards.\n"
FINISHTEXT+=" |\n"
FINISHTEXT+=" | bp05_unStakeTokens.sh........unstake tokens.\n"
FINISHTEXT+=" |\n"
FINISHTEXT+=" | bp06_unRegisterProducer.sh...unregister producer.\n"
FINISHTEXT+=" |\n"
FINISHTEXT+=" | If you inserted your private key, then everything is ready.\n"
FINISHTEXT+=" | So start and please wait until synced.\n"
FINISHTEXT+=" | Logs are located on stderr.txt (tail -f stderr.txt)\n"
FINISHTEXT+=" |\n"
FINISHTEXT+=" |\n"
FINISHTEXT+=" | To start/stop wallet use start.sh/stop.sh scripts in wallet folder.\n"
FINISHTEXT+=" | This installation script will start wallet by default.\n"
FINISHTEXT+=" | \n"
FINISHTEXT+=" | Installation script was disabled. To run again please chmod:\n"
FINISHTEXT+=" | chmod u+x $0\n"
FINISHTEXT+=" |\n"
FINISHTEXT+=" ._____________________________________________________________________\n\n"
echo -ne $FINISHTEXT
echo -ne $FINISHTEXT > ghostbusters.txt

echo
echo "This info was saved to ghostbusters.txt file"
echo
echo "You will now need to execute the following commands:"
echo "1 to publish your peer info to keybase >> ./publishPeerInfo my-peer-info"
echo "2 to start your wireguard interface >> sudo wg-quick up ghostbusters"
echo "3 to connect to the other ghostbusters peers >> ./updatePeers.sh"
read -n 1 -s -r -p "Press any key to continue"
echo ""
chmod 644 $0
