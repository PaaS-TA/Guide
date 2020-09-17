## Table of Contents  

1. [문서 개요](#1)   
  1.1. [목적](#1.1)   
  1.2. [범위](#1.2)   
  1.3. [시스템 구성도](#1.3)   
  1.4. [참고자료](#1.4)   
  
2. [Mongodb 서비스 설치](#2)  
  2.1. [Prerequisite](#2.1)   
  2.2. [Stemcell 확인](#2.2)    
  2.3. [Deployment 다운로드](#2.3)   
  2.4. [Deployment 파일 수정](#2.4)  
  2.5. [서비스 설치](#2.5)    
  2.6. [서비스 설치 - 다운로드 된 PaaS-TA Release 파일 이용 방식](#2.6)   
  2.7. [서비스 설치 확인](#2.7)  
  
3. [Mongodb 연동 Sample Web App 설명](#3)  
  3.1. [Mongodb 서비스 브로커 등록](#3.1)  
  3.2. [Sample App 구조](#3.2)  
  3.3. [PaaS-TA에서 서비스 신청](#3.3)  
  3.4. [Sample App에 서비스 바인드 신청 및 App 확인](#3.4)   

4. [Mongodb Client 툴 접속](#4)  
  4.1. [MongoChef 설치 및 연결](#4.1)  


## <div id='1'> 1. 문서 개요
### <div id='1.1'> 1.1. 목적

본 문서(Mongodb 서비스팩 설치 가이드)는 전자정부표준프레임워크 기반의 PaaS-TA에서 제공되는 서비스팩인 Mongodb 서비스팩을 Bosh를 이용하여 설치 하는 방법과 PaaS-TA의 SaaS 형태로 제공하는 Application 에서 Mongodb 서비스를 사용하는 방법을 기술하였다.
PaaS-TA 3.5 버전부터는 Bosh2.0 기반으로 deploy를 진행하며 기존 Bosh1.0 기반으로 설치를 원할경우에는 PaaS-TA 3.1 이하 버전의 문서를 참고한다.

### <div id='1.2'> 1.2. 범위
설치 범위는 Mongodb 서비스팩을 검증하기 위한 기본 설치를 기준으로 작성하였다.

### <div id='1.3'> 1.3. 시스템 구성도
본 문서의 설치된 시스템 구성도이다. Mongodb Server, Mongodb 서비스 브로커로 최소사항을 구성하였다.

![시스템구성도][mongodb_image_02]

<table>
  <tr>
    <td>구분</td>
    <td>스펙</td>
  </tr>
  <tr>
    <td>PaaS-TA-mongodb-broker</td>
    <td>1vCPU / 1GB RAM / 8GB Disk</td>
  </tr>
  <tr>
    <td>Mongos</td>
    <td>1vCPU / 1GB RAM / 8GB Disk</td>
  </tr>
  <tr>
    <td>Mongo Config</td>
    <td>1vCPU / 1GB RAM / 8GB Disk+4GB(영구적 Disk)</td>
  </tr>
  <tr>
    <td>Mongod</td>
    <td>1vCPU / 1GB RAM /8GB Disk+4GB(영구적 Disk)</td>
  </tr>
</table>


### <div id='1.4'> 1.4. 참고자료
[**http://bosh.io/docs**](http://bosh.io/docs)<br>
[**http://docs.cloudfoundry.org/**](http://docs.cloudfoundry.org/)


## <div id='2'> 2.  Mongodb 서비스 설치

### <div id="2.1"/> 2.1. Prerequisite  

본 설치 가이드는 Linux 환경에서 설치하는 것을 기준으로 하였다. 서비스 설치를 위해서는 BOSH 2.0과 PaaS-TA 5.0, PaaS-TA 포털이 설치되어 있어야 한다. 

### <div id="2.2"/> 2.2. Stemcell 확인

Stemcell 목록을 확인하여 서비스 설치에 필요한 Stemcell이 업로드 되어 있는 것을 확인한다.  (PaaS-TA 5.0 과 동일 stemcell 사용)

> $ bosh -e micro-bosh stemcells

```
Using environment '10.0.1.6' as client 'admin'

Name                                     Version  OS             CPI  CID  
bosh-aws-xen-hvm-ubuntu-xenial-go_agent  315.64*  ubuntu-xenial  -    ami-0297ff649e8eea21b  

(*) Currently deployed

1 stemcells

Succeeded
```

### <div id="2.3"/> 2.3. Deployment 다운로드  

서비스 설치에 필요한 Deployment를 Git Repository에서 받아 서비스 설치 작업 경로로 위치시킨다.  

- Service Deployment Git Repository URL : https://github.com/PaaS-TA/service-deployment/tree/v5.0.2

```
# Deployment 다운로드 파일 위치 경로 생성 및 설치 경로 이동
$ mkdir -p ~/workspace/paasta-5.0/deployment
$ cd ~/workspace/paasta-5.0/deployment

# Deployment 파일 다운로드
$ git clone https://github.com/PaaS-TA/service-deployment.git -b v5.0.2
```

### <div id="2.4"/> 2.4. Deployment 파일 수정

BOSH Deployment manifest는 Components 요소 및 배포의 속성을 정의한 YAML 파일이다.
Deployment 파일에서 사용하는 network, vm_type, disk_type 등은 Cloud config를 활용하고, 활용 방법은 BOSH 2.0 가이드를 참고한다.   

- Cloud config 설정 내용을 확인한다.   

> $ bosh -e micro-bosh cloud-config   

```
Using environment '10.0.1.6' as client 'admin'

azs:
- cloud_properties:
    availability_zone: ap-northeast-2a
  name: z1
- cloud_properties:
    availability_zone: ap-northeast-2a
  name: z2

... ((생략)) ...

disk_types:
- disk_size: 1024
  name: default
- disk_size: 1024
  name: 1GB

... ((생략)) ...

networks:
- name: default
  subnets:
  - az: z1
    cloud_properties:
      security_groups: paasta-security-group
      subnet: subnet-00000000000000000
    dns:
    - 8.8.8.8
    gateway: 10.0.1.1
    range: 10.0.1.0/24
    reserved:
    - 10.0.1.2 - 10.0.1.9
    static:
    - 10.0.1.10 - 10.0.1.120

... ((생략)) ...

vm_types:
- cloud_properties:
    ephemeral_disk:
      size: 3000
      type: gp2
    instance_type: t2.small
  name: minimal
- cloud_properties:
    ephemeral_disk:
      size: 10000
      type: gp2
    instance_type: t2.small
  name: small

... ((생략)) ...

Succeeded
```

Deployment YAML에서 사용하는 변수 파일을 서버 환경에 맞게 수정한다.

> $ vi ~/workspace/paasta-5.0/deployment/service-deployment/mongodb/vars.yml
```
# STEMCELL
stemcell_os: "ubuntu-xenial"                                     # stemcell os
stemcell_version: "315.64"                                       # stemcell version

# NETWORK
private_networks_name: "default"                                 # private network name

# MONGODB_REPL_SET_NAME
replSetName1: "op1"                                              # replica set1 name
replSetName2: "op2"                                              # replica set2 name
replSetName3: "op3"                                              # replica set3 name

# MONGODB_SLAVE1
mongodb_slave1_azs: [z3]                                         # mongodb slave1 azs
mongodb_slave1_instances: 2                                      # mongodb slave1 instances
mongodb_slave1_vm_type: "medium"                                 # mongodb slave1 vm type
mongodb_slave1_persistent_disk_type: "10GB"                      # mongodb slave1 persistent disk type
mongodb_slave1_static_ips: "<MONGODB_SLAVE1_PRIVATE_IPS>"        # mongodb slave1's private IPs (e.g. ["10.0.81.11","10.0.81.12"])

# MONGODB_SLAVE2
mongodb_slave2_azs: [z3]                                         # mongodb slave2 azs
mongodb_slave2_instances: 2                                      # mongodb slave2 instances
mongodb_slave2_vm_type: "medium"                                 # mongodb slave2 vm type
mongodb_slave2_persistent_disk_type: "10GB"                      # mongodb slave2 persistent disk type
mongodb_slave2_static_ips: "<MONGODB_SLAVE2_PRIVATE_IPS>"        # mongodb slave2's private IPs (e.g. ["10.0.81.14","10.0.81.15"])

# MONGODB_SLAVE3
mongodb_slave3_azs: [z3]                                         # mongodb slave3 azs
mongodb_slave3_instances: 2                                      # mongodb slave3 instances
mongodb_slave3_vm_type: "medium"                                 # mongodb slave3 vm type
mongodb_slave3_persistent_disk_type: "10GB"                      # mongodb slave3 persistent disk type
mongodb_slave3_static_ips: "<MONGODB_SLAVE3_PRIVATE_IPS>"        # mongodb slave3's private IPs (e.g. ["10.0.81.17","10.0.81.18"])

# MONGODB_MASTER1
mongodb_master1_azs: [z3]                                                # mongodb master1 azs
mongodb_master1_instances: 1                                             # mongodb master1 instances
mongodb_master1_vm_type: "medium"                                        # mongodb master1 vm type
mongodb_master1_persistent_disk_type: "10GB"                             # mongodb master1 persistent disk type
mongodb_master1_static_ips: "<MONGODB_MASTER1_PRIVATE_IP>"               # mongodb master1's private IP (e.g. "10.0.81.10")
mongodb_master1_replSet_hosts: "<MONGODB_MASTER1_REPLSET_HOSTS>"         # 첫번째 Host는 replicaSet1 의master1 ip, 차례대로 slave1 의 ips. (e.g. ["10.0.81.10", "10.0.81.11","10.0.81.12"])

# MONGODB_MASTER2
mongodb_master2_azs: [z3]                                                # mongodb master2 azs
mongodb_master2_instances: 1                                             # mongodb master2 instances
mongodb_master2_vm_type: "medium"                                        # mongodb master2 vm type
mongodb_master2_persistent_disk_type: "10GB"                             # mongodb master2 persistent disk type
mongodb_master2_static_ips: "<MONGODB_MASTER2_PRIVATE_IP>"               # mongodb master2's private IP (e.g. "10.0.81.13")
mongodb_master2_replSet_hosts: "<MONGODB_MASTER2_REPLSET_HOSTS>"         # 첫번째 Host는 replicaSet2 의master2 ip, 차례대로 slave2 의 ips. (e.g. ["10.0.81.13", "10.0.81.14","10.0.81.15"])

# MONGODB_MASTER3
mongodb_master3_azs: [z3]                                                # mongodb master3 azs
mongodb_master3_instances: 1                                             # mongodb master3 instances
mongodb_master3_vm_type: "medium"                                        # mongodb master3 vm type
mongodb_master3_persistent_disk_type: "10GB"                             # mongodb master3 persistent disk type
mongodb_master3_static_ips: "<MONGODB_MASTER3_PRIVATE_IP>"               # mongodb master3's private IP (e.g. "10.0.81.16")
mongodb_master3_replSet_hosts: "<MONGODB_MASTER3_REPLSET_HOSTS>"         # 첫번째 Host는 replicaSet3 의master3 ip, 차례대로 slave3 의 ips. (e.g. ["10.0.81.16", "10.0.81.17","10.0.81.18"])

# MONGODB_CONFIG
mongodb_config_azs: [z3]                                                 # mongodb config azs
mongodb_config_instances: 3                                              # mongodb config instances
mongodb_config_vm_type: "medium"                                         # mongodb config vm type
mongodb_config_persistent_disk_type: "10GB"                              # mongodb config persistent disk type
mongodb_config_static_ips: "<MONGODB_CONFIG_PRIVATE_IPS>"                # mongodb config's private IPs (e.g. ["10.0.81.19", "10.0.81.20","10.0.81.21"])

# MONGODB_SHARD
mongodb_shard_azs: [z3]                                                  # mongodb shard azs
mongodb_shard_instances: 1                                               # mongodb shard instances
mongodb_shard_vm_type: "medium"                                          # mongodb shard vm type
mongodb_shard_static_ips: "<MONGODB_SHARD_PRIVATE_IP>"                   # mongodb shard's private IP (e.g. "10.0.81.22")

# MONGODB_BROKER
mongodb_broker_azs: [z3]                                                 # mongodb broker azs
mongodb_broker_instances: 1                                              # mongodb broker instances
mongodb_broker_vm_type: "medium"                                         # mongodb broker vm type
mongodb_broker_static_ips: "<MONGODB_BROKER_PRIVATE_IP>"                 # mongodb broker's private IP (e.g. "10.0.81.23")

# BROKER_REGISTRAR
broker_registrar_broker_azs: [z3]                                        # broker registrar azs
broker_registrar_broker_instances: 1                                     # broker registrar instances
broker_registrar_broker_vm_type: "medium"                                # broker registrar vm type

# BROKER_DEREGISTRAR
broker_deregistrar_broker_azs: [z3]                                      # broker deregistrar azs
broker_deregistrar_broker_instances: 1                                   # broker deregistrar instances
broker_deregistrar_broker_vm_type: "medium"                              # broker deregistrar vm type
```

'pem.yml' 은 MongoDB자체 pem을 등록해 쓰기 때문에 내용 수정하지 않는다.

### <div id="2.5"/> 2.5. 서비스 설치

- 서버 환경에 맞추어 Deploy 스크립트 파일의 VARIABLES 설정을 수정한다. 

> $ vi ~/workspace/paasta-5.0/deployment/service-deployment/mongodb/deploy.sh

```
#!/bin/bash
  
# VARIABLES
BOSH_NAME="<BOSH_NAME>"                          # bosh name (e.g. micro-bosh)
IAAS="<IAAS_NAME>"                               # IaaS (e.g. aws/azure/gcp/openstack/vsphere)
COMMON_VARS_PATH="<COMMON_VARS_FILE_PATH>"       # common_vars.yml File Path (e.g. /home/ubuntu/paasta-5.0/common/common_vars.yml)

# DEPLOY
bosh -e ${BOSH_NAME} -n -d mongodb deploy --no-redact mongodb.yml \
    -l ${COMMON_VARS_PATH} \
    -l vars.yml \
    -l operations/pem.yml
```

- 서비스를 설치한다.  
```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/mongodb  
$ sh ./deploy.sh  
```  
### <div id="2.6"/> 2.6. 서비스 설치 - 다운로드 된 PaaS-TA Release 파일 이용 방식

- 서비스 설치에 필요한 릴리즈 파일을 다운로드 받아 Local machine의 서비스 설치 작업 경로로 위치시킨다.  
  
  - 설치 릴리즈 파일 다운로드 : [paasta-mongodb-shard-2.0.1.tgz](http://45.248.73.44/index.php/s/7DyiWNWD2N8pT8J/download)

```
# 릴리즈 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta-5.0/release/service

# 릴리즈 파일 다운로드 및 파일 경로 확인
$ ls ~/workspace/paasta-5.0/release/service
paasta-mongodb-shard-2.0.1.tgz
```
  
- 서버 환경에 맞추어 Deploy 스크립트 파일의 VARIABLES 설정을 수정하고 Option file 및 변수를 추가한다.  
     (추가) -o operations/use-compiled-releases.yml  
     (추가) -v inception_os_user_name="<HOME_USER_NAME>"  
     
> $ vi ~/workspace/paasta-5.0/deployment/service-deployment/mongodb/deploy.sh
  
```
#!/bin/bash
  
# VARIABLES
BOSH_NAME="<BOSH_NAME>"                          # bosh name (e.g. micro-bosh)
IAAS="<IAAS_NAME>"                               # IaaS (e.g. aws/azure/gcp/openstack/vsphere)
COMMON_VARS_PATH="<COMMON_VARS_FILE_PATH>"       # common_vars.yml File Path (e.g. /home/ubuntu/paasta-5.0/common/common_vars.yml)

# DEPLOY
bosh -e ${BOSH_NAME} -n -d mongodb deploy --no-redact mongodb.yml \
    -o operations/use-compiled-releases.yml \
    -l ${COMMON_VARS_PATH} \
    -l vars.yml \
    -l operations/pem.yml \
    -v inception_os_user_name="ubuntu"
```  

- 서비스를 설치한다.  
```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/mongodb  
$ sh ./deploy.sh  
```  

### <div id="2.7"/> 2.7. 서비스 설치 확인

설치 완료된 서비스를 확인한다.  

> $ bosh -e micro-bosh -d mongodb vms  

```
Using environment '10.0.1.6' as client 'admin'

Task 8176. Done

Deployment 'mongodb'

Instance                                              Process State  AZ  IPs            VM CID                                   VM Type  Active  
mongodb_broker/0e8933f1-1b67-4486-b37a-2b104da1351a   running        z5  10.30.107.114  vm-e0bb79c6-6482-497a-b071-f7df4bf2a059  minimal  true  
mongodb_config/35ee66e6-9c25-44c2-85a4-e7c1d520641b   running        z5  10.30.107.111  vm-672ce5b9-4d8f-4b22-9745-43f7d9e39402  minimal  true  
mongodb_config/935aed3c-e7a4-4179-b397-68d0535bc1d9   running        z5  10.30.107.112  vm-8069a84b-5a91-44ca-a5d8-cca37b5d8952  minimal  true  
mongodb_config/cc798fba-7840-46ea-9211-6b5646fc766f   running        z5  10.30.107.110  vm-5a7a9d16-8de4-4adf-b504-1364716decce  minimal  true  
mongodb_master1/1e8b971e-c503-4ba6-bcba-ab28dd7dd797  running        z5  10.30.107.101  vm-54b33ec2-582d-44ef-a4bf-6281acfbf81b  minimal  true  
mongodb_master2/7a4460e4-a9b5-4d15-9508-adba3405f387  running        z5  10.30.107.104  vm-a388a44e-4ab9-4340-9227-b12b7bd2c410  minimal  true  
mongodb_master3/88e1aa1c-fb1f-467d-a550-b6334fdfce8d  running        z5  10.30.107.107  vm-9c6aed35-69aa-4a7d-9b08-c5671e728e2a  minimal  true  
mongodb_shard/1fd85812-c8d4-4ebd-98f5-c8cf637db9e5    running        z5  10.30.107.113  vm-c2628ba8-feed-4401-b1c9-be1445722d34  minimal  true  
mongodb_slave1/2710c368-dbc2-4d72-a100-1fa37d73e2ec   running        z5  10.30.107.102  vm-048757cf-1c19-4c30-a3cd-2b0dd05c1554  minimal  true  
mongodb_slave1/bb6275f1-4ab5-4998-ba89-ef30c36c3f67   running        z5  10.30.107.103  vm-6d0f52ef-a0b3-4c26-8e04-cb5cef30337d  minimal  true  
mongodb_slave2/9671e09b-7ca1-4da2-af8a-88d20caeebfe   running        z5  10.30.107.106  vm-8a57713b-68df-4639-8ab3-3d12c01fd880  minimal  true  
mongodb_slave2/fed23144-9c18-42f6-9f99-213f7dc294ee   running        z5  10.30.107.105  vm-c58e860a-8b5e-43e1-abe9-c3043cbfb16d  minimal  true  
mongodb_slave3/7cebf99b-5a79-4033-a4e8-86f8d476a709   running        z5  10.30.107.108  vm-d34d8a3f-37fb-41a8-b995-6e8c7e8ff041  minimal  true  
mongodb_slave3/ab6d22fb-d436-4c1c-a423-9e9d82c4266a   running        z5  10.30.107.109  vm-ca14b629-4d00-4c96-8782-1cf7a174ce1e  minimal  true  

14 vms

Succeeded
```

## <div id='3'> 3. Mongodb 연동 Sample Web App 설명

본 Sample Web App은 PaaS-TA에 배포되며 Mongodb의 서비스를 Provision과 Bind를 한 상태에서 사용이 가능하다.

### <div id='3.1'> 3.1. Mongodb 서비스 브로커 등록

Mongodb 서비스팩 배포가 완료 되었으면 Application에서 서비스 팩을 사용하기 위해서 먼저 Mongodb 서비스 브로커를 등록해 주어야 한다.

서비스 브로커 등록시 개방형 클라우드 플랫폼에서 서비스브로커를 등록할 수 있는 사용자로 로그인이 되어있어야 한다.

##### 서비스 브로커 목록을 확인한다.

>`$ cf service-brokers`  

>![mongodb_image_06]

<br>

##### Mongodb 서비스 브로커를 등록한다.  

>`$ cf create-service-broker {서비스팩 이름} {서비스팩 사용자ID} {서비스팩 사용자비밀번호} http://{서비스팩 URL(IP)}`  
  
  **서비스팩 이름** : 서비스 팩 관리를 위해 PaaS-TA에서 보여지는 명칭이다. 서비스 Marketplace에서는 각각의 API 서비스 명이 보여지니 여기서 명칭은 서비스팩 리스트의 명칭이다.<br>
  **서비스팩 사용자ID** / 비밀번호 : 서비스팩에 접근할 수 있는 사용자 ID입니다. 서비스팩도 하나의 API 서버이기 때문에 아무나 접근을 허용할 수 없어 접근이 가능한 ID/비밀번호를 입력한다.<br>
  **서비스팩 URL** : 서비스팩이 제공하는 API를 사용할 수 있는 URL을 입력한다.

>`$ cf create-service-broker mongodb-shard-service-broker admin cloudfoundry http://10.30.107.114:8080`  

> ![mongodb_image_07]


##### 등록된 mongodb 서비스 브로커를 확인한다.

>`$ cf service-brokers`

> ![mongodb_image_08]


##### 접근 가능한 서비스 목록을 확인한다.

>`$ cf service-access`  

> ![mongodb_image_09]

>서비스 브로커 생성시 디폴트로 접근을 허용하지 않는다.


##### 특정 조직에 해당 서비스 접근 허용을 할당하고 접근 서비스 목록을 다시 확인한다. (전체 조직)

>`$ cf enable-service-access Mongo-DB` <br>
>`$ cf service-access`

> ![mongodb_image_10]

### <div id='3.2'> 3.2. Sample App 구조

Sample Web App은 PaaS-TA에 App으로 배포가 된다. App을 배포하여 구동시 Bind 된 Mongodb 서비스 연결정보로 접속하여 초기 데이터를 생성하게 된다. 배포 완료 후 정상적으로 App 이 구동되면 브라우저나 curl로 해당 App에 접속 하여 Mongodb 환경정보(서비스 연결 정보)와 초기 적재된 데이터를 보여준다.

Sample Web App 구조는 다음과 같다.

<table>
  <tr>
    <td>이름</td>
    <td>설명</td>
  </tr>
  <tr>
    <td>src</td>
    <td>Sample 소스디렉토리</td>
  </tr>
  <tr>
    <td>manifest</td>
    <td>PaaS-TA에 app 배포시 필요한 설정을 저장하는 파일</td>
  </tr>
  <tr>
    <td>build.gradle</td>
    <td>gradle project 설정 파일</td>
  </tr>
  <tr>
    <td>build</td>
    <td>gradle 빌드시 생성되는 디렉토리(war 파일, classes 폴더 등)</td>
  </tr>
</table>


##### PaaS-TA-Sample-Apps.zip 파일 압축을 풀고 Service 폴더안에 있는 Mongodb Sample Web App인 hello-spring-mongodb를 복사한다.

>`$ ls -all`

> ![mongodb_image_11]

<br>

### <div id='3.3'> 3.3. PaaS-TA에서 서비스 신청

Sample Web App에서 Mongodb 서비스를 사용하기 위해서는 서비스 신청(Provision)을 해야 한다.
*참고: 서비스 신청시 개방형 클라우드 플랫폼에서 서비스를 신청 할 수 있는 사용자로 로그인이 되어 있어야 한다.


##### 먼저 PaaS-TA Marketplace에서 서비스가 있는지 확인을 한다.

>`$ cf marketplace`

> ![mongodb_image_12]

<br>

##### Marketplace에서 원하는 서비스가 있으면 서비스 신청(Provision)을 한다.

>`$ cf create-service-broker {서비스팩 이름} {서비스팩 사용자ID} {서비스팩 사용자비밀번호} http://{서비스팩 URL(IP)}`
  
  **서비스팩 이름** : 서비스 팩 관리를 위해 PaaS-TA에서 보여지는 명칭이다. 서비스 Marketplace에서는 각각의 API 서비스 명이 보여지니 여기서 명칭은 서비스팩 리스트의 명칭이다.<br>
  **서비스팩 사용자ID** / 비밀번호 : 서비스팩에 접근할 수 있는 사용자 ID입니다. 서비스팩도 하나의 API 서버이기 때문에 아무나 접근을 허용할 수 없어 접근이 가능한 ID/비밀번호를 입력한다.<br>
  **서비스팩 URL** : 서비스팩이 제공하는 API를 사용할 수 있는 URL을 입력한다.
  
>`$ cf create-service Mongo-DB default-plan mongodb-service-instance`

>![mongodb_image_13]

<br>

##### 생성된 Mongodb 서비스 인스턴스를 확인한다.

>`$ cf services`

>![mongodb_image_14]

<br>

### <div id='3.4'> 3.4. Sample App에 서비스 바인드 신청 및 App 확인  

서비스 신청이 완료되었으면 Sample Web App 에서는 생성된 서비스 인스턴스를 Bind 하여 App에서 Mongodb 서비스를 이용한다.
*참고: 서비스 Bind 신청시 개방형 클라우드 플랫폼에서 서비스 Bind신청 할 수 있는 사용자로 로그인이 되어 있어야 한다.


##### Sample Web App 디렉토리로 이동하여 manifest 파일을 확인한다.
다운로드 :: http://45.248.73.44/index.php/s/x8Tg37WDFiL5ZDi/download
```
$ wget -O sample.zip http://45.248.73.44/index.php/s/x8Tg37WDFiL5ZDi/download
$ unzip sample.zip -d sample
$ cd sample/Service/hello-spring-mongodb

```

>`$ vi manifest.yml` <br>

```
---
applications:
- name: hello-spring-mysql       #배포할 App 이름
  memory: 1G                # 배포시 메모리 사이즈
  instances: 1                    # 배포 인스턴스 수
path: target/hello-spring-mysql-1.0.0-BUILD-SNAPSHOT.war      #배포하는 App 파일 PATH
```

참고: target/hello-spring-mysql-1.0.0-BUILD-SNAPSHOT.war파일이 존재 하지 않을 경우 mvn 빌드를 수행 하면 파일이 생성된다.
<br>

##### --no-start 옵션으로 App을 배포한다.
- -no-start: App 배포시 구동은 하지 않는다.

>`$ cf push --no-start`

>![mongodb_image_15]

<br>

##### 배포된 Sample App을 확인하고 로그를 수행한다.

>`$ cf apps`

>![mongodb_image_16]

<br>

>`$ cf logs hello-spring-mongodb`  **// cf logs {배포된 App명}**

![mongodb_image_17]

<br>

##### Sample Web App에서 생성한 서비스 인스턴스 바인드 신청을 한다.

>`$  cf bind-service hello-spring-Mongodb mongodb-service-instance` 

> ![mongodb_image_42]

<br>

##### 바인드가 적용되기 위해서 App을 재기동한다.

>`$  cf restart hello-spring-mongodb` 

> ![mongodb_image_18]

(참고) 바인드 후 App구동시 Mongodb 서비스 접속 에러로 App 구동이 안될 경우 보안 그룹을 추가한다.

##### rule.json 파일을 만들고 아래와 같이 내용을 넣는다.

>`$ vi rule.json` 

```
[
  {
    "protocol": "tcp",
    "destination": "10.20.0.153",
    "ports": "27017"
  }
]
```

##### 보안 그룹을 생성한다.

>`$  cf create-security-group Mongo-DB rule.json` 

> ![mongodb_image_19]

<br>


##### 모든 App에 Mongodb 서비스를 사용할 수 있도록 생성한 보안 그룹을 적용한다.


>`$ cf bind-running-security-group Mongo-DB` 

> ![mongodb_image_20]

<br>

-	App을 리부팅 한다.
```
$ cf restart hello-spring-Mongodb
```
![mongodb_image_21]


##### App이 정상적으로 Mongodb 서비스를 사용하는지 확인한다.

> curl 로 확인

>`$  curl hello-spring-Mongodb.115.68.46.30.xip.io` 

> ![mongodb_image_22]


##### 브라우에서 확인
> ![mongodb_image_23]


## <div id='4'> 4.  Mongodb Client 툴 접속

Application에 바인딩된 Mongodb 서비스 연결정보는 Private IP로 구성되어 있기 때문에 Mongodb Client 툴에서 직접 연결할수 없다. 따라서 SSH 터널, Proxy 터널 등을 제공하는 Mongodb Client 툴을 사용해서 연결하여야 한다. 본 가이드는 SSH 터널을 이용하여 연결 하는 방법을 제공하며 Mongodb Client 툴로써는 MongoChef 로 가이드한다. MongoChef 에서 접속하기 위해서 먼저 SSH 터널링 할수 있는 VM 인스턴스를 생성해야한다. 이 인스턴스는 SSH로 접속이 가능해야 하고 접속 후 PaaS-TA에 설치한 서비스팩에 Private IP 와 해당 포트로 접근이 가능하도록 시큐리티 그룹을 구성해야 한다. 이 부분은 OpenStack관리자 및 PaaS-TA 운영자에게 문의하여 구성한다.


### <div id='4.1'> 4.1.  MongoChef 설치 & 연결
MongoChef 프로그램은 무료로 사용할 수 있는 소프트웨어이다.


##### MongoChef을 다운로드 하기 위해 아래 URL로 이동하여 설치파일을 다운로드 한다.
[**http://3t.io/mongochef/download/platform/**](http://3t.io/mongochef/download/platform/)
> ![mongodb_image_24]


##### 다운로드한 설치파일을 실행한다.
> ![mongodb_image_25]

<br>

##### MongoChef 설치를 위한 안내사항이다. Next 버튼을 클릭한다.
> ![mongodb_image_26]

<br>

##### 프로그램 라이선스에 관련된 내용이다. 동의(I accept the terms in the License Agreement)에 체크 후 Next 버튼을 클릭한다.
> ![mongodb_image_27]

<br>

##### MongoChef 을 설치할 경로를 설정 후 Next 버튼을 클릭한다. 별도의 경로 설정이 필요 없을 경우 default로 C드라이브 Program Files 폴더에 설치가 된다.
> ![mongodb_image_28]

<br>

##### Install 버튼을 클릭하여 설치를 진행한다.
> ![mongodb_image_29]

<br>

##### Finish 버튼 클릭으로 설치를 완료한다.
> ![mongodb_image_30]

<br>

##### MongoChef를 실행했을 때 처음 뜨는 화면이다. 이 화면에서 Server에 접속하기 위한 profile을 설정/저장하여 접속할 수 있다. Connect버튼을 클릭한다.
> ![mongodb_image_31]

<br>

##### 새로운 접속 정보를 작성하기 위해New Connection 버튼을 클릭한다.
> ![mongodb_image_32]

<br>

##### Server에 접속하기 위한 Connection 정보를 입력한다.
> ![mongodb_image_33]

<br>

##### 서버 정보는 Application에 바인드되어 있는 서버 정보를 입력한다. cf env <app_name> 명령어로 이용하여 확인한다.
>`$ cf env hello-spring-mongodb` 

<br>

> ![mongodb_image_34]

<br>

##### Authentication탭으로 이동하여 mongodb 의 인증정보를 입력한다.
> ![mongodb_image_35]

<br>

##### SSH 터널 탭을 클릭하고 PaaS-TA 운영 관리자에게 제공받은 SSH 터널링 가능한 서버 정보를 입력한다.
> ![mongodb_image_36]

<br>

##### 모든 정보를 입력했으면 Test Connection 버튼을 눌러 접속 테스트를 한다.
> ![mongodb_image_37]

<br>

##### 모두 OK 결과가 나오면 정상적으로 접속이 된다는 것이다. OK 버튼을 누른다.


##### Save 버튼을 눌러 작성한 접속정보를 저장한다.
> ![mongodb_image_38]

<br>

##### 방금 저장한 접속정보를 선택하고 Connect 버튼을 클릭하여 접속한다.
> ![mongodb_image_39]

<br>

##### 접속이 완료되면 좌측에 스키마 정보가 나타난다. 컬럼을 더블클릭 해보면 우측에 적재되어있는 데이터가 출력된다.
> ![mongodb_image_40]

<br>

##### 우측 화면에 쿼리 항목에 Query문을 작성한 후 실행 버튼(삼각형)을 클릭한다. Query문에 이상이 없다면 정상적으로 결과를 얻을 수 있을 것이다.
> ![mongodb_image_41]


[mongodb_image_01]:/service-guide/images/mongodb/mongodb_image_01.png
[mongodb_image_02]:/service-guide/images/mongodb/mongodb_image_02.png
[mongodb_image_03]:/service-guide/images/mongodb/mongodb_image_03.png
[mongodb_image_04]:/service-guide/images/mongodb/mongodb_image_04.png
[mongodb_image_05]:/service-guide/images/mongodb/mongodb_image_05.png
[mongodb_image_06]:/service-guide/images/mongodb/mongodb_image_06.png
[mongodb_image_07]:/service-guide/images/mongodb/mongodb_image_07.png
[mongodb_image_08]:/service-guide/images/mongodb/mongodb_image_08.png
[mongodb_image_09]:/service-guide/images/mongodb/mongodb_image_09.png
[mongodb_image_10]:/service-guide/images/mongodb/mongodb_image_10.png
[mongodb_image_11]:/service-guide/images/mongodb/mongodb_image_11.png
[mongodb_image_12]:/service-guide/images/mongodb/mongodb_image_12.png
[mongodb_image_13]:/service-guide/images/mongodb/mongodb_image_13.png
[mongodb_image_14]:/service-guide/images/mongodb/mongodb_image_14.png
[mongodb_image_15]:/service-guide/images/mongodb/mongodb_image_15.png
[mongodb_image_16]:/service-guide/images/mongodb/mongodb_image_16.png
[mongodb_image_17]:/service-guide/images/mongodb/mongodb_image_17.png
[mongodb_image_18]:/service-guide/images/mongodb/mongodb_image_18.png
[mongodb_image_19]:/service-guide/images/mongodb/mongodb_image_19.png
[mongodb_image_20]:/service-guide/images/mongodb/mongodb_image_20.png
[mongodb_image_21]:/service-guide/images/mongodb/mongodb_image_21.png
[mongodb_image_22]:/service-guide/images/mongodb/mongodb_image_22.png
[mongodb_image_23]:/service-guide/images/mongodb/mongodb_image_23.png
[mongodb_image_24]:/service-guide/images/mongodb/mongodb_image_24.png
[mongodb_image_25]:/service-guide/images/mongodb/mongodb_image_25.png
[mongodb_image_26]:/service-guide/images/mongodb/mongodb_image_26.png
[mongodb_image_27]:/service-guide/images/mongodb/mongodb_image_27.png
[mongodb_image_28]:/service-guide/images/mongodb/mongodb_image_28.png
[mongodb_image_29]:/service-guide/images/mongodb/mongodb_image_29.png
[mongodb_image_30]:/service-guide/images/mongodb/mongodb_image_30.png
[mongodb_image_31]:/service-guide/images/mongodb/mongodb_image_31.png
[mongodb_image_32]:/service-guide/images/mongodb/mongodb_image_32.png
[mongodb_image_33]:/service-guide/images/mongodb/mongodb_image_33.png
[mongodb_image_34]:/service-guide/images/mongodb/mongodb_image_34.png
[mongodb_image_35]:/service-guide/images/mongodb/mongodb_image_35.png
[mongodb_image_36]:/service-guide/images/mongodb/mongodb_image_36.png
[mongodb_image_37]:/service-guide/images/mongodb/mongodb_image_37.png
[mongodb_image_38]:/service-guide/images/mongodb/mongodb_image_38.png
[mongodb_image_39]:/service-guide/images/mongodb/mongodb_image_39.png
[mongodb_image_40]:/service-guide/images/mongodb/mongodb_image_40.png
[mongodb_image_41]:/service-guide/images/mongodb/mongodb_image_41.png
[mongodb_image_42]:/service-guide/images/mongodb/mongodb_image_42.png
