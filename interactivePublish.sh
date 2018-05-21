#!/bin/bash
np=1;
echo -e "\n\n----- >> Interactive peer info builder << ------\n";

if [[ $1 != "new" ]]; then

	if [[ -f ./peerInfo.temp ]]; then
		source peerInfo.temp
		echo "Loaded config...";
		echo "WG_IP: $WG_IP";
		echo "WG_PublicKey: $WG_PublicKey";
		echo "WG_Endpoint: $WG_Endpoint";
	else
		echo -e "## Temp settings" > peerInfo.temp;
	fi

fi

new_wg_peer

if [[ $WG_IP == "" ]]; then
	echo -e " > WG Peer $np ip address [192.168.100.0 to 192.168.103.255]: \c"
	read
	if [[ "$REPLY" = "" ]]; then
		exit 1;
	else
		WG_IP="$REPLY";
	 # ls ~/kbfs/team/eos_ghostbusters/ip_list/ | grep $WG_IP
	 echo "WG_IP=\"$WG_IP\"" >> peerInfo.temp;
	fi  
fi

if [[ $WG_PublicKey == "" ]]; then
	echo -e " > WG Peer $np PublicKey: \c"
	read
	if [[ "$REPLY" = "" ]]; then
		exit 1;
	else
		WG_PublicKey="$REPLY";
	 echo "WG_PublicKey=\"$WG_PublicKey\"" >> peerInfo.temp;
	fi  
fi

if [[ $WG_PublicKey == "" ]]; then
	echo -e " > WG Peer $np PublicKey: \c"
	read
	if [[ "$REPLY" = "" ]]; then
		exit 1;
	else
		WG_PublicKey="$REPLY";
	 echo "WG_PublicKey=\"$WG_PublicKey\"" >> peerInfo.temp;
	fi  
fi

if [[ $WG_Endpoint == "" ]]; then
	echo -e " > WG Peer $np Endpoint: \c"
	read
	if [[ "$REPLY" = "" ]]; then
		exit 1;
	else
		WG_Endpoint="$REPLY";
	 echo "WG_Endpoint=\"$WG_Endpoint\"" >> peerInfo.temp;
	fi  
fi

if [[ $WG_PKA == "" ]]; then
	echo -e " > WG Peer $np PersistentKeepAlive [default=20]: \c"
	read
	if [[ "$REPLY" = "" ]]; then
		WG_PKA="20";
	else
		WG_PKA="$REPLY";
	fi
	echo "WG_PKA=\"$WG_PKA\"" >> peerInfo.temp;
fi
