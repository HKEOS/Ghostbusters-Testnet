# How to use the trusted peer scripts correctly

[中文版本](https://github.com/HKEOS/Ghostbusters-Testnet/blob/master/trusted-peers_CN.md)

The general `publishPeerInfo.sh` and `updatePeers.sh` scripts allows all nodes in the private mesh to peer with each other.
If you would like to join the large mesh and open your node to connect too all others, or have no trusted peers, use these to start off.
We do not recommend to use this for your BP nodes.

### Reset prior config
If you have been using `updatePeers.sh` on this node before, your `ghostbusters.conf` file will still keep most of the peers.
```console
sudo cat /etc/wireguard/ghostbusters.conf
# Copy the [Interface] section
sudo rm /etc/wireguard/ghostbusters.conf
nano /etc/wireguard/ghostbusters.conf
# Paste in the [Interface] section
```

### Remove your old peer info on Keybase
```console
rm ~/kbfs/team/eos_ghostbusters/mesh/<keybase-username>_peer_info.signed
```

### Make a list of trusted peers
```console
nano trusted-peers
# Add a list of the keybase usernames of your trusted peers. Add a space in between each one, without commas or new lines in between.
```

### Run trusted publish
```console
cd /path/to/Ghostbusters
./trustedPublish.sh my-peer-info trusted-peers
```

### Run trusted update
```console
./trustedUpdate.sh
```
