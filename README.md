# Ghostbusters Testnet Instructions

### 1. Setup

`cd` to your `opt` folder.

```console
mkdir Ghostbusters
wget https://raw.githubusercontent.com/jchung00/Ghostbusters-Testnet/master/installGhostbusters.sh
```

### 2. Fill out info in install script

Edit the following information in the file:

```console
nano installGhostbusters.sh
```

***Will make a screenshot with inputs that need to be inserted in highlights***

### 3. Run the script

```console
sudo chmod u+x installGhostbusters.sh
./installGhostbusters.sh
```

### 4. Publish info.json

The `info.json` file should have been created in your directory. ***Need instructions on how we should publish this***

#### 4.1 Keybase.pub instructions

### 5. Check scripts

`cd` into your Ghostbusters testnet folder, which was created from the install script.
Try `cat config.ini`, and `cat cleos.sh` to check that all the information is correct.

### 6. Add peers

***Still need to define this step better with the web of trust idea. Should refer to launch status spreadsheet***
