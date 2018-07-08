# Ghostbusters测试网络操作指南

- 目前有了可以设置 [prometheus](https://github.com/HKEOS/Ghostbusters-Testnet/blob/master/prometheus.md) (Patroneos + HAProxy)、[regproducer](https://github.com/HKEOS/Ghostbusters-Testnet/blob/master/regproducer.md)和[可信任的伙伴节点](https://github.com/HKEOS/Ghostbusters-Testnet/blob/master/trusted-peers.md)脚本的新指令。
- 从2018年6月1日起，我们将使用EOS-mainnet存储库。EOS.IO应该使用此存储库构建。

```
# Clean install
git clone https://github.com/EOS-Mainnet/eos.git
cd eos
git checkout mainnet-1.0.8
git submodule update --init --recursive
./eosio_build.sh -s "EOS"
cd build
sudo make install
```

如果您正在从eoesmainnet repo更新:

```
git pull
git checkout <tag>
git submodule update --init --recursive
./eosio_build.sh
cd build
sudo make install
```

- 第一次同步时间

  ```
  sudo timedatectl set-ntp no
  # Check if default timesyncd is off
  timedatectl
  sudo apt-get install ntp
  # Check if ntp is fine
  sudo ntpq -p
  ```

  ## 0.安装Keybase

  注意:跳过已经完成的部分。

  首先加入eos_ghostbusters Keybase群组: <https://keybase.io/team/eos_ghostbusters>.如果您还没有keybase，那么需要安装并通过身份的验证。发送加入到eos_ghostbusters群组的请求，并完成keybase身份认证。

  ​

  建议您在与沟通节点相关的信息时使用Keybase软件，每个操作系统和移动设备都有keybase客户端。Keybase非常安全，所有的BP都可以依赖它。

  ​

  -  安装keybase:https://keybase.io/docs/the_app/install_linux

  Ubuntu说明-不要作为root用户安装，请在适当的地方使用sudo。

  ```
  # Install curl if required
  sudo apt install curl

  curl -O https://prerelease.keybase.io/keybase_amd64.deb
  # if you see an error about missing `libappindicator1`
  # from the next command, you can ignore it, as the
  # subsequent command corrects it
  sudo dpkg -i keybase_amd64.deb
  sudo apt-get install -f
  run_keybase
  ```

  - 强制性步骤:修改kbfs的keybase默认存储路径。

  ```
  curl -sL https://raw.githubusercontent.com/hkeos/Ghostbusters-Testnet/master/keybase_relocate.sh | bash -
  ```

  - 登录或注册:

  ```
  # Login
  keybase login
  # Sign up
  keybase signup
  ```

  ## 1.防火墙设置 

  - 安装防火墙

  ```
  sudo add-apt-repository ppa:wireguard/wireguard
  sudo apt-get update
  sudo apt-get install wireguard resolvconf
  ```

  ## 2.设置节点`cd` 到你的`opt`文件夹。

  ```
  mkdir Ghostbusters && cd Ghostbusters
  curl -sL https://raw.githubusercontent.com/hkeos/Ghostbusters-Testnet/master/setup.sh | bash -
  ```

  - 提示：Ghostbusters testnet，将需要选择4个端口，也可以是您自己认为合适的——我们鼓励多样性!请写下您计划使用的每一步，以便将它作为下一步的指引。(端口必须大于1024，除非您以root身份运行，一般人不以root身份运行)。

  1、防火墙VPN端口-默认是5555 -请不要使用默认

  2、EOS API / HTTP端口-默认是8888 -请不要使用默认

  3、EOS P2P端口-默认是9876 -请不要使用默认

  4、`keosd`使用的钱包端口——这仅用于本地主机连接——默认值是7777

    - 选择您的线保护IP和端口
  您的防火墙IP地址应该在192.168.100范围到X 192.168.103，且X在0到255（包含）之间。
  检查已申领的ip地址:

```
cd ~/kbfs/team/eos_ghostbusters/ip_list
ls
# You will see the list of IP addresses that have already been claimed
# Choose an address that is open
touch <chosen-ip-address>@<your-node-name>
This adds a file with your IP address to the ip_list folder in an easy to sort format.
```

检查防火墙设置，并确保您的线路保护选择的端口是打开的。

如果您正在使用lxd，那么您将需要从WAN IP转发端口。如果您正在使用AWS，那么您将需要编辑您的安全设置。如果您在Ubuntu上使用ufw，您可以使用(将5555替换为您计划用于您的Wireguard VPN的任何端口):

```
sudo ufw allow 5555
```

## 3.在安装脚本中填写您的信息

```
cd /path/to/Ghostbusters
nano params.sh
```

请在###选项##上面的字段中更新您的信息(其余的是可选的):

```
EOS_SOURCE_DIR="/path/to/eos"
API_PORT=""
EOS_P2P_PORT=""
WIREGUARD_PORT=""
WALLET_PORT="7777"
KEYBASE_USER="<yourkeybaseusername>"
EOS_PUBLIC_KEY=""
EOS_PRODUCER_NAME=""
NODE_PUBLIC_IP="xxx.xxx.xxx.xxx"
AGENT_NAME="<agent-name>"
WIREGUARD_PRIVATE_IP="192.168.10Y.X"
```

注:生产者名称必须是12个字符长!

## 4.运行脚本安装testnet文件夹和脚本

```
# Run testnet installation script
./installGhostbusters.sh
```

然后，启动线路保护并检查它是否正常工作。

```
# Start wireguard
sudo wg-quick up ghostbusters
# Test configuration
sudo wg show ghostbusters
# If at any time you want to reload the network interface
sudo ip link del dev ghostbusters && sudo wg-quick up ghostbusters.conf
```

发布伙伴节点信息

```
./publishPeerInfo.sh my-peer-info
```

选择:只向可信任的伙伴节点发布节点信息

```
nano trusted-peers
# Add a list of the keybase usernames of your trusted peers. Add a space in between each one, without commas or new lines in between.
./trustedPublish.sh my-peer-info trusted-peers
```

更新防火墙和EOS `config.ini`

```
# update peers on the base config.ini
./updatePeers.sh
 # You can run updatePeers.sh again to automatically update Wireguard and EOS peer configs any time a new peer joins and publishes their peer info.
```

选择:只更新可信任的防火墙和EOS节点

```
./trustedUpdate.sh
```

检查防火墙连接

```
# You can check your communication with other peers
sudo wg show

# Count your handshakes with peers
sudo wg show|grep hand|wc -l
```

其他可选的命令

```
# Other options for updatePeers.sh
./updatePeers.sh - restart # will reload nodeos after update
./updatePeers.sh lxd restart # will reload nodeos on lxd after update

 ## If you want to cleanup dead peers (wg only), run:
./peerCleanup.sh remove strict # removes all even if just wg is down
./peerCleanup.sh remove # removes just completely offline host
./peerCleanup.sh # debug mode, doesn't actually remove peers
```

如果您更改了您的防火墙IP，在这里请进行更新

```
# This is the configuration file that you can edit to change your VPN IP and port
nano /path/to/Ghostbusters/ghostbusters.conf

# You will also need to update the following locations
nano /path/to/Ghostbusters/my-peer-info
/path/to/Ghostbusters/publishPeerInfo.sh my-peer-info
nano /path/to/Ghostbusters/base_config.ini
nano /path/to/Ghostbusters/params.sh
nano /path/to/Ghostbusters/ghostbusters-<your-producername>/config.ini
#then you need to restart your wireguard
cd /path/to/Ghostbusters
sudo ip link del dev ghostbusters && sudo wg-quick up ghostbusters.conf

# Ask team members to update peers
```

## 5.在keybase上发布BP信息

在KBFS保存: 如果你还没有在那里，`cd` 你的`Ghostbusters`文件夹

```
nano bp_info.json
# add your basic bp info and save it! at a minimum you will need the producer_account_name,
# producer_public_key. Bonus points if you add your LAT and LONG for the map.
#  "producer_account_name": "<producername>",
#  "producer_public_key": "<eos-producer-public-key>",

cp bp_info.json ~/kbfs/public/<username>
```

注意:您不必填写BP节点的api_endpoint和p2p_endpoint——需要将他们隐藏起来。

- 在如下链接检查文件是否已经打开 `https://<username>.keybase.pub/bp_info.json`

### 5.1 验证BP信息(可选项)

您可以使用命令行正确地遵循模式验证bp_info.json，我们在此推荐ajv-cli。如果没有安装npm:

```
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs
```

`schema.json`应该是从前面的Ghostbusters安装脚本生成的，`bp_info.json`文件也应该在其中。

```
sudo npm install -g ajv-cli
ajv validate -s schema.json -d bp_info.json
```

## 6.检查脚本

`cd` 在Ghostbusters testnet文件夹中，该文件夹是由安装脚本所创建的。试试`cat config.ini`，同时`cat cleos.sh`检查所有信息是否正确。

## 7.重新同步

如果您需要重新启动节点:

```
./start.sh
tail -F stderr.txt

# Hard resync
./start.sh --delete-all-blocks --genesis-json /path/to/genesis.json
tail -F stderr.txt
```

您也可以更新您的节点且同时重新开始:

```
./updatePeers - restart
```

