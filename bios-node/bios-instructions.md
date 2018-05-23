# Bios Instructions

If you were selected as the bios node, here are your instructions:

First, `cd` into the `BiosNode` directory created by `autolaunch.sh`.

**The current bios-instructions are inaccurate. Please communicate with the team on Keybase for the first iteration until these are patched**

### Edit scripts
```console
nano start.sh
#Add /BiosNode at the end of DATADIR
nano stop.sh
#Add /BiosNode at the end of DIR
nano config.ini
# Set enable-stale-production to true
# Substitue in the bios_keys
# Change producer name to eosio
```

### Download bios-scripts
```console
# Install svn if it isn't already installed
sudo apt-get install subversion
curl -sL https://raw.githubusercontent.com/HKEOS/Ghostbusters-Testnet/master/bios-node/getScripts.sh | bash -
```

### Set up BIOS config
```console
nano ./bios-files/00_CONFIG.conf
# Enter information
# Check bios_keys file for bios public and private key
```

### Start node
```cosole
./start.sh
tail -F stderr.txt
# Check logs live
```

### Run scripts
```console
# Run scripts one by one and monitor logs
./bios-files/00_WALLET_IMPORT.sh
./bios-files/01_BIOS_CONTRACT.sh
./bios-files/02_SYSTEM_ACCOUNTS.sh
./bios-files/03_TOKENMSIG_CONTRACTS.sh
./bios-files/04_TOKEN_CREATE_ISSUE.sh
./bios-files/05_SYSTEM_CONTRACTS.sh
```
