#!/bin/bash

echo "Downloading latest install script...";
curl -s -O https://raw.githubusercontent.com/bensig/Ghostbusters-Testnet/master/installGhostbusters.sh
chmod u+x installGhostbusters.sh

echo "Downloading latest publishPeerInfo script...";
curl -s -O https://raw.githubusercontent.com/bensig/Ghostbusters-Testnet/master/publishPeerInfo.sh
chmod u+x publishPeerInfo.sh

echo "Downloading latest updatePeers script...";
curl -s -O https://raw.githubusercontent.com/bensig/Ghostbusters-Testnet/master/updatePeers.sh
chmod u+x updatePeers.sh

echo "Downloading latest peerCleanup script...";
curl -s -O https://raw.githubusercontent.com/bensig/Ghostbusters-Testnet/master/peerCleanup.sh
chmod u+x peerCleanup.sh

echo "Downloading latest interactivePublish script...";
curl -s -O https://raw.githubusercontent.com/bensig/Ghostbusters-Testnet/master/interactivePublish.sh
chmod u+x interactivePublish.sh

if [[ ! -f ./my-peer-info ]]; then
	echo "Downloading my-peer-info sample";
	curl -s -O https://raw.githubusercontent.com/bensig/Ghostbusters-Testnet/master/my-peer-info
fi

if [[ ! -f ./params.sh ]]; then
	echo "Downloading sample params...";
	curl -s -O https://raw.githubusercontent.com/bensig/Ghostbusters-Testnet/master/params.sh
	chmod u+x params.sh
fi

echo "Scripts updated. Please follow the README.md to setup wireguard, update your peer information to keybase, check firewall, start wireguard, edit params.sh and (finally) execute ./installGhostbusters.sh";
