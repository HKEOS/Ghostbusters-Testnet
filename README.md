# Ghostbusters Testnet Instructions

### 0. Wireguard VPN Setup

```console
sudo add-apt-repository ppa:wireguard/wireguard
sudo apt-get update
sudo apt-get install wireguard

umask 077
wg genkey | tee privatekey | wg pubkey > publickey
echo -e "[Interface]\nPrivateKey = $(cat privatekey)\nSaveConfig = true\nDNS = 1.1.1.1" > ghostbusters.conf
echo -e "ListenPort = 5555" >> ghostbusters.conf
echo -e "Address = 192.168.10.X/24" >> ghostbusters.conf
sudo cp ghostbusters.conf /etc/wireguard/.
sudo nano /etc/wireguard/ghostbusters.conf
# Add your trusted vpn peers by repeating the line below for each peer

[Peer]
PublicKey = <peer-public-key>
AllowedIPs = 192.168.10.Y/32
Endpoint = <peer-public-endpoint>:<peer-vpn-port>
PersistentKeepAlive = 20

# Save the file
```
It is recommended that you use Keybase to share information between your 6-8 trusted peers. Both you and your peer must add each other to the Wireguard config. With your trusted peers, you should share the following information:

- Wireguard Public Key
- VPN IP Address
- Peer public endpoint (IP Address or domain of node)
- VPN Port
- HTTP/API Port
- P2P Port
- EOS Public Key

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

### 1. Setup

`cd` to your `opt` folder.

```console
mkdir Ghostbusters && cd Ghostbusters
curl -s https://raw.githubusercontent.com/jchung00/Ghostbusters-Testnet/master/setup.sh | bash -
```

### 2. Fill out your info in the install script

```console
nano params.sh
```
Input your information for the highlighted fields shown below:

![gb-config](https://github.com/jchung00/Ghostbusters-Testnet/blob/master/gb-config.png)

After you have received the **p2p-peer-address** and public keys of your trusted peers, fill in the corresponding information for all of your peers in the section shown below:

![gb-peers](https://github.com/jchung00/Ghostbusters-Testnet/blob/master/gb-peers.png)

### 3. Run the script

```console
./installGhostbusters.sh
```

### 4. Publishing BP info on Keybase

**Note:** Skip parts that you have already completed.

Start by joining the eos_ghostbusters Keybase group.

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
 - Login or signup:
 ```console
 # Login
 keybase login
 # Sign up
 keybase signup
 ```
 - Save on KBFS:
 `cd` to your `Ghostbusters` folder if you are not in there already.
 ```console
 nano bp_info.json
  # add your bp info and save it!
 cp bp_info.json /keybase/public/<username>
 ```
 **Note:** You do not have to fill out your node's api_endpoint and p2p_endpoint-- this way, they can remain hidden.
 
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

### 5. Check scripts

`cd` into your Ghostbusters testnet folder, which was created from the install script.
Try `cat config.ini`, and `cat cleos.sh` to check that all the information is correct.

### 6. Setup Autolaunch

```console
sudo apt install jq

# Test script execution manually
./autolaunch.sh

# Add to CRON
./setupAutoLaunch.sh
```

### 7. Bios Node

If you were selected as the bios node, please follow instructions [here](https://github.com/jchung00/Ghostbusters-Testnet/blob/master/bios-instructions.md)

### 8. Resync

If at any point you need to restart your node:
```console
./start.sh
tail -F stderr.txt
```
