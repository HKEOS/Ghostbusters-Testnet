# 欢迎来到 Prometheus

Prometheus是一个反向代理机器，在你的整个节点前面。它使用haproxy和patroneos。

本指南假设您运行的是Ubuntu 18.04，我们建议使用简单的云服务器来运行。

确保您的防火墙设置允许来自端口80的通信，以及允许您的完整节点与prometheus节点之间通信所需的任何其他端口。

## 获取Michael的优秀的LXC容器映像

```
wget https://transfer.sh/UOxlD/prometheus
```

配置LXD(LXC后台程序)

```
lxd init
# Type default options for everything
```

导入图片

```
lxc image import <name of image>
lxc image list
# Check that your image has been imported
```

启动容器

```
lxc launch <fingerprint-name-of-image>
lxc list
# Check the name of the container
lxc stop <name-of-container>
lxc rename <name-of-container> prometheus
lxc start prometheus
```

容器内的工作

```
lxc exec prometheus -- su - ubuntu
sudo nano /opt/patroneos/config.json
# Edit parameters
cd /etc/haproxy
sudo rm haproxy.cfg
sudo wget https://raw.githubusercontent.com/HKEOS/Ghostbusters-Testnet/master/haproxy.cfg
sudo service haxproxy restart
cd ~
sudo ./script.sh
sudo ifconfig
# Copy and paste IPv4 address (starting with 10.something) somewhere
exit
```

编辑 iptable 规则

```
sudo iptables -F
sudo iptables -t nat -A PREROUTING -p tcp -i <network-interface> -d <host-private-ip> --dport 80 -j DNAT --to-destination <container-IP-address>:80
```
