#!/bin/bash

# Create keybase config folder
sudo mkdir -p /etc/keybase
# Insert config
echo '{"disable-root-redirector": true}' | sudo tee /etc/keybase/config.json
# Kill redirector
sudo killall keybase-redirector
# Block it
sudo chmod a-s /usr/bin/keybase-redirector
# Create your KBFS folder
mkdir -p ~/kbfs
# Setup proper permissions
sudo chown $USER:$USER ~/kbfs
# Define new mount path
keybase config set mountdir ~/kbfs
# Reload keybase and kbfs
run_keybase
# Verify kbfs folders
ls ~/kbfs/

if [[ -d ~/kbfs/public ]]; then
        echo
        echo "Relocation successful! Now your mount point is ~/kbfs.";
        sudo rm -rf /keybase
        if [[ ! -d /keybase ]]; then
                echo
                echo "root-level keybase folder removed!";
        fi
fi
