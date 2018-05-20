#!/bin/bash
GLOBAL_PATH=$(pwd)
if [[ $1 == "" ]]; then
        echo
        echo -e "ERROR:\nPlease provide the input peer_info file!";
        echo
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

keybase sign -i "$1" --saltpack-version 2 -o $KBFS_MOUNT/team/eos_ghostbusters/mesh/$keybaseUser.peer_info.signed

echo "Done. File saved at $GLOBAL_PATH/$keybaseUser.peer_info.signed";

echo -e "\n\n ---- BEGIN SIGNED FILE ---- \n";

cat $GLOBAL_PATH/$keybaseUser.peer_info.signed;

echo -e "\n ---- END SIGNED FILE ----";