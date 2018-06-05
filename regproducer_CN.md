# EOS区块生产者注册命令

#### 非常感谢EOS42的Charles H为社区提供了这些有用的指导

### 创建EOS的钱包

```
cleos.sh wallet create -n walletname
```

记下密码并保持密码的安全。

### 解锁EOS钱包

```
cleos.sh wallet unlock
```

粘贴你的钱包密码

### 负载生成EOS帐户私钥到您的钱包

```
cleos.sh wallet import <privkey>
```

### 从生成的帐户创建新帐户

要找到您自动创建的帐户，请访问https://eosauthority.com ，并将其粘贴到您的ETH公钥中，这将返回您的EOS公钥和您创建的帐户名称。这个新帐户名应该是12个小写字母／数字(a-z, 0-9)

```
cleos.sh system newaccount --stake-net “4.0000 EOS” --stake-cpu “4.0000 EOS” --buy-ram-kbytes 8 accountname newaccountname <owner-publickey> <active-publickey>
```

### 将新帐户私钥载入钱包

```
cleos.sh wallet import -n walletname <privkey>
```

### 为区块生产者创建一个**bp_info.json**

这将被投票门户和网站用来识别生产者。bp_info.json和bp.json包含了您区块生产者的节点的位置信息，并且还包含其他可识别的信息，例如您的区块生产者公钥。

**例如**http://yourwebsite.com/bp.json当您注册生产者时url字段应该填入http://yourwebsite.com/。不要把bp_info.json & bp.json的文件放置到url中。

### EOS区块生产者bp_info.json的示例

例如，对于EOS42, bp_info.json在https://keybase.pub/ankh2054/bp_info上。因此，定位它的URL将是https://keybase.pub/ankh2054/。你的bp_info.json不是一定要在keybase上，这只是推荐的地方。

[EOS主网标准bp_info.json模板](https://github.com/EOSPortal/bp-info-standard)

[JSON文件应该是什么样子的例子](https://github.com/EOSPortal/bp-info-standard/blob/master/bp_info_sample.json)

***请符合[JSON格式标准](https://www.w3schools.com/js/js_json_syntax.asp)

### 注册为EOS区块生成者(regproducer)

这个帐户名应该是由12个小写字母／数字(a-z, 0-9)字符组成的，并且它应该与上面创建的新帐户匹配。

```
cleos.sh system regproducer accountname <producer-publickey> “http://<domain or ip>/BP_info.json/” -p accountname
```

### 最后，验证你是一个已注册的生产者

```
cleos.sh system listproducers
```

应在列表中显示您作为生产者与投票数的输出:

```
Producer Producer key Url Scaled votes

eos42freedom XXXXXXXXXXXXXXXXXXX https://keybase.pub/ankh2054/ 14.4242
```





`

