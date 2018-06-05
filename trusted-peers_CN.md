# 如何正确地使用可信任伙伴节点的脚本

总脚本中的publishPeerInfo.sh和updatePeers.sh允许私有网络中的所有节点彼此联系对等。如果您想要加入大型网络并打开您的节点来连接所有其他节点，或者没有可信任的伙伴节点，建议您使用这些节点作为开始。

### 重置配置之前

如果您之前一直在这个节点上使用'updatePeers.sh'，您的`ghostbusters.conf`文件仍保留大多数伙伴节点。

```
sudo cat /etc/wireguard/ghostbusters.conf
# Copy the [Interface] section
sudo rm /etc/wireguard/ghostbusters.conf
nano /etc/wireguard/ghostbusters.conf
# Paste in the [Interface] section
```

### 删除您在 Keybase上旧伙伴节点的信息

```
rm ~/kbfs/team/eos_ghostbusters/mesh/<keybase-username>_peer_info.signed
```

### 建立一个可信任伙伴节点的名单

```
nano trusted-peers
# Add a list of the keybase usernames of your trusted peers. Add a space in between each one, without commas or new lines in between.
```

### 发布可信任部分

```
cd /path/to/Ghostbusters
./trustedPublish.sh my-peer-info trusted-peers
```

### 更新可信任部分

```
./trustedUpdate.sh
```

