#!/bin/bash

TAG="mainnet-1.0.3"

cd eos
git pull
git checkout tags/$TAG
git submodule update --init --recursive
./eosio_build.sh
cd build
sudo make install
