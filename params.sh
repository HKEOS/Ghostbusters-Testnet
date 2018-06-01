#!/bin/bash

##########################################
## Created by
## Bohdan Kossak, CryptoLions.io
##
## Edited for Ghostbusters Testnet by
## Igor Lins e Silva, EOS Rio
## Jae Chung, HKEOS
##########################################

TAG="DAWN-2018-05-30";
EOS_TARGET_VERSION="3655280044";
TESTNET="ghostbusters";

##### REQUIRED PARAMETERS TO BE MODIFIED ######
GLOBAL_PATH=$(pwd)
#DOCKER ATTENTION: put nodeos docker-compose.yml under the TESTNET_DIR
TESTNET_DIR="$GLOBAL_PATH/$TESTNET";

# Set port numbers for everything on the BP
#DOCKER ATTENTION: deploy by docker plase keep same with the docker port and path
API_PORT="10010"
EOS_P2P_PORT="10011"
WIREGUARD_PORT="80"
WALLET_PORT="8888"
#DOCKER ATTENTION: put keosd docker-compose.yml under the WALLET_DIR
WALLET_DIR="$GLOBAL_PATH/wallet"

# EOS Source code folder, if left completely blank - it will create the folder, download sources and compile on the specified tag
EOS_SOURCE_DIR="/path/to/eos"
USE_DOCKER=false
DOCKER_PATH="$GLOBAL_PATH/docker"
DOCKER_FILE="$DOCKER_PATH/docker-compose.yml"
NODEOSD_SNAME="nodeosd"
KEOSD_SNAME="keosd"
DOCKER_CLEOS_CMD="sudo docker-compose exec keosd /opt/eosio/bin/cleos -u http://nodeosd:$API_PORT --wallet-url http://localhost:$WALLET_PORT \"\$@\""

# Set your keybase username here
KEYBASE_USER="<your-keybase-username>"

# Enter your EOS BP Info - you can generate keys using #  cleos create key
EOS_PUBLIC_KEY=""
EOS_PRODUCER_NAME=""

#This should be the public IP for your BP for the interface tied to wireguard (if you have NAT, pls provide WAN IP and open UDP to your Wiregaurd port)
NODE_PUBLIC_IP="xxx.xxx.xxx.xxx"

### Node Agent Name - can match the BP name or be something else
AGENT_NAME="<agent-name>"

## WIREGUARD INFO
# must be in the 192.168.100.1/22 subnet
# to view available IPs please check the directory use this command # ls ~/kbfs/team/eos_ghostbusters/ip_list
# once you have chosen an IP - please run # touch ~/kbfs/team/eos_ghostbusters/ip_list/192.168.10Y.X@producername
WIREGUARD_PRIVATE_IP="192.168.10Y.X"



##### OPTIONAL SECTION ######

# HTTPS Settings - Leave port blank to disable
NODE_SSL_PORT=""
SSL_PRIV_KEY="/path/to/certificate-key"
SSL_CERT_FILE="/path/to/certificate-chain"

### Peer Credentials (if blank will be equal to the producer keys)
PEER_PUB_KEY=""
PEER_PRIV_KEY=""

### IS A BLOCK PRODUCER ? ###
ISBP=true

### PRE-DEFINED PEER LIST ###
PEER_LIST='
# p2p-peer-address = 192.168.10.Y:9876
# p2p-peer-address = <vpn-ip-address>:<p2p-port>
'

### PRE-DEFINED PEER KEYS ###
PEER_KEYS='
# peer-key = "EOS4tiVonwbmT6w5jZjxaWx8p1CkejsBtcwtn6YaqZRteKyYGQZAE"
# peer-key = "<EOS-public-key>"
'

## THIS WILL AUTOFILL FROM ABOVE

# Node port definitions (avoid ports below 1024 - you shouldn't run as root)
NODE_API_PORT="$API_PORT"
NODE_P2P_PORT="$EOS_P2P_PORT"
# Network address (Wireguard private IP)
NODE_NET_ADDR="$WIREGUARD_PRIVATE_IP"
# VPN node address (Wireguard private IP)
NODE_HOST="$WIREGUARD_PRIVATE_IP"

### PRODUCER INFO ###
PRODUCER_PUB_KEY="$EOS_PUBLIC_KEY"
# Leave blank to fill in via script later
PRODUCER_PRIV_KEY="";
# PRODUCER NAME MUST HAVE 12 CHARS EXACTLY!
PRODUCER_NAME="$EOS_PRODUCER_NAME"

### STANDARD BLOCK PRODUCER INFO - according to https://github.com/eosrio/bp-info-standard
### Replace username with your keybase username
PRODUCER_URL="https://$KEYBASE_USER.keybase.pub/bp_info.json"

### WALLET INFO - should remain localhost ###
WALLET_HOST="127.0.0.1"
WALLET_PORT="$WALLET_PORT"
