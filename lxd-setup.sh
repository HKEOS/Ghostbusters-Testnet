### LXD Setup on Dawn v4.1

cd /opt/eos
git pull
git checkout dawn-v4.1.0
git submodule update --recursive

# Change token name
ex -sc '16i|set( CORE_SYMBOL_NAME "EOS" )' -cx CMakeLists.txt
./eosio_build.sh

build/programs/nodeos/nodeos --version
# should output 3449264167

# initialize LXD
sudo lxd init

# launch a ubuntu 18.04 container
lxc launch ubuntu:18.04 eos-node

# enter bash
lxc exec eos-node -- /bin/bash
apt update
apt upgrade

# create a user for eos
sudo adduser eos
# complete interactive instructions

sudo usermod -aG sudo eos

mkdir -p /opt/eos
chown eos:eos /opt/eos

# exit the lxd container
exit

# copy nodeos binary
lxc file push /home/entropia/eos/build/programs/nodeos/nodeos  eos-node/opt/eos/nodeos

# test execution on container
lxc exec eos-node -- /opt/eos/nodeos --version