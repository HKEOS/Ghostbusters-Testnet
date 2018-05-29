# Ghostbusters Testnet Instructions

### 0. Install Keybase

**Note:** Skip parts that you have already completed.

Start by joining the eos_ghostbusters Keybase group: https://keybase.io/team/eos_ghostbusters.

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

### 2. Setup

`cd` to your `opt` folder.

```console
mkdir Ghostbusters && cd Ghostbusters
curl -sL https://raw.githubusercontent.com/HKEOS/Ghostbusters-Testnet/master/setup.sh | bash -
```
- Note
For the Ghostbusters testnet, you will need to choose 3 ports that can be whatever you want (greater than 1024):
1. wireguard VPN port - default is 5555
2. EOS API / HTTP port - some are using 8888
3. EOS P2P port - some are using 9876

- Create Wireguard keys and config
```console
umask 077
wg genkey | tee privatekey | wg pubkey > publickey
echo -e "[Interface]\nPrivateKey = $(cat privatekey)\nSaveConfig = true\nDNS = 1.1.1.1" > ghostbusters.conf
echo -e "ListenPort = 5555" >> ghostbusters.conf
echo -e "Address = 192.168.100.X/22" >> ghostbusters.conf
sudo cp ghostbusters.conf /etc/wireguard/.
```


- Selecting your Wireguard IP

Your Wireguard IP address should be within the range of 192.168.100.X to 192.168.103.X, where X is between 0 and 255, inclusive.
You can input any number for "X" in `ghostbusters.conf` that hasn't been taken by another node.
To check which IPs have been claimed:
```console
cd ~/kbfs/team/eos_ghostbusters/ip_list
ls
# You will see the list of IP addresses that have already been claimed
# Choose an address that is open
touch <your-node-name>@<chosen-ip-address>
```

This adds your a file with your IP address to the ip_list folder.

```console
sudo nano /etc/wireguard/ghostbusters.conf
# Add in the value of X that you have chosen
# Save the file
```

It is recommended that you use Keybase when communicating information related to your node.

- Publish peer information
```console
nano my-peer-info
 ## Fill in your information for PublicKey, AllowedIPs, Endpoint, p2p-peer-address, and peer-key

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

Update the params.sh file.

```console
nano params.sh
```

### 4. Run the script

```console
 # Run testnet installation script
./installGhostbusters.sh

 # update peers on the base config.ini
./updatePeers.sh
 # You can run updatePeers.sh again to automatically update Wireguard and EOS peer configs any time a new peer joins and publishes their peer info.

# other options for updatePeers.sh
./updatePeers.sh - restart # will reload nodeos after update
./updatePeers.sh lxd restart # will reload nodeos on lxd after update

 ## If you want to cleanup dead peers (wg only), run:
./peerCleanup.sh remove strict # removes all even if just wg is down
./peerCleanup.sh remove # removes just completely offline host
./peerCleanup.sh # debug mode, doesn't actually remove peers
```

### 5. Publishing BP info on Keybase

 - Save on KBFS:
 `cd` to your `Ghostbusters` folder if you are not in there already.
 ```console
 nano bp_info.json
  # add your bp info and save it!
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
