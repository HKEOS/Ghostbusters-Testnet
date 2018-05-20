#!/bin/bash

svn export https://github.com/HKEOS/Ghostbusters-Testnet/trunk/bios-node bios-scripts

for filename in ./bios-node/*.sh; do
  chmod u+x "$filename"
done
