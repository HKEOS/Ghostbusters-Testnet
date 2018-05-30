# Ghostbusters Testnet Instructions

### 0. Install Keybase

**Note:** Skip parts that you have already completed.

Start by joining the eos_ghostbusters Keybase group: https://keybase.io/team/eos_ghostbusters.

If you don't already have keybase, you will need to install it and verify your identity. Join requests to the eos_ghostbusters group require a verified keybase identity.

It is recommended that you use Keybase chat when communicating information related to your node. There are keybase clients for every OS and mobile. Keybase is very secure and all of the BPs are relying on it.

- Install keybase: https://keybase.io/docs/the_app/install_linux

 Ubuntu instructions - do not install as root user, please use sudo where appropriate
 ```console
# Install curl if required
sudo apt install curl

curl -O https://prerelease.keybase.io/keybase_amd64.deb
# if you see an error about missing `libappindicator1`
# from the next command, you can ignore it, as the
# subsequent command corrects it
sudo dpkg -i keybase_amd64.deb
sudo apt-get install -f
run_keybase
 ```

 - Mandatory step: modify keybase default storage path for kbfs
 ```console
 curl -sL https://raw.githubusercontent.com/hkeos/Ghostbusters-Testnet/master/keybase_relocate.sh | bash -
 ```

 - Login or signup:
 ```console
 # Login
 keybase login
 # Sign up
 keybase signup
 ```

### 1. Wireguard Setup

- Install Wireguard
```console
sudo add-apt-repository ppa:wireguard/wireguard
sudo apt-get update
sudo apt-get install wireguard resolvconf
```

### 2. Setup Node

`cd` to your `opt` folder.

```console
mkdir Ghostbusters && cd Ghostbusters
curl -sL https://raw.githubusercontent.com/hkeos/Ghostbusters-Testnet/master/setup.sh | bash -
```
- Note
For the Ghostbusters testnet, you will need to choose 4 ports that can be whatever you want - we encourage diversity! Please write down what you plan to use for each of these so that you have it as a guide moving forward. (Ports must greater than 1024 unless you run as root and NO ONE should run as root).

1. Wireguard VPN port - default is 5555 - pls do not to use defaults
2. EOS API / HTTP port - default is 8888 - pls do not to use defaults
3. EOS P2P port - default is 9876 - pls do not to use defaults
4. Wallet port used by `keosd` - this is only for localhost connections - default is 7777

- Selecting your Wireguard IP and port

Your Wireguard IP address should be within the range of 192.168.100.X to 192.168.103.X, where X is between 0 and 255, inclusive.

To check which IPs have been claimed:
```console
cd ~/kbfs/team/eos_ghostbusters/ip_list
ls
# You will see the list of IP addresses that have already been claimed
# Choose an address that is open
touch <chosen-ip-address>@<your-node-name>
This adds a file with your IP address to the ip_list folder in an easy to sort format.
```

Check firewall settings, and make sure that port you chose for your wireguard is open.

If you are using lxd, then you will need to forward ports from your WAN IP. If you are using AWS, then you will need to edit your security policy.

If you use ufw on Ubuntu, you can use:
```console
sudo ufw allow 5555
```

### 3. Fill out your info in the install script

```console
cd /opt/Ghostbusters
nano params.sh

Please update your information in the fields above ## OPTIONAL ### (the rest are optional):
```console
EOS_SOURCE_DIR="/opt/eos"
API_PORT=""
EOS_P2P_PORT=""
WIREGUARD_PORT=""
WALLET_PORT="7777"
KEYBASE_USER="<yourkeybaseusername>"
EOS_PUBLIC_KEY=""
EOS_PRODUCER_NAME=""
NODE_PUBLIC_IP="xxx.xxx.xxx.xxx"
AGENT_NAME="<agent-name>"
WIREGUARD_PRIVATE_IP="192.168.10Y.X"
```


**Note:** Producer name must be exactly **12 characters** long!

### 4. Run the script

```console
 # Run testnet installation script
./installGhostbusters.sh


Then, start Wireguard and check if it's working.

```console
# Start wireguard
sudo wg-quick up ghostbusters
# Test configuration
sudo wg show ghostbusters
# If at any time you want to reload the network interface
sudo ip link del dev ghostbusters && sudo wg-quick up ghostbusters.conf


 # update peers on the base config.ini
./updatePeers.sh
 # You can run updatePeers.sh again to automatically update Wireguard and EOS peer configs any time a new peer joins and publishes their peer info.

# You can check your communication with other peers
sudo wg show

# Count your handshakes with peers
sudo wg show|grep hand|wc -l

# other options for updatePeers.sh
./updatePeers.sh - restart # will reload nodeos after update
./updatePeers.sh lxd restart # will reload nodeos on lxd after update

 ## If you want to cleanup dead peers (wg only), run:
./peerCleanup.sh remove strict # removes all even if just wg is down
./peerCleanup.sh remove # removes just completely offline host
./peerCleanup.sh # debug mode, doesn't actually remove peers
```

```console
## If you change your wireguard IP, here is where you need to update it

nano /path/to/Ghostbusters/my-peer-info
/path/to/Ghostbusters/publishPeerInfo.sh my-peer-info
nano /path/to/Ghostbusters/base_config.ini
nano /path/to/Ghostbusters/params.sh
nano /path/to/Ghostbusters/ghostbusters-<your-producername>/config.ini
#then you need to restart your wireguard
cd /opt/Ghostbusters
sudo ip link del dev ghostbusters && sudo wg-quick up ghostbusters.conf

# Ask team members to update peers
```


### 5. Publishing BP info on Keybase

 - Save on KBFS:
 `cd` to your `Ghostbusters` folder if you are not in there already.
 ```console
 nano bp_info.json
# add your basic bp info and save it! at a minimum you will need the producer_account_name,
# producer_public_key. Bonus points if you add your LAT and LONG for the map.
#  "producer_account_name": "<producername>",
#  "producer_public_key": "<eos-producer-public-key>",

 cp bp_info.json ~/kbfs/public/<username>
 ```
 **Note:** You do not have to fill out your BP node's api_endpoint and p2p_endpoint-- this way, they can remain hidden from public.

 - Check that file is up on `https://<username>.keybase.pub/bp_info.json`

#### 5.1 BP Info verification (optional)

 You can verify that bp_info.json correctly follows the schema using command line. We recommend ajv-cli for the job.

 If npm is not installed:
 ```console
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs
 ```
 `schema.json` should have been generated from the Ghostbusters install script from earlier, and your `bp_info.json` file should be in there too.
 ```console
 sudo npm install -g ajv-cli
 ajv validate -s schema.json -d bp_info.json
```

### 6. Check scripts

`cd` into your Ghostbusters testnet folder, which was created from the install script.
Try `cat config.ini`, and `cat cleos.sh` to check that all the information is correct.

### 7. Setup Autolaunch

```console
sudo apt install jq
crontab -e
# Select nano (if you are initializing cron for the first time)
# Exit
```

Run `autolaunch.sh` when the team (on Keybase) is ready to queue up and launch. Run `autolaunch.sh` on only one of your nodes, and manually launch the rest of them when the genesis.json file is published.

```console
# Run autolaunch, answer questions prompted by script
./autolaunch.sh

# If the target BTC block was not reached at runtime,
# it will schedule itself on CRON, please verify with
crontab -e
```
If `autolaunch.sh` doesn't start your node correctly, run the following command:
```console
./start.sh --delete-all-blocks --genesis-json ./genesis.json
```

### 8. Bios Node

If you were selected as the bios node, please follow instructions [here](https://github.com/hkeos/Ghostbusters-Testnet/blob/master/bios-node/bios-instructions.md)

### 9. Resync

If at any point you need to restart your node:
```console
./start.sh
tail -F stderr.txt

# Hard resync
./start.sh --delete-all-blocks --hard-replay-blockchain
tail -F stderr.txt
```
You can also update your peers and restart at the same time:
```console
./updatePeers - restart
```
