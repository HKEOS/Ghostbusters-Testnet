
# EOS 코어 지침

   
본 지침은 EOS NodeOne이 번역했습니다.

[English](https://github.com/HKEOS/Ghostbusters-Testnet/blob/master/README.md)

[中文版本](https://github.com/HKEOS/Ghostbusters-Testnet/blob/master/README_CN.md)

- [prometheus](https://github.com/HKEOS/Ghostbusters-Testnet/blob/master/prometheus.md) (Patroneos + HAProxy), [regproducer](https://github.com/HKEOS/Ghostbusters-Testnet/blob/master/regproducer.md) 그리고 [trusted peer](https://github.com/HKEOS/Ghostbusters-Testnet/blob/master/trusted-peers.md) 의 설정을 위한 안내서를 이제 보실 수 있습니다.
- 2018년 6월 1일부터 EOS-mainnet 저장소를 사용할 것입니다. EOS.IO는 이 저장소를 이용해 빌드 되어야합니다.
 
```console
# Clean install
git clone https://github.com/EOS-Mainnet/eos.git
cd eos
git checkout launch-rc
git submodule update --init --recursive
./eosio_build.sh
cd build
sudo make install
```

EOS-mainnet 저장소를 통해 업데이트:
```console
git pull
git checkout <tag>
git submodule update --init --recursive
./eosio_build.sh
cd build
sudo make install
```
- 시간을 먼저 동기화 합니다
```console
sudo timedatectl set-ntp no
# 기본 timesyncd 가 꺼져있는지 확인
timedatectl
sudo apt-get install ntp
# ntp 가 괜찮은지 확인
sudo ntpq -p
```

### 0. Keybase 설치

**주의:** 이미 완료 했다면 건너뛰세요.

eos_ghostbusters 키배이스(Keybase) 그룹에 가입하여 시작하세요: https://keybase.io/team/eos_ghostbusters.

아직 키베이스를 가지고 있지 않다면, 설치 후 본인 확인을 해야합니다.

아직 키베이스가없는 경우 키베이스를 설치하고 신원을 확인해야합니다. eos_ghostbusters 그룹에 대한 가입 요청에는 확인 된 키베이스 삭별자가 필요합니다.

노드와 관련된 정보를 통신 할 때에는 키베이스 채팅을 사용하는 것이 좋습니다. 모든 OS 및 모바일 용 키베이스 클라이언트가 있습니다. Keybase는 매우 안전하며 모든 BP가 그것에 의존하고 있습니다.

여러분의 노드의 정보와 관련된 이야기는 키베이스 챗을 이용할 것을 권합니다. 모든 종류의 OS와 모바일에서 키베이스를 사용할 수 있습니다. 키베이스는 매우 안전하고 모든 BP들이 사용합니다.

- 키베이스 설치: https://keybase.io/docs/the_app/install_linux

**우분투 이용자:** 루트 계정을 이용해 설치 하지 마세요. 적합한 위치에서 sudo를 이용해 설치하세요.

```console
# 필요할 경우 curl 설치
sudo apt install curl
curl -O https://prerelease.keybase.io/keybase_amd64.deb
# 다음 명령에서 `libappindicator1`가 누락 되었다는 에러가 발생하면
# 무시하고 명령으로 바로 잡으세요
# subsequent command corrects it
sudo dpkg -i keybase_amd64.deb
sudo apt-get install -f
run_keybase
```

- 필수 과정: kbfs에 대한 키베이스 기본 저장소 경로 수정

```console
curl -sL https://raw.githubusercontent.com/hkeos/Ghostbusters-Testnet/master/keybase_relocate.sh | bash -
```

- 로그인 및 가입:

```console
# 로그인
keybase login
# 가입
keybase signup
```

### 1. Wireguard 설치

- Wireguard 설치
```console
sudo add-apt-repository ppa:wireguard/wireguard
sudo apt-get update
sudo apt-get install wireguard resolvconf
```

### 2. Node 설치

`cd` 명령으로 `opt` 폴더로 갑니다.

```console
mkdir Ghostbusters && cd Ghostbusters
curl -sL https://raw.githubusercontent.com/hkeos/Ghostbusters-Testnet/master/setup.sh | bash -
```

- 유의 사항

Ghostbusters 테스트넷에서는 4개의 포트가 사용되며 어떤 번호라도 좋습니다. - 우리는 다양성을 장려합니다!

앞으로의 진행 과정에 가이드가 되도록 각 포트에 대한 사용 계획을 작성하세요. (루트로 실행하지 않는 한 포트는 1024보다 커야하며 루트로는 실행하지 마세요.

1. Wireguard VPN 포트 - 기본 5555 - 기본 포트를 사용하지 마세요
2. EOS API / HTTP 포트 - 기본 8888 - 기본 포트를 사용하지 마세요
3. EOS P2P 포트 - 기본 9876 - 기본 포트를 사용하지 마세요
4. Wallet 포트 used by `keosd` - 로컬호스트연결 전용 - 기본: 7777

- Wireguard IP 와 포트 설정

Wireguard의 IP 주소는 192.168.100.X 에서 192.168.103.X 사이의 범위 내 여야하고, 여기서 X는 0에서 255 사이를 의미 합니다

소유권이 요청된 IP 확인:

```console
cd ~/kbfs/team/eos_ghostbusters/ip_list
ls
# 이미 요청된 IP 주소 목록을 봅니다
# 사용가능한 주소 하나를 선택하세요
touch <chosen-ip-address>@<your-node-name>
이 명령어로 당신의 IP 주소로 된 파일을 ip_list 폴더에 추가 합니다.
```

방화벽 설정에서 Wireguard를 위해 선택한 포트가 열려있는지 확인하세요.

lxd를 상용하고 있다면 WAN IP에서 포워딩을 해야할 것입니다. 만약 AWS를 사용한다면 당신의 Security Group을 수정해야 합니다.

우분투에서 ufw를 사용한다면, Wireguard VPN에 사용할 포트를 5555로 대체 할 수 있습니다 :

```console
sudo ufw allow 5555
```

### 3. 설치 스크립트에 본인의 정보를 입력하세요.

```console
cd /path/to/Ghostbusters
nano params.sh
```

각 필드에 정보를 업데이트 하세요. ### OPTIONAL ### 위의 필드에만 채워넣으면 됩니다. (나머지는 모두 선택사항입니다.)

```console
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

**주의:** 프로듀서명은 반드시 **12 글자** 여야합니다!

### 4. 스크립트 실행하기

먼저 테스트넷 폴더와 스크립트를 설치합니다.

```console
# 테스트넷 설치 스크립트 실행
./installGhostbusters.sh
```

설치가 완료되면 Wireguard를 실행하고 정상작동여부를 확인합니다.

```console
# Wireguard 실행
sudo wg-quick up ghostbusters
# 설정(configuration) 테스트
sudo wg show ghostbusters
# 네트워크 인터페이스를 리로드 하고싶다면 다음 커맨드를 입력
sudo ip link del dev ghostbusters && sudo wg-quick up ghostbusters.conf
```

피어 정보 발행.

```console
./publishPeerInfo.sh my-peer-info
```

선택사항: 신뢰하는 피어에게만 피어 정보 공유하기
```console
nano trusted-peers
# 신뢰하는 피어의 키베이스 유저네임 리스트를 추가합니다.
# 각 유저네임 사이에 공백을 둡니다. (컴마나 줄바꿈은 안됨)
./trustedPublish.sh my-peer-info trusted-peers
```

Wireguard와 EOS `config.ini` 업데이트하기

```console
# base config.ini 에서 피어를 업데이트합니다.
./updatePeers.sh
# updatePeers.sh를 다시 실행하면 새로운 피어 합류하여 자신의 피어정보를 공유할 할 때 자동으로 Wireguard와 EOS 피어 설정을 업데이트할 수 있습니다.
```

선택사항: 신뢰하는 와이어가드와 EOS 피어만 업데이트하기
```console
./trustedUpdate.sh
```

Wireguard 커넥션 확인
```console
# 다른 피어와의 커뮤니케이션 상황 확인하기
sudo wg show
# 다른 피어와의 핸드쉐이크 횟수 확인하기
sudo wg show|grep hand|wc -l
```

기타 커맨드 (선택사항)
```console
# updatePeers.sh 의 다른 옵션들
./updatePeers.sh - restart # 업데이트 후 nodeos를 리로드합니다.
./updatePeers.sh lxd restart # 업데이트 후 lxd 상에서 nodeos를 리로드합니다.
## 죽은 피어(wg만)를 정리하고싶으면 다음을 실행합니다:
./peerCleanup.sh remove strict # wg만 죽었더라도 모두 지우기
./peerCleanup.sh remove # 완전히 오프라인된 호스트만 지우기
./peerCleanup.sh # 디버그 모드(실제로 피어를 지우지는 않음)
```

Wireguard IP를 변경했다면, 다음에서 그 변경 내용을 업데이트 해야 합니다.
```console
# 다음은 당신의 VPN IP와 포트정보를 수정할 수 있는 설정 파일입니다.
nano /path/to/Ghostbusters/ghostbusters.conf

# 변경된 IP와 포트는 다음 파일들에 모두 반영해야 합니다.
nano /path/to/Ghostbusters/my-peer-info
/path/to/Ghostbusters/publishPeerInfo.sh my-peer-info
nano /path/to/Ghostbusters/base_config.ini
nano /path/to/Ghostbusters/params.sh
nano /path/to/Ghostbusters/ghostbusters-<your-producername>/config.ini

# 변경을 완료했다면 Wireguard를 재시작합니다.
cd /path/to/Ghostbusters
sudo ip link del dev ghostbusters && sudo wg-quick up ghostbusters.conf

# 팀원들에게 피어를 업데이트 하라고 부탁합니다.
```

### 5. 키페이스에 BP 정보를 공유하기

- KBFS에 저장:

아직 `Ghostbusters` 폴더가 아니라면 `cd` 명령을 통해 그리로 이동합니다.

```console
nano bp_info.json
# 당신의 기본적인 bp 정보를 입력하고 저장합니다.
# 반드시 입력해야 하는 내용으로는
# producer_account_name, producer_public_key가 있습니다.
# 지도상의 LAT과 LONG을 입력하면 더 좋습니다.
# "producer_account_name": "<producername>",
# "producer_public_key": "<eos-producer-public-key>",

cp bp_info.json ~/kbfs/public/<username>
```

  

**주의:** BP노드의 api_endpoint와 p2p_endpoint는 입력하지 않아도 됩니다. 입력하지 않음으로서 공공에 노출되지 않을 수 있습니다.

- 해당 파일이 다음 주소에 올라갔는지 확인합니다: `https://<username>.keybase.pub/bp_info.json`

#### 5.1 BP 정보 인증 (선택사항)

  
bp_info.json의 파일이 형식을 제대로 따라 작성되었는지 검증하기 위해 커맨드라인을 활용할 수 있습니다. 검증에는 ajv-cli 사용을 추천합니다.

만일 npm이 설치되지 않았다면:

```console
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs
```

앞서 고스트버스터 설치 스크립트를 실행했다면, `schema.json`파일이 생성되어 있을 것이고, `bp_info.json`파일 역시 그 안에 있을 것입니다.

```console
sudo npm install -g ajv-cli
ajv validate -s schema.json -d bp_info.json
```

### 6. 스크립트 확인하기

`cd` 명령을 통해 설치 스크립트로 설치된 고스트버스터 테스트넷 폴더에 들어갑니다.

`cat config.ini`와 `cat cleos.sh`를 통해 모든 정보가 정확한지 확인합니다.

  

### 7. 재동기

노드를 재시작하고싶다면:

```console
./start.sh
tail -F stderr.txt

# 하드 리싱크(Hard resync)
./start.sh --delete-all-blocks --genesis-json /path/to/genesis.json
tail -F stderr.txt
```

피어정보 업데이트와 재시작을 동시해 할 수도 있습니다:

```console
./updatePeers - restart
```
