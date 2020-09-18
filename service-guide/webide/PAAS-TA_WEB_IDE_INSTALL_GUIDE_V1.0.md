## Table of Contents
1. [문서 개요](#1)  
  1.1. [목적](#1.1)  
  1.2. [범위](#1.2)  
  1.3. [시스템 구성도](#1.3)  
  1.4. [참고자료](#1.4)  

2. [WEB IDE 설치](#2)  
  2.1. [Prerequisite](#2.1)   
  2.2. [Stemcell 확인](#2.2)    
  2.3. [Deployment 다운로드](#2.3)   
  2.4. [Deployment 파일 수정](#2.4)  
  2.5. [서비스 설치](#2.5)    
  2.6. [서비스 설치 - 다운로드 된 PaaS-TA Release 파일 이용 방식](#2.6)   
  2.7. [서비스 설치 확인](#2.7)  

3. [WEB-IDE의 PaaS-TA 포털사이트 연동](#3)  
  3.1. [WEB-IDE 서비스 브로커 등록](#3.1)

4. [WEB-IDE 에서 CF CLI 사용법](#4)  
  4.1. [WEB-IDE New Project 화면](#4.1)  
  4.2. [WEB-IDE Workspace 화면](#4.2)  
  4.3. [WEB-IDE Teminal에서의 CF CLI 실행](#4.3)  



## <div id="1"/> 1. 문서 개요

### <div id='1.1'/>1.1. 목적

본 문서는 PaaS-TA에서 사용할 수 있는 WEB-IDE의 설치를 Bosh를 이용하여 설치 하는 방법과 PaaS-TA 포털에서 WEB-IDE 서비스를 사용하는 방법을 기술하였다.
PaaS-TA 3.5 버전부터는 Bosh2.0 기반으로 deploy를 진행하며 기존 Bosh1.0 기반으로 설치를 원할경우에는 PaaS-TA 3.1 이하 버전의 문서를 참고한다.

### <div id='1.2'/> 1.2. 범위
설치 범위는 WEB-IDE 사용을 검증하기 위한 기본 설치를 기준으로 작성하였다.

### <div id='1.3'/> 1.3. 시스템 구성도
본 장에서는 WEB-IDE의 시스템 구성에 대해 기술하였다. Browser(PaaS-TA Portal), WEB IDE Server, Workspace, Desktop IDE로 최소사항을 구성하였다.

![](/service-guide/images/webide/web-ide-01.png)

| 구분 | Resource Pool | 스펙 |
|--------|-------|-------|
| paasta-web-ide1 | resource\_pools | 1vCPU / 2GB RAM / 10GB Disk |
| paasta-web-ide2 | resource\_pools | 1vCPU / 2GB RAM / 10GB Disk |


### <div id='1.4'/>1.4. 참고자료

> [**http://bosh.io/docs**](http://bosh.io/docs) <br>
> [**http://docs.cloudfoundry.org/**](http://docs.cloudfoundry.org/) <br>
> [**https://www.eclipse.org/che/technology/**](https://www.eclipse.org/che/technology/) <br>


## <div id='2'/> 2. WEB IDE 설치  

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

- Deployment YAML에서 사용하는 변수 파일을 서버 환경에 맞게 수정한다.

> $ vi ~/workspace/paasta-5.0/deployment/service-deployment/web-id/vars.yml

```
# STEMCELL
stemcell_os: "ubuntu-xenial"                                         # stemcell os
stemcell_version: "315.64"                                           # stemcell version

# NETWORK
private_networks_name: "default"                                     # private network name
public_networks_name: "vip"                                          # public network name

# ECLIPSE-CHE
eclipse_che_azs: [z7]                                                # eclipse-che : azs
eclipse_che_instances: 1                                             # eclipse-che : instances (1)
eclipse_che_vm_type: "large"                                         # eclipse-che : vm type
eclipse_che_public_ips: "<ECLIPSE_CHE_PUBLIC_IPS>"                   # eclipse-che : public ips (e.g. ["00.00.00.00" , "11.11.11.11"])

# MARIA_DB
mariadb_azs: [z3]                                                    # mariadb : azs
mariadb_instances: 1                                                 # mariadb : instances (1) 
mariadb_vm_type: "small"                                             # mariadb : vm type
mariadb_persistent_disk_type: "10GB"                                 # mariadb : persistent disk type
mariadb_port: "<MARIADB_PORT>"                                       # mariadb : database port (e.g. 31306) -- Do Not Use "3306"
mariadb_admin_password: "<MARIADB_ADMIN_PASSWORD>"                   # mariadb : database admin password (e.g. "Paasta@2018")

# SERVICE-BROKER
broker_azs: [z3]                                                     # service-broker : azs
broker_instances: 1                                                  # service-broker : instances (1)
broker_vm_type: "medium"                                             # service-broker : vm type
broker_port: "<BROKER_PORT>"                                         # service-broker : broker port (e.g. "8080")
broker_services_id: "<BROKER_SERVICES_ID>"                           # service-broker : service guid (e.g. "af86588c-6212-11e7-907b-b6006ad3webide0")
broker_services_plans_id: "<BROKER_SERVICES_PLANS_ID>"               # service-broker : service plan id (e.g. "a5930564-6212-11e7-907b-b6006ad3webide1")
```

### <div id="2.5"/> 2.5. 서비스 설치

- 서버 환경에 맞추어 Deploy 스크립트 파일의 VARIABLES 설정을 수정한다. 

> $ vi ~/workspace/paasta-5.0/deployment/service-deployment/web-id/deploy.sh

```
#!/bin/bash
  
# VARIABLES
BOSH_NAME="micro-bosh"                           # bosh name (e.g. micro-bosh)
IAAS="openstack"                                 # IaaS (e.g. aws/azure/gcp/openstack/vsphere)
COMMON_VARS_PATH="<COMMON_VARS_FILE_PATH>"       # common_vars.yml File Path (e.g. /home/ubuntu/paasta-5.0/common/common_vars.yml)

# DEPLOY
bosh -e ${BOSH_NAME} -n -d web-ide deploy --no-redact web-ide.yml \
    -o operations/${IAAS}-network.yml \
    -l ${COMMON_VARS_PATH} \
    -l vars.yml      
```

- 서비스를 설치한다.  
```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/web-id
$ sh ./deploy.sh  
```  

### <div id="2.6"/> 2.6. 서비스 설치 - 다운로드 된 PaaS-TA Release 파일 이용 방식  

- 서비스 설치에 필요한 릴리즈 파일을 다운로드 받아 Local machine의 서비스 설치 작업 경로로 위치시킨다.  
  
  - 설치 릴리즈 파일 다운로드 : [paasta-webide-release-1.0.tgz](http://45.248.73.44/index.php/s/q7fBcXokm7FSNdW/download)

```
# 릴리즈 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta-5.0/release/service

# 릴리즈 파일 다운로드 및 파일 경로 확인
$ ls ~/workspace/paasta-5.0/release/service
paasta-webide-release-1.0.tgz
```
  
- 서버 환경에 맞추어 Deploy 스크립트 파일의 VARIABLES 설정을 수정하고 Option file 및 변수를 추가한다.  
     (추가) -o operations/use-compiled-releases.yml  
     (추가) -v inception_os_user_name="<HOME_USER_NAME>"  
     
> $ vi ~/workspace/paasta-5.0/deployment/service-deployment/web-id/deploy.sh

```
#!/bin/bash

# VARIABLES
BOSH_NAME="micro-bosh"                           # bosh name (e.g. micro-bosh)
IAAS="openstack"                                 # IaaS (e.g. aws/azure/gcp/openstack/vsphere)
COMMON_VARS_PATH="<COMMON_VARS_FILE_PATH>"       # common_vars.yml File Path (e.g. /home/ubuntu/paasta-5.0/common/common_vars.yml)

# DEPLOY
bosh -e ${BOSH_NAME} -n -d web-ide deploy --no-redact web-ide.yml \
    -o operations/${IAAS}-network.yml \
    -o operations/use-compiled-releases.yml \
    -l ${COMMON_VARS_PATH} \
    -l vars.yml\
    -v inception_os_user_name="ubuntu"
```  

- 서비스를 설치한다.  
```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/web-id
$ sh ./deploy.sh  
```  

### <div id="2.7"/> 2.7. 서비스 설치 확인

설치 완료된 서비스를 확인한다.  

> $ bosh -e micro-bosh -d web-id vms

```
Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)

Task 7872. Done

Deployment 'web-id'

Instance                                            Process State  AZ  IPs            VM CID                                   VM Type  Active
eclipse-che/ed136540-c650-47a2-918b-bb7f6020469d    running        z7  10.30.56.54    vm-5a3a2b10-d0c9-47c8-97f0-6ea64c339df8  large    true
							               115.68.46.178
mariadb/ec34aa5b-c7cc-4297-9e2d-babf05d83832        running        z3  10.30.56.55    vm-9e1631af-b6c8-481e-aad3-3fd713f106a9  small    true
webide-broker/a641df99-d36a-49ee-8329-018fe10fa23d  running        z3  10.30.56.56    vm-eb784964-48cd-4e4c-b080-53675d3738c2  medium   true

3 vms

Succeeded
```

## <div id='3'/> 3. WEB-IDE의 PaaS-TA 포털사이트 연동

### <div id='3.1'/> 3.1. WEB-IDE 서비스 브로커 등록

>`$ cf create-service-broker {서비스팩 이름} {서비스팩 사용자ID} {서비스팩 사용자비밀번호} http://{서비스팩 URL(IP)}`

  **서비스팩 이름** : 서비스 팩 관리를 위해 PaaS-TA에서 보여지는 명칭이다. 서비스 Marketplace에서는 각각의 API 서비스 명이 보여지니 여기서 명칭은 서비스팩 리스트의 명칭이다.<br>
  **서비스팩 사용자ID** / 비밀번호 : 서비스팩에 접근할 수 있는 사용자 ID입니다. 서비스팩도 하나의 API 서버이기 때문에 아무나 접근을 허용할 수 없어 접근이 가능한 ID/비밀번호를 입력한다.<br>
  **서비스팩 URL** : 서비스팩이 제공하는 API를 사용할 수 있는 URL을 입력한다.

>`$ cf create-service-broker webide-service-broker admin cloudfoundry http://10.30.56.56:8080`
```
$ cf create-service-broker webide-service-broker admin cloudfoundry http://10.30.56.56:8080
Creating service broker webide-service-broker as admin...
OK
```
<br>

##### 등록된 WEB-IDE 서비스 브로커를 확인한다.
>`$ cf service-brokers`
```
$ cf service-brokers
Getting service brokers as admin...

name                          url
webide-service-broker         http://10.30.56.56:8080
```
<br>

#### 접근 가능한 서비스 목록을 확인한다.
>`$ cf service-access`
```
$ cf service-access
Getting service access as admin...
broker: webide-service-broker
   service   plan            access   orgs
   webide    webide-shared   none
```
<br>

- 서비스 브로커 등록시 최초에는 접근을 허용하지 않는다. 따라서 access는 none으로 설정된다.

#### 특정 조직에 해당 서비스 접근 허용을 할당하고 접근 서비스 목록을 다시 확인한다. (전체 조직)
>`$ cf enable-service-access webide`<br>
>`$ cf service-access`
```
$ cf enable-service-access webide
Enabling access to all plans of service webide for all orgs as admin...
OK
```
```
$ cf service-access
Getting service access as admin...

broker: webide-service-broker
   service   plan            access   orgs
   webide    webide-shared   all
```
<br>

#### PaaS-TA Marketplace에서 서비스가 있는지 확인을 한다.

>`$ cf marketplace`
```
$ cf marketplace
Getting services from marketplace in org system / space dev as admin...
OK

service                  plans                                   description                                                                                                                              broker
webide                   webide-shared                           A paasta web ide service for application development.provision parameters                                                                webide-service-broker
```
<br>

#### Marketplace에서 원하는 서비스가 있으면 서비스 신청(Provision)을 한다.

>`$ cf create-service {서비스명} {서비스 플랜} {내 서비스명}`
- **서비스명** : webide로 Marketplace에서 보여지는 서비스 명칭이다.
- **서비스플랜** : 서비스에 대한 정책으로 plans에 있는 정보 중 하나를 선택한다. webide 서비스는 standard plan만 지원한다.
- **내 서비스명** : 내 서비스에서 보여지는 명칭이다. 이 명칭을 기준으로 환경 설정 정보를 가져온다.


>`$ cf create-service webide webide-shared webide-service`
```
$ cf create-service webide webide-shared paasta-webide-service
Creating service instance paasta-webide-service in org system / space dev as admin...
OK
```
<br>

#### 생성된 WEB-IDE 서비스 인스턴스를 확인한다.

>`$ cf services`
```
$ cf services
Getting services in org system / space dev as admin...

name                    service      plan            bound apps   last operation     broker                    upgrade available
paasta-webide-service   webide       webide-shared                create succeeded   webide-service-broker
```
<br>

## <div id='4'/> 4. WEB-IDE 에서 CF CLI 사용법

### <div id='4.1'/> 4.1. WEB-IDE New Project 화면
***※ [PaaS-TA 운영자 포탈 4.3.3 카탈로그 관리 서비스 가이드](/use-guide/portal/PAAS-TA_ADMIN_PORTAL_USE_GUIDE_V1.1.md#4.3.3) 참고***  

- 사용할 언어를 선택하고 Create workspace and project 로 새로운 프로젝트를 시작한다.

![](/service-guide/images/webide/web-ide-08-1.png)

<br>

- Workspace를 구성하기 위해 Docker 관련 자료를 다운로드한다.

![](/service-guide/images/webide/web-ide-09.png)

<br>

### <div id='4.2'/> 4.2. WEB-IDE Workspace 화면

- Open Project를 누르면 Workspace 화면이 열린다.

![](/service-guide/images/webide/web-ide-10.png)

- 실제로 소스를 개발해서 빌드하거나 GIT이나 SVN에서 IMPORT 한다.

![](/service-guide/images/webide/web-ide-11.png)

<br>

### <div id='4.3'/> 4.3. WEB-IDE Teminal에서의 CF CLI 실행

##### -cf api 명령을 이용해 endpoint를 지정한다.

> ![](/service-guide/images/webide/web-ide-12.png)

##### cf login 명령어로 로그인하고 조직과 공간을 선택한다.

> ![](/service-guide/images/webide/web-ide-13.png)

##### cf push 를 이용해 cf에 앱을 업로드한다.

> ![](/service-guide/images/webide/web-ide-14.png)
