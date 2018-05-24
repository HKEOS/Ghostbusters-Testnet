#!/bin/bash

svn export https://github.com/HKEOS/Ghostbusters-Testnet/trunk/bios-node bios-files
rm ./bios-files/getScripts.sh

for filename in ./bios-files/*.sh; do
  chmod u+x "$filename"
done
