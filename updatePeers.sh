#!/bin/bash
GLOBAL_PATH=$(pwd)

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
fi

myKeybaseUser=$(keybase status | grep Username: | cut -f2- -d: | sed -e 's/^\s*//' -e '/^$/d');

echo "Keybase user = $myKeybaseUser";

echo "### AUTOMATIC PEER CONFIGURATION ###" > config.ini.temp;

wgPeerCount=0;
eosPeerCount=0;

add_section()
{
	if [[ $section == "wg" ]] && [[ $publickey != "" ]] && [[ $endpoint != "" ]] && [[ $allowedips != "" ]]; then
		echo -e "\n Injecting wg peer with:\n >> PublicKey: $publickey\n >> Endpoint: $endpoint\n >> AllowedIPs: $allowedips\n >> PKA: $persistentkeepalive\n";
		sudo wg set ghostbusters peer "$publickey=" endpoint "$endpoint" allowed-ips "$allowedips" persistent-keepalive "$persistentkeepalive";
		((wgPeerCount++))
	fi
	if [[ $section == "eos" ]]; then
		((eosPeerCount++))
	fi
	section=""
}

add_eos_line()
{
	if [[ $line == "peer-key"* ]] || [[ $line == "p2p-peer-address"* ]]; then
		echo "ADD EOS LINE";
		echo "$line" >> config.ini.temp;
	fi
}

for file in ~/kbfs/team/eos_ghostbusters/mesh/*.peer_info.signed; do
	[ -e "$file" ] || continue
	echo -e "\n";
	echo "Reading data from $file";
	kbuser=$(echo "$file" | sed -e 's/.*mesh\/\(.*\).peer_info.signed*/\1/');
	if [[ $myKeybaseUser != $kbuser ]]; then
		echo "Verifying signature from $kbuser";
		cat "$file" | keybase verify -S "$kbuser" &>output
		out=$(<output)
		err=$(echo "$out" | grep "ERR");
		if [[ "$err" == "" ]]; then
			# echo -e "\n---- PEER DATA ----";
			# echo "$out";
			# echo -e "\n---- PEER DATA ----";
			section="";
			while read line; do
			  if [[ $line != "" ]] && [[ $line != \#* ]]; then
				if [[ $line == [* ]]; then
					add_section;
				fi

				if [[ "${line,,}" == "[peer]" ]]; then
					section="wg";
					continue;
				fi

                                if [[ "${line,,}" == "[eos]" ]]; then
                                        section="eos";
					continue;
                                fi

				if [[ $section == "wg" ]]; then
					shopt -s extglob
					prop=$(echo "$line" | cut -f1 -d"=" | sed -e 's/^\s*//' -e '/^$/d');
					prop="${prop,,}";
					prop="${prop%%*( )}";
					value=$(echo "$line" | cut -f2 -d"=" | sed -e 's/^\s*//' -e '/^$/d');
					declare "$prop=$value";
					shopt -u extglob
				fi
                                if [[ $section == "eos" ]]; then
                                	echo "[EOS] >> $line";
					add_eos_line;
                                fi
			  fi
			done <output
		else
			echo -e "Unable to verify! Skipping...";
		fi
	else
		echo -e "Hey, that's you!\n";
	fi
done

# Save wg config
sudo wg-quick save ghostbusters;

# Display wg
echo -e "\n-------- WIREGUARD INTERFACE ---------";
sudo wg show ghostbusters;

echo -e "\n-------- EOS CONFIG DATA ---------";

cat config.ini.temp;
echo -e "\nWG Peers: $wgPeerCount \nEOS Peers: $eosPeerCount";
