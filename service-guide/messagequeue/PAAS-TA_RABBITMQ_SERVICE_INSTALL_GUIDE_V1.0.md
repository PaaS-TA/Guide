## Table of Contents

1. [문서 개요](#1)   
  1.1. [목적](#1.1)   
  1.2. [범위](#1.2)   
  1.3. [시스템 구성도](#1.3)   
  1.4. [참고자료](#1.4)   

2. [RabbitMQ 서비스 설치](#2)  
  2.1. [Prerequisite](#2.1)   
  2.2. [Stemcell 확인](#2.2)    
  2.3. [Deployment 다운로드](#2.3)   
  2.4. [Deployment 파일 수정](#2.4)  
  2.5. [서비스 설치](#2.5)    
  2.6. [서비스 설치 - 다운로드 된 PaaS-TA Release 파일 이용 방식](#2.6)   
  2.7. [서비스 설치 확인](#2.7)  

3. [RabbitMQ 연동 Sample App 설명](#3)  
  3.1. [서비스 브로커 등록](#3.1)  
  3.2. [서비스 신청](#3.2)  
  3.3. [Sample App에 서비스 바인드 신청 및 App 확인](#3.3)  
     
## <div id='1'> 1. 문서 개요
### <div id='1.1'> 1.1. 목적
본 문서는 전자정부표준프레임워크 기반의 PaaS-TA에서 제공되는 서비스팩인 RabbitMQ 서비스팩을 Bosh를 이용하여 설치 하는 방법과 PaaS-TA의 SaaS 형태로 제공하는 Application에서 RabbitMQ 서비스를 사용하는 방법을 기술하였다.
PaaS-TA 3.5 버전부터는 Bosh2.0 기반으로 deploy를 진행하며 기존 Bosh1.0 기반으로 설치를 원할경우에는 PaaS-TA 3.1 이하 버전의 문서를 참고한다.

### <div id='1.2'> 1.2. 범위 
설치 범위는 RabbitMQ 서비스팩을 검증하기 위한 기본 설치를 기준으로 작성하였다. 

### <div id='1.3'> 1.3. 시스템 구성도
본 문서의 설치된 시스템 구성도이다. RabbitMQ(1대), RabbitMQ 서비스 브로커, haproxy로 최소사항을 구성하였다.

![시스템 구성도][rabbitmq_image_01]

<table>
  <tr>
    <td>구분</td>
    <td>스펙</td>
  </tr>
  <tr>
    <td>paasta-rmq-broker</td>
    <td>1vCPU / 1GB RAM / 8GB Disk</td>
  </tr>
  <tr>
    <td>haproxy</td>
    <td>1vCPU / 1GB RAM / 8GB Disk</td>
  </tr>
  <tr>
    <td>rmq</td>
    <td>1vCPU / 1GB RAM / 8GB Disk</td>
  </tr>
</table>


### <div id='1.4'> 1.4. 참고자료
[**http://bosh.io/docs**](http://bosh.io/docs)  
[**http://docs.cloudfoundry.org/**](http://docs.cloudfoundry.org/)


## <div id='2'> 2. RabbitMQ 서비스 설치

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

> $ vi ~/workspace/paasta-5.0/deployment/service-deployment/rabbitmq/vars.yml

```
# STEMCELL
stemcell_os: "ubuntu-xenial"                                # stemcell os
stemcell_version: "315.64"                                  # stemcell version

# VM_TYPE
vm_type_small: "minimal"                                    # vm type small 

# NETWORK
private_networks_name: "default"                            # private network name

# RABBITMQ
rabbitmq_azs: [z3]                                          # rabbitmq : azs
rabbitmq_instances: 1                                       # rabbitmq : instances (1) 
rabbitmq_private_ips: "<RABBITMQ_PRIVATE_IPS>"              # rabbitmq : private ips (e.g. "10.0.81.31")

# HAPROXY
haproxy_azs: [z3]                                           # haproxy : azs
haproxy_instances: 1                                        # haproxy : instances (1) 
haproxy_private_ips: "<HAPROXY_PRIVATE_IPS>"                # haproxy : private ips (e.g. "10.0.81.32")

# SERVICE-BROKER
broker_azs: [z3]                                            # service-broker : azs
broker_instances: 1                                         # service-broker : instances (1)
broker_private_ips: "<SERVICE_BROKER_PRIVATE_IPS>"          # service-broker : private ips (e.g. "10.0.81.33")
broker_port: 4567                                           # service-broker : broker port (e.g. "4567")

# BROKER-REGISTRAR
broker_registrar_azs: [z3]                                  # broker-registrar : azs
broker_registrar_instances: 1                               # broker-registrar : instances (1) 

# BROKER-DEREGISTRAR
broker_deregistrar_azs: [z3]                                # broker-deregistrar : azs
broker_deregistrar_instances: 1                             # broker-deregistrar : instances (1)
```

### <div id="2.5"/> 2.5. 서비스 설치

- 서버 환경에 맞추어 Deploy 스크립트 파일의 VARIABLES 설정을 수정한다. 

> $ vi ~/workspace/paasta-5.0/deployment/service-deployment/rabbitmq/deploy.sh

```
#!/bin/bash
  
# VARIABLES
BOSH_NAME="micro-bosh"                           # bosh name (e.g. micro-bosh)
IAAS="openstack"                                 # IaaS (e.g. aws/azure/gcp/openstack/vsphere)
COMMON_VARS_PATH="<COMMON_VARS_FILE_PATH>"       # common_vars.yml File Path (e.g. /home/ubuntu/paasta-5.0/common/common_vars.yml)

# DEPLOY
bosh -e ${BOSH_NAME} -n -d rabbitmq deploy --no-redact rabbitmq.yml \
    -l ${COMMON_VARS_PATH} \
    -l vars.yml
```

- 서비스를 설치한다.  
```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/rabbitmq  
$ sh ./deploy.sh  
```  

### <div id="2.6"/> 2.6. 서비스 설치 - 다운로드 된 PaaS-TA Release 파일 이용 방식

- 서비스 설치에 필요한 릴리즈 파일을 다운로드 받아 Local machine의 서비스 설치 작업 경로로 위치시킨다.  
  
  - 설치 릴리즈 파일 다운로드 : [paasta-rabbitmq-2.0.tgz](http://45.248.73.44/index.php/s/3eT2Zmia5Jww5Gx/download)

```
# 릴리즈 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta-5.0/release/service

# 릴리즈 파일 다운로드 및 파일 경로 확인
$ ls ~/workspace/paasta-5.0/release/service
paasta-rabbitmq-2.0.tgz
```
  
- 서버 환경에 맞추어 Deploy 스크립트 파일의 VARIABLES 설정을 수정하고 Option file 및 변수를 추가한다.  
     (추가) -o operations/use-compiled-releases.yml  
     (추가) -v inception_os_user_name="<HOME_USER_NAME>"  
     
> $ vi ~/workspace/paasta-5.0/deployment/service-deployment/rabbitmq/deploy.sh
  
```
#!/bin/bash
  
# VARIABLES
BOSH_NAME="micro-bosh"                           # bosh name (e.g. micro-bosh)
IAAS="openstack"                                 # IaaS (e.g. aws/azure/gcp/openstack/vsphere)
COMMON_VARS_PATH="<COMMON_VARS_FILE_PATH>"       # common_vars.yml File Path (e.g. /home/ubuntu/paasta-5.0/common/common_vars.yml)

# DEPLOY
bosh -e ${BOSH_NAME} -n -d rabbitmq deploy --no-redact rabbitmq.yml \
    -o operations/use-compiled-releases.yml \
    -l ${COMMON_VARS_PATH} \
    -l vars.yml \
    -v inception_os_user_name="ubuntu"  
```  

- 서비스를 설치한다.  
```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/rabbitmq  
$ sh ./deploy.sh  
```  

### <div id="2.7"/> 2.7. 서비스 설치 확인

설치 완료된 서비스를 확인한다.  

> $ bosh -e micro-bosh -d rabbitmq vms  

```
Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)

Task 8077. Done

Deployment 'rabbitmq'

Instance                                                Process State  AZ  IPs            VM CID                                   VM Type  Active  
haproxy/a30fb543-000d-4f74-b62d-7418da0e6101            running        z5  10.30.107.192  vm-fbd4a04a-5346-4e00-b793-17c327f90aa7  minimal  true  
paasta-rmq-broker/52629ddb-32c9-4097-b9f6-e5dc0aff55ce  running        z5  10.30.107.191  vm-5238f05b-ec4f-449c-ab1d-a1a5b932d76e  minimal  true  
rmq/a4ef4c7e-4776-411d-8317-b2b059e416dd                running        z5  10.30.107.193  vm-f8d8a62d-bfc4-442e-8306-9f133ebfc518  minimal  true  

3 vms

Succeeded
```

## <div id='3'> 3. RabbitMQ 연동 Sample App 설명

본 Sample App은 PaaS-TA에 배포되며 RabbitMQ의 서비스를 Provision과 Bind를 한 상태에서 사용이 가능하다.

### <div id='3.1'> 3.1. 서비스 브로커 등록 

RabbitMQ 서비스팩 배포가 완료 되었으면 Application에서 서비스 팩을 사용하기 위해서 먼저 RabbitMQ 서비스 브로커를 등록해 주어야 한다.
서비스 브로커 등록시에는 PaaS-TA에서 서비스 브로커를 등록할 수 있는 사용자로 로그인 하여야 한다

##### 서비스 브로커 목록을 확인한다.

```
$ cf service-brokers
Getting service brokers as admin...

name                    url
cubrid-service-broker   http://10.30.101.1:8080

```

<br>

##### rabbitmq 서비스 브로커를 등록한다.

>`$ cf create-service-broker {서비스팩 이름} {서비스팩 사용자ID} {서비스팩 사용자비밀번호} http://{서비스팩 URL(IP)}`
  
  **서비스팩 이름** : 서비스 팩 관리를 위해 PaaS-TA에서 보여지는 명칭이다. 서비스 Marketplace에서는 각각의 API 서비스 명이 보여지니 여기서 명칭은 서비스팩 리스트의 명칭이다.<br>
  **서비스팩 사용자ID** / 비밀번호 : 서비스팩에 접근할 수 있는 사용자 ID입니다. 서비스팩도 하나의 API 서버이기 때문에 아무나 접근을 허용할 수 없어 접근이 가능한 ID/비밀번호를 입력한다.<br>
  **서비스팩 URL** : 서비스팩이 제공하는 API를 사용할 수 있는 URL을 입력한다.


```
$ cf create-service-broker rabbitmq-service-broker admin admin http://10.30.53.33:4567
Creating service broker rabbitmq-service-broker as admin...
OK

```
<br>

##### 등록된 RabbitMQ 서비스 브로커를 확인한다.

>`$ cf service-brokers`

```
$ cf service-brokers
Getting service brokers as admin...

name                    url
cubrid-service-broker   http://10.30.101.1:8080
```
<br>

#### 접근 가능한 서비스 목록을 확인한다.

>`$ cf service-access`

```
$ cf service-access
Getting service access as admin...
broker: rabbitmq-service-broker
   service      plan       access   orgs
   p-rabbitmq   standard   none      
```

- 서비스 브로커 등록시 최초에는 접근을 허용하지 않는다. 따라서 access는 none으로 설정된다.

#### 특정 조직에 해당 서비스 접근 허용을 할당하고 접근 서비스 목록을 다시 확인한다. (전체 조직)

>`$ cf enable-service-access p-rabbitmq`

```
Enabling access to all plans of service p-rabbitmq for all orgs as admin...
OK

$ cf service-access
Getting service access as admin...
broker: rabbitmq-service-broker
   service      plan       access   orgs
   p-rabbitmq   standard   all      
```

### <div id='3.2'> 3.2. 서비스 신청
Sample App에서 RabbitMQ 서비스를 사용하기 위해서는 서비스 신청(Provision)을 해야 한다.
*참고: 서비스 신청시 PaaS-TA에서 서비스를 신청 할 수 있는 사용자로 로그인이 되어 있어야 한다.

#### 먼저 PaaS-TA Marketplace에서 서비스가 있는지 확인을 한다.

>`$ cf marketplace`

```
$ cf marketplace
getting services from marketplace in org system / space dev as admin...
OK

service      plans         description                                                                           broker
p-rabbitmq   standard      RabbitMQ is a robust and scalable high-performance multi-protocol messaging broker.   rabbitmq-service-broker

TIP: Use 'cf marketplace -s SERVICE' to view descriptions of individual plans of a given service.
```
<br>

#### Marketplace에서 원하는 서비스가 있으면 서비스 신청(Provision)을 한다.

>`$ cf create-service {서비스명} {서비스 플랜} {내 서비스명}`
- **서비스명** : p-rabbitmq로 Marketplace에서 보여지는 서비스 명칭이다.
- **서비스플랜** : 서비스에 대한 정책으로 plans에 있는 정보 중 하나를 선택한다. RabbitMQ 서비스는 standard plan만 지원한다.
- **내 서비스명** : 내 서비스에서 보여지는 명칭이다. 이 명칭을 기준으로 환경 설정 정보를 가져온다.

```
$ cf create-service p-rabbitmq standard my_rabbitmq_service
Creating service instance my_rabbitmq_service in org system / space dev as admin...
OK
```

<br>

#### 생성된 rabbitmq 서비스 인스턴스를 확인한다.

>`$ cf services`

```
$ cf services
Getting services in org system / space dev as admin...

name                  service      plan       bound apps   last operation     broker                    upgrade available
my_rabbitmq_service   p-rabbitmq   standard                create succeeded   rabbitmq-service-broker   
```

<br>

### <div id='3.3'> 3.3. Sample App에 서비스 바인드 신청 및 App 확인
서비스 신청이 완료되었으면 cf 에서 제공하는 rabbit-example-app을 다운로드해서 테스트를 진행한다.
* 참고: 서비스 Bind 신청시 PaaS-TA에서 서비스 Bind 신청 할 수 있는 사용자로 로그인이 되어 있어야 한다.

#### git을 통해 sample-app을 다운로드 한다.

```
$ git clone https://github.com/pivotal-cf/rabbit-example-app.git
Cloning into 'rabbit-example-app'...
remote: Enumerating objects: 297, done.
remote: Total 297 (delta 0), reused 0 (delta 0), pack-reused 297
Receiving objects: 100% (297/297), 10.59 MiB | 4.48 MiB/s, done.
Resolving deltas: 100% (87/87), done.
Checking connectivity... done
```

#### --no-start 옵션으로 App을 배포한다. 
--no-start: App 배포시 구동은 하지 않는다.

>`$cd rabbit-example-app`<br>

>`$cf push rabbit-example-app --no-start`<br>

```
$ cf push rabbit-example-app --no-start
Pushing from manifest to org system / space dev as admin...
Using manifest file /home/inception/workspace/user/cheolhan/rabbit-example-app/manifest.yml
Getting app info...
Creating app with these attributes...
+ name:       test-app
  path:       /home/inception/workspace/user/cheolhan/rabbit-example-app
+ command:    thin -R config.ru start
  routes:

Creating app test-app...
Mapping routes...
Comparing local files to remote cache...
Packaging files to upload...
Uploading files...
 3.24 MiB / 3.24 MiB [============================================================================================================================================================================================================================================] 100.00% 1s

Waiting for API to complete processing files...

name:              test-app
requested state:   stopped
routes:            test-app.115.68.47.178.xip.io
last uploaded:     
stack:             
buildpacks:        

type:            web
instances:       0/1
memory usage:    1024M
start command:   thin -R config.ru start
     state   since                  cpu    memory   disk     details
#0   down    2019-11-19T01:24:08Z   0.0%   0 of 0   0 of 0   
```

#### Sample App에서 생성한 서비스 인스턴스 바인드 신청을 한다. 

>`cf bind-service test-app my_rabbitmq_service`<br>

<br>

>(참고) 바인드 후 App구동시 Mysql 서비스 접속 에러로 App 구동이 안될 경우 보안 그룹을 추가한다.  

<br>

##### rule.json 화일을 만들고 아래와 같이 내용을 넣는다.
>`$ vi rule.json`

```json
[
  {
    "protocol": "all",
    "destination": "{haproxy_IP}"
  }
]
```
<br>

##### 보안 그룹을 생성한다.

>`$ cf create-security-group rabbitmq rule.json`

<br>

##### 모든 App에 Mysql 서비스를 사용할수 있도록 생성한 보안 그룹을 적용한다.

>`$ cf bind-running-security-group rabbitmq`

<br>



#### 바인드가 적용되기 위해서 App을 재기동한다.

>`cf restart test-app`

<br>

####  App이 정상적으로 RabbitMQ 서비스를 사용하는지 확인한다.


####  브라우저에서 확인
>`http://test-app.<YOUR_DOMAIN>/write`

>`http://test-app.<YOUR_DOMAIN>/read`

>![rabbitmq_image_12]

####  스토어 엔드포인트 테스트
>`curl -XPOST -d 'test' http://test-app.<YOUR-DOMAIN>/store`

>`curl -XGET http://test-app.<YOUR-DOMAIN>/store`

>![rabbitmq_image_13]

####  큐 엔드포인트 테스트
>`curl -XPOST -d 'test' http://test-app.<YOUR-DOMAIN>/queues/<YOUR-QUEUE-NAME>`

>`curl -XGET http://test-app.<YOUR-DOMAIN>/queues/<YOUR-QUEUE-NAME>`

>![rabbitmq_image_14]

[rabbitmq_image_01]:/service-guide/images/rabbitmq/rabbitmq_image_01.png

[rabbitmq_image_12]:/service-guide/images/rabbitmq/rabbitmq_image_12.png
[rabbitmq_image_13]:/service-guide/images/rabbitmq/rabbitmq_image_13.png
[rabbitmq_image_14]:/service-guide/images/rabbitmq/rabbitmq_image_14.png
[rabbitmq_image_15]:/service-guide/images/rabbitmq/rabbitmq_image_15.png
[rabbitmq_image_16]:/service-guide/images/rabbitmq/rabbitmq_image_16.png
[rabbitmq_image_17]:/service-guide/images/rabbitmq/rabbitmq_image_17.png
[rabbitmq_image_18]:/service-guide/images/rabbitmq/rabbitmq_image_18.png
[rabbitmq_image_19]:/service-guide/images/rabbitmq/rabbitmq_image_19.png
