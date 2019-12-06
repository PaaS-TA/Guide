## Table of Contents

1. [개요](#101)
  * [목적](#102)
  * [범위](#103)
  * [참고 자료](#104)
2. [BOSH](#105)
    * [BOSH1](#106)
    * [BOSH2](#107)
    * [BOSH 컴포넌트 구성](#108)
3. [BOSH 설치 환경 구성 및 설치](#109)
    * [BOSH 설치 절차](#1010)
    * [Inception 서버 구성](#1011)
    * [BOSH 설치](#1012)
        *  [Prerequisite](#1013)
        *  [BOSH CLI 및 dependency 설치](#1014)
        *  [설치 파일 다운로드](#1015)
        *  [BOSH 설치 파일](#1016)
        *  [BOSH 환경 설정](#1017)
            *  [OpenStack BOSH 환경 설정](#1018)
            *  [AWS BOSH 환경 설정](#1019)
            *  [VMware vSphere BOSH 환경 설정](#1020)
            *  [MS Azure BOSH 환경 설정](#1021)
            *  [GCP BOSH 환경 설정](#1022)
            *  [BOSH-LITE 환경 설정](#1023)
        *  [PaaS-TA Monitoring Operation 파일](#1024)
        *  [BOSH 설치](#1025)
        *  [BOSH 로그인](#1026)
        *  [CredHub](#1027)
            *  [CredHub CLI 설치](#1028)
            *  [CredHub 로그인](#1029)
        *  [Jumpbox](#1030)

## Executive Summary

본 문서는 BOSH2(이하 BOSH)의 설명 및 설치 가이드 문서로, BOSH를 실행할 수 있는 환경을 구성하고 사용하는 방법에 관해서 설명하였다.

# <div id='101'/>1.  문서 개요 

## <div id='102'/>1.1.  목적
클라우드 환경에 서비스 시스템을 배포할 수 있는 BOSH는 릴리즈 엔지니어링, 개발, 소프트웨어 라이프사이클 관리를 통합한 오픈소스 프로젝트로 본 문서에서는 Inception 환경(설치환경)에서 BOSH를 설치하는 데 그 목적이 있다. 

## <div id='103'/>1.2.  범위
본 문서는 Linux 환경(Ubuntu 18.04)을 기준으로 BOSH 설치를 위한 패키지와 라이브러리를 설치 및 구성하고, 이를 이용하여 BOSH를 설치하는 것을 기준으로 작성하였다.

## <div id='104'/>1.3.  참고 자료

본 문서는 Cloud Foundry의 BOSH Document와 Cloud Foundry Document를 참고로 작성하였다.

BOSH Document: [http://bosh.io](http://bosh.io)

BOSH Deployment: [https://github.com/cloudfoundry/bosh-deployment](https://github.com/cloudfoundry/bosh-deployment)

Cloud Foundry Document: [https://docs.cloudfoundry.org](https://docs.cloudfoundry.org)

# <div id='105'/>2. BOSH
BOSH는 초기에 Cloud Foundry PaaS를 위해 개발되었지만, 현재는 Jenkins, Hadoop 등 Yaml 파일 형식으로 소프트웨어를 쉽게 배포할 수 있으며, 수백 가지의 VM을 설치할 수 있고, 각각의 VM에 대해 모니터링, 장애 복구 등 라이프 사이클을 관리할 수 있는 통합 프로젝트이다.

BOSH가 지원하는 IaaS는 VMware vSphere, Google Cloud Platform, AWS, OpenStack, MS Azure, VMware vCloud, RackHD, SoftLayer가 있다. PaaS-TA는 VMware vSphere, Google Cloud Platform, AWS, OpenStack, MS Azure 등의 IaaS를 지원한다.

PaaS-TA 3.1 버전까지는 Cloud Foundry BOSH1을 기준으로 설치했지만, PaaS-TA 3.5 버전부터 BOSH2를 기준으로 설치하였다. PaaS-TA 5.0은 Cloud Foundry에서 제공하는 bosh-deployment를 활용하여 BOSH를 설치한다.

## <div id='106'/>2.1. BOSH1

BOSH1은 bosh-init을 통하여 BOSH를 생성하고, BOSH1 CLI를 통하여 PaaS-TA Controller, Container를 생성하였다.

![PaaSTa_BOSH_Use_Guide_Image1]

## <div id='107'/>2.2. BOSH2

BOSH2는 BOSH2 CLI를 통하여 BOSH와 PaaS-TA를 모두 생성한다. bosh-deployment를 이용하여 BOSH를 생성한 후, paasta-deployment로 PaaS-TA를 설치한다.
PaaS-TA 3.1 버전까지는 PaaS-TA Container, Controller를 별도의 deployment로 설치했지만, PaaS-TA 3.5 버전부터는 paasta-deployment 하나로 통합되어 한 번에 PaaS-TA를 설치한다.

![PaaSTa_BOSH_Use_Guide_Image2]

## <div id='108'/>2.3. BOSH 컴포넌트 구성

BOSH의 컴포넌트 구성은 다음과 같다.

![PaaSTa_BOSH_Use_Guide_Image3]

- Director: Director는 VM 생성 또는 수정 시 설정 정보를 레지스트리에 저장한다. 저장된 레지스트리 정보는 VM의 Bootstrapping Stage에서 이용된다.
- Health Monitor: Health Monitor는 BOSH Agent로부터 클라우드 상태 정보를 수집한다. 클라우드로부터 특정 Alert이 발생하면, Resurrector를 하거나 Notification Plug-in을 통해 Alert Message를 전송할 수도 있다.
- Blobstore: Blobstore는 Release, Compilation package data를 저장하는 저장소이다.
- UAA: UAA는 BOSH 사용자 인증 인가 처리를 한다.
- Database: Director가 사용하는 Postgres 데이터베이스로, Deployment에 필요한 Stemcell, Release, Deployment의 메타 정보를 저장한다.
- Message bus(Nats): Message bus는 Director와 Agent 간 통신을 위한 Publish-subscribe 방식의 Message system으로, VM 모니터링과 특정 명령을 수행하기 위해 사용된다.
- Agent: Agent는 클라우드에 배포되는 모든 VM에 설치되고, Director로부터 특정 명령을 받고 수행하는 역할을 한다. Agent는 Director로부터 수신받은 Job specification(설치할 패키지 및 구성 방법) 정보로 해당 VM에 Director의 지시대로 지정된 패키지를 설치하고, 필요한 구성 정보를 설정한다.

# <div id='109'/>3. BOSH 설치 환경 구성 및 설치

## <div id='1010'/>3.1. BOSH 설치 절차
Inception(PaaS-TA 설치 환경)은 BOSH 및 PaaS-TA를 설치하기 위한 설치 환경으로, VM 또는 서버 장비이다. OS version은 Ubuntu 18.04를 기준으로 한다. IaaS에서 수동으로 Inception VM을 생성해야 한다.

Inception VM은 ubuntu 18.04, vCPU 2 core, Memory 4G, Disk 100G 이상을 권고한다.

## <div id='1011'/>3.2.  Inception 서버 구성

Inception 서버는 BOSH 및 PaaS-TA를 설치하기 위해 필요한 패키지 및 라이브러리, Manifest 파일 등의 환경을 가지고 있는 배포 작업 실행 서버이다. Inception 서버는 외부 통신이 가능해야 한다.

BOSH 및 PaaS-TA 설치를 위해 Inception 서버에 구성해야 할 컴포넌트는 다음과 같다.

- BOSH CLI 6.1.x 이상 
- BOSH Dependency : ruby, ruby-dev, openssl 등
- BOSH Deployment: BOSH 설치를 위한 manifest deployment  
- PaaS-TA Deployment : PaaS-TA 설치를 위한 manifest deployment (cf-deployment v9.5.0 기준)

## <div id='1012'/>3.3.  BOSH 설치

### <div id='1013'/>3.3.1.    Prerequisite

- 본 설치 가이드는 Ubuntu 18.04 버전을 기준으로 한다.
- PaaS-TA 설치 파일은 ${HOME}/workspace/paasta-5.0 이하에 다운로드한다.

### <div id='1014'/>3.3.2.    BOSH CLI 및 dependency 설치

- BOSH dependency 설치 (Ubuntu 18.04)

```
$ sudo apt install -y build-essential zlibc zlib1g-dev ruby ruby-dev openssl libxslt1-dev libxml2-dev libssl-dev libreadline7 libreadline-dev libyaml-dev libsqlite3-dev sqlite3
```

- BOSH dependency 설치 (Ubuntu 16.04)

```
$ sudo apt install -y libcurl4-openssl-dev gcc g++ build-essential zlibc zlib1g-dev ruby ruby-dev openssl libxslt-dev libxml2-dev libssl-dev libreadline6 libreadline6-dev libyaml-dev libsqlite3-dev sqlite3
```

- BOSH CLI 설치

```
$ sudo apt update
$ curl -Lo ./bosh https://github.com/cloudfoundry/bosh-cli/releases/download/v6.1.0/bosh-cli-6.1.0-linux-amd64
$ chmod +x ./bosh
$ sudo mv ./bosh /usr/local/bin/bosh
$ bosh -v
```

BOSH2 CLI는 BOSH 설치 시, BOSH certificate 정보를 생성해 주는 기능이 있다. Cloud Foundry의 기본 BOSH CLI는 인증서가 1년으로 제한되어 있다. 
BOSH 인증서는 BOSH 내부 Component 간의 통신 시 필요한 certificate이다. 만약 BOSH 설치 후 1년이 지나면 BOSH를 다시 설치해야 한다.

BOSH2 CLI 6.1.0 이상 버전은 create-env의 config-server를 통해 생성된 인증서를 1년 이상 구성할 수 있다.

BOSH2 CLI 6.0.0 이하 버전 사용 시, 인증서 기간을 늘리고 싶다면 BOSH CLI 소스를 다운로드해 컴파일하여 사용해야 한다. 소스 컴파일 방법은 다음 가이드를 참고한다.  

- 소스 build 전제 조건 :: ubuntu, go 1.9.2 버전 이상

```
$ mkdir -p ${HOME}/workspace/bosh-cli/src/
$ cd ${HOME}/workspace/bosh-cli

$ export GOPATH=$PWD
$ export PATH=$GOPATH/bin:$PATH

$ go get -d github.com/cloudfoundry/bosh-cli
$ cd $GOPATH/src/github.com/cloudfoundry/bosh-cli
$ git checkout v5.5.1
$ vi ./vendor/github.com/cloudfoundry/config-server/types/certificate_generator.go

func generateCertTemplate 함수에 아래 내용 중 365(일)을 원하는 기간만큼 수정한다.

  - notAfter := now.Add(365 * 24 * time.Hour) 

$ ./bin/build
$ cd out
$ sudo cp ./bosh /usr/local/bin/bosh

$ bosh -version
```

### <div id='1015'/>3.3.3.    설치 파일 다운로드

- [설치 파일 다운로드](https://paas-ta.kr/download/package)

- 디렉터리 생성 (내려받은 파일이 위치할 경로)

```
$ mkdir -p ${HOME}/workspace/paasta-5.0/deployment
$ mkdir -p ${HOME}/workspace/paasta-5.0/release
$ mkdir -p ${HOME}/workspace/paasta-5.0/stemcell
```

- PaaS-TA 사이트에서 [PaaS-TA Deployment] 파일을 다운로드해 ${HOME}/workspace/paasta-5.0/deployment 이하 디렉터리에 압축을 푼다.
- PaaS-TA 사이트에서 [PaaS-TA Release] 파일을 다운로드해 ${HOME}/workspace/paasta-5.0/release 이하 디렉터리에 압축을 푼다.
- PaaS-TA 사이트에서 [PaaS-TA Stemcell] 파일을 다운로드해 ${HOME}/workspace/paasta-5.0/stemcell 이하 디렉터리에 압축을 푼다.

### <div id='1016'/>3.3.4.    BOSH 설치 파일

- paasta-5.0 이하 디렉터리

```
ubuntu@ip-10-0-0-59:~/workspace/paasta-5.0$ ls
deployment  release  stemcell
```

<table>
<tr>
<td>deployment</td>
<td>deployment 및 cloud-config가 존재한다.</td>
</tr>
<tr>
<td>release</td>
<td>release 파일이 존재한다.</td>
</tr>   
<tr>
<td>stemcell</td>
<td>IaaS별 stemcell 파일이 존재한다.</td>
</tr>
</table>

- paasta-5.0/deployment 이하 디렉터리

```
ubuntu@ip-10-0-0-59:~/workspace/paasta-5.0/deployment$ ls
bosh-deployment  cloud-config  paasta-deployment  paasta-deployment-monitoring  portal-deployment  service-deployment
```

<table>
<tr>
<td>bosh-deployment</td>
<td>BOSH 설치를 위한 manifest 및 설치 파일이 존재하는 디렉터리</td>
</tr>
<tr>
<td>cloud-config</td>
<td>PaaS-TA 설치를 위한 IaaS network/storage/vm 관련 설정 파일이 존재하는 디렉터리</td>
</tr>
<tr>
<td>paasta-deployment</td>
<td>PaaS-TA 설치를 위한 manifest 및 설치 파일이 존재하는 디렉터리</td>
</tr>
<tr>
<td>paasta-deployment-monitoring</td>
<td>PaaS-TA 및 Monitoring 설치를 위한 manifest 및 설치 파일이 존재하는 디렉터리</td>
</tr>
<tr>
<td>portal-deployment</td>
<td>PaaS-TA Portal 설치를 위한 manifest 및 설치 파일이 존재하는 디렉터리</td>
</tr>
<tr>
<td>service-deployment</td>
<td>PaaS-TA Service (mysql, glusterfs 등) 설치를 위한 manifest 및 설치 파일이 존재하는 디렉터리</td>
</tr>
</table>

- paasta-5.0/release 이하 디렉터리

```
ubuntu@ip-10-0-0-59:~/workspace/paasta-5.0/release$ ls
bosh  paasta  paasta-monitoring  portal  service
```

<table>
<tr>
<td>bosh</td>
<td>BOSH 설치 시 필요한 release 파일이 존재하는 디렉터리</td>
</tr>
<tr>
<td>paasta</td>
<td>PaaS-TA 설치 시 필요한 release 파일이 존재하는 디렉터리</td>
</tr>
<tr>
<td>paasta-monitoring</td>
<td>PaaS-TA 및 Monitoring 설치 시 필요한 release 파일이 존재하는 디렉터리</td>
</tr>
<tr>
<td>portal</td>
<td>PaaS-TA Portal 설치 시 필요한 release 파일이 존재하는 디렉터리</td>
</tr>
<tr>
<td>service</td>
<td>Paas-TA Service (mysql, glusterfs 등) 설치 시 필요한 release 파일이 존재하는 디렉터리</td>
</tr>
</table>

- paasta-5.0/stemcell 이하 디렉터리

```
ubuntu@ip-10-0-0-59:~/workspace/paasta-5.0/stemcell$ ls
paasta  paasta-monitoring
```

<table>
<tr>
<td>paasta</td>
<td>PaaS-TA 및 PaaS-TA Service 설치 시 필요한 stemcell 파일이 존재하는 디렉터리</td>
</tr>
<tr>
<td>paasta-monitoring</td>
<td>PaaS-TA 및 Monitoring 설치 시 필요한 stemcell 파일이 존재하는 디렉터리</td>
</tr>   
</table>

### <div id='1017'/>3.3.5.    BOSH 환경 설정

${HOME}/workspace/paasta-5.0/deployment/bosh-deployment 이하 디렉터리에는 BOSH 설치를 위한 IaaS별 Shell script 파일이 존재한다. Shell script 파일을 이용하여 BOSH를 설치한다.
파일명은 deploy-{IaaS}.sh 로 만들어졌다. 

<table>
<tr>
<td>deploy-aws.sh</td>
<td>AWS 환경에 BOSH 설치를 위한 Shell script 파일</td>
</tr>
<tr>
<td>deploy-openstack.sh</td>
<td>OpenStack 환경에 BOSH 설치를 위한 Shell script 파일</td>
</tr>   
<tr>
<td>deploy-vsphere.sh</td>
<td>VMware vSphere 환경에 BOSH 설치를 위한 Shell script 파일</td>
</tr>
<tr>
<td>deploy-gcp.sh</td>
<td>GCP(Google Cloud Platform) 환경에 BOSH 설치를 위한 Shell script 파일</td>
</tr>
<tr>
<td>deploy-azure.sh</td>
<td>MS Azure 환경에 BOSH 설치를 위한 Shell script 파일</td>
</tr>
<tr>
<td>deploy-bosh-lite.sh</td>
<td>Local test 용도로 BOSH-LITE 설치를 위한 Shell script 파일</td>
</tr>
</table>

BOSH 설치 명령어는 create-env로 시작한다. Shell이 아닌 BOSH command로 실행 가능하며, 설치하는 IaaS 환경에 따라 Option이 달라진다. BOSH 삭제 시 delete-env 명령어를 사용하여 설치된 BOSH를 삭제할 수 있다.

BOSH 설치 Option은 아래와 같다.

<table>
<tr>
<td>--state</td>
<td>BOSH 설치 명령어 실행 시 생성되는 파일로, 설치된 BOSH의 IaaS 설정 정보가 저장된다. (Backup 필요)</td>
</tr>
<tr>
<td>--vars-store</td>
<td>BOSH 설치 명령어 실행 시 생성되는 파일로, 설치된 BOSH의 내부 컴포넌트가 사용하는 인증서 및 인증정보가 저장된다. (Backup 필요)</td>
</tr>   
<tr>
<td>-o</td>
<td>BOSH 설치 시 적용하는 Operation 파일을 설정할 경우 사용한다. IaaS별 CPI 또는 Jumpbox, CredHub 등의 설정을 적용할 수 있다.</td>
</tr>
<tr>
<td>-v</td>
<td>BOSH 설치 시 적용하는 변숫값 또는 Operation 파일에 변숫값을 설정할 경우 사용한다. Operation 파일 속성에 따라 필수 또는 선택 항목으로 나뉜다.</td>
</tr>
<tr>
<td>--var-file</td>
<td>주로 인증서를 사용하는 경우 사용하는 Option이다.</td>
</tr>
</table>

#### <div id='1018'/>3.3.5.1. OpenStack BOSH 환경 설정

```
bosh create-env bosh.yml \
    --state=openstack/state.json \                      # BOSH latest running state, 설치 시 생성, Backup 필요
    --vars-store=openstack/creds.yml \                  # BOSH credentials and certs, 설치 시 생성, Backup 필요
    -o openstack/cpi.yml \                              # openstack cpi 적용
    -o openstack/disable-readable-vm-names.yml \        # VM 명을 UUIDs로 적용
    -o uaa.yml \                                        # uaa 적용
    -o credhub.yml \                                    # credhub 적용
    -o jumpbox-user.yml \                               # jumpbox 적용
    -o syslog.yml \                                     # [MONITORING] monitoring logging agent 적용
    -o paasta-addon/paasta-monitoring-agent.yml \       # [MONITORING] monitoring metric agent 적용
    -v metric_url='10.0.161.101:8059' \                 # [MONITORING] monitoring agent가 BOSH 상태 정보 (Cpu/Memory/Disk...)를 모니터링 influxdb에 전송할 influxdb ip
    -v syslog_address='10.0.121.100' \                  # [MONITORING] log agent가 BOSH log 정보를 logsearch의 ls-router에 전송할 log ip
    -v syslog_port='2514' \                             # [MONITORING] log agent가 BOSH log 정보를 logsearch의 ls-router에 전송할 log port
    -v syslog_transport='relp' \                        # [MONITORING] log agent가 BOSH log 정보를 logsearch의 ls-router에 전송할 때 사용하는 logsearch protocol
    -v inception_os_user_name='ubuntu' \                # home user name
    -v director_name='micro-bosh' \                     # BOSH director name
    -v internal_cidr='10.0.1.0/24' \                    # internal ip range
    -v internal_gw='10.0.1.1' \                         # internal ip gateway
    -v internal_ip='10.0.1.6' \                         # internal ip 
    -v auth_url=http://xxx.xxx.xxx.xxx:5000/v3/  \      # openstack keystone url
    -v az='zone1' \                                     # openstack az zone
    -v default_key_name='openpaas' \                    # openstack key name
    -v default_security_groups=[openpaas] \             # openstack security group
    -v net_id='51b96a68-aded-4e73-aa44-f44a812b9b30' \  # openstack network id
    -v multizone=true \                                 # openstack compute node의 Multizone 설정(Ceph)
    -v openstack_password='xxxx' \                      # openstack user password
    -v openstack_username='xxxx'\                       # openstack user name
    -v openstack_domain='default' \                     # openstack domain name
    -v openstack_project='monitoring' \                 # openstack project
    -v region='RegionOne' \                             # openstack region
    -v private_key=~/.ssh/OpenPaas.pem                  # ssh private key path
```

#### <div id='1019'/>3.3.5.2. AWS BOSH 환경 설정

```
bosh create-env bosh.yml \
    --state=aws/state.json \                            # BOSH latest running state, 설치 시 생성, Backup 필요
    --vars-store aws/creds.yml \                        # BOSH credentials and certs, 설치 시 생성, Backup 필요
    -o aws/cpi.yml \                                    # aws cpi 적용
    -o uaa.yml \                                        # uaa 적용
    -o credhub.yml \                                    # credhub 적용
    -o jumpbox-user.yml \                               # jumpbox 적용
    -o syslog.yml \                                     # [MONITORING] monitoring logging agent 적용
    -o paasta-addon/paasta-monitoring-agent.yml \       # [MONITORING] monitoring metric agent 적용
    -v metric_url='10.0.161.101:8059' \                 # [MONITORING] monitoring agent가 BOSH 상태 정보 (Cpu/Memory/Disk...)를 모니터링 influxdb에 전송할 influxdb ip
    -v syslog_address='10.0.121.100' \                  # [MONITORING] log agent가 BOSH log 정보를 logsearch의 ls-router에 전송할 log ip
    -v syslog_port='2514' \                             # [MONITORING] log agent가 BOSH log 정보를 logsearch의 ls-router에 전송할 log port
    -v syslog_transport='relp' \                        # [MONITORING] log agent가 BOSH log 정보를 logsearch의 ls-router에 전송할 때 사용하는 logsearch protocol
    -v inception_os_user_name='ubuntu' \                # home user name
    -v director_name='micro-bosh' \                     # BOSH director name
    -v internal_cidr='10.0.1.0/24' \                    # internal ip range
    -v internal_gw='10.0.1.1' \                         # internal ip gateway
    -v internal_ip='10.0.1.6' \                         # internal ip 
    -v access_key_id='xxxxx' \                          # aws access key
    -v secret_access_key='xxxxx' \                      # aws secret key
    -v region='ap-northeast-1' \                        # aws region
    -v az='ap-northeast-1a' \                           # aws az zone
    -v default_key_name='paasta' \                      # aws key name
    -v default_security_groups=[paasta-rnd] \           # aws security-group
    -v subnet_id='subnet-ba1e15f3' \                    # aws subnet
    -v private_key=~/.ssh/paasta.pem                    # ssh private key path
```

#### <div id='1020'/>3.3.5.3. VMware vSphere BOSH 환경 설정

```
bosh create-env bosh.yml \
    --state=vsphere/state.json \                        # BOSH latest running state, 설치 시 생성, Backup 필요
    --vars-store=vsphere/creds.yml \                    # BOSH credentials and certs, 설치 시 생성, Backup 필요
    -o vsphere/cpi.yml \                                # vsphere cpi 적용
    -o vsphere/resource-pool.yml \                      # vsphere resource pool 적용    
    -o uaa.yml \                                        # uaa 적용
    -o credhub.yml \                                    # credhub 적용
    -o jumpbox-user.yml \                               # jumpbox 적용
    -o syslog.yml \                                     # [MONITORING] monitoring logging agent 적용
    -o paasta-addon/paasta-monitoring-agent.yml \       # [MONITORING] monitoring metric agent 적용
    -v metric_url='10.0.161.101:8059' \                 # [MONITORING] monitoring agent가 BOSH 상태 정보 (Cpu/Memory/Disk...)를 모니터링 influxdb에 전송할 influxdb ip
    -v syslog_address='10.0.121.100' \                  # [MONITORING] log agent가 BOSH log 정보를 logsearch의 ls-router에 전송할 log ip
    -v syslog_port='2514' \                             # [MONITORING] log agent가 BOSH log 정보를 logsearch의 ls-router에 전송할 log port
    -v syslog_transport='relp' \                        # [MONITORING] log agent가 BOSH log 정보를 logsearch의 ls-router에 전송할 때 사용하는 logsearch protocol
    -v inception_os_user_name='inception' \             # home user name
    -v director_name='micro-bosh' \                     # BOSH director name
    -v internal_cidr='10.30.0.0/16' \                   # internal ip range
    -v internal_gw='10.30.20.23' \                      # internal ip gateway
    -v internal_ip='10.30.40.111' \                     # internal ip 
    -v network_name="internal" \                        # internal network name (vcenter)
    -v vcenter_dc='datacenter' \                        # vcenter data center name
    -v vcenter_ds='storage' \                           # vcenter data storage name
    -v vcenter_ip='10.30.20.22' \                       # vcenter internal ip
    -v vcenter_user='xxxx' \                            # vcenter user name
    -v vcenter_password='xxxx' \                        # vcenter user password
    -v vcenter_templates='templates' \                  # vcenter templates name
    -v vcenter_vms='vms' \                              # vcenter vms name
    -v vcenter_disks='disks' \                          # vcenter disk name
    -v vcenter_cluster='cluster' \                      # vcenter cluster name
    -v vcenter_rp='resourcepool'                        # vcenter resource pool name
```

#### <div id='1021'/>3.3.5.4. MS Azure BOSH 환경 설정
```
bosh create-env bosh.yml \
    --state=azure/state.json \                          # BOSH latest running state, 설치 시 생성, Backup 필요
    --vars-store azure/creds.yml \                      # BOSH credentials and certs, 설치 시 생성, Backup 필요
    -o azure/cpi.yml \                                  # azure cpi 적용
    -o uaa.yml \                                        # uaa 적용
    -o credhub.yml \                                    # credhub 적용
    -o jumpbox-user.yml \                               # jumpbox 적용
    -o syslog.yml \                                     # [MONITORING] monitoring logging agent 적용
    -o paasta-addon/paasta-monitoring-agent.yml \       # [MONITORING] monitoring metric agent 적용
    -v metric_url='10.0.161.101:8059' \                 # [MONITORING] monitoring agent가 BOSH 상태 정보 (Cpu/Memory/Disk...)를 모니터링 influxdb에 전송할 influxdb ip
    -v syslog_address='10.0.121.100' \                  # [MONITORING] log agent가 BOSH log 정보를 logsearch의 ls-router에 전송할 log ip
    -v syslog_port='2514' \                             # [MONITORING] log agent가 BOSH log 정보를 logsearch의 ls-router에 전송할 log port
    -v syslog_transport='relp' \                        # [MONITORING] log agent가 BOSH log 정보를 logsearch의 ls-router에 전송할 때 사용하는 logsearch protocol
    -v inception_os_user_name='ubuntu' \                # home user name
    -v director_name='micro-bosh' \                     # BOSH director name
    -v internal_cidr='10.0.1.0/24' \                    # internal ip range
    -v internal_gw='10.0.1.1' \                         # internal ip gateway
    -v internal_ip='10.0.1.6' \                         # internal ip
    -v vnet_name='paasta-net' \                         # azure vnet name
    -v subnet_name='bosh-net' \                         # azure vnet subnet name
    -v subscription_id='xxxx' \                         # azure subscription id
    -v tenant_id='xxxx' \                               # azure tenant id
    -v client_id='xxxx' \                               # azure client id
    -v client_secret='xxxx' \                           # azure client secret
    -v resource_group_name='resoureceGorup' \           # azure resource group
    -v storage_account_name='paasta' \                  # azure storage account
    -v default_security_group='bosh-security'           # azure security group
```

#### <div id='1022'/>3.3.5.5. GCP BOSH 환경 설정
```
bosh create-env bosh.yml \
    --state=gcp/state.json \                            # BOSH latest running state, 설치 시 생성, Backup 필요
    --vars-store gcp/creds.yml \                        # BOSH credentials and certs, 설치 시 생성, Backup 필요
    -o gcp/cpi.yml \                                    # gcp cpi 적용
    -o uaa.yml \                                        # uaa 적용
    -o credhub.yml \                                    # credhub 적용
    -o jumpbox-user.yml \                               # jumpbox 적용
    -o syslog.yml \                                     # [MONITORING] monitoring logging agent 적용
    -o paasta-addon/paasta-monitoring-agent.yml \       # [MONITORING] monitoring metric agent 적용
    -v metric_url='10.0.161.101:8059' \                 # [MONITORING] monitoring agent가 BOSH 상태 정보 (Cpu/Memory/Disk...)를 모니터링 influxdb에 전송할 influxdb ip
    -v syslog_address='10.0.121.100' \                  # [MONITORING] log agent가 BOSH log 정보를 logsearch의 ls-router에 전송할 log ip
    -v syslog_port='2514' \                             # [MONITORING] log agent가 BOSH log 정보를 logsearch의 ls-router에 전송할 log port
    -v syslog_transport='relp' \                        # [MONITORING] log agent가 BOSH log 정보를 logsearch의 ls-router에 전송할 때 사용하는 logsearch protocol
    -v inception_os_user_name='ubuntu' \                # home user name
    -v director_name='micro-bosh' \                     # BOSH director name
    -v internal_cidr='10.0.1.0/24' \                    # internal ip range
    -v internal_gw='10.0.1.1' \                         # internal ip gateway
    -v internal_ip='10.0.1.6' \                         # internal ip
    -v network='paas-ta-network' \                      # gcp network name
    -v subnetwork='bosh-net' \                          # gcp subnet name
    -v tags=[bosh-security] \                           # gcp tags
    -v project_id='paas-ta-198701' \                    # gcp project id
    -v zone='asia-northeast1-a' \                       # gcp zone
    -v private_key=~/.ssh/vcap.pem \                    # ssh private key path
    --var-file gcp_credentials_json=~/.ssh/a54132.json  # gcp service account key
```

#### <div id='1023'/>3.3.5.6. BOSH-LITE 환경 설정
```
bosh create-env bosh.yml \
    --state=warden/state.json \                         # BOSH latest running state, 설치 시 생성, Backup 필요
    --vars-store warden/creds.yml \                     # BOSH credentials and certs, 설치 시 생성, Backup 필요
    -o virtualbox/cpi.yml \                             # virtualbox cpi 적용
    -o virtualbox/outbound-network.yml \                # virtualbox outbound network 적용
    -o bosh-lite.yml \                                  # BOSH lite 적용
    -o uaa.yml \                                        # uaa 적용
    -o credhub.yml \                                    # credhub 적용
    -o jumpbox-user.yml \                               # jumpbox 적용
    -o syslog.yml \                                     # [MONITORING] monitoring logging agent 적용
    -o paasta-addon/paasta-monitoring-agent.yml \       # [MONITORING] monitoring metric agent 적용
    -v metric_url='10.0.161.101:8059' \                 # [MONITORING] monitoring agent가 BOSH 상태 정보 (Cpu/Memory/Disk...)를 모니터링 influxdb에 전송할 influxdb ip
    -v syslog_address='10.0.121.100' \                  # [MONITORING] log agent가 BOSH log 정보를 logsearch의 ls-router에 전송할 log ip
    -v syslog_port='2514' \                             # [MONITORING] log agent가 BOSH log 정보를 logsearch의 ls-router에 전송할 log port
    -v syslog_transport='relp' \                        # [MONITORING] log agent가 BOSH log 정보를 logsearch의 ls-router에 전송할 때 사용하는 logsearch protocol
    -v inception_os_user_name='ubuntu' \                # home user name
    -v director_name='vbox' \                           # BOSH director name
    -v internal_ip='192.168.150.4' \                    # internal ip range
    -v internal_gw='192.168.150.1' \                    # internal gateway
    -v internal_cidr='192.168.150.0/24' \               # internal ip rang
    -v network_name='vboxnet0' \                        # internal network name
    -v outbound_network_name='NatNetwork'               # outbound network name
```

- Shell script 파일에 실행 권한 부여

```
$ chmod +x ${HOME}/workspace/paasta-5.0/deployment/bosh-deployment/*.sh  
```

### <div id='1024'/>3.3.6. PaaS-TA Monitoring Operation 파일

PaaS-TA Monitoring을 적용하기 위해서 BOSH 설치 시 아래 두 파일과 변숫값을 추가해야 한다. 만약 Monitoring을 사용하지 않는다면, 두 파일을 제거하고 설치한다.

| 파일명 | 설명 | 요구사항 |
|:---  |:---     |:---   |
|paasta-addon/paasta-monitoring-agent.yml | PaaS-TA Monitoring Agent 적용 | Requries value:   -v metric_url  |
|syslog.yml | Syslog 구성 적용 | Requries value: -v syslog_address   -v syslog_port -v syslog_transport |

PaaS-TA Monitoring Agent는 BOSH VM의 상태 정보(Metric data)를 paasta-monitoring의 influxdb에 전송한다. 
Syslog Agent는 BOSH VM의 log 정보를 logsearch의 ls-router에 전송하는 역할을 한다.
BOSH 설치 전에 paasta-monitoring의 influxdb ip를 metric_url로 사용하기 위해 사전에 정의해야 한다. 마찬가지로 logsearch의 ls-router ip도 syslog_address로 연동하기 위해 사전에 정의해야 한다.

### <div id='1025'/>3.3.7. BOSH 설치

- BOSH 설치 Shell script 파일 실행

```
$ cd ${HOME}/workspace/paasta-5.0/deployment/bosh-deployment
$ ./deploy-{iaas}.sh
```

- BOSH 설치 중

```
ubuntu@ip-10-0-0-59:~/workspace/paasta-5.0/deployment/bosh-deployment$ ./deploy-aws.sh
Deployment manifest: '/home/ubuntu/workspace/paasta-5.0/deployment/bosh-deployment/bosh.yml'
Deployment state: 'aws/state.json'

Started validating
  Validating release 'bosh'... Finished (00:00:01)
  Validating release 'bpm'... Finished (00:00:01)
  Validating release 'bosh-aws-cpi'... Finished (00:00:00)
  Validating release 'uaa'... Finished (00:00:03)
  Validating release 'credhub'...
```

- BOSH 설치 완료

```
  Compiling package 'uaa_utils/90097ea98715a560867052a2ff0916ec3460aabb'... Skipped [Package already compiled] (00:00:00)
  Compiling package 'davcli/f8a86e0b88dd22cb03dec04e42bdca86b07f79c3'... Skipped [Package already compiled] (00:00:00)
  Updating instance 'bosh/0'... Finished (00:01:44)
  Waiting for instance 'bosh/0' to be running... Finished (00:02:16)
  Running the post-start scripts 'bosh/0'... Finished (00:00:13)
Finished deploying (00:11:54)

Stopping registry... Finished (00:00:00)
Cleaning up rendered CPI jobs... Finished (00:00:00)

Succeeded
```

### <div id='1026'/>3.3.8. BOSH 로그인
BOSH가 설치되면, BOSH 설치 디렉터리 이하 {iaas}/creds.yml 파일이 생성된다. creds.yml은 BOSH 인증정보를 가지고 있으며, creds.yml을 활용하여 BOSH에 로그인한다. BOSH 로그인 후, BOSH CLI 명령어를 이용하여 PaaS-TA를 설치할 수 있다.

```
$ cd ${HOME}/workspace/paasta-5.0/deployment/bosh-deployment
$ export BOSH_CA_CERT=$(bosh int ./{iaas}/creds.yml --path /director_ssl/ca)
$ export BOSH_CLIENT=admin
$ export BOSH_CLIENT_SECRET=$(bosh int ./{iaas}/creds.yml --path /admin_password)
$ bosh alias-env {director_name} -e {bosh-internal-ip} --ca-cert <(bosh int {iaas}/creds.yml --path /director_ssl/ca)
$ bosh –e {director_name} env
```

### <div id='1027'/>3.3.9. CredHub
CredHub은 인증정보 저장소이다. BOSH 설치 시 Operation 파일로 credhub.yml을 추가하였다. BOSH 설치 시 credhub.yml을 적용하면, PaaS-TA 설치 시  PaaS-TA에서 사용하는 인증정보(certificate, password)를 CredHub에 저장한다. PaaS-TA 인증정보가 필요할 때 CredHub을 사용하며, CredHub CLI를 통해 CredHub에 로그인하여 인증정보 조회, 수정, 삭제를 할 수 있다.

#### <div id='1028'/>3.3.9.1. CredHub CLI 설치

CredHub CLI는 BOSH를 설치한 Inception(설치환경)에 설치한다.

```
$ wget https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/2.5.3/credhub-linux-2.5.3.tgz
$ tar -xvf credhub-linux-2.5.3.tgz 
$ chmod +x credhub
$ sudo mv credhub /usr/local/bin/credhub 
$ credhub –version
```

#### <div id='1029'/>3.3.9.2. CredHub 로그인
CredHub에 로그인하기 위해 BOSH를 설치한 bosh-deployment 디렉터리의 creds.yml을 활용하여 로그인한다.

```
$ export CREDHUB_CLIENT=credhub-admin
$ export CREDHUB_SECRET=$(bosh int --path /credhub_admin_client_secret {iaas}/creds.yml)
$ export CREDHUB_CA_CERT=$(bosh int --path /credhub_tls/ca {iaas}/creds.yml)
$ credhub login -s https://{bosh-internal-ip}:8844 --skip-tls-validation
$ credhub find
```

CredHub 로그인 후 find 명령어로 조회하면 비어 있는 것을 알 수 있다. PaaS-TA를 설치하면 인증 정보가 저장되어 조회할 수 있다.

- uaa 인증정보 조회

```
$ credhub get -n /{director}/{deployment}/uaa_ca
```

### <div id='1030'/>3.3.10. Jumpbox
BOSH 설치 시 Operation 파일로 jumpbox-user.yml을 추가하였다. Jumpbox는 BOSH VM에 접근하기 위한 인증을 적용하게 된다. 인증키는 BOSH에서 자체적으로 생성하며, 인증키를 통해 BOSH VM에 접근할 수 있다. BOSH VM에 이상이 있거나 상태를 체크할 때 Jumpbox를 활용하여 BOSH VM에 접근할 수 있다.

```
$ cd ${HOME}/workspace/paasta-5.0/deployment/bosh-deployment
$ bosh int {iaas}/creds.yml --path /jumpbox_ssh/private_key > jumpbox.key 
$ chmod 600 jumpbox.key
$ ssh jumpbox@{bosh_ip} -i jumpbox.key
```

```
ubuntu@ip-10-0-0-59:~/workspace/paasta-5.0/deployment/bosh-deployment$ ssh jumpbox@10.0.1.6 -i jumpbox.key
Unauthorized use is strictly prohibited. All access and activity
is subject to logging and monitoring.
Welcome to Ubuntu 16.04.6 LTS (GNU/Linux 4.15.0-54-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
Last login: Thu Oct 17 03:57:48 UTC 2019 from 10.0.0.9 on pts/0
Last login: Fri Oct 25 07:05:42 2019 from 10.0.0.9
bosh/0:~$
```

[PaaSTa_BOSH_Use_Guide_Image1]:./images/bosh1.png
[PaaSTa_BOSH_Use_Guide_Image2]:./images/bosh2.png
[PaaSTa_BOSH_Use_Guide_Image3]:./images/bosh3.png
