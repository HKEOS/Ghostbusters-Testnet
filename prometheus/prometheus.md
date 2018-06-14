# Welcome to Prometheus - ADVANCED

[中文版本](https://github.com/HKEOS/Ghostbusters-Testnet/blob/master/prometheus_CN.md)

**Note:** Patroneos should be updated regularly, as there are still active changes being made on the repository. Find the Patroneos update script below (designed for Prometheus).

Prometheus is a reverse proxy machine that goes in front of your full node. It uses haproxy and patroneos.

This guide assumes that you are running on Ubuntu 18.04. We recommend using simple cloud server for this.

Make sure that your firewall settings allows traffic in from port 80, and any other ports needed to allow communication between your full node and the prometheus node.

Sam from EOS Dublin has created a setup script for the majority of this process too: https://github.com/eosdublin/scripts/blob/master/nyx/setup.sh

He also wrote a Patroneos update script:
https://github.com/eosdublin/scripts/blob/master/nyx/update_patroneos.sh

### Grab Michael's great LXC container image

```console
wget https://transfer.sh/UOxlD/prometheus
```

### Configure LXD (LXC daemon)

```console
lxd init
# Type default options for everything
```

### Import image

```console
lxc image import <name of image>
lxc image list
# Check that your image has been imported
```

### Launch container

```console
lxc launch <fingerprint-name-of-image>
lxc list
# Check the name of the container
lxc stop <name-of-container>
lxc rename <name-of-container> prometheus
lxc start prometheus
```

### Work inside the container

```console
lxc exec prometheus -- su - ubuntu
sudo nano /opt/patroneos/config.json
# Edit parameters
cd /etc/haproxy
sudo rm haproxy.cfg
sudo wget https://raw.githubusercontent.com/HKEOS/Ghostbusters-Testnet/master/haproxy.cfg
sudo service haproxy restart
cd ~
sudo ./script.sh
sudo ifconfig
# Copy and paste IPv4 address (starting with 10.something) somewhere
exit
```

### Edit iptable rules
```console
sudo iptables -F
sudo iptables -t nat -A PREROUTING -p tcp -i <network-interface> -d <host-private-ip> --dport 80 -j DNAT --to-destination <container-IP-address>:80
sudo /sbin/iptables -I INPUT -p tcp --syn -m multiport --dports 80 -m connlimit --connlimit-above 10 --connlimit-mask 24 -j DROP -m comment --comment WFW-ClassC-limit
sudo /sbin/iptables -I INPUT -p tcp --syn -m multiport --dports 80 -m connlimit --connlimit-above 1000 --connlimit-mask 0 -j DROP -m comment --comment WFW-total-limit
```
