## Table of Contents  

1. [문서 개요](#1)  
  1.1. [목적](#1.1)  
  1.2. [범위](#1.2)  
  1.3. [시스템 구성](#1.3)  
  1.4. [참고자료](#1.4)  

2. [PaaS-TA Portal infra 설치](#2)  
  2.1. [Prerequisite](#2.1)   
  2.2. [Stemcell 확인](#2.2)    
  2.3. [Deployment 다운로드](#2.3)   
  2.4. [Deployment 파일 수정](#2.4)  
  2.5. [서비스 설치](#2.5)    
  2.6. [서비스 설치 - 다운로드 된 PaaS-TA Release 파일 이용 방식](#2.6)   
  2.7. [서비스 설치 확인](#2.7)  

3. [PaaS-TA Portal 설치](#3)  
  3.1. [Prerequisite](#3.1)  
    3.1.1. [App 파일 및 Manifest 파일 다운로드](#3.1.1)  
    3.1.2. [Portal App Manifest 변경 Script 변수 설정](#3.1.2)  
    3.1.3. [Portal App Manifest 변경 Script 실행](#3.1.3)  
    3.1.4. [Portal App 배포 Script 변수 설정](#3.1.4)  
    3.1.5. [Portal App 배포 Script 실행](#3.1.5)  
    3.1.6. [Portal SSH 설치](#3.1.6)  
    
4. [PaaS-TA Portal 운영](#4)  
  4.1. [사용자의 조직 생성 Flag 활성화](#4.1)  
  4.2. [사용자포탈 UAA 페이지 오류](#4.2)  
  4.3. [카탈로그 적용](#4.3)  
  

## <div id="1"/> 1. 문서 개요
### <div id="1.1"/> 1.1. 목적

본 문서(PaaS-TA Portal 배포 가이드)는 PaaS-TA에서 배포되는 Portal을 PaaS-TA를 이용하여 설치 하는 방법을 기술하였다.

### <div id="1.2"/> 1.2. 범위
설치 범위는 PaaS-TA Portal을 검증하기 위한 Portal infra Release 설치 및 Portal App 배포를 기준으로 작성하였다. 

### <div id="1.3"/> 1.3. 시스템 구성
본 문서의 설치된 시스템 구성도이다. Binary Storage, Mariadb, Gateway Api, Registration Api, Portal Api, Common Api, Log Api, Storage Api, Webadmin, Webuser로 최소사항을 구성하였다.

![시스템구성도][paas-ta-portal-01]
* Paas-TA Portal infra VM   

| 구분 | Resource Pool | 스펙 |
|--------|-------|-------|
| infra (mariadb / binary storage) | small | 1vCPU / 512MB RAM / 10GB Disk 20GB(영구적 Disk) |

* Paas-TA Portal App 

| App명 | 인스턴스 수 | 메모리 | 디스크 |
|--------|-------|-------|-------|
| portal-registration | 1 | 1G | 1G|
| portal-gateway | 1 | 1G | 1G|
| portal-api | N | 2G | 2G|
| portal-common-api | N | 1G | 1G|
| portal-storage-api | N | 1G | 1G|
| portal-log-api | N | 1G | 1G|
| portal-web-admin | N | 1G | 1G|
| portal-web-user | N | 1G | 1G|  

### <div id="1.4"/> 1.4. 참고자료
[**http://bosh.io/docs**](http://bosh.io/docs)  
[**http://docs.cloudfoundry.org/**](http://docs.cloudfoundry.org/)

## <div id="2"/> 2. PaaS-TA Portal infra 설치  

### <div id="2.1"/> 2.1. Prerequisite 
본 설치 가이드는 Linux 환경에서 설치하는 것을 기준으로 하였다. 서비스 설치를 위해서는 BOSH 2.0과 5.0 이상의 PaaS-TA가 설치 되어 있어야 한다.

### <div id="2.2"/> 2.2. Stemcell 확인
Stemcell 목록을 확인하여 서비스 설치에 필요한 Stemcell이 업로드 되어 있는 것을 확인한다.  (PaaS-TA 5.5.0 과 동일 stemcell 사용)  

> $ bosh -e ${BOSH_ENVIRONMENT} stemcells

```
Using environment '10.0.1.6' as client 'admin'

Name                                     Version  OS             CPI  CID  
bosh-aws-xen-hvm-ubuntu-xenial-go_agent  621.94*  ubuntu-xenial  -    ami-0297ff649e8eea21b  

(*) Currently deployed

1 stemcells

Succeeded
```

### <div id="2.3"/> 2.3. Deployment 다운로드 

서비스 설치에 필요한 Deployment를 Git Repository에서 받아 서비스 설치 작업 경로로 위치시킨다.  

- Portal Deployment Git Repository URL : https://github.com/PaaS-TA/portal-deployment/tree/v5.1.0

```
# Deployment 다운로드 파일 위치 경로 생성 및 설치 경로 이동
$ mkdir -p ~/workspace/paasta-5.5.0/deployment
$ cd ~/workspace/paasta-5.5.0/deployment

# Deployment 파일 다운로드
$ git clone https://github.com/PaaS-TA/portal-deployment.git -b v5.1.0
```

### <div id="2.4"/> 2.4. Deployment 파일 수정  
BOSH Deployment manifest는 Components 요소 및 배포의 속성을 정의한 YAML 파일이다. Deployment 파일에서 사용하는 network, vm_type, disk_type 등은 Cloud config를 활용하고, 활용 방법은 BOSH 2.0 가이드를 참고한다.

- Cloud config 설정 내용을 확인한다.   

> $ bosh -e ${BOSH_ENVIRONMENT} cloud-config   

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

> $ vi ~/workspace/paasta-5.5.0/deployment/portal-deployment/portal-container-infra/vars.yml

```
# STEMCELL INFO
stemcell_os: "ubuntu-xenial"                                    # stemcell os
stemcell_version: "621.94"                                      # stemcell version

# NETWORKS INFO
private_networks_name: "default"                                # private network name

# PORTAL-INFRA INFO
infra_azs: [z3]                                                 # infra : azs
infra_instances: 1                                              # infra : instances (1) 
infra_vm_type: "large"                                          # infra : vm type
infra_persistent_disk_type: "20GB"                              # infra : persistent disk type


# MARIADB INFO
mariadb_port: "<MARIADB_PORT>"                                  # mariadb : database port (e.g. 13306) -- Do Not Use "3306"
mariadb_admin_password: "<MARIADB_ADMIN_PASSWORD>"              # mariadb : database admin password (e.g. "Paasta@2019")
portal_default_api_name: "PaaS-TA 5.5.0"                        # portal default api name
portal_default_api_url: "http://<PORTAL_GATEWAY_ROUTE>"         # portal default api url (portal gateway url) (e.g. "http://portal-gateway.<DOMAIN>")
portal_default_header_auth: "Basic YWRtaW46b3BlbnBhYXN0YQ=="    # portal default header auth
portal_default_api_desc: "PaaS-TA 5.5.0 infra"                  # portal default api description


# BINARY_STORAGE INFO
binary_storage_auth_port: "<BINARY_STORAGE_AUTH_PORT>"          # binary storage : keystone port (e.g. 15001) -- Do Not Use "5000"
binary_storage_username: "<BINARY_STORAGE_USERNAME>"            # binary storage : username (e.g. "paasta-portal")
binary_storage_password: "<BINARY_STORAGE_PASSWORD>"            # binary storage : password (e.g. "paasta")
binary_storage_tenantname: "<BINARY_STORAGE_TENANTNAME>"        # binary storage : tenantname (e.g. "paasta-portal")
binary_storage_email: "<BINARY_STORAGE_EMAIL>"                  # binary storage : email (e.g. "paasta@paasta.com")
```

### <div id="2.5"/> 2.5. 서비스 설치

- 서버 환경에 맞추어 Deploy 스크립트 파일의 VARIABLES 설정을 수정하고, Option file을 추가할지 선택한다.  
     (선택) -o operations/use-compiled-releases.yml (ubuntu-xenial/621.94로 컴파일 된 릴리즈 사용)  

> $ vi ~/workspace/paasta-5.5.0/deployment/portal-deployment/portal-container-infra/deploy.sh
```
#!/bin/bash

# VARIABLES
COMMON_VARS_PATH="<COMMON_VARS_FILE_PATH>"  # common_vars.yml File Path (e.g. ../../common/common_vars.yml)
BOSH_ENVIRONMENT="${BOSH_ENVIRONMENT}"      # bosh director alias name (PaaS-TA에서 제공되는 create-bosh-login.sh 미 사용시 bosh envs에서 이름을 확인하여 입력)

# DEPLOY
bosh -e ${BOSH_ENVIRONMENT} -n -d portal-container-infra deploy --no-redact portal-container-infra.yml \
   -l ${COMMON_VARS_PATH} \
   -l vars.yml
```

- 서비스를 설치한다.  
```
$ cd ~/workspace/paasta-5.5.0/deployment/portal-deployment/portal-container-infra    
$ sh ./deploy.sh  
```  

### <div id="2.6"/> 2.6. 서비스 설치 - 다운로드 된 PaaS-TA Release 파일 이용 방식  

- 서비스 설치에 필요한 릴리즈 파일을 다운로드 받아 Local machine의 서비스 설치 작업 경로로 위치시킨다.  
  
  - 설치 릴리즈 파일 다운로드 : [paasta-portal-api-release-2.3.0-ctn.tgz](http://45.248.73.44/index.php/s/eKf8XWwt8Wy9HrA/download)

```
# 릴리즈 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta-5.5.0/release/portal

# 릴리즈 파일 다운로드 및 파일 경로 확인
$ ls ~/workspace/paasta-5.5.0/release/portal
paasta-portal-api-release-2.3.0-ctn.tgz
```
  
- 서버 환경에 맞추어 Deploy 스크립트 파일의 VARIABLES 설정을 수정하고 Option file 및 변수를 추가한다.  
     (추가) -o operations/use-offline-releases.yml (미리 다운받은 offline 릴리즈 사용)  
     (추가) -v releases_dir="<RELEASE_DIRECTORY>"  
     
> $ vi ~/workspace/paasta-5.5.0/deployment/portal-deployment/portal-container-infra/deploy.sh
  
```
#!/bin/bash

# VARIABLES
COMMON_VARS_PATH="<COMMON_VARS_FILE_PATH>"  # common_vars.yml File Path (e.g. ../../common/common_vars.yml)
BOSH_ENVIRONMENT="${BOSH_ENVIRONMENT}"      # bosh director alias name (PaaS-TA에서 제공되는 create-bosh-login.sh 미 사용시 bosh envs에서 이름을 확인하여 입력)

# DEPLOY
bosh -e ${BOSH_ENVIRONMENT} -n -d portal-container-infra deploy --no-redact portal-container-infra.yml \
   -o operations/use-offline-releases.yml \
   -l ${COMMON_VARS_PATH} \
   -l vars.yml \
   -v releases_dir="/home/ubuntu/workspace/paasta-5.5.0/release"     
```  

- 서비스를 설치한다.  
```
$ cd ~/workspace/paasta-5.5.0/deployment/portal-deployment/portal-container-infra   
$ sh ./deploy.sh  
```  

### <div id="2.7"/> 2.7. 서비스 설치 확인
설치 완료된 서비스를 확인한다.  

> $ bosh -e ${BOSH_ENVIRONMENT} -d portal-container-infra vms  

```
Using environment '10.0.1.6' as client 'admin'

Task 1246. Done

Deployment 'portal-container-infra'

Instance                                    Process State  AZ  IPs          VM CID               VM Type  Active  
infra/3193a1fa-156d-4dd9-935d-4b67cdcc1182  running        z3  10.0.81.121  i-09ec0c2e7f3594683  large    true  

1 vms

Succeeded
```

## <div id="3"/> 3. PaaS-TA Portal 설치

### <div id="3.1"/> 3.1. Prerequisite  
### <div id="3.1.1"/> 3.1.1. App 파일 및 Manifest 파일 다운로드
Portal 설치에 필요한 App 파일 및 Manifest 파일을 다운로드 받아 서비스 설치 작업 경로로 위치시킨다.

```
### 설치 작업 경로  
$ cd ~/workspace/paasta-5.5.0/release/portal

### portal app 파일을 다운로드한다
$ wget --content-disposition http://45.248.73.44/index.php/s/jcDJmxrnsnc772E/download
$ unzip portal-app.zip 

### 설치 디렉토리 (파일) 구성  
portal-app
├── portal-api-2.3.0
│   ├── manifest.yml
│   └── paas-ta-portal-api.jar
├── portal-common-api-2.1.0
│   ├── manifest.yml
│   └── paas-ta-portal-common-api.jar
├── portal-gateway-2.1.0
│   ├── manifest.yml
│   └── paas-ta-portal-gateway.jar
├── portal-log-api-2.1.0
│   ├── manifest.yml
│   └── paas-ta-portal-log-api.jar
├── portal-registration-2.1.0
│   ├── manifest.yml
│   └── paas-ta-portal-registration.jar
├── portal-storage-api-2.1.0
│   ├── manifest.yml
│   └── paas-ta-portal-storage-api.jar
├── portal-web-admin-2.2.0
│   ├── manifest.yml
│   └── paas-ta-portal-webadmin.war
└── portal-web-user-2.3.0
│   ├── config
│   ├── manifest.yml
│   └── paas-ta-portal-webuser
├── 1.applyChangeVariable.sh
├── 2.portalContainerPush.sh
└── portal-rule.json
 ```
 
### <div id="3.1.2"/> 3.1.2. Portal App Manifest 변경 Script 변수 설정
manifest는 Components 요소 및 배포의 속성을 정의한 YAML 파일이다. manifest 파일에는 어떤 name, memory, instance, host, path, buildpack, env 등을 사용 할 것인지 정의가 되어 있다.

- infra 정보 : [2.4. Deployment 파일 수정 - vars.yml](#2.4) 및 [2.7. 서비스 설치 확인](#2.7) 참조  
- PaaS-TA 정보 : PaaS-TA 설치 시 사용한 common_vars.yml 파일을 참고한다.  

```
### e.g.) common_vars.yml의 PaaS-TA 정보
# PAAS-TA INFO
system_domain: "61.252.53.246.xip.io"                   # Domain (xip.io를 사용하는 경우 HAProxy Public IP와 동일)
paasta_admin_username: "admin"                          # PaaS-TA Admin Username
paasta_admin_password: "admin"                          # PaaS-TA Admin Password
paasta_nats_ip: "10.0.1.121"
paasta_nats_port: 4222
paasta_nats_user: "nats"
paasta_nats_password: "7EZB5ZkMLMqT73h2JtxPv1fvh3UsqO"  # PaaS-TA Nats Password (CredHub 로그인후 'credhub get -n /micro-bosh/paasta/nats_password' 명령어를 통해 확인 가능)
paasta_nats_private_networks_name: "default"            # PaaS-TA Nats 의 Network 이름
paasta_database_ips: "10.0.1.123"                       # PaaS-TA Database IP (e.g. "10.0.1.123")
paasta_database_port: 5524                              # PaaS-TA Database Port (e.g. 5524)
paasta_database_type: "postgresql"                      # PaaS-TA Database Type (e.g. "postgresql" or "mysql")
paasta_database_driver_class: "org.postgresql.Driver"   # PaaS-TA Database driver-class (e.g. "org.postgresql.Driver" or "com.mysql.jdbc.Driver")
paasta_cc_db_id: "cloud_controller"                     # CCDB ID (e.g. "cloud_controller")
paasta_cc_db_password: "cc_admin"                       # CCDB Password (e.g. "cc_admin")
paasta_uaa_db_id: "uaa"                                 # UAADB ID (e.g. "uaa")
paasta_uaa_db_password: "uaa_admin"                     # UAADB Password (e.g. "uaa_admin")
paasta_api_version: "v3"

# UAAC INFO
uaa_client_admin_id: "admin"                            # UAAC Admin Client Admin ID
uaa_client_admin_secret: "admin-secret"                 # UAAC Admin Client에 접근하기 위한 Secret 변수
uaa_client_portal_secret: "clientsecret"                # UAAC Portal Client에 접근하기 위한 Secret 변수

# Monitoring INFO
monitoring_api_url: "61.252.53.241"                     # Monitoring-WEB의 Public IP

### ETC INFO
abacus_url: "http://abacus.61.252.53.248.xip.io"        # abacus url (e.g. "http://abacus.xxx.xxx.xxx.xxx.xip.io")
```

Portal을 PaaS-TA에 App으로 배포하기 전에 Portal App의 Manifest의 변수를 일괄 변경해주는 Script 동작을 위해 Portal 설치에 필요한 PaaS-TA 및 infra 정보를 확인하여 Script의 변수를 설정한다.

> $ vi ~/workspace/paasta-5.5.0/release/portal/portal-app/1.applyChangeVariable.sh
```
#!/bin/bash

# COMMON VARIABLE
DOMAIN="xx.xxx.xx.xxx.xip.io"           # PaaS-TA System Domain
CF_USER_ADMIN_USERNAME="admin"          # PaaS-TA Admin Username
CF_USER_ADMIN_PASSWORD="admin"          # PaaS-TA Admin Password
UAA_CLIENT_ID="admin"                   # UAA Client ID
UAA_CLIENT_SECRET="admin-secret"        # UAA Cliant Secret
UAA_ADMIN_CLIENT_ID="admin"             # UAA Admin Client ID
UAA_ADMIN_CLIENT_SECRET="admin-secret"  # UAA Admin Client Secret
UAA_LOGIN_CLIENT_ID="admin"             # UAA Login Client ID
UAA_LOGIN_CLIENT_SECRET="admin-secret"  # UAA Login Client Secret
PORTAL_DB_IP="10.0.41.101"              # portal-container-infra IP
PORTAL_DB_PORT="13306"                  # portal-container-infra Port
PORTAL_DB_USER_PASSWORD="Paasta@2019"   # portal-container-infra DB Password

# PORTAL-API
ABACUS_URL=""                           # Abacus URL(Not required)
MONITORING_API_URL=""                   # Monitoring API URL(Not required)

# PORTAL-COMMON-API
PAASTA_DB_DRIVER="org.postgresql.Driver"  # PaaS-TA DB Driver (e.g. org.postgresql.Driver OR com.mysql.jdbc.Driver)
PAASTA_DATABASE="postgresql"              # PaaS-TA DB (e.g. postgresql OR mysql)
PAASTA_DB_IP="10.0.1.123"`                # PaaS-TA DB IP
PAASTA_DB_PORT="5524"                     # PaaS-TA DB Port (e.g. 5524(postgres) OR 13307(mysql))
CC_DB_NAME="cloud_controller"             # PaaS-TA CCDB Name
CC_DB_USER_NAME="cloud_controller"        # PaaS-TA CCDB ID
CC_DB_USER_PASSWORD="cc_admin"            # PaaS-TA CCDB Password
UAA_DB_NAME="uaa"                         # PaaS-TA UAA Name
UAA_DB_USER_NAME="uaa"                    # PaaS-TA UAA ID
UAA_DB_USER_PASSWORD="uaa_admin"          # PaaS-TA UAA Password
MAIL_SMTP_HOST="smtp.gmail.com"           # Mail-SMTP Host
MAIL_SMTP_PORT="465"                      # Mail-SMTP Port
MAIL_SMTP_USERNAME="paasta"               # Mail-SMTP User Name
MAIL_SMTP_PASSWORD="paasta"               # Mail-SMTP Password
MAIL_SMTP_USEREMAIL="paas-ta@gmail.com"   # Mail-SMTP User Email
MAIL_SMTP_PROPERTIES_AUTHURL="portal-web-user.<DOMAIN>"   # Mail-SMTP Properties Auth URL

# PORTAL-STORAGE-API
OBJECTSTORAGE_TENANTNAME="paasta-portal"  # portal-container-infra Binary Storage Tenant Name
OBJECTSTORAGE_USERNAME="paasta-portal"    # portal-container-infra Binary Storage User Name
OBJECTSTORAGE_PASSWORD="paasta"           # portal-container-infra Binary Storage Password
OBJECTSTORAGE_IP="10.0.41.101"            # portal-container-infra IP
OBJECTSTORAGE_PORT="15001"                # portal-container-infra Binary Storage Port

# PORTAL-WEBUSER
UAAC_PORTAL_CLIENT_ID="portalclient"      # UAAC Portal Client ID
UAAC_PORTAL_CLIENT_SECRET="clientsecret"  # UAAC Poral Client Secret
USER_APP_SIZE_MB=0                        # USER My App size(MB), if value==0 -> unlimited

......

```


### <div id="3.1.3"/> 3.1.3. Portal App Manifest 변경 Script 실행
Portal을 PaaS-TA에 App으로 배포하기 전에 Portal App의 Manifest의 변수를 일괄 변경해주는 Script를 실행한다.

```
$ cd ~/workspace/paasta-5.5.0/release/portal/portal-app
$ source 1.applyChangeVariable.sh


### 이후 각 Manifest.yml 파일을 확인하여 값이 정상적으로 바뀌었는지 확인한다.

e.g.) portal-registration
$ vi ~/workspace/paasta-5.5.0/release/portal/portal-app/portal-registration-2.1.0/manifest.yml

applications:
  - name: portal-registration
    memory: 1G
    instances: 1
    buildpacks:
    - java_buildpack
    routes:
    - route: portal-registration.xx.xxx.xxx.xxx.xip.io
    path: paas-ta-portal-registration.jar
    env:
      server_port: 80

      spring_application_name: PortalRegistration

      eureka_server_enableSelfPreservation: true
      eureka_instance_hostname: ${vcap.application.uris[0]}
      eureka_instance_nonSecurePort: 80
      eureka_client_registerWithEureka: false
      eureka_client_fetchRegistry: false
      eureka_server_maxThreadsForPeerReplication: 0
      eureka_client_server_waitTimeInMsWhenSyncEmpty: 0
      eureka_client_serviceUrl_defaultZone: http://${vcap.application.uris[0]}/eureka/



```



### <div id="3.1.4"/> 3.1.4. Portal App 배포 Script 변수 설정
Portal을 PaaS-TA에 App으로 배포해주는 Script 동작을 위해 Script의 접속정보 변수를 설정한다.

> $ vi ~/workspace/paasta-5.5.0/release/portal/portal-app/2.portalContainerPush.sh
```
#!/bin/bash

#VARIABLE
DOMAIN="xx.xxx.xx.xxx.xip.io"           # PaaS-TA System Domain
PAASTA_USER_ADMIN_USERNAME="admin"      # PaaS-TA Admin Username
PAASTA_USER_ADMIN_PASSWORD="admin"      # PaaS-TA Admin Password
PORTAL_QUOTA_NAME="portal_quota"        # PaaS-TA Portal Quota Name
PORTAL_ORG_NAME="portal"                # PaaS-TA Portal Org Name
PORTAL_SPACE_NAME="system"              # PaaS-TA Portal Space Name
PORTAL_SECURITY_GROUP_NAME="portal"     # PaaS-TA Portal Space Name

......

```

### <div id="3.1.5"/> 3.1.5. Portal App 배포 Script 실행
Portal을 PaaS-TA에 App으로 배포해주는 Script를 실행한다.

```
$ cd ~/workspace/paasta-5.5.0/release/portal/portal-app
$ source 2.portalContainerPush.sh

.....

name                  requested state   processes           routes
portal-api            started           web:1/1, task:0/0   portal-api.61.252.53.246.xip.io
portal-common-api     started           web:1/1, task:0/0   portal-common-api.61.252.53.246.xip.io
portal-gateway        started           web:1/1, task:0/0   portal-gateway.61.252.53.246.xip.io
portal-log-api        started           web:1/1, task:0/0   portal-log-api.61.252.53.246.xip.io
portal-registration   started           web:1/1, task:0/0   portal-registration.61.252.53.246.xip.io
portal-storage-api    started           web:1/1, task:0/0   portal-storage-api.61.252.53.246.xip.io
portal-web-admin      started           web:1/1, task:0/0   portal-web-admin.61.252.53.246.xip.io
portal-web-user       started           web:1/1             portal-web-user.61.252.53.246.xip.io

```

### <div id="3.1.6"/> 3.1.6. Portal SSH 설치

Portal 5.1.0 버전 이상부터는 배포된 어플리케이션의 SSH 접속이 가능하다.

이를 위해 Portal SSH App을 먼저 배포해야 한다.


- Portal SSH 다운로드 및 배포
```
$ wget --content-disposition http://45.248.73.44/index.php/s/awPjYDYCMiHY7yF/download
$ unzip portal-ssh.zip
$ cd portal-ssh
$ cf push
```



## <div id="4"/>4. PaaS-TA Portal 운영

### <div id="4.1"/> 4.1. 사용자의 조직 생성 Flag 활성화

PaaS-TA는 기본적으로 일반 사용자는 조직을 생성할 수 없도록 설정되어 있다. 포털 배포를 위해 조직 및 공간을 생성해야 하고 또 테스트를 구동하기 위해서도 필요하므로 사용자가 조직을 생성할 수 있도록 user_org_creation FLAG를 활성화 한다. FLAG 활성화를 위해서는 PaaS-TA 운영자 계정으로 로그인이 필요하다.

```
$ cf enable-feature-flag user_org_creation
```
```
Setting status of user_org_creation as admin...
OK

Feature user_org_creation Enabled.
```

### <div id="4.2"/> 4.2. 사용자포탈 UAA페이지 오류  

- uaac의 endpoint를 설정하고 uaac 로그인을 실행한다.
```
# endpoint 설정
$ uaac target https://uaa.<DOMAIN> --skip-ssl-validation

# target 확인
$ uaac target
Target: https://uaa.<DOMAIN>
Context: uaa_admin, from client uaa_admin

# uaac 로그인
$ uaac token client get <UAA_ADMIN_CLIENT_ID> -s <UAA_ADMIN_CLIENT_SECRET>
Successfully fetched token via client credentials grant.
Target: https://uaa.<DOMAIN>
Context: admin, from client admin
```
- redirect오류 - portalclient 미등록  
![paas-ta-portal-31]  
1. uaac portalclient가 등록이 되어있지 않다면 해당 화면과 같이 redirect오류가 발생한다.  
2. uaac client add를 통해 potalclient를 추가시켜주어야 한다.   
> $ uaac client add <PORTAL_UAA_CLIENT_ID> -s <PORTAL_UAA_CLIENT_SECRET> --redirect_uri <PORTAL_WEB_USER_URI>, <PORTAL_WEB_USER_URI>/callback --scope   "cloud_controller_service_permissions.read , openid , cloud_controller.read , cloud_controller.write , cloud_controller.admin" --authorized_grant_types "authorization_code , client_credentials , refresh_token" --authorities="uaa.resource" --autoapprove="openid , cloud_controller_service_permissions.read"  
  
```
# e.g. portal client 계정 생성 

$ uaac client add portalclient -s clientsecret --redirect_uri "http://portal-web-user.<DOMAIN>, http://portal-web-user.<DOMAIN>/callback" \
--scope "cloud_controller_service_permissions.read , openid , cloud_controller.read , cloud_controller.write , cloud_controller.admin" \
--authorized_grant_types "authorization_code , client_credentials , refresh_token" \
--authorities="uaa.resource" \
--autoapprove="openid , cloud_controller_service_permissions.read"
```

- redirect오류 - portalclient의 redirect_uri 등록 오류  
![paas-ta-portal-32]  
1. uaac portalclient가 uri가 잘못 등록되어있다면 해당 화면과 같이 redirect오류가 발생한다.   
2. uaac client update를 통해 uri를 수정해야한다.  
> $ uaac client update portalclient --redirect_uri "<PORTAL_WEB_USER_URI>, <PORTAL_WEB_USER_URI>/callback"   

```
#  e.g. portal client redirect_uri update
$ uaac client update portalclient --redirect_uri "http://portal-web-user.<DOMAIN>, http://portal-web-user.<DOMAIN>/callback" 
```

### <div id="4.3"/> 4.3. 카탈로그 적용  
##### 1. Catalog 빌드팩, 서비스팩 추가  
Paas-TA Portal 설치 후에 관리자 포탈에서 빌드팩, 서비스팩을 등록해야 사용자 포탈에서 사용이 가능하다.  
 
1. 관리자 포탈에 접속한다.(portal-web-admin.\<DOMAIN\>)  
![paas-ta-portal-15]  
2. 운영관리를 누른다.  
![paas-ta-portal-16]  
3. 카탈로그 페이지에 들어간다.  
![paas-ta-portal-17]  
4. 빌드팩, 서비스팩 상세화면에 들어가서 각 항목란에 값을 입력후에 저장을 누른다.  
![paas-ta-portal-18]  
5. 사용자포탈에서 변경된값이 적용되어있는지 확인한다.  
![paas-ta-portal-19]   
    
[paas-ta-portal-01]:../../install-guide/portal/images/Paas-TA-Portal_App_01.png
[paas-ta-portal-15]:../../install-guide/portal/images/Paas-TA-Portal_15.png
[paas-ta-portal-16]:../../install-guide/portal/images/Paas-TA-Portal_16.png
[paas-ta-portal-17]:../../install-guide/portal/images/Paas-TA-Portal_17.png
[paas-ta-portal-18]:../../install-guide/portal/images/Paas-TA-Portal_18.png
[paas-ta-portal-19]:../../install-guide/portal/images/Paas-TA-Portal_19.png
[paas-ta-portal-31]:../../install-guide/portal/images/Paas-TA-Portal_27.jpg
[paas-ta-portal-32]:../../install-guide/portal/images/Paas-TA-Portal_28.jpg
