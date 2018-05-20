# Ghostbusters Testnet Instructions

### 0. Install Keybase

**Note:** Skip parts that you have already completed.

Start by joining the eos_ghostbusters Keybase group: https://keybase.io/team/eos_ghostbusters.

- Install keybase: https://keybase.io/docs/the_app/install_linux
 Ubuntu instructions
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

### 1. Wireguard VPN Setup

- Install Wireguard
```console
sudo add-apt-repository ppa:wireguard/wireguard
sudo apt-get update
sudo apt-get install wireguard
```

- Create Wireguard keys and config
```console
umask 077
wg genkey | tee privatekey | wg pubkey > publickey
echo -e "[Interface]\nPrivateKey = $(cat privatekey)\nSaveConfig = true\nDNS = 1.1.1.1" > ghostbusters.conf
echo -e "ListenPort = 5555" >> ghostbusters.conf
echo -e "Address = 192.168.100.X/22" >> ghostbusters.conf
sudo cp ghostbusters.conf /etc/wireguard/.
sudo nano /etc/wireguard/ghostbusters.conf
# You can input any number for "X" that hasn't been taken by another node.
# X Can be any integer between 0 and 255, inclusive.
# The full range is 192.168.100.0 to 192.168.103.255

# Save the file
```
It is recommended that you use Keybase when communicating information related to your node.

### 2. Setup

`cd` to your `opt` folder.

```console
mkdir Ghostbusters && cd Ghostbusters
curl -sL https://raw.githubusercontent.com/HKEOS/Ghostbusters-Testnet/master/setup.sh | bash -
```

- Publish and update peers
```console
nano my-peer-info
# Fill in your information

./publishPeerInfo.sh my-peer-info

./updatePeers.sh

# If you want to cleanup dead peers, run:
./peerCleanup.sh remove strict # removes all even if just wg is down
./peerCleanup.sh remove # removes just completely offline host
./peerCleanup.sh # debug mode, don't remove
```
You can run updatePeers.sh again to update Wireguard config any time a new peer joins and publishes their peer info.

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
./installGhostbusters.sh
```

### 5. Publishing BP info on Keybase

 - Save on KBFS:
 `cd` to your `Ghostbusters` folder if you are not in there already.
 ```console
 nano bp_info.json
  # add your bp info and save it!
 cp bp_info.json /keybase/public/<username>
 ```
 **Note:** You do not have to fill out your BP node's api_endpoint and p2p_endpoint-- this way, they can remain hidden from public.
 
 - Check that file is up on `https://<username>.keybase.pub/bp_info.json`
 
 You can verify that bp_info.json correctly follows the schema using command line.
 
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

# Make sure you don't have a genesis.json file on your public keybase folder...
sudo rm /keybase/public/<username>/genesis.json

# Test script execution manually
./autolaunch.sh

# If the target BTC block was not reached at runtime,
# it will schedule itself on CRON, please verify with
crontab -e

# Add to CRON (if required)
./setupAutoLaunch.sh
```

### 8. Bios Node

If you were selected as the bios node, please follow instructions [here](https://github.com/HKEOS/Ghostbusters-Testnet/blob/master/bios-node/bios-instructions.md)

### 9. Resync

If at any point you need to restart your node:
```console
./start.sh
tail -F stderr.txt
```
