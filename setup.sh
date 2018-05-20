#!/bin/bash

echo "Downloading latest install script...";
curl -s -O https://raw.githubusercontent.com/HKEOS/Ghostbusters-Testnet/master/installGhostbusters.sh
chmod u+x installGhostbusters.sh

echo "Downloading latest publishPeerInfo script...";
curl -s -O https://raw.githubusercontent.com/HKEOS/Ghostbusters-Testnet/master/publishPeerInfo.sh
chmod u+x publishPeerInfo.sh

echo "Downloading latest updatePeers script...";
curl -s -O https://raw.githubusercontent.com/HKEOS/Ghostbusters-Testnet/master/updatePeers.sh
chmod u+x updatePeers.sh

if [[ ! -f ./params.sh ]]; then
  echo "Downloading sample params...";
  curl -s -O https://raw.githubusercontent.com/HKEOS/Ghostbusters-Testnet/master/params.sh
  chmod u+x params.sh
fi

echo "Scripts updated. Verify information on params.sh and execute ./installGhostbusters.sh";
