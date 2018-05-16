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

# Save the file
```
It is recommended that you use Keybase to share information between trusted peers. Both you and your peer must add each other to the Wireguard config.

Check firewall settings, and make sure that port 5555 is open. If not, you can use:
```console
sudo ufw allow 5555
```

Then, start Wireguard and check that it is working.

```console
# Start wireguard
sudo wg-quick up ghostbusters
# Test configuration
sudo wg show ghostbusters
```

### 1. Setup

`cd` to your `opt` folder.

```console
mkdir Ghostbusters
cd Ghostbusters
curl -O https://raw.githubusercontent.com/jchung00/Ghostbusters-Testnet/master/installGhostbusters.sh > installGhostbusters.sh
```

### 2. Fill out info in install script

```console
nano installGhostbusters.sh
```
Input your information for the highlighted fields shown below:

![gb-config](https://github.com/jchung00/Ghostbusters-Testnet/blob/master/gb-config.png)

### 3. Run the script

```console
sudo chmod u+x installGhostbusters.sh
./installGhostbusters.sh
```

### 4. Publishing BP info on Keybase

**Note:** Skip parts that you have already completed.

To begin with, join the eos_ghostbusters Keybase group.

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
 ```console
 cd /keybase/public/<username>
 curl -O https://raw.githubusercontent.com/eosrio/bp-info-standard/master/bp_info_sample.json > bp_info.json
 nano bp_info.json
 # add your bp info and save it!
 ```
 **Note:** You do not have to fill out your node's api_endpoint and p2p_endpoint-- this way, they can remain hidden.
 
 - Verify file on `https://<username>.keybase.pub/bp_info.json`
 
 You can also verify using command line.
 
 If npm is not installed:
 ```console
 sudo apt-get update
 curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
 sudo apt-get install -y nodejs
 ```
 Now `cd` to your `Ghostbusters` folder if you are not in there already. `schema.json` should have been generated from the Ghostbusters install script from earlier, and your `bp_info.json` file should be in there too.
 ```console
 sudo npm install -g ajv-cli
 ajv validate -s schema.json -d /keybase/public/<username>/bp_info.json
```

### 5. Check scripts

`cd` into your Ghostbusters testnet folder, which was created from the install script.
Try `cat config.ini`, and `cat cleos.sh` to check that all the information is correct.

### 6. Add peers

***Still need to define this step better with the web of trust idea. Should refer to launch status spreadsheet. Merge with step 0?***

##### 6.1 Bios Node

If you were selected as the bios node, please follow instructions [here](https://github.com/jchung00/Ghostbusters-Testnet/blob/master/bios-instructions.md)

### 7. Receive genesis file

*Find link published by bios node*

*Use `keybase verify`*

***Need further directions for this***

### 8. Sync

```console
./start.sh
tail -F stderr.txt
```
