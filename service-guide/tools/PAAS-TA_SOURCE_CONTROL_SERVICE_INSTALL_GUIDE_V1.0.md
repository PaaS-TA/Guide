## Table of Contents  

1. [문서 개요](#1)  
  1.1. [목적](#1.1)  
  1.2. [범위](#1.2)  
  1.3. [시스템 구성도](#1.3)  
  1.4. [참고 자료](#1.4)  

2. [형상관리 서비스 설치](#2)  
  2.1. [Prerequisite](#2.1)   
  2.2. [Stemcell 확인](#2.2)    
  2.3. [Deployment 다운로드](#2.3)   
  2.4. [Deployment 파일 수정](#2.4)  
  2.5. [서비스 설치](#2.5)    
  2.6. [서비스 설치 - 다운로드 된 PaaS-TA Release 파일 이용 방식](#2.6)   
  2.7. [서비스 설치 확인](#2.7)  
  
3. [형상관리 서비스 관리 및 신청](#3)  
  3.1. [서비스 브로커 등록](#3.1)  
  3.2. [UAA Client 등록](#3.2)  
  3.3  [서비스 신청](#3.3)  
    

## <div id='1'/> 1. 문서 개요

### <div id='1.1'/> 1.1. 목적
본 문서는 개방형 PaaS 플랫폼 고도화 및 개발자 지원 환경 기반의 Open PaaS에서 제공되는 서비스인 형상관리 서비스를 Bosh를 이용하여 설치하는 방법을 기술하였다.
PaaS-TA 3.5 버전부터는 Bosh2.0 기반으로 deploy를 진행하며 기존 Bosh1.0 기반으로 설치를 원할경우에는 PaaS-TA 3.1 이하 버전의 문서를 참고한다.

### <div id='1.2'/> 1.2. 범위
설치 범위는 형상관리 서비스 Release를 검증하기 위한 기본 설치를 기준으로 작성하였다.

### <div id='1.3'/> 1.3. 시스템 구성도

본 장에서는 형상관리 서비스의 시스템 구성에 대해 기술하였다. 형상관리 서비스의 시스템은 service-broker, mariadb, 형상관리 Server의 최소 사항을 구성하였다.  
![source_controller_service_guide01]

### <div id='1.4'/> 1.4. 참고 자료
> http://bosh.io/docs <br>
> http://docs.cloudfoundry.org/

## <div id="2"/> 2. 형상관리 서비스 설치  

### <div id="2.1"/> 2.1. Prerequisite  

본 설치 가이드는 Linux 환경에서 설치하는 것을 기준으로 하였다. 서비스 설치를 위해서는 BOSH 2.0과 PaaS-TA 5.0 이상, PaaS-TA 포털이 설치되어 있어야 한다. 

### <div id="2.2"/> 2.2. Stemcell 확인  

Stemcell 목록을 확인하여 서비스 설치에 필요한 Stemcell이 업로드 되어 있는 것을 확인한다.  (PaaS-TA 5.5.2 과 동일 stemcell 사용)

> $ bosh -e micro-bosh stemcells

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

- Service Deployment Git Repository URL : https://github.com/PaaS-TA/service-deployment/tree/v5.1.0  

```
# Deployment 다운로드 파일 위치 경로 생성 및 설치 경로 이동
$ mkdir -p ~/workspace/paasta-5.5.2/deployment
$ cd ~/workspace/paasta-5.5.2/deployment

# Deployment 파일 다운로드
$ git clone https://github.com/PaaS-TA/service-deployment.git -b v5.1.0

# common_vars.yml 파일 다운로드(common_vars.yml가 존재하지 않는다면 다운로드)
$ git clone https://github.com/PaaS-TA/common.git
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

- common_vars.yml을 서버 환경에 맞게 수정한다. 
- 형상관리 서비스에서 사용하는 변수는 system_domain이다.

> $ vi ~/workspace/paasta-5.5.2/deployment/common/common_vars.yml
```
# BOSH INFO
bosh_ip: "10.0.1.6"				# BOSH IP
bosh_url: "https://10.0.1.6"			# BOSH URL (e.g. "https://00.000.0.0")
bosh_client_admin_id: "admin"			# BOSH Client Admin ID
bosh_client_admin_secret: "ert7na4jpew48"	# BOSH Client Admin Secret('echo $(bosh int ~/workspace/paasta-5.5.2/deployment/paasta-deployment/bosh/{iaas}/creds.yml --path /admin_password)' 명령어를 통해 확인 가능)
bosh_director_port: 25555			# BOSH director port
bosh_oauth_port: 8443				# BOSH oauth port
bosh_version: 271.2				# BOSH version('bosh env' 명령어를 통해 확인 가능, on-demand service용, e.g. "271.2")

# PAAS-TA INFO
system_domain: "61.252.53.246.nip.io"		# Domain (nip.io를 사용하는 경우 HAProxy Public IP와 동일)
paasta_admin_username: "admin"			# PaaS-TA Admin Username
paasta_admin_password: "admin"			# PaaS-TA Admin Password
paasta_nats_ip: "10.0.1.121"
paasta_nats_port: 4222
paasta_nats_user: "nats"
paasta_nats_password: "7EZB5ZkMLMqT73h2Jh3UsqO"	# PaaS-TA Nats Password (CredHub 로그인후 'credhub get -n /micro-bosh/paasta/nats_password' 명령어를 통해 확인 가능)
paasta_nats_private_networks_name: "default"	# PaaS-TA Nats 의 Network 이름
paasta_database_ips: "10.0.1.123"		# PaaS-TA Database IP (e.g. "10.0.1.123")
paasta_database_port: 5524			# PaaS-TA Database Port (e.g. 5524(postgresql)/13307(mysql)) -- Do Not Use "3306"&"13306" in mysql
paasta_database_type: "postgresql"                      # PaaS-TA Database Type (e.g. "postgresql" or "mysql")
paasta_database_driver_class: "org.postgresql.Driver"   # PaaS-TA Database driver-class (e.g. "org.postgresql.Driver" or "com.mysql.jdbc.Driver")
paasta_cc_db_id: "cloud_controller"		# CCDB ID (e.g. "cloud_controller")
paasta_cc_db_password: "cc_admin"		# CCDB Password (e.g. "cc_admin")
paasta_uaa_db_id: "uaa"				# UAADB ID (e.g. "uaa")
paasta_uaa_db_password: "uaa_admin"		# UAADB Password (e.g. "uaa_admin")
paasta_api_version: "v3"

# UAAC INFO
uaa_client_admin_id: "admin"			# UAAC Admin Client Admin ID
uaa_client_admin_secret: "admin-secret"		# UAAC Admin Client에 접근하기 위한 Secret 변수
uaa_client_portal_secret: "clientsecret"	# UAAC Portal Client에 접근하기 위한 Secret 변수

# Monitoring INFO
metric_url: "10.0.161.101"			# Monitoring InfluxDB IP
elasticsearch_master_ip: "10.0.1.146"           # Logsearch의 elasticsearch master IP
elasticsearch_master_port: 9200                 # Logsearch의 elasticsearch master Port
syslog_address: "10.0.121.100"            	# Logsearch의 ls-router IP
syslog_port: "2514"                          	# Logsearch의 ls-router Port
syslog_transport: "relp"                        # Logsearch Protocol
saas_monitoring_url: "61.252.53.248"	   	# Pinpoint HAProxy WEBUI의 Public IP
monitoring_api_url: "61.252.53.241"        	# Monitoring-WEB의 Public IP

### Portal INFO
portal_web_user_ip: "52.78.88.252"
portal_web_user_url: "http://portal-web-user.52.78.88.252.nip.io" 

### ETC INFO
abacus_url: "http://abacus.61.252.53.248.nip.io"	# abacus url (e.g. "http://abacus.xxx.xxx.xxx.xxx.nip.io")

```


- Deployment YAML에서 사용하는 변수 파일을 서버 환경에 맞게 수정한다.

> $ vi ~/workspace/paasta-5.5.2/deployment/service-deployment/source-control-service/vars.yml

```
# STEMCELL
stemcell_os: "ubuntu-xenial"                                   # stemcell os
stemcell_version: "621.94"                                     # stemcell version

# VM_TYPE
vm_type_small: "minimal"                                       # vm type small

# NETWORK
private_networks_name: "default"                               # private network name
public_networks_name: "vip"                                    # public network name

# SCM-SERVER
scm_azs: [z3]                                                  # scm : azs
scm_instances: 1                                               # scm : instances (1)
scm_persistent_disk_type: "30GB"                               # scm : persistent disk type
scm_private_ips: "<SCM_PRIVATE_IPS>"                           # scm : private ips (e.g. "10.0.81.41")

# MARIA-DB# MARIA_DB
mariadb_azs: [z3]                                              # mariadb : azs
mariadb_instances: 1                                           # mariadb : instances (1) 
mariadb_persistent_disk_type: "2GB"                            # mariadb : persistent disk type 
mariadb_private_ips: "<MARIADB_PRIVATE_IPS>"                   # mariadb : private ips (e.g. "10.0.81.42")
mariadb_port: "<MARIADB_PORT>"                                 # mariadb : database port (e.g. 31306) -- Do Not Use "3306"
mariadb_admin_password: "<MARIADB_ADMIN_PASSWORD>"             # mariadb : database admin password (e.g. "!paas_ta202")
mariadb_broker_username: "<MARIADB_BROKER_USERNAME>"           # mariadb : service-broker-user id (e.g. "sourcecontrol")
mariadb_broker_password: "<MARIADB_BROKER_PASSWORD>"           # mariadb : service-broker-user password (e.g. "!scadmin2017")

# HAPROXY
haproxy_azs: [z7]                                              # haproxy : azs
haproxy_instances: 1                                           # haproxy : instances (1)
haproxy_persistent_disk_type: "2GB"                            # haproxy : persistent disk type
haproxy_private_ips: "<HAPROXY_PRIVATE_IPS>"                   # haproxy : private ips (e.g. "10.0.0.31")
haproxy_public_ips: "<HAPROXY_PUBLIC_IPS>"                     # haproxy : public ips (e.g. "101.101.101.5")

# WEB-UI
web_ui_azs: [z3]                                               # web-ui : azs
web_ui_instances: 1                                            # web-ui : instances (1)
web_ui_persistent_disk_type: "2GB"                             # web-ui : persistent disk type
web_ui_private_ips: "<WEB_UI_PRIVATE_IPS>"                     # web-ui : private ips (e.g. "10.0.81.44")

# SCM-API
api_azs: [z3]                                                  # scm-api : azs
api_instances: 1                                               # scm-api : instances (1)
api_persistent_disk_type: "2GB"                                # scm-api : persistent disk type
api_private_ips: "<API_PRIVATE_IPS>"                           # scm-api : private ips (e.g. "10.0.81.45")

# SERVICE-BROKER
broker_azs: [z3]                                               # service-broker : azs
broker_instances: 1                                            # service-broker : instances (1)
broker_persistent_disk_type: "2GB"                             # service-broker : persistent disk type
broker_private_ips: "<BROKER_PRIVATE_IPS>"                     # service-broker : private ips (e.g. "10.0.81.46")

# UAAC
uaa_client_sc_id: "scclient"                                   # source-control-service uaa client id
uaa_client_sc_secret: "clientsecret"                           # source-control-service uaa client secret
```

### <div id="2.5"/> 2.5. 서비스 설치

- 서버 환경에 맞추어 Deploy 스크립트 파일의 VARIABLES 설정을 수정하고, Option file을 추가할지 선택한다.  
     (선택) -o operations/cce.yml (CCE 조치를 적용하여 설치)

> $ vi ~/workspace/paasta-5.5.2/deployment/service-deployment/source-control-service/deploy.sh

```
#!/bin/bash
  
# VARIABLES
COMMON_VARS_PATH="<COMMON_VARS_FILE_PATH>"	# common_vars.yml File Path (e.g. ../../common/common_vars.yml)
CURRENT_IAAS="${CURRENT_IAAS}"			# IaaS Information (PaaS-TA에서 제공되는 create-bosh-login.sh 미 사용시 aws/azure/gcp/openstack/vsphere 입력)
BOSH_ENVIRONMENT="${BOSH_ENVIRONMENT}"		# bosh director alias name (PaaS-TA에서 제공되는 create-bosh-login.sh 미 사용시 bosh envs에서 이름을 확인하여 입력)

# DEPLOY
bosh -e ${BOSH_ENVIRONMENT} -n -d source-control-service deploy --no-redact source-control-service.yml \
    -o operations/${CURRENT_IAAS}-network.yml \
    -o operations/cce.yml \
    -l ${COMMON_VARS_PATH} \
    -l vars.yml
```

- 서비스를 설치한다.  
```
$ cd ~/workspace/paasta-5.5.2/deployment/service-deployment/source-control-service  
$ sh ./deploy.sh  
```  

### <div id="2.6"/> 2.6. 서비스 설치 - 다운로드 된 PaaS-TA Release 파일 이용 방식

- 서비스 설치에 필요한 릴리즈 파일을 다운로드 받아 Local machine의 서비스 설치 작업 경로로 위치시킨다.  
  
  - 설치 릴리즈 파일 다운로드 : [paasta-sourcecontrol-release-1.1.0.tgz](https://nextcloud.paas-ta.org/index.php/s/2bk6FibYzZBK6ng/download)

```
# 릴리즈 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta-5.5.2/release/service

# 릴리즈 파일 다운로드 및 파일 경로 확인
$ ls ~/workspace/paasta-5.5.2/release/service
paasta-sourcecontrol-release-1.1.0.tgz
```
  
- 서버 환경에 맞추어 Deploy 스크립트 파일의 VARIABLES 설정을 수정하고 Option file 및 변수를 추가한다.  
     (추가) -o operations/use-offline-releases.yml (미리 다운받은 offline 릴리즈 사용)  
     (추가) -v releases_dir="<RELEASE_DIRECTORY>"  

     
> $ vi ~/workspace/paasta-5.5.2/deployment/service-deployment/source-control-service/deploy.sh
  
```
#!/bin/bash
  
# VARIABLES
COMMON_VARS_PATH="<COMMON_VARS_FILE_PATH>"	# common_vars.yml File Path (e.g. ../../common/common_vars.yml)
CURRENT_IAAS="${CURRENT_IAAS}"			# IaaS Information (PaaS-TA에서 제공되는 create-bosh-login.sh 미 사용시 aws/azure/gcp/openstack/vsphere 입력)
BOSH_ENVIRONMENT="${BOSH_ENVIRONMENT}"		# bosh director alias name (PaaS-TA에서 제공되는 create-bosh-login.sh 미 사용시 bosh envs에서 이름을 확인하여 입력)

# DEPLOY
bosh -e ${BOSH_ENVIRONMENT} -n -d source-control-service deploy --no-redact source-control-service.yml \
    -o operations/${CURRENT_IAAS}-network.yml \
    -o operations/cce.yml \
    -l ${COMMON_VARS_PATH} \
    -l vars.yml \
    -v releases_dir="/home/ubuntu/workspace/paasta-5.5.2/release"  
```  

- 서비스를 설치한다.  
```
$ cd ~/workspace/paasta-5.5.2/deployment/service-deployment/source-control-service   
$ sh ./deploy.sh  
```  

### <div id="2.7"/> 2.7. 서비스 설치 확인

설치 완료된 서비스를 확인한다.

> $ bosh -e micro-bosh -d source-control-service vms  

```
Using environment '10.0.1.6' as client 'admin'

Task 7847. Done

Deployment 'source-control-service'

Instance                                                   Process State  AZ  IPs            VM CID                                   VM Type  Active
haproxy/878b393c-d817-4e71-8fe5-553ddf87d362               running        z5  115.68.47.179  vm-cc4c774d-9857-4b3a-9ffc-5f836098eb4e  minimal  true
								              10.30.107.123
mariadb/90ea7861-57ed-43f7-853d-25712a67ba2a               running        z5  10.30.107.122  vm-6952fb76-b4d6-4f53-86cb-b0517a76f0d0  minimal  true
scm-server/6e23addc-33c7-4bb0-af95-d66420f15c06            running        z5  10.30.107.121  vm-08eb6dd3-04ae-435c-9558-9b78286b730c  minimal  true
sourcecontrol-api/3ecb90fa-2211-4df6-82bb-5c91ed9a4310     running        z5  10.30.107.125  vm-ee4daa28-3e10-4409-9d6f-ce566d54e8a5  minimal  true
sourcecontrol-broker/ec83edb5-130f-4a91-9ac1-20fb622ed0a2  running        z5  10.30.107.126  vm-23d1a9fc-30d2-4a0f-8631-df8807fc8612  minimal  true
sourcecontrol-webui/840278e2-e1a2-4a30-b904-68538c7cd06f   running        z5  10.30.107.124  vm-0f7300dd-63b5-4399-b1fd-35aeccffac5c  minimal  true

6 vms

Succeeded
```

## <div id="3"/>3.  형상관리 서비스 관리 및 신청

### <div id="3.1"/> 3.1. 서비스 브로커 등록

서비스의 설치가 완료 되면, PaaS-TA 포탈에서 서비스를 사용하기 위해 형상관리 서비스 브로커를 등록해 주어야 한다.  
서비스 브로커 등록 시에는 개방형 클라우드 플랫폼에서 서비스 브로커를 등록 할 수 있는 권한을 가진 사용자로 로그인 되어 있어야 한다. 

- 서비스 브로커 목록을 확인한다  
> $ cf service-brokers

```
Getting service brokers as admin...

name   url
No service brokers found
```

- 형상관리 서비스 브로커를 등록한다.
> $ cf create-service-broker [SERVICE_BROKER] [USERNAME] [PASSWORD] [SERVICE_BROKER_URL]  
> - [SERVICE_BROKER] : 서비스 브로커 명  
> - [USERNAME] / [PASSWORD] : 서비스 브로커에 접근할 수 있는 사용자 ID / PASSWORD  
> - [SERVICE_BROKER_URL] : 서비스 브로커 접근 URL

```
### e.g. 형상관리 서비스 브로커 등록
$ cf create-service-broker paasta-sourcecontrol-broker admin cloudfoundry http://10.30.107.126:8080
Creating service broker paasta-sourcecontrol-broker as admin...   
OK       
```

- 등록된 형상관리 서비스 브로커를 확인한다.  
> $ cf service-brokers

```
Getting service brokers as admin...

name                         url
paasta-sourcecontrol-broker   http://10.30.107.126:8080
```

- 형상관리 서비스의 서비스 접근 정보를 확인한다.  
> $ cf service-access -b paasta-sourcecontrol-broker  

```
Getting service access for broker paasta-sourcecontrol-broker as admin...
broker: paasta-sourcecontrol-broker
   service                  plan      access   orgs
   p-paasta-sourcecontrol   Default   none
```

- 형상관리 서비스의 서비스 접근 허용을 설정(전체)하고 서비스 접근 정보를 재확인 한다.  
> $ cf enable-service-access p-paasta-sourcecontrol    
> $ cf service-access -b paasta-sourcecontrol-broker   

```
$ cf enable-service-access p-paasta-sourcecontrol
Enabling access to all plans of service p-paasta-sourcecontrol for all orgs as admin...
OK

$ cf service-access -b paasta-sourcecontrol-broker 
Getting service access for broker paasta-sourcecontrol-broker as admin...
broker: paasta-sourcecontrol-broker
   service                  plan      access   orgs
   p-paasta-sourcecontrol   Default   all  
```

### <div id="3.2"/> 3.2. UAA Client 등록

- uaac server의 endpoint를 설정한다.

```
# endpoint 설정
$ uaac target https://uaa.<DOMAIN> --skip-ssl-validation

# target 확인
$ uaac target
Target: https://uaa.<DOMAIN>
Context: uaa_admin, from client uaa_admin

```

- uaac 로그인을 한다.

```
$ uaac token client get <UAA_ADMIN_CLIENT_ID> -s <UAA_ADMIN_CLIENT_SECRET>
Successfully fetched token via client credentials grant.
Target: https://uaa.<DOMAIN>
Context: admin, from client admin

```

- 형상관리 서비스 계정을 생성 한다.  
$ uaac client add <CF_UAA_CLIENT_ID> -s <CF_UAA_CLIENT_SECRET> --redirect_uri <형상관리서비스 대시보드 URI> --scope <퍼미션 범위> --authorized_grant_types <권한 타입> --authorities=<권한 퍼미션> --autoapprove=<자동승인권한>  

  - <CF_UAA_CLIENT_ID> : uaac 클라이언트 id  
  - <CF_UAA_CLIENT_SECRET> : uaac 클라이언트 secret  
  - <형상관리서비스 대시보드 URI> : 성공적으로 리다이렉션 할 형상관리서비스 대시보드 URI 
    ("http://<source-control-service의 haproxy public IP>:8080, http://<source-control-service의 haproxy public IP>:8080/repositories, http://<source-control-service의 haproxy public IP>:8080/repositories/user")  
  - <퍼미션 범위> : 클라이언트가 사용자를 대신하여 얻을 수있는 허용 범위 목록  
  - <권한 타입> : 서비스가 제공하는 API를 사용할 수 있는 권한 목록  
  - <권한 퍼미션> : 클라이언트에 부여 된 권한 목록  
  - <자동승인권한> : 사용자 승인이 필요하지 않은 권한 목록  

```  
# e.g. 형상관리 서비스 계정 생성
$ uaac client add scclient -s clientsecret --redirect_uri "http://115.68.47.179:8080 http://115.68.47.179:8080/repositories http://115.68.47.179:8080/repositories/user" \
  --scope "cloud_controller_service_permissions.read , openid , cloud_controller.read , cloud_controller.write , cloud_controller.admin" \
  --authorized_grant_types "authorization_code , client_credentials , refresh_token" \
  --authorities="uaa.resource" \
  --autoapprove="openid , cloud_controller_service_permissions.read"

# e.g. 형상관리 서비스 계정 생성 확인
$ uaac clients
scclient
    scope: cloud_controller.read cloud_controller.write cloud_controller_service_permissions.read openid
        cloud_controller.admin
    resource_ids: none
    authorized_grant_types: refresh_token client_credentials authorization_code
    redirect_uri: http://115.68.47.179:8080 http://115.68.47.179:8080/repositories http://115.68.47.179:8080/repositories/user
    autoapprove: cloud_controller_service_permissions.read openid
    authorities: uaa.resource
    name: scclient
    lastmodified: 1542894096080
```  

### <div id="3.3"/>  3.3. 서비스 신청  

- 형상관리 서비스 사용을 위해 서비스를 신청 한다.

> $ cf create-service [SERVICE] [PLAN] [SERVICE_INSTANCE] [-c PARAMETERS_AS_JSON]
> - [SERVICE] / [PLAN] : 서비스 명과 서비스 플랜
> - [SERVICE_INSTANCE] : 서비스 인스턴스 명 (내 서비스 목록에서 보여지는 명칭)
> - [-c PARAMETERS_AS_JSON] : JSON 형식의 파라미터 (형상관리 서비스 신청 시, owner, org_name 파라미터는 필수)

```
### e.g. 형상관리 서비스 신청
$ cf create-service p-paasta-sourcecontrol Default paasta-sourcecontrol -c '{"owner":"demo", "org_name":"demo"}'  
service                  plans                                   description  
paasta-sourcecontrol     Default                                 A paasta source control service for application development.provision parameters : parameters {owner : {owner}, org_name : {org_name}}  paasta-sourcecontrol-broker

### e.g. 형상관리 서비스 확인
$ cf services
Getting services in org system / space dev as admin...

name                    service                  plan            bound apps   last operation     broker                        upgrade available
paasta-sourcecontrol    p-paasta-sourcecontrol   Default                      create succeeded   paasta-sourcecontrol-broker
```

- 서비스 상세의 대시보드 URL 정보를 확인하여 서비스에 접근한다.
 ```
 ### 서비스 상세 정보의 Dashboard URL을 확인한다.
 $ cf service paasta-sourcecontrol
 ... (생략) ...
 Dashboard:        http://115.68.47.179:8080/repositories/user/b840ecb4-15fb-4b35-a9fc-185f42f0de37
 Service broker:   paasta-sourcecontrol-broker
 ... (생략) ...
 ```
 
[source_controller_service_guide01]:/service-guide/images/source-control/source_controller_service_guide01.PNG
