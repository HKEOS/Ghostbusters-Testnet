#!/bin/bash

GLOBAL_PATH=$(pwd)

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

echo "### AUTOMATIC PEER CONFIGURATION ###" > temp_config.ini;

for file in /keybase/team/eos_ghostbusters/mesh/*.peer_info.signed; do
    [ -e "$file" ] || continue

    echo "Reading data from $file";
    kbuser=$(echo "$file" | cut -f1 -d'.' | cut -f6 -d'/');

    echo "Verifying signature from $kbuser";

    openssl des3 -d -in "$file" -pass pass:ghostbusters | keybase verify -S "$kbuser" &>output
    out=$(<output)
    err=$(echo "$out" | grep "ERR");
    if [[ "$err" == "" ]]; then

	wgPubKey=$(echo "$out" | grep PublicKey | cut -f3 -d' ');
	wgAllowedIPs=$(echo "$out" | grep AllowedIPs | cut -f3 -d' ');
	wgEndpoint=$(echo "$out" | grep Endpoint | cut -f3 -d' ');
	wgPKA=$(echo "$out" | grep PersistentKeepAlive | cut -f3 -d' ');

	eosData=$(echo "$out" | grep -A 2 '\[EOS\]');
	echo "$eosData" | grep 'p2p-peer-address' >> temp_config.ini;
	echo "$eosData" | grep 'peer-key' >> temp_config.ini;

	sudo wg set ghostbusters peer "$wgPubKey" endpoint "$wgEndpoint" allowed-ips "$wgAllowedIPs" persistent-keepalive "$wgPKA";
    else
	echo "Unable to verify! Skipping...";
    fi

done

# Save keybase config
sudo wg-quick save ghostbusters;
