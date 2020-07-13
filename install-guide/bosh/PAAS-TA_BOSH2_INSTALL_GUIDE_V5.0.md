## Table of Contents

1. [개요](#101)  
　● [목적](#102)  
　● [범위](#103)  
　● [참고 자료](#104)  
2. [BOSH](#105)  
　● [BOSH 컴포넌트 구성](#106)  
3. [BOSH 설치 환경 구성 및 설치](#107)  
　3.1. [BOSH 설치 절차](#108)  
　3.2. [Inception 서버 구성](#109)  
　3.3. [BOSH 설치](#1010)  
　　3.3.1. [Prerequisite](#1011)  
　　3.3.2. [BOSH CLI 및 Dependency 설치](#1012)  
　　3.3.3. [설치 파일 다운로드](#1013)  
　　3.3.4. [BOSH 설치 파일](#1014)  
　　3.3.5. [BOSH 환경 설정](#1015)  
　　　3.3.5.1. [BOSH 설치 Variable 파일](#1016)  
　　　　● [aws-vars.yml](#1017)  
　　　　● [azure-vars.yml](#1018)  
　　　　● [gcp-vars.yml](#1019)  
　　　　● [openstack-vars.yml](#1020)  
　　　　● [vsphere-vars.yml](#1021)  
　　　　● [bosh-lite-vars.yml](#1022)  
　　　3.3.5.2. [BOSH 설치 Option 파일](#1023)  
　　　　● [BOSH Optional 파일](#1024)  
　　　　● [PaaS-TA Monitoring Operation 파일](#1025)  
　　　3.3.5.3. [BOSH 설치 Shell Script](#1026)  
　　　　● [deploy-aws.sh](#1027)  
　　　　● [deploy-azure.sh](#1028)  
　　　　● [deploy-gcp.sh](#1029)  
　　　　● [deploy-openstack.sh](#1030)  
　　　　● [deploy-vsphere.sh](#1031)  
　　　　● [deploy-{IaaS}-monitoring.sh](#1032)  
　　　　● [deploy-bosh-lite.sh](#1033)  
　　3.3.6. [BOSH 설치](#1034)  
　　3.3.7. [BOSH 설치 - 다운로드 된 Release 파일 이용 방식](#1035)  
　　3.3.8. [BOSH 로그인](#1036)  
　　3.3.9. [CredHub](#1038)  
　　　3.3.9.1. [CredHub CLI 설치](#1038)  
　　　3.3.9.2. [CredHub 로그인](#1039)  
　　3.3.9. [Jumpbox](#1040)  

## Executive Summary

본 문서는 BOSH2(이하 BOSH)의 설명 및 설치 가이드 문서로, BOSH를 실행할 수 있는 환경을 구성하고 사용하는 방법에 관해서 설명하였다.

# <div id='101'/>1. 문서 개요 

## <div id='102'/>● 목적
클라우드 환경에 서비스 시스템을 배포할 수 있는 BOSH는 릴리즈 엔지니어링, 개발, 소프트웨어 라이프사이클 관리를 통합한 오픈소스 프로젝트로 본 문서에서는 Inception 환경(설치환경)에서 BOSH를 설치하는 데 그 목적이 있다. 

## <div id='103'/>● 범위
본 문서는 Linux 환경(Ubuntu 18.04)을 기준으로 BOSH 설치를 위한 패키지와 라이브러리를 설치 및 구성하고, 이를 이용하여 BOSH를 설치하는 것을 기준으로 작성하였다.

## <div id='104'/>● 참고 자료

본 문서는 Cloud Foundry의 BOSH Document와 Cloud Foundry Document를 참고로 작성하였다.

BOSH Document: [http://bosh.io](http://bosh.io)

BOSH Deployment: [https://github.com/cloudfoundry/bosh-deployment](https://github.com/cloudfoundry/bosh-deployment)

Cloud Foundry Document: [https://docs.cloudfoundry.org](https://docs.cloudfoundry.org)

# <div id='105'/>2. BOSH
BOSH는 초기에 Cloud Foundry PaaS를 위해 개발되었지만, 현재는 Jenkins, Hadoop 등 Yaml 파일 형식으로 소프트웨어를 쉽게 배포할 수 있으며, 수백 가지의 VM을 설치할 수 있고, 각각의 VM에 대해 모니터링, 장애 복구 등 라이프 사이클을 관리할 수 있는 통합 프로젝트이다.

BOSH가 지원하는 IaaS는 VMware vSphere, Google Cloud Platform, AWS, OpenStack, MS Azure, VMware vCloud, RackHD, SoftLayer가 있다.  
PaaS-TA는 VMware vSphere, Google Cloud Platform, AWS, OpenStack, MS Azure 등의 IaaS를 지원한다.

PaaS-TA 3.1 버전까지는 Cloud Foundry BOSH1을 기준으로 설치했지만, PaaS-TA 3.5 버전부터 BOSH2를 기준으로 설치하였다.  
PaaS-TA 5.0은 Cloud Foundry에서 제공하는 bosh-deployment를 활용하여 BOSH를 설치한다.

BOSH2는 BOSH2 CLI를 통하여 BOSH와 PaaS-TA를 모두 생성한다.  
bosh-deployment를 이용하여 BOSH를 생성한 후, paasta-deployment로 PaaS-TA를 설치한다.  
PaaS-TA 3.1 버전까지는 PaaS-TA Container, Controller를 별도의 deployment로 설치했지만, PaaS-TA 3.5 버전부터는 paasta-deployment 하나로 통합되어 한 번에 PaaS-TA를 설치한다.

![PaaSTa_BOSH_Use_Guide_Image2](https://github.com/PaaS-TA/Guide-5.0-Ravioli/blob/master/install-guide/bosh/images/bosh2.png)

## <div id='106'/>● BOSH 컴포넌트 구성

BOSH의 컴포넌트 구성은 다음과 같다.

![PaaSTa_BOSH_Use_Guide_Image3](https://github.com/PaaS-TA/Guide-5.0-Ravioli/blob/master/install-guide/bosh/images/bosh3.png)

- Director: Director는 VM 생성 또는 수정 시 설정 정보를 레지스트리에 저장한다.  
저장된 레지스트리 정보는 VM의 Bootstrapping Stage에서 이용된다.
- Health Monitor: Health Monitor는 BOSH Agent로부터 클라우드 상태 정보를 수집한다.  
클라우드로부터 특정 Alert이 발생하면, Resurrector를 하거나 Notification Plug-in을 통해 Alert Message를 전송할 수도 있다.
- Blobstore: Blobstore는 Release, Compilation Package Data를 저장하는 저장소이다.
- UAA: UAA는 BOSH 사용자 인증 인가 처리를 한다.
- Database: Director가 사용하는 Postgres 데이터베이스로, Deployment에 필요한 Stemcell, Release, Deployment의 메타 정보를 저장한다.
- Message Bus(Nats): Message Bus는 Director와 Agent 간 통신을 위한 Publish-Subscribe 방식의 Message System으로, VM 모니터링과 특정 명령을 수행하기 위해 사용된다.
- Agent: Agent는 클라우드에 배포되는 모든 VM에 설치되고, Director로부터 특정 명령을 받고 수행하는 역할을 한다. Agent는 Director로부터 수신받은 Job Specification(설치할 패키지 및 구성 방법) 정보로 해당 VM에 Director의 지시대로 지정된 패키지를 설치하고, 필요한 구성 정보를 설정한다.

# <div id='107'/>3. BOSH 설치 환경 구성 및 설치

## <div id='108'/>3.1. BOSH 설치 절차
Inception(PaaS-TA 설치 환경)은 BOSH 및 PaaS-TA를 설치하기 위한 설치 환경으로, VM 또는 서버 장비이다.  
OS Version은 Ubuntu 18.04를 기준으로 한다. IaaS에서 수동으로 Inception VM을 생성해야 한다.

Inception VM은 Ubuntu 18.04, vCPU 2 Core, Memory 4G, Disk 100G 이상을 권고한다.

## <div id='109'/>3.2.  Inception 서버 구성

Inception 서버는 BOSH 및 PaaS-TA를 설치하기 위해 필요한 패키지 및 라이브러리, Manifest 파일 등의 환경을 가지고 있는 배포 작업 실행 서버이다.  
Inception 서버는 외부 통신이 가능해야 한다.

BOSH 및 PaaS-TA 설치를 위해 Inception 서버에 구성해야 할 컴포넌트는 다음과 같다.

- BOSH CLI 6.1.x 이상 
- BOSH Dependency : ruby, ruby-dev, openssl 등
- BOSH Deployment: BOSH 설치를 위한 manifest deployment  
- PaaS-TA Deployment : PaaS-TA 설치를 위한 manifest deployment (cf-deployment v9.5.0 기준)

## <div id='1010'/>3.3.  BOSH 설치

### <div id='1011'/>3.3.1.    Prerequisite

- 본 설치 가이드는 Ubuntu 18.04 버전을 기준으로 한다.

### <div id='1012'/>3.3.2.    BOSH CLI 및 Dependency 설치

- BOSH Dependency 설치 (Ubuntu 18.04)

```
$ sudo apt install -y build-essential zlibc zlib1g-dev ruby ruby-dev openssl libxslt1-dev libxml2-dev libssl-dev libreadline7 libreadline-dev libyaml-dev libsqlite3-dev sqlite3
```

- BOSH Dependency 설치 (Ubuntu 16.04)

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

BOSH2 CLI는 BOSH 설치 시, BOSH certificate 정보를 생성해 주는 기능이 있다.  
Cloud Foundry의 기본 BOSH CLI는 인증서가 1년으로 제한되어 있다.  
BOSH 인증서는 BOSH 내부 Component 간의 통신 시 필요한 certificate이다.  
만약 BOSH 설치 후 1년이 지나면 BOSH를 다시 설치해야 한다.

BOSH2 CLI 6.1 이상 버전은 create-env의 config-server를 통해 생성된 인증서를 1년 이상 구성할 수 있다.

BOSH2 CLI 6.0 이하 버전 사용 시, 인증서 기간을 늘리고 싶다면 BOSH CLI 소스를 다운로드해 컴파일하여 사용해야 한다.  
소스 컴파일 방법은 다음 가이드를 참고한다.  

- 소스 build 전제 조건 :: Ubuntu, go 1.9.2 버전 이상

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

### <div id='1013'/>3.3.3.    설치 파일 다운로드

- BOSH를 설치하기 위한 deployment가 존재하지 않는다면 다운로드 받는다
```
$ cd ${HOME}/workspace/paasta-5.0/deployment
$ git clone https://github.com/PaaS-TA/paasta-deployment.git
```

### <div id='1014'/>3.3.4.    BOSH 설치 파일

- paasta-5.0/paasta-deployment 이하 디렉터리

```
$ cd ${HOME}/workspace/paasta-5.0/paasta-deployment
$ ls
bosh  cloud-config  paasta
```

<table>
<tr>
<td>bosh</td>
<td>BOSH 설치를 위한 manifest 및 설치 파일이 존재하는 디렉터리</td>
</tr>
<tr>
<td>cloud-config</td>
<td>PaaS-TA 설치를 위한 IaaS network, storage, vm 관련 설정 파일이 존재하는 디렉터리</td>
</tr>
<tr>
<td>paasta</td>
<td>PaaS-TA 설치를 위한 manifest 및 설치 파일이 존재하는 디렉터리</td>
</tr>
</table>

### <div id='1015'/>3.3.5.    BOSH 환경 설정

${HOME}/workspace/paasta-5.0/deployment/paasta-deployment/bosh 이하 디렉터리에는 BOSH 설치를 위한 IaaS별 Shell Script 파일이 존재한다.  
Shell Script 파일을 이용하여 BOSH를 설치한다.
파일명은 deploy-{IaaS}.sh 로 만들어졌다.  
또한 {IaaS}-vars.yml을 수정하여 BOSH 설치시 적용하는 변숫값을 변경할 수 있다.

<table>
<tr>
<td>aws-vars.yml</td>
<td>AWS 환경에 BOSH 설치시 적용하는 변숫값 설정 파일</td>
</tr>
<tr>
<td>azure-vars.yml</td>
<td>MS Azure 환경에 BOSH 설치시 적용하는 변숫값 설정 파일</td>
</tr>
<tr>
<td>gcp-vars.yml</td>
<td>GCP(Google Cloud Platform) 환경에 BOSH 설치시 적용하는 변숫값 설정 파일</td>
</tr>
<tr>
<td>openstack-vars.yml</td>
<td>OpenStack 환경에 BOSH 설치시 적용하는 변숫값 설정 파일</td>
</tr>
<tr>
<td>vsphere-vars.yml</td>
<td>VMware vSphere 환경에 BOSH 설치시 적용하는 변숫값 설정 파일</td>
</tr>
<tr>
<td>bosh-lite-vars.yml</td>
<td>Local Test 환경에 BOSH-LITE 설치시 적용하는 변숫값 설정 파일</td>
</tr>
<tr>
<td>deploy-aws.sh</td>
<td>AWS 환경에 BOSH 설치를 위한 Shell Script 파일</td>
</tr>
<tr>
<td>deploy-azure.sh</td>
<td>MS Azure 환경에 BOSH 설치를 위한 Shell Script 파일</td>
</tr>
<tr>
<td>deploy-gcp.sh</td>
<td>GCP(Google Cloud Platform) 환경에 BOSH 설치를 위한 Shell Script 파일</td>
</tr>
<tr>
<td>deploy-openstack.sh</td>
<td>OpenStack 환경에 BOSH 설치를 위한 Shell Script 파일</td>
</tr>
<tr>
<td>deploy-vsphere.sh</td>
<td>VMware vSphere 환경에 BOSH 설치를 위한 Shell Script 파일</td>
</tr>
<tr>
<td>deploy-{IaaS}-monitoring.sh</td>
<td>각 IaaS 환경에 PaaS-TA Monitoring을 설치하기 전에 BOSH 설치를 위한 Shell Script 파일</td>
</tr>
<tr>
<td>deploy-bosh-lite.sh</td>
<td>Local Test 용도로 BOSH-LITE 설치를 위한 Shell Script 파일</td>
</tr>
</table>

BOSH 설치 명령어는 create-env로 시작한다.  
Shell이 아닌 BOSH Command로 실행 가능하며, 설치하는 IaaS 환경에 따라 Option이 달라진다.  
BOSH 삭제 시 delete-env 명령어를 사용하여 설치된 BOSH를 삭제할 수 있다.

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
<td>-l, --var-file</td>
<td>YAML파일에 작성한 변수를 읽어올때 사용한다.</td>
</tr>
</table>


#### <div id='1016'/>3.3.5.1. BOSH 설치 Variable File

##### <div id='1017'/>● aws-vars.yml

```
# BOSH VARIABLE
bosh_client_admin_id: "admin"				# Bosh Client Admin ID
private_cidr: "10.0.1.0/24"				# Private IP Range
private_gw: "10.0.1.1"					# Private IP Gateway
bosh_url: "10.0.1.6"					# Private IP 
inception_os_user_name: "ubuntu"			# Home User Name
director_name: "micro-bosh"				# BOSH Director Name
access_key_id: "XXXXXXXXXXXXXXX"			# AWS Access Key
secret_access_key: "XXXXXXXXXXXXX"			# AWS Secret Key
region: "ap-northeast-2"				# AWS Region
az: "ap-northeast-2a"					# AWS AZ Zone
default_key_name: "aws-paasta.pem"			# AWS Key Name
default_security_groups: ["bosh"]			# AWS Security-Group
subnet_id: "paasta-subnet"				# AWS Subnet
private_key: "~/.ssh/aws-paasta.pem"			# SSH Private Key Path

# MONITORING VARIABLE(PaaS-TA Monitoring을 설치할 경우 향후 설치할 VM의 값으로 미리 수정)
metric_url: "10.0.161.101"				# PaaS-TA Monitoring InfluxDB IP
syslog_address: "10.0.121.100"				# Logsearch의 ls-router IP
syslog_port: "2514"					# Logsearch의 ls-router Port
syslog_transport: "relp"				# Logsearch Protocol
```



##### <div id='1018'/>● azure-vars.yml
```
# BOSH VARIABLE
bosh_client_admin_id: "admin"				# Bosh Client Admin ID
private_cidr: "10.0.1.0/24"				# Private IP Range
private_gw: "10.0.1.1"					# Private IP Gateway
bosh_url: "10.0.1.6"					# Private IP
inception_os_user_name: "ubuntu"			# Home User Name
director_name: "micro-bosh"				# BOSH Director Name
vnet_name: "paasta-bosh-net"				# Azure VNet Name
subnet_name: "paasta-subnet"				# Azure VNet Subnet Name
subscription_id: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"	# Azure Subscription ID
tenant_id: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"	# Azure Tenant ID
client_id: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"	# Azure Client ID
client_secret: "client-secret"				# Azure Client Secret
resource_group_name: "paasta-bosh-group"		# Azure Resource Group
storage_account_name: "paasta-store"			# Azure Storage Account
default_security_group: "paasta-security"		# Azure Security Group

# MONITORING VARIABLE(PaaS-TA Monitoring을 설치할 경우 향후 설치할 VM의 값으로 미리 수정)
metric_url: "10.0.161.101"				# PaaS-TA Monitoring InfluxDB IP
syslog_address: "10.0.121.100"				# Logsearch의 ls-router IP
syslog_port: "2514"					# Logsearch의 ls-router Port
syslog_transport: "relp"				# Logsearch Protocol
```

##### <div id='1019'/>● gcp-vars.yml
```
# BOSH VARIABLE
bosh_client_admin_id: "admin"				# Bosh Client Admin ID
inception_os_user_name: "ubuntu"			# Home User Name
director_name: "micro-bosh"				# BOSH Director Name
private_cidr: "10.0.1.0/24"				# Private IP Range
private_gw: "10.0.1.1"					# Private IP Gateway
bosh_url: "10.0.1.6"					# Private IP
network: "public-bosh"					# GCP Network Name
subnetwork: "public-bosh-subnet"			# GCP Subnet Name
tags: ["paasta-security"]				# GCP Tags
project_id: "paasta-project"				# GCP Project ID
zone: "asia-northeast1-a"				# GCP Zone

# MONITORING VARIABLE(PaaS-TA Monitoring을 설치할 경우 향후 설치할 VM의 값으로 미리 수정)
metric_url: "10.0.161.101"				# PaaS-TA Monitoring InfluxDB IP
syslog_address: "10.0.121.100"				# Logsearch의 ls-router IP
syslog_port: "2514"					# Logsearch의 ls-router Port
syslog_transport: "relp"				# Logsearch Protocol
```


##### <div id='1020'/>● openstack-vars.yml

```
# BOSH VARIABLE
bosh_client_admin_id: "admin"				# Bosh Client Admin ID
inception_os_user_name: "ubuntu"			# Home User Name
director_name: "micro-bosh"				# BOSH Director Name
private_cidr: "10.0.1.0/24"				# Private IP Range
private_gw: "10.0.1.1"					# Private IP Gateway
bosh_url: "10.0.1.6"					# Private IP 
auth_url: "http://XX.XXX.XX.XX:XXXX/v3/"		# Openstack Keystone URL
az: "nova"						# Openstack AZ Zone
default_key_name: "paasta"				# Openstack Key Name
default_security_groups: ["paasta"]			# Openstack Security Group
net_id: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"		# Openstack Network ID
openstack_password: "XXXXXX"				# Openstack User Password
openstack_username: "XXXXXX"				# Openstack User Name
openstack_domain: "XXXXXXX"				# Openstack Domain Name
openstack_project: "PaaSTA"				# Openstack Project
private_key: "~/.ssh/id_rsa.pem"			# Openstack Region
region: "RegionOne"					# SSH Private Key Path

# MONITORING VARIABLE(PaaS-TA Monitoring을 설치할 경우 향후 설치할 VM의 값으로 미리 수정)
metric_url: "10.0.161.101"				# PaaS-TA Monitoring InfluxDB IP
syslog_address: "10.0.121.100"				# Logsearch의 ls-router IP
syslog_port: "2514"					# Logsearch의 ls-router Port
syslog_transport: "relp"				# Logsearch Protocol
```



##### <div id='1021'/>● vsphere-vars.yml

```
# BOSH VARIABLE
bosh_client_admin_id: "admin"				# Bosh Client Admin ID
inception_os_user_name: "ubuntu"			# Home User Name
director_name: "micro-bosh"				# BOSH Director Name
private_cidr: "10.0.1.0/24"				# Private IP Range
private_gw: "10.0.1.1"					# Private IP Gateway
bosh_url: "10.0.1.6"					# Private IP 
network_name: "PaaS-TA"					# Private Network Name (vCenter)
vcenter_dc: "PaaS-TA-DC"				# vCenter Data Center Name
vcenter_ds: "PaaS-TA-Storage"				# vCenter Data Storage Name
vcenter_ip: "XX.XX.XXX.XX"				# vCenter Private IP
vcenter_user: "XXXXX"					# vCenter User Name
vcenter_password: "XXXXXX"				# vCenter User Password
vcenter_templates: "PaaS-TA_Templates"			# vCenter Templates Name
vcenter_vms: "PaaS-TA_VMs"				# vCenter VMS Name
vcenter_disks: "PaaS-TA_Disks"				# vCenter Disk Name
vcenter_cluster: "PaaS-TA"				# vCenter Cluster Name
vcenter_rp: "PaaS-TA_Pool"				# vCenter Resource Pool Name

# MONITORING VARIABLE(PaaS-TA Monitoring을 설치할 경우 향후 설치할 VM의 값으로 미리 수정)
metric_url: "10.0.161.101"				# PaaS-TA Monitoring InfluxDB IP
syslog_address: "10.0.121.100"				# Logsearch의 ls-router IP
syslog_port: "2514"					# Logsearch의 ls-router Port
syslog_transport: "relp"				# Logsearch Protocol
```

##### <div id='1022'/>● bosh-lite-vars.yml
```
# BOSH VARIABLE
bosh_client_admin_id: "admin"				# Bosh Client Admin ID
inception_os_user_name: 'ubuntu'			# Home User Name
director_name: 'micro-bosh'				# BOSH Director Name
private_cidr: '10.0.1.0/24'				# Private IP Range
private_gw: '10.0.1.1'					# Private IP Gateway
bosh_url: '10.0.1.6'					# Private IP 
outbound_network_name: 'NatNetwork'			# Outbound Network Name
```



#### <div id='1023'/>3.3.5.2. BOSH 설치 Option 파일

##### <div id='1024'/>● BOSH Optional 파일

<table>
<tr>
<td>파일명</td>
<td>설명</td>
</tr>
<tr>
<td>use-compiled-releases.yml</td>
<td>다운로드 및 컴파일 없이 빠른 설치가 가능하다.</td>
</tr>
<tr>
<td>use-compiled-releases-aws.yml</td>
<td>다운로드 및 컴파일 없이 AWS-CPI의 릴리즈의 빠른 설치가 가능하다.</td>
</tr>
<tr>
<td>use-compiled-releases-azure.yml</td>
<td>다운로드 및 컴파일 없이 Azure-CPI의 릴리즈의 빠른 설치가 가능하다.</td>
</tr>
<tr>
<td>use-compiled-releases-gcp.yml</td>
<td>다운로드 및 컴파일 없이 GCP-CPI의 릴리즈의 빠른 설치가 가능하다.</td>
</tr>
<tr>
<td>use-compiled-releases-openstack.yml</td>
<td>다운로드 및 컴파일 없이 OpenStack-CPI의 릴리즈의 빠른 설치가 가능하다.</td>
</tr>
<tr>
<td>use-compiled-releases-vsphere.yml</td>
<td>다운로드 및 컴파일 없이 vSphere-CPI의 릴리즈의 빠른 설치가 가능하다.</td>
</tr>
<tr>
<td>uaa.yml</td>
<td>UAA 적용</td>
</tr>
<tr>
<td>use-compiled-releases-uaa.yml</td>
<td>다운로드 및 컴파일 없이 UAA의 빠른 설치가 가능하다.</td>
</tr>
<tr>
<td>credhub.yml</td>
<td>CredHub 적용</td>
</tr>
<tr>
<td>use-compiled-releases-credhub.yml</td>
<td>다운로드 및 컴파일 없이 CredHub의 빠른 설치가 가능하다.</td>
</tr>
<tr>
<td>jumpbox.yml</td>
<td>Jumpbox 적용</td>
</tr>
<tr>
<td>use-compiled-releases-jumpbox.yml</td>
<td>다운로드 및 컴파일 없이 Jumpbox의 빠른 설치가 가능하다.</td>
</tr>
</table>

##### <div id='1025'/>● PaaS-TA Monitoring Operation 파일

PaaS-TA Monitoring을 적용하기 위해서 BOSH 설치 시 아래 두 파일과 변숫값을 추가해야 한다.  
만약 Monitoring을 사용하지 않는다면, 두 파일을 제거하고 설치한다.

| 파일명 | 설명 | 요구사항 |
|:---  |:---     |:---   |
|paasta-addon/paasta-monitoring-agent.yml | PaaS-TA Monitoring Agent 적용 | Requries value:   -v metric_url  |
|paasta-addon/use-compiled-releases-monitoring-agent.yml | 다운로드 및 컴파일 없이 PaaS-TA Monitoring Agent의 빠른 설치가 가능하다.	 | |
|syslog.yml | Syslog 구성 적용 | Requries value: -v syslog_address   -v syslog_port -v syslog_transport |
|use-compiled-releases-syslog.yml | 다운로드 및 컴파일 없이 Syslog의 빠른 설치가 가능하다.	 |  |

PaaS-TA Monitoring Agent는 BOSH VM의 상태 정보(Metric data)를 paasta-monitoring의 InfluxDB에 전송한다.  
Syslog Agent는 BOSH VM의 log 정보를 logsearch의 ls-router에 전송하는 역할을 한다.  
BOSH 설치 전에 paasta-monitoring의 InfluxDB IP를 metric_url로 사용하기 위해 사전에 정의해야 한다.  
마찬가지로 logsearch의 ls-router IP도 syslog_address로 연동하기 위해 사전에 정의해야 한다.





#### <div id='1026'/>3.3.5.3. BOSH 설치 Shell Script

##### <div id='1027'/>● deploy-aws.sh

```
bosh create-env bosh.yml \                         
	--state=aws/state.json \			# BOSH Latest Running State, 설치 시 생성, Backup 필요
	--vars-store=aws/creds.yml \			# BOSH Credentials and Certs, 설치 시 생성, Backup 필요 
	-o use-compiled-releases.yml \			# BOSH 설치시 공통 릴리즈 파일 Local 정보
	-o aws/cpi.yml \				# AWS CPI 적용
	-o use-compiled-releases-aws.yml \		# BOSH 설치시 AWS CPI 릴리즈 파일 Local 정보
	-o uaa.yml \					# UAA 적용      
	-o use-compiled-releases-uaa.yml \		# BOSH 설치시 UAA 릴리즈 파일 Local 정보
	-o credhub.yml \				# CredHub 적용    
	-o use-compiled-releases-credhub.yml \		# BOSH 설치시 CredHub 릴리즈 파일 Local 정보
	-o jumpbox-user.yml \				# Jumpbox 적용  
	-o use-compiled-releases-jumpbox.yml \		# BOSH 설치시 Jumpbox 릴리즈 파일 Local 정보 
 	-l aws-vars.yml					# AWS 환경에 BOSH 설치시 적용하는 변숫값 설정 파일
```
##### <div id='1028'/>● deploy-azure.sh
```
bosh create-env bosh.yml \                         
	--state=azure/state.json \			# BOSH Latest Running State, 설치 시 생성, Backup 필요
	--vars-store azure/creds.yml \			# BOSH Credentials and Certs, 설치 시 생성, Backup 필요   
	-o use-compiled-releases.yml \			# BOSH 설치시 공통 릴리즈 파일 Local 정보
	-o azure/cpi.yml \				# MS Azure CPI 적용
	-o use-compiled-releases-azure.yml \		# BOSH 설치시 MS Azure CPI 릴리즈 파일 Local 정보
	-o uaa.yml  \					# UAA 적용 
	-o use-compiled-releases-uaa.yml \		# BOSH 설치시 UAA 릴리즈 파일 Local 정보
	-o credhub.yml  \				# CredHub 적용
	-o use-compiled-releases-credhub.yml \		# BOSH 설치시 CredHub 릴리즈 파일 Local 정보
	-o jumpbox-user.yml  \				# Jumpbox 적용 
	-o use-compiled-releases-jumpbox.yml \		# BOSH 설치시 Jumpbox 릴리즈 파일 Local 정보
	-l azure-vars.yml				# MS Azure 환경에 BOSH 설치시 적용하는 변숫값 설정 파일
```

##### <div id='1029'/>● deploy-gcp.sh
```
bosh create-env bosh.yml \                         
	--state=gcp/state.json \			# BOSH Latest Running State, 설치 시 생성, Backup 필요 
	--vars-store gcp/creds.yml \			# BOSH Credentials and Certs, 설치 시 생성, Backup 필요
	-o use-compiled-releases.yml \			# BOSH 설치시 공통 릴리즈 파일 Local 정보
	-o gcp/cpi.yml \				# GCP CPI 적용
	-o use-compiled-releases-gcp.yml \		# BOSH 설치시 GCP CPI 릴리즈 파일 Local 정보
	-o uaa.yml  \					# UAA 적용  
	-o use-compiled-releases-uaa.yml \		# BOSH 설치시 UAA 릴리즈 파일 Local 정보
	-o credhub.yml  \				# CredHub 적용  
	-o use-compiled-releases-credhub.yml \		# BOSH 설치시 CredHub 릴리즈 파일 Local 정보
	-o jumpbox-user.yml  \				# Jumpbox 적용
	-o use-compiled-releases-jumpbox.yml \		# BOSH 설치시 Jumpbox 릴리즈 파일 Local 정보 
	--var-file gcp_credentials_json=~/.ssh/gcp.json \	# GCP Service Account Key      
	-l vars-gcp.yml					# GCP 환경에 BOSH 설치시 적용하는 변숫값 설정 파일   

```


##### <div id='1030'/>● deploy-openstack.sh

```
bosh create-env bosh.yml \                       
	--state=openstack/state.json \			# BOSH Latest Running State, 설치 시 생성, Backup 필요
	--vars-store=openstack/creds.yml \		# BOSH Credentials and Certs, 설치 시 생성, Backup 필요
	-o use-compiled-releases.yml \			# BOSH 설치시 공통 릴리즈 파일 Local 정보
	-o openstack/cpi.yml \				# Openstack CPI 적용
	-o use-compiled-releases-openstack.yml \	# BOSH 설치시 OpenStack CPI 릴리즈 파일 Local 정보
	-o uaa.yml \					# UAA 적용
	-o use-compiled-releases-uaa.yml \		# BOSH 설치시 UAA 릴리즈 파일 Local 정보
	-o credhub.yml \				# CredHub 적용
	-o use-compiled-releases-credhub.yml \		# BOSH 설치시 CredHub 릴리즈 파일 Local 정보
	-o jumpbox-user.yml \				# Jumpbox 적용
	-o use-compiled-releases-jumpbox.yml \		# BOSH 설치시 Jumpbox 릴리즈 파일 Local 정보
	-o openstack/disable-readable-vm-names.yml \	# VM 명을 UUIDs로 적용
	-l openstack-vars.yml				# OpenStack 환경에 BOSH 설치시 적용하는 변숫값 설정 파일
```

##### <div id='1031'/>● deploy-vsphere.sh

```
bosh create-env bosh.yml \                         
	--state=vsphere/state.json \			# BOSH Latest Running State, 설치 시 생성, Backup 필요 
	--vars-store=vsphere/creds.yml \		# BOSH Credentials and Certs, 설치 시 생성, Backup 필요 
	-o use-compiled-releases.yml \			# BOSH 설치시 공통 릴리즈 파일 Local 정보    
	-o vsphere/cpi.yml \				# vSphere CPI 적용 
	-o use-compiled-releases-vsphere.yml \		# BOSH 설치시 vSphere CPI 릴리즈 파일 Local 정보
	-o vsphere/resource-pool.yml  \			# vSphere Resource Pool 적용       
	-o uaa.yml  \					# UAA 적용   
	-o use-compiled-releases-uaa.yml \		# BOSH 설치시 UAA 릴리즈 파일 Local 정보
	-o credhub.yml  \				# CredHub 적용 
	-o use-compiled-releases-credhub.yml \		# BOSH 설치시 CredHub 릴리즈 파일 Local 정보
	-o jumpbox-user.yml  \				# Jumpbox 적용  
	-o use-compiled-releases-jumpbox.yml \		# BOSH 설치시 Jumpbox 릴리즈 파일 Local 정보
	-l vars-vsphere.yml				# VMware vSphere 환경에 BOSH 설치시 적용하는 변숫값 설정 파일
```

##### <div id='1032'/>● deploy-{IaaS}-monitoring.sh

```
bosh create-env bosh.yml \                         
	--state=vsphere/state.json \			# BOSH Latest Running State, 설치 시 생성, Backup 필요 
	--vars-store=vsphere/creds.yml \		# BOSH Credentials and Certs, 설치 시 생성, Backup 필요 
	......................................
	......................................
	-o syslog.yml \					# [MONITORING] Monitoring Logging Agent 적용
	-o use-compiled-releases-syslog.yml \		# [MONITORING] Monitoring Logging Agent 적용시 필요한 릴리즈 파일 Local 정보
	-o paasta-addon/paasta-monitoring-agent.yml \	# [MONITORING] Monitoring Metric Agent 적용    
	-o paasta-addon/use-compiled-releases-monitoring-agent.yml \	# [MONITORING] Monitoring Metric Agent 적용시 필요한 릴리즈 파일 Local 정보
	-l vars-{IaaS}.yml				# 각 IaaS 환경에 BOSH 설치시 적용하는 변숫값 설정 파일
```



##### <div id='1033'/>● deploy-bosh-lite.sh
```
bosh create-env bosh.yml \
	--state=bosh-lite/state.json \			# BOSH Latest Running State, 설치 시 생성, Backup 필요   
	--vars-store bosh-lite/creds.yml \		# BOSH Credentials and Certs, 설치 시 생성, Backup 필요   
	-o use-compiled-releases.yml \			# BOSH 설치시 공통 릴리즈 파일 Local 정보
	-o virtualbox/cpi.yml \				# Virtualbox CPI 적용 
	-o virtualbox/outbound-network.yml \		# Virtualbox Outbound Network 적용
	-o bosh-lite.yml \				# BOSH-LITE 적용    
	-o use-compiled-releases-bosh-lite.yml \	# BOSH 설치시 BOSH-LITE 릴리즈 파일 Local 정보
	-o uaa.yml \					# UAA 적용
	-o use-compiled-releases-uaa.yml \		# BOSH 설치시 UAA 릴리즈 파일 Local 정보
	-o credhub.yml \				# CredHub 적용
	-o use-compiled-releases-credhub.yml \		# BOSH 설치시 CredHub 릴리즈 파일 Local 정보
	-o jumpbox-user.yml \				# Jumpbox 적용
	-o use-compiled-releases-jumpbox.yml \		# BOSH 설치시 Jumpbox 릴리즈 파일 Local 정보
	-l vars-bosh-lite.yml				# BOSH-LITE 환경에 BOSH 설치시 적용하는 변숫값 설정 파일
```


- Shell Script 파일에 실행 권한 부여

```
$ chmod +x ${HOME}/workspace/paasta-5.0/deployment/paasta-deployment/bosh/*.sh  
```


### <div id='1034'/>3.3.6. BOSH 설치

- 서버 환경에 맞추어 Deploy 스크립트 파일의 설정을 수정한다. 

> $ vi ~/workspace/paasta-5.0/deployment/paasta-deployment/bosh/deploy-aws.sh
```                     
bosh create-env bosh.yml \                         
	--state=aws/state.json \	
	--vars-store=aws/creds.yml \ 
	-o aws/cpi.yml \
	-o uaa.yml \
	-o credhub.yml \
	-o jumpbox-user.yml \
 	-l aws-vars.yml
```

- BOSH 설치 Shell Script 파일 실행

```
$ cd ${HOME}/workspace/paasta-5.0/deployment/paasta-deployment/bosh
$ ./deploy-{iaas}.sh
```

- BOSH 설치 중

```
ubuntu@inception:~/workspace/paasta-5.0/deployment/paasta-deployment/bosh$ ./deploy-aws.sh
Deployment manifest: '/home/ubuntu/workspace/paasta-5.0/deployment/paasta-deployment/bosh/bosh.yml'
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

### <div id='1035'/>3.3.7. BOSH 설치 - 다운로드 된 Release 파일 이용 방식

- 서비스 설치에 필요한 릴리즈 파일을 다운로드 받아 Local machine의 작업 경로로 위치시킨다.  
  
  - 설치 파일 다운로드 위치 : https://paas-ta.kr/download/package    

```
# 릴리즈 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta-5.0/release/bosh

# 릴리즈 파일 다운로드 및 파일 경로 확인
$ ls ~/workspace/paasta-5.0/release/bosh
```


- 서버 환경에 맞추어 Deploy 스크립트 파일의 설정을 수정한다. 

> $ vi ~/workspace/paasta-5.0/deployment/paasta-deployment/bosh/deploy-aws.sh
```                     
bosh create-env bosh.yml \                         
	--state=aws/state.json \
	--vars-store=aws/creds.yml \
	-o use-compiled-releases.yml \
	-o aws/cpi.yml \
	-o use-compiled-releases-aws.yml \
	-o uaa.yml \
	-o use-compiled-releases-uaa.yml \
	-o credhub.yml \
	-o use-compiled-releases-credhub.yml \
	-o jumpbox-user.yml \
	-o use-compiled-releases-jumpbox.yml \
 	-l aws-vars.yml	
```

- BOSH 설치 Shell Script 파일 실행

```
$ cd ${HOME}/workspace/paasta-5.0/deployment/paasta-deployment/bosh
$ ./deploy-{iaas}.sh
```

- BOSH 설치 중

```
ubuntu@inception:~/workspace/paasta-5.0/deployment/paasta-deployment/bosh$ ./deploy-aws.sh
Deployment manifest: '/home/ubuntu/workspace/paasta-5.0/deployment/paasta-deployment/bosh/bosh.yml'
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


### <div id='1036'/>3.3.8. BOSH 로그인
BOSH가 설치되면, BOSH 설치 디렉터리 이하 {iaas}/creds.yml 파일이 생성된다.  
creds.yml은 BOSH 인증정보를 가지고 있으며, creds.yml을 활용하여 BOSH에 로그인한다.  
BOSH 로그인 후, BOSH CLI 명령어를 이용하여 PaaS-TA를 설치할 수 있다.

```
$ cd ${HOME}/workspace/paasta-5.0/deployment/paasta-deployment/bosh
$ export BOSH_CA_CERT=$(bosh int ./{iaas}/creds.yml --path /director_ssl/ca)
$ export BOSH_CLIENT=admin
$ export BOSH_CLIENT_SECRET=$(bosh int ./{iaas}/creds.yml --path /admin_password)
$ bosh alias-env {director_name} -e {bosh_url} --ca-cert <(bosh int ./{iaas}/creds.yml --path /director_ssl/ca)
$ bosh –e {director_name} env
```

### <div id='1037'/>3.3.9. CredHub
CredHub은 인증정보 저장소이다.  
BOSH 설치 시 Operation 파일로 credhub.yml을 추가하였다.  
BOSH 설치 시 credhub.yml을 적용하면, PaaS-TA 설치 시 PaaS-TA에서 사용하는 인증정보(Certificate, Password)를 CredHub에 저장한다.  
PaaS-TA 인증정보가 필요할 때 CredHub을 사용하며, CredHub CLI를 통해 CredHub에 로그인하여 인증정보 조회, 수정, 삭제를 할 수 있다.

#### <div id='1038'/>3.3.9.1. CredHub CLI 설치

CredHub CLI는 BOSH를 설치한 Inception(설치환경)에 설치한다.

```
$ wget https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/2.5.3/credhub-linux-2.5.3.tgz
$ tar -xvf credhub-linux-2.5.3.tgz 
$ chmod +x credhub
$ sudo mv credhub /usr/local/bin/credhub 
$ credhub –version
```

#### <div id='1039'/>3.3.9.2. CredHub 로그인
CredHub에 로그인하기 위해 BOSH를 설치한 bosh-deployment 디렉터리의 creds.yml을 활용하여 로그인한다.

```
$ cd ${HOME}/workspace/paasta-5.0/deployment/paasta-deployment/bosh
$ export CREDHUB_CLIENT=credhub-admin
$ export CREDHUB_SECRET=$(bosh int --path /credhub_admin_client_secret {iaas}/creds.yml)
$ export CREDHUB_CA_CERT=$(bosh int --path /credhub_tls/ca {iaas}/creds.yml)
$ credhub login -s https://{bosh_url}:8844 --skip-tls-validation
$ credhub find
```

CredHub 로그인 후 find 명령어로 조회하면 비어 있는 것을 알 수 있다.  
PaaS-TA를 설치하면 인증 정보가 저장되어 조회할 수 있다.

- uaa 인증정보 조회

```
$ credhub get -n /{director}/{deployment}/uaa_ca
```

### <div id='1040'/>3.3.10. Jumpbox
BOSH 설치 시 Operation 파일로 jumpbox-user.yml을 추가하였다.  
Jumpbox는 BOSH VM에 접근하기 위한 인증을 적용하게 된다.  
인증키는 BOSH에서 자체적으로 생성하며, 인증키를 통해 BOSH VM에 접근할 수 있다.  
BOSH VM에 이상이 있거나 상태를 체크할 때 Jumpbox를 활용하여 BOSH VM에 접근할 수 있다.

```
$ cd ${HOME}/workspace/paasta-5.0/deployment/paasta-deployment/bosh
$ bosh int {iaas}/creds.yml --path /jumpbox_ssh/private_key > jumpbox.key 
$ chmod 600 jumpbox.key
$ ssh jumpbox@{bosh_url} -i jumpbox.key
```

```
ubuntu@inception:~/workspace/paasta-5.0/deployment/paasta-deployment/bosh$ ssh jumpbox@10.0.1.6 -i jumpbox.key
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
