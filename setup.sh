#!/bin/bash

echo "Downloading latest install script...";
curl -s -O https://raw.githubusercontent.com/jchung00/Ghostbusters-Testnet/master/installGhostbusters.sh
chmod u+x installGhostbusters.sh

if [[ ! -f ./params.sh ]]; then
  echo "Downloading sample params...";
  curl -s -O https://raw.githubusercontent.com/jchung00/Ghostbusters-Testnet/master/params.sh
  chmod u+x params.sh
fi

echo "Scripts updated. Verify information on params.sh and execute ./installGhostbusters.sh";
