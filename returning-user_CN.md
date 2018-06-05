# 用户返回的快速说明

在启动之间，我们通常会更新脚本的重要部分。

这是一个关于如何为下一次启动做好准备的快速指南。

注意:跳过您知道对您的场景没有必要的部分(例如，如果您已经更新了EOS.IO，就可以跳过“更新EOS”的部分)

## 更新EOS

```
Follow the updated part in the beginning of the Readme.md file.
```

## Ghostbusters文件夹

首先，'cd'进入Ghostbusters文件夹

```
curl -sL https://raw.githubusercontent.com/HKEOS/Ghostbusters-Testnet/master/setup.sh | bash -
```

更新你所有的脚本，除了`params.sh`

```
rm params.sh
wget https://raw.githubusercontent.com/HKEOS/Ghostbusters-Testnet/master/params.sh
nano params.sh
# Fill in your information again
# Save
cat my-peer-info
# Check that your peer info is still correct
```

### ### ghostbusters文件

```
sudo rm -r ghostbusters-<account-name>
./installGhostbusters.sh
./publishPeerInfo.sh my-peer-info
./updatePeers
```

通过完成这些操作，您应该开始对您的节点进行监视并准备再次启动!

在运行'autolaunch.sh'之前，等待团队决定启动模块。运行'updatePeers.sh'定期向表格中添加新成员。