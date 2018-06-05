### EOS Block Producer Registration Commands

[中文版本](https://github.com/HKEOS/Ghostbusters-Testnet/blob/master/regproducer_CN.md)

**Many thanks to Charles H from EOS42 for providing these helpful instructions for the community**

#### **Create EOS wallet**

    cleos.sh wallet create -n walletname

Record the password and keep secure.

#### **Unlock EOS Wallet**

    cleos.sh wallet unlock

Paste your wallet password

#### **Load Generated EOS Account Private Key Into Your Wallet**

    cleos.sh wallet import <privkey>

#### **Create New Account From Your Generated Account**

To find your automatically created account visit
[https://eosauthority.com](https://eosauthority.com/) and paste in your ETH
public key, this will return your EOS public key and your created account name.
This new account name should be 12 lowercase alphanumeric (a-z,0–9)

    cleos.sh system newaccount --stake-net “4.0000 EOS” --stake-cpu “4.0000 EOS” --buy-ram-kbytes 8 accountname newaccountname <owner-publickey> <active-publickey>

**Load new account private key into your wallet.**

    cleos.sh wallet import -n walletname <privkey>

#### **Create a bp_info.json For Your Block Producer**

This will be used by voting portals and websites to identify producers. The
bp_info.json & bp.json contains location info for your Block Producer, nodes, and also
contains other identifiable information such as your Block Producer public key.

**For instance
**[http://yourwebsite.com/bp.json](http://yourwebsite.com/bp.json)
When you register your producer the url field should be filled with
[http://yourwebsite.com/.](http://yourwebsite.com/) Do not put the bp_info.json & bp.json
file in the url.

#### **Example of EOS Block Producer bp_info.json**

For instance, for EOS42 the bp_info.json is located at
[https://keybase.pub/ankh2054/bp_info.json](https://keybase.pub/ankh2054/bp_info.json)
so, the URL to locate this will be
[https://keybase.pub/ankh2054/.](https://keybase.pub/ankh2054/) Your
bp_info.json doesn’t have to be located on keybase, but that’s recommended.

[Template for the standard bp_info.json format for the EOS
Mainnet](https://github.com/EOSPortal/bp-info-standard)**.**

[Example of what a JSON file should look
like](https://github.com/EOSPortal/bp-info-standard/blob/master/bp_info_sample.json)**.**

***Please conform to the [JSON format
standard](https://www.w3schools.com/js/js_json_syntax.asp).

#### **Register as an EOS Block Producer (regproducer)**

This account name should be 12 lowercase alphanumeric (a-z,0–9) characters and
it should match the new account you created above.

    cleos.sh system regproducer accountname <producer-publickey> “http://<domain or ip>/BP_info.json/” -p accountname

#### **Finally, Verify You Are A Registered Producer**

`cleos.sh system listproducers`

The output should show your producer in the list with the number of votes:

`Producer Producer key Url Scaled votes`

`eos42freedom XXXXXXXXXXXXXXXXXXX https://keybase.pub/ankh2054/ 14.4242`
