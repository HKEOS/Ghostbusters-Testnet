#!/bin/bash
GLOBAL_PATH=$(pwd)
if [[ $1 == "" ]]; then
	echo "Please provide the input peer_info file!";
	exit 1;
fi
if [[ $2 == "" ]]; then
	echo "Please provide the password";
	exit 1;
fi
## Check KBFS mount point
echo
echo "--------------- VERIFYING KEYBASE FILE SYSTEM ---------------";
echo
KBFS_MOUNT=$(keybase status | grep mount | cut -f 2 -d:);
## Restart Keybase if needed
if [ -d "$KBFS_MOUNT" ]; then
	echo "kbfs is not running!";
	run_keybase
	sleep 3
else
	printf "KBFS mounted at %s" "$KBFS_MOUNT";
	echo
fi
keybaseUser=$(keybase status | grep Username: | cut -f2- -d: | sed -e 's/^\s*//' -e '/^$/d');
echo "Keybase user = $keybaseUser";
echo "Signing config file...";
keybase sign -i "$1" --saltpack-version 2 -o "$keybaseUser".peer_info.signed
echo "Done. File saved at $GLOBAL_PATH/$keybaseUser.peer_info.signed";
openssl des3 -salt -in "$GLOBAL_PATH/$keybaseUser.peer_info.signed" -out ~/kbfs/team/eos_ghostbusters/mesh/$keybaseUser.peer_info.signed -pass pass:"$2"