#!/bin/bash
GLOBAL_PATH=$(pwd)
if [[ $1 == "" ]]; then
        echo
        echo -e "ERROR:\nPlease provide the input my-peer-info file!";
        echo
        exit 1;
fi

if [[ $2 == "" ]]; then
        echo
        echo -e "ERROR:\nPlease provide the input trusted-peers file!";
        echo
        exit 1;
fi

TRUSTED_PEERS=`cat $2`

if ! which keybase > /dev/null; then
   echo -e "Keybase not installed. Exiting..."
   exit 1;
fi

## Check KBFS mount point
echo
echo "--------------- VERIFYING KEYBASE FILE SYSTEM ---------------";
echo

KBFS_MOUNT=$(keybase status | grep mount | cut -f 2 -d: | sed -e 's/^\s*//' -e '/^$/d');

## Restart Keybase if needed

if [ ! -d "$KBFS_MOUNT" ]; then
        echo "KBFS is not running!";
        run_keybase
        sleep 3
else
        echo "KBFS mount point: $KBFS_MOUNT";
        echo
fi

keybaseUser=$(keybase status | grep Username: | cut -f2- -d: | sed -e 's/^\s*//' -e '/^$/d');

echo "Keybase user = $keybaseUser";

echo "Signing config file...";

keybase encrypt --anonymous --no-self -i "$1" $TRUSTED_PEERS | keybase sign --saltpack-version 2 -o $KBFS_MOUNT/team/eos_ghostbusters/mesh/$keybaseUser.trusted_peers.enc.signed

echo "Done. File saved at $KBFS_MOUNT/team/eos_ghostbusters/mesh/$keybaseUser.trusted_peers.enc.signed";

echo -e "\n\n ---- BEGIN SIGNED FILE ---- \n";

cat $KBFS_MOUNT/team/eos_ghostbusters/mesh/$keybaseUser.trusted_peers.enc.signed;

echo -e "\n ---- END SIGNED FILE ----";
