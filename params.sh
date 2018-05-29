#!/bin/bash

##########################################
## Created by
## Bohdan Kossak, CryptoLions.io
##
## Edited for Ghostbusters Testnet by
## Igor Lins e Silva, EOS Rio
## Jae Chung, HKEOS
## James Sutherland, Cypherglass
##########################################

TAG="dawn-v4.2.0";
EOS_TARGET_VERSION="13076119";
TESTNET="ghostbusters";

##### PARAMETERS TO BE MODIFIED ######

# Wireguard private IP
# This is used to set the HTTP addresses in the config.ini
NODE_NET_ADDR="<net-addr>"

# Wireguard private IP
# This is used to set the P2P address in the config.ini
# For most people this is the same as NODE_NET_ADDR above
NODE_HOST="<server-address>"

# This is your EOS Public key, it should start with EOS
# if you don't have one you can get one here -- https://nadejde.github.io/eos-token-sale/
PRODUCER_PUB_KEY="<EOS-public-key>"

## PRODUCER NAME MUST BE EXACTLY 12 CHARS LETTERS A-Z and Numbers 5-9
PRODUCER_NAME="<producer-name>"

# For most this can be the same as PRODUCER_NAME above
AGENT_NAME="<agent-name>"

### STANDARD BLOCK PRODUCER INFO - according to https://github.com/eosrio/bp-info-standard
### Replace username with your keybase username
PRODUCER_URL="https://<username>.keybase.pub/bp_info.json"


##### PARAMETERS BELOW HERE DON'T NEED TO BE MOFILED FOR MOST PEOPLE ######

# EOS Source code folder, if left completely blank - it will create the folder, download sources and compile on the specified tag
EOS_SOURCE_DIR=""

# You can leave this blank, you will be asked during install.
PRODUCER_PRIV_KEY=""; 

### Peer Credentials (if blank will be equal to the producer keys)
PEER_PUB_KEY=""
PEER_PRIV_KEY=""

# Node port definitions (avoid ports below 1024 - you shouldn't run as root)
# This is used to set the HTTP Port in the config.ini
NODE_API_PORT="8888"

# This is used to set the P2P Port in the config.ini
NODE_P2P_PORT="9876"

# Network address (Wireguard private IP)
# HTTPS Settings - Leave port blank to disable
NODE_SSL_PORT=""
SSL_PRIV_KEY="/path/to/certificate-key"
SSL_CERT_FILE="/path/to/certificate-chain"

### Node Agent Name
### IS A BLOCK PRODUCER ? ###
ISBP=true

### PRODUCER INFO ###
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
