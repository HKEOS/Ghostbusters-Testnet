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
echo "# --- --- ---" > config.ini.temp;

wgPeerCount=0;
eosPeerCount=0;

if [[ $1 == "lxd" ]]; then
	echo -e "\n ### ----- LXD MODE ----- ###\n";
	LXD_MODE=true;
	WG_DATA=$(lxc exec eos-node -- cat /etc/wireguard/ghostbusters.conf)
	PVT_KEY=$(echo "$WG_DATA" | grep "PrivateKey" | cut -f2 -d"=" | sed -e 's/^\s*//' -e '/^$/d')"=";
	WG_PUB_KEY=$(echo "$PVT_KEY" | wg pubkey);
else
	LXD_MODE=false;
	WG_DATA=$(sudo cat /etc/wireguard/ghostbusters.conf)
	WG_ADDR=$(echo "$WG_DATA" | grep "Address" | cut -f2 -d"=" | sed -e 's/^\s*//' -e '/^$/d' | cut -f1 -d'/')
	echo "Wireguard: $WG_ADDR";
	PVT_KEY=$(echo "$WG_DATA" | grep "PrivateKey" | cut -f2 -d"=" | sed -e 's/^\s*//' -e '/^$/d')"=";
	WG_PUB_KEY=$(echo "$PVT_KEY" | wg pubkey);
fi

if [[ ! -f base_config.ini ]]; then
	echo "base_config.ini not found!";
	exit 1
else
	EOS_PUB_KEY=$(cat base_config.ini | grep "peer-private-key" | cut -f3 -d' ' | sed 's/\[//' | cut -f1 -d',');
	echo "Current Public Key: $EOS_PUB_KEY";
fi

add_section()
{
	if [[ "$WG_PUB_KEY" != "$publickey=" ]]; then
		if [[ $section == "wg" ]] && [[ $publickey != "" ]] && [[ $endpoint != "" ]] && [[ $allowedips != "" ]]; then
			echo -e "\n Injecting wg peer with:\n >> PublicKey: $publickey\n >> Endpoint: $endpoint\n >> AllowedIPs: $allowedips\n >> PKA: $persistentkeepalive\n";
			if [[ $LXD_MODE == true ]]; then
				lxc exec eos-node -- sudo wg set ghostbusters peer "$publickey=" endpoint "$endpoint" allowed-ips "$allowedips" persistent-keepalive "$persistentkeepalive"
			else
				sudo wg set ghostbusters peer "$publickey=" endpoint "$endpoint" allowed-ips "$allowedips" persistent-keepalive "$persistentkeepalive";
			fi
			((wgPeerCount++))
			publickey=""
			endpoint=""
			allowedips=""
		fi
		if [[ $section == "eos" ]]; then
			((eosPeerCount++))
		fi
		section=""
	fi
}

add_eos_line()
{
	NEW_PUB_KEY=$(echo "$line" | cut -f3 -d" ")
	if [[ $line == "peer-key"* ]]; then
		NEW_PUB_KEY=$(echo "$line" | cut -f3 -d" ")
		if [[ "$NEW_PUB_KEY" != "$EOS_PUB_KEY" ]]; then
			echo "$line" >> config.ini.temp;
		fi
	fi

	if [[ $line == "p2p-peer-address"* ]]; then
		EOS_ADDR=$(echo "$line" | cut -f3 -d " " |cut -f1 -d":");
		echo $EOS_ADDR;
		if [[ "$WG_ADDR" != "$EOS_ADDR" ]]; then
			echo "$line" >> config.ini.temp;
		fi
	fi
}

if [[ ! -f /etc/wireguard/ghostbusters.conf ]]; then
	echo "Configuration file not found! Please add your interface info to /etc/wireguard/ghostbusters.conf";
	exit 1;
else
	if [[ $LXD_MODE == true ]]; then
		lxc exec eos-node -- wg-quick up ghostbusters;
	else
		sudo wg-quick up ghostbusters;
	fi
fi

for file in $KBFS_MOUNT/team/eos_ghostbusters/mesh/*.peer_info.signed; do
	[ -e "$file" ] || continue
	echo -e "\n";
	echo "Reading data from $file";
	kbuser=$(echo "$file" | sed -e 's/.*mesh\/\(.*\).peer_info.signed*/\1/');
	echo "Verifying signature from $kbuser";
	cat "$file" | keybase verify -S "$kbuser" &>output
	out=$(<output)
	err=$(echo "$out" | grep "ERR");
	if [[ "$err" == "" ]]; then
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
					add_eos_line;
				fi
			fi
		done <output
	else
		echo -e "Unable to verify! Skipping...";
	fi
done

# Save wg config
if [[ $LXD_MODE == true ]]; then
	lxc exec eos-node -- wg-quick save ghostbusters;
else
	sudo wg-quick save ghostbusters;
fi

# Display wg
echo -e "\n-------- WIREGUARD INTERFACE ---------";
if [[ $LXD_MODE == true ]]; then
	lxc exec eos-node -- wg show ghostbusters;
else
	sudo wg show ghostbusters;
fi

echo -e "\n-------- EOS CONFIG DATA ---------";

sort config.ini.temp | uniq > autoPeers;
cat autoPeers;
cat base_config.ini > config.ini
echo -e "\n\n### ----- AUTO GENERATED PEER INFO ----- ###\n" >> config.ini;
cat autoPeers >> config.ini
rm autoPeers config.ini.temp;

if [[ $LXD_MODE == true ]]; then
	lxc file push config.ini eos-node/home/eos/gb/config.ini;
else
	cp config.ini ghostbusters-*/config.ini;
fi

echo -e "\n Update finished!\nWG Peers: $wgPeerCount \nEOS Peers: $eosPeerCount";

# TODO: Call start.sh to restart the node