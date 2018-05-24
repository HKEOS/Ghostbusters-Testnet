# Bios Instructions

If you were selected as the bios node, here are your instructions:

First, `cd` into the `bios-files` directory created by `autolaunch.sh`.

### Set up BIOS config
```console
nano ./bios-files/00_CONFIG.conf
# Enter information
# Check bios_keys file for bios public and private key
```

### Generate bios node config
```console
./generate-config.sh
```

### Start seed node
```console
cd ..
nano config.ini
```
Copy and paste the following at the end of the file with the correct information
```
p2p-peer-address = <wireguard-ip>:<bios-node-p2p-port>
peer-key = "<bios-node-public-key>"
```
Do the same for base_config.ini if you need to update peers.
```console
# Start seed node
./start.sh
tail -F stderr.txt
```
No blocks should be produced yet since you haven't started the bios node yet.

### Start bios node
```console
cd bios-files
./start.sh
tail -F stderr.txt
# Check logs live
```

### Run scripts
```console
# Run scripts one by one and monitor logs
./00_WALLET_IMPORT.sh
./01_BIOS_CONTRACT.sh
./02_SYSTEM_ACCOUNTS.sh
./03_TOKENMSIG_CONTRACTS.sh
./04_TOKEN_CREATE_ISSUE.sh
./05_SYSTEM_CONTRACTS.sh
```
**Note:** There may be an error in deploying system contract at the moment. Our "workaround" at the moment is to create and issue "SYS" tokens instead of "EOS" tokens for `04_TOKEN_CREATE_ISSUE.sh`. Consult with Keybase team if you encounter this scenario.
