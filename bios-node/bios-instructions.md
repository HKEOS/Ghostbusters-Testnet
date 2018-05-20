# Bios Instructions

If you were selected as the bios node, here are your instructions:

First, `cd` into the `BiosNode` directory created by `autolaunch.sh`.

### Edit scripts
```console
nano start.sh
#Add /BiosNode at the end of DATADIR
nano stop.sh
#Add /BiosNode at the end of DIR
```

### Download bios-scripts
```console
curl -sL https://raw.githubusercontent.com/HKEOS/Ghostbusters-Testnet/master/bios-node/getScripts.sh | bash -
```

### Set up BIOS config
