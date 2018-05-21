#!/bin/bash

##########################################
## Created by
## Bohdan Kossak, CryptoLions.io
##
## Edited for Ghostbusters Testnet by
## Igor Lins e Silva, EOS Rio
## Jae Chung, HKEOS
##########################################

TAG="dawn-v4.1.0";
EOS_TARGET_VERSION="3449264167";
TESTNET="ghostbusters";

##### PARAMETERS TO BE MODIFIED ######

# EOS Source code folder, if empty - it will create the folder, download sources and compile on the specified tag
EOS_SOURCE_DIR="/path/to/eos"

# Node port definitions (avoid ports below 1024 - you shouldn't run as root)
NODE_API_PORT="<api-port>"
NODE_P2P_PORT="<p2p-port>"
# Network address (Wireguard private IP)
NODE_NET_ADDR="<net-addr>"
# Externally accessible node address (Wireguard private IP)
NODE_HOST="<server-address>"

# HTTPS Settings - Leave port blank to disable
NODE_SSL_PORT=""
SSL_PRIV_KEY="/path/to/certificate-key"
SSL_CERT_FILE="/path/to/certificate-chain"

### Node Agent Name
AGENT_NAME="<agent-name>"

### Peer Credentials (if blank will be equal to the producer keys)
PEER_PUB_KEY=""
PEER_PRIV_KEY=""

### IS A BLOCK PRODUCER ? ###
ISBP=true

### PRODUCER INFO ###
PRODUCER_PUB_KEY="<EOS-public-key>"
PRODUCER_PRIV_KEY="";
## PRODUCER NAME MUST HAVE 12 CHARS!
PRODUCER_NAME="<producer-name>"

### STANDARD BLOCK PRODUCER INFO - according to https://github.com/eosrio/bp-info-standard
### Replace username with your keybase username
PRODUCER_URL="https://<username>.keybase.pub/bp_info.json"

### WALLET INFO ###
WALLET_HOST="127.0.0.1"
WALLET_PORT="7777"

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
echo "Configuration done!";
