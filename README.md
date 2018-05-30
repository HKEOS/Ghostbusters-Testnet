# Ghostbusters Testnet Instructions

### 0. Install Keybase

**Note:** Skip parts that you have already completed.

Start by joining the eos_ghostbusters Keybase group: https://keybase.io/team/eos_ghostbusters.

If you don't already have keybase, you will need to install it and verify your identity. Join requests to the eos_ghostbusters group require a verified keybase identity.

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
 curl -sL https://raw.githubusercontent.com/HKEOS/Ghostbusters-Testnet/master/keybase_relocate.sh | bash -
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
curl -sL https://raw.githubusercontent.com/HKEOS/Ghostbusters-Testnet/master/setup.sh | bash -
```
- Note
For the Ghostbusters testnet, you will need to choose 4 ports that can be whatever you want - we encourage diversity! Please write down what you plan to use for each of these so that you have it as a guide moving forward. (Ports must greater than 1024 unless you run as root and NO ONE should run as root):
1. Wireguard VPN port - default is 5555
2. EOS API / HTTP port - default is 8888
3. EOS P2P port - default is 9876
4. Wallet port used by `keosd` - this is only for localhost connections - default is 7777

- Create Wireguard keys and config
```console
umask 077
wg genkey | tee privatekey | wg pubkey > publickey
echo -e "[Interface]\nPrivateKey = $(cat privatekey)\nSaveConfig = true\nDNS = 1.1.1.1" > ghostbusters.conf
echo -e "ListenPort = 5555" >> ghostbusters.conf
echo -e "Address = 192.168.100.X/22" >> ghostbusters.conf
sudo cp ghostbusters.conf /etc/wireguard/.
```


- Selecting your Wireguard IP and port

To check which IPs have been claimed:
```console
cd ~/kbfs/team/eos_ghostbusters/ip_list
ls
# You will see the list of IP addresses that have already been claimed
# Choose an address that is open
touch <your-node-name>@<chosen-ip-address>
This adds a file with your IP address to the ip_list folder.
```

Your Wireguard IP address should be within the range of 192.168.100.X to 192.168.103.X, where X is between 0 and 255, inclusive.
You can input any number for "X" in `ghostbusters.conf` that hasn't been taken by another node.
You can put any number in place of "5555" in `ghostbusters.conf` - this is your VPN port.

```console
sudo nano /etc/wireguard/ghostbusters.conf
# Add in the value of X that you have chosen where it says 192.168.100.x/22 - do not change /22 please
$ Add in the port number you have chosen where it says ListenPort = 5555
# Save the file
```
It is recommended that you use Keybase chat when communicating information related to your node. There are keybase clients for every OS and mobile.

- Publish peer information
```console
nano my-peer-info
 ## Fill in your information for the Wireguard VPN setup
 ## PublicKey - from the publickey file that should be in your /Ghostbusters folder   
 ## AllowedIPs - your wireguard IP (from ghostbusters.conf) do not change the /32, only the IP
 ## Endpoint - this should be your public IP or hostname
 ## p2p-peer-address - your wireguard IP and your EOS p2p port
 ## peer-key - EOS Public Key for your BP

 ## then run this script  
./publishPeerInfo.sh my-peer-info
```

Check firewall settings, and make sure that port 5555 is open. If not, you can use:
```console
sudo ufw allow 5555
```

Then, start Wireguard and check if it's working.

```console
# Start wireguard
sudo wg-quick up ghostbusters
# Test configuration
sudo wg show ghostbusters
# If at any time you want to reload the network interface
sudo ip link del dev ghostbusters && sudo wg-quick up ghostbusters
```

### 3. Fill out your info in the install script

```console
nano params.sh
```
Input your information for the highlighted fields shown below:

![gb-config](https://github.com/HKEOS/Ghostbusters-Testnet/blob/master/gb-config.png)

**Note:** Producer name must be exactly **12 characters** long!

### 4. Run the script

```console
 # Run testnet installation script
./installGhostbusters.sh

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

nano /opt/Ghostbusters/my-peer-info
/opt/Ghostbusters/publishPeerInfo.sh my-peer-info
nano /opt/Ghostbusters/ghostbusters
nano /opt/Ghostbusters/base_config.ini
nano /opt/Ghostbusters/params.sh
nano /opt/Ghostbusters/ghostbusters-yourproducername/config.ini
#then you need to restart your wireguard
cd /opt/Ghostbusters
sudo ip link del dev ghostbusters && sudo wg-quick up ghostbusters.conf
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

If you were selected as the bios node, please follow instructions [here](https://github.com/HKEOS/Ghostbusters-Testnet/blob/master/bios-node/bios-instructions.md)

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
