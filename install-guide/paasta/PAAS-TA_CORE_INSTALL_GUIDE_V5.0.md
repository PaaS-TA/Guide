## Table of Contents

1. [개요](#101)  
　● [목적](#102)  
　● [범위](#103)  
　● [참고 자료](#104)  
2. [PaaS-TA 5.0](#105)  
3. [PaaS-TA 5.0 설치](#106)  
　3.1. [Prerequisite](#107)  
　3.2. [설치 파일 다운로드](#108)  
　3.3. [Stemcell 업로드](#109)  
　3.4. [Cloud Config 설정](#1010)  
　　●  [AZs](#1011)  
　　●  [VM types](#1012)  
　　●  [Compilation](#1013)  
　　●  [Disk Size](#1014)  
　　●  [Networks](#1015)  
　3.5. [Runtime Config 설정](#1016)  
　3.6. [PaaS-TA 환경 설정](#1017)  
　　3.6.1. [PaaS-TA 설치 Variable 파일](#1018)    
　　　●  [common_vars.yml](#1019)  
　　　●  [{IaaS}-vars.yml](#1020)  
　　　●  [PaaS-TA 그외 Variable List](#1021)  
　　3.6.2. [PaaS-TA Operation 파일](#1022)  
　　3.6.3. [PaaS-TA 설치 Shell Scripts](#1023)  
　　　●  [deploy-aws.sh](#1024)  
　　　●  [deploy-azure.sh](#1025)  
　　　●  [deploy-gcp.sh](#1026)  
　　　●  [deploy-openstack.sh](#1027)  
　　　●  [deploy-vsphere.sh](#1028)  
　　　●  [deploy-bosh-lite.sh](#1029)  
　3.7. [PaaS-TA 설치](#1030)  
　3.8. [PaaS-TA 설치 - 다운로드 된 Release 파일 이용 방식](#1031)  
　3.9. [PaaS-TA 로그인](#1032)  
● [통합 Monitoring을 적용한 PaaS-TA 5.0 설치](#1033)  

## Executive Summary

본 문서는 PaaS-TA 5.0(이하 PaaS-TA)을 수동으로 설치하기 위한 가이드를 제공하는 데 그 목적이 있다.

# <div id='101'/>1.  문서 개요 

## <div id='102'/>● 목적
본 문서는 Inception 환경(설치환경)에서 BOSH2(이하 BOSH) 설치 후, BOSH를 기반으로 PaaS-TA를 설치하기 위한 가이드를 제공하는 데 그 목적이 있다.

## <div id='103'/>● 범위
본 문서는 cf-deployment v9.5.0을 기준으로 작성되었다.  
PaaS-TA은 bosh-deployment를 기반으로 한 BOSH 환경에서 설치한다.  
PaaS-TA 설치 시 필요한 Stemcell은 기존 ubuntu-xenial-315.36에서 ubuntu-xenial-315.64로 변경되었다.

## <div id='104'/>● 참고 자료

본 문서는 Cloud Foundry의 BOSH Document와 Cloud Foundry Document를 참고로 작성하였다.

BOSH Document: [http://bosh.io](http://bosh.io)

Cloud Foundry Document: [https://docs.cloudfoundry.org](https://docs.cloudfoundry.org)

BOSH Deployment: [https://github.com/cloudfoundry/bosh-deployment](https://github.com/cloudfoundry/bosh-deployment)

CF Deployment: [https://github.com/cloudfoundry/cf-deployment](https://github.com/cloudfoundry/cf-deployment)

# <div id='105'/>2. PaaS-TA 5.0

PaaS-TA는 BOSH를 기반으로 설치된다. BOSH CLI를 사용하여 BOSH를 생성한 후, paasta-deployment로 PaaS-TA를 배포한다. 

PaaS-TA 3.1 버전까지는 PaaS-TA Container, Controller를 각각의 deployment로 설치했지만, PaaS-TA 3.5 버전부터 paasta-deployment 하나로 통합되었으며, 한 번에 PaaS-TA를 설치한다. 

![PaaSTa_BOSH_Use_Guide_Image2](https://github.com/PaaS-TA/Guide-5.0-Ravioli/blob/master/install-guide/paasta/images/bosh2.png)

# <div id='106'/>3. PaaS-TA 5.0 설치

## <div id='107'/>3.1. Prerequisite

- BOSH2 기반의 BOSH를 설치한다.
- PaaS-TA 설치는 BOSH를 설치한 Inception(설치 환경)에서 작업한다.


## <div id='108'/>3.2. 설치 파일 다운로드
- PaaS-TA를 설치하기 위한 deployment가 존재하지 않는다면 다운로드 받는다
```
$ cd ${HOME}/workspace/paasta-5.0/deployment
$ git clone https://github.com/PaaS-TA/common.git
$ git clone https://github.com/PaaS-TA/paasta-deployment.git 
```

## <div id='109'/>3.3. Stemcell 업로드
VM을 배포할 때 사용되는 Stemcell을 BOSH에 업로드할 경우 로컬 파일과 URL을 직접 입력하여 업로드, 두가지 방법을 사용할 수 있다.  
로컬 파일을 사용할 경우 PaaS-TA 사이트에서 [PaaS-TA Stemcell](https://paas-ta.kr/download/package) 파일을 내려받아 ${HOME}/workspace/paasta-5.0/stemcell 이하 디렉터리에 압축을 푼다.  
압축을 풀면 아래와 같이 ${HOME}/workspace/paasta-5.0/stemcell/paasta 디렉터리가 생성되며 릴리즈 파일(tgz)이 존재한다.

```
$ cd ${HOME}/workspace/paasta-5.0/stemcell/paasta
$ ls
bosh-stemcell-315.64-alicloud-kvm-ubuntu-xenial-go_agent.tgz  bosh-stemcell-315.64-google-kvm-ubuntu-xenial-go_agent.tgz     bosh-stemcell-315.64-vsphere-esxi-ubuntu-xenial-go_agent.tgz
bosh-stemcell-315.64-aws-xen-hvm-ubuntu-xenial-go_agent.tgz   bosh-stemcell-315.64-openstack-kvm-ubuntu-xenial-go_agent.tgz  bosh-stemcell-315.64-warden-boshlite-ubuntu-xenial-go_agent.tgz
bosh-stemcell-315.64-azure-hyperv-ubuntu-xenial-go_agent.tgz  bosh-stemcell-315.64-vcloud-esxi-ubuntu-xenial-go_agent.tgz
```

Stemcell은 배포 시 생성되는 PaaS-TA VM Base OS Image이며, PaaS-TA 5.0은 Ubuntu xenial stemcell 315.64를 기반으로 한다.  
BOSH 로그인 후 다음 명령어를 수행하여 Stemcell을 올린다.  
{director_name}은 BOSH 설치 시 사용한 Director 명이다.


- AWS

```
(로컬파일)
$ bosh -e {director_name} upload-stemcell ${HOME}/workspace/paasta-5.0/stemcell/paasta/bosh-stemcell-315.64-aws-xen-hvm-ubuntu-xenial-go_agent.tgz

(URL)
$ bosh -e {director_name} upload-stemcell https://s3.amazonaws.com/bosh-core-stemcells/315.64/bosh-stemcell-315.64-aws-xen-hvm-ubuntu-xenial-go_agent.tgz
```

- MS Azure

```
(로컬파일)
$ bosh -e {director_name} upload-stemcell ${HOME}/workspace/paasta-5.0/stemcell/paasta/bosh-stemcell-315.64-azure-hyperv-ubuntu-xenial-go_agent.tgz

(URL)
$ bosh -e {director_name} upload-stemcell https://bosh-core-stemcells.s3-accelerate.amazonaws.com/315.64/bosh-stemcell-315.64-azure-hyperv-ubuntu-xenial-go_agent.tgz
```

- Google Cloud Platform

```
(로컬파일)
$ bosh -e {director_name} upload-stemcell ${HOME}/workspace/paasta-5.0/stemcell/paasta/bosh-stemcell-315.64-google-kvm-ubuntu-xenial-go_agent.tgz

(URL)
$ bosh -e {director_name} upload-stemcell https://bosh-core-stemcells.s3-accelerate.amazonaws.com/315.64/bosh-stemcell-315.64-google-kvm-ubuntu-xenial-go_agent.tgz
```

- OpenStack

```
(로컬파일)
$ bosh -e {director_name} upload-stemcell ${HOME}/workspace/paasta-5.0/stemcell/paasta/bosh-stemcell-315.64-openstack-kvm-ubuntu-xenial-go_agent.tgz

(URL)
$ bosh -e {director_name} upload-stemcell https://s3.amazonaws.com/bosh-core-stemcells/315.64/bosh-stemcell-315.64-openstack-kvm-ubuntu-xenial-go_agent.tgz
```

- VMware vSphere

```
(로컬파일)
$ bosh -e {director_name} upload-stemcell ${HOME}/workspace/paasta-5.0/stemcell/paasta/bosh-stemcell-315.64-vsphere-esxi-ubuntu-xenial-go_agent.tgz

(URL)
$ bosh -e {director_name} upload-stemcell https://s3.amazonaws.com/bosh-core-stemcells/315.64/bosh-stemcell-315.64-vsphere-esxi-ubuntu-xenial-go_agent.tgz
```

- BOSH-LITE

```
(로컬파일)
$ bosh -e {director_name} upload-stemcell ${HOME}/workspace/paasta-5.0/stemcell/paasta/bosh-stemcell-315.64-warden-boshlite-ubuntu-xenial-go_agent.tgz

(URL)
$ bosh -e {director_name} upload-stemcell https://s3.amazonaws.com/bosh-core-stemcells/315.64/bosh-stemcell-315.64-warden-boshlite-ubuntu-xenial-go_agent.tgz
```

## <div id='1010'/>3.4. Cloud Config 설정

PaaS-TA를 설치하기 위한 IaaS 관련 Network, Storage, VM 관련 설정을 Cloud Config로 정의한다.  
PaaS-TA 설치 파일을 내려받으면 ${HOME}/workspace/paasta-5.0/deployment/paasta-deployment/cloud-config 디렉터리 이하에 IaaS별 Cloud Config 예제를 확인할 수 있으며, 예제를 참고하여 cloud-config.yml을 IaaS에 맞게 수정한다.  
PaaS-TA 배포 전에 Cloud Config를 BOSH에 적용해야 한다. 

- OpenStack을 기준으로 한 cloud-config.yml 예제

```
## azs :: 가용 영역(Availability Zone)을 정의한다.
azs:
- name: z1
  cloud_properties:
    availability_zone: zone1
- name: z2
  cloud_properties:
    availability_zone: zone2
- name: z3
  cloud_properties:
    availability_zone: zone3
- name: z4
  cloud_properties:
    availability_zone: zone1
- name: z5
  cloud_properties:
    availability_zone: zone2
- name: z6
  cloud_properties:
    availability_zone: zone3

## vm_type :: 가상머신 유형(VM Type)을 정의한다. (OpenStack의 경우, Flavor 설정)
vm_types:
- name: minimal
  cloud_properties:
    instance_type: m1.tiny
- name: default 
  cloud_properties:
    instance_type: m1.medium
- name: small
  cloud_properties:
    instance_type: m1.small
- name: medium
  cloud_properties:
    instance_type: m1.medium
- name: medium-memory-8GB
  cloud_properties:
    instance_type: m1.medium
- name: large
  cloud_properties:
    instance_type: m1.large
- name: xlarge
  cloud_properties:
    instance_type: m1.xlarge
- name: small-50GB
  cloud_properties:
    instance_type: m1.medium
- name: small-50GB-ephemeral-disk 
  cloud_properties:
    instance_type: m1.medium
- name: small-100GB-ephemeral-disk
  cloud_properties:
    instance_type: m1.large
- name: small-highmem-100GB-ephemeral-disk 
  cloud_properties:
    instance_type: m1.large
- name: small-highmem-16GB
  cloud_properties:
    instance_type: m1.large
- name: service_medium
  cloud_properties:
    instance_type: m1.medium
- name: service_medium_2G
  cloud_properties:
    instance_type: m1.medium
- name: portal_small
  cloud_properties:
    instance_type: m1.tiny
- name: portal_medium
  cloud_properties:
    instance_type: m1.small
- name: portal_large
  cloud_properties:
    instance_type: m1.small

## compilation :: 컴파일 가상머신이 생성될 가용 영역 및 가상머신 유형 등을 정의한다.
compilation:
  az: z3
  network: default
  reuse_compilation_vms: true
  vm_type: large
  workers: 5

## disk_types :: 디스크 유형(Disk Type, Persistent Disk)을 정의한다.
disk_types:
- disk_size: 1024
  name: default
- disk_size: 1024
  name: 1GB
- disk_size: 2048
  name: 2GB
- disk_size: 4096
  name: 4GB
- disk_size: 5120
  name: 5GB
- disk_size: 8192
  name: 8GB
- disk_size: 10240
  name: 10GB
- disk_size: 20480
  name: 20GB
- disk_size: 30720
  name: 30GB
- disk_size: 51200
  name: 50GB
- disk_size: 102400
  name: 100GB
- disk_size: 1048576
  name: 1TB

- cloud_properties:
    type: SSD1 
  disk_size: 2000
  name: 2GB_GP2
- cloud_properties:
    type: SSD1 
  disk_size: 5000
  name: 5GB_GP2
- cloud_properties:
    type: SSD1 
  disk_size: 10000
  name: 10GB_GP2
- cloud_properties:
    type: SSD1 
  disk_size: 50000
  name: 50GB_GP2

## networks :: 네트워크(Network)를 정의한다. (OpenStack의 경우, Subnet 및 Security Group, DNS, Gateway 설정)
networks:
- name: default
  subnets:
  - az: z1
    cloud_properties:
      name: random
      net_id: 51b96a68-aded-4e73-aa44-f44a812b9b30
      security_groups:
      - openpaas
    dns:
    - 8.8.8.8
    gateway: 10.20.10.1
    range: 10.20.10.0/24
    reserved:
    - 10.20.10.2 - 10.20.10.10
    static:
    - 10.20.10.11 - 10.20.10.30
  - az: z2
    cloud_properties:
      name: random
      net_id: 51b96a68-aded-4e73-aa44-f44a812b9b30
      security_groups:
      - openpaas
    dns:
    - 8.8.8.8
    gateway: 10.20.20.1
    range: 10.20.20.0/24
    reserved:
    - 10.20.20.2 - 10.20.20.10
    static:
    - 10.20.20.11 - 10.20.20.30
  - az: z3
    cloud_properties:
      name: random
      net_id: 51b96a68-aded-4e73-aa44-f44a812b9b30
      security_groups:
      - openpaas
    dns:
    - 8.8.8.8
    gateway: 10.20.30.1
    range: 10.20.30.0/24
    reserved:
    - 10.20.30.2 - 10.20.30.10
    static:
    - 10.20.30.11 - 10.20.30.30
  - az: z4
    cloud_properties:
      name: random
      net_id: 51b96a68-aded-4e73-aa44-f44a812b9b30
      security_groups:
      - openpaas
    dns:
    - 8.8.8.8
    gateway: 10.20.40.1
    range: 10.20.40.0/24
    reserved:
    - 10.20.40.2 - 10.20.40.10
    static:
    - 10.20.40.11 - 10.20.40.30
  
- name: vip 
  type: vip

- name: service_private
  subnets:
  - az: z5
    cloud_properties:
      name: random
      net_id: 51b96a68-aded-4e73-aa44-f44a812b9b30
      security_groups:
      - openpaas
    dns:
    - 8.8.8.8
    gateway: 10.20.50.1
    range: 10.20.50.0/24
    reserved:
    - 10.20.50.2 - 10.20.50.10
    static:
    - 10.20.50.11 - 10.20.50.30
  - az: z6
    cloud_properties:
      name: random
      net_id: 51b96a68-aded-4e73-aa44-f44a812b9b30
      security_groups:
      - openpaas
    dns:
    - 8.8.8.8
    gateway: 10.20.60.1
    range: 10.20.60.0/24
    reserved:
    - 10.20.60.2 - 10.20.60.10
    static:
    - 10.20.60.11 - 10.20.60.30

- name: vip
  type: vip

## vm_extentions :: 임의의 특정 IaaS 구성을 지정하는 가상머신 구성을 정의한다. (Security Groups 및 Load Balancers 등)
vm_extensions:
- cloud_properties:
    ports:
    - host: 3306
  name: mysql-proxy-lb
- name: cf-router-network-properties
- name: cf-tcp-router-network-properties
- name: diego-ssh-proxy-network-properties
- name: cf-haproxy-network-properties 
- cloud_properties:
    ephemeral_disk:
      size: 51200
      type: gp2
  name: small-50GB 
- cloud_properties:
    ephemeral_disk:
      size: 102400
      type: gp2
  name: small-highmem-100GB 

```

- Cloud Config 업데이트

```
$ bosh –e {director_name} update-cloud-config ${HOME}/workspace/paasta-5.0/deployment/paasta-deployment/cloud-config/{iaas}-cloud-config.yml
```

- Cloud Config 확인

```
$ bosh –e {director_name} cloud-config  
```

### <div id='1011'/>● AZs

PaaS-TA에서 제공되는 Cloud Config 예제는 z1 ~ z6까지 설정되어 있다.  
z1 ~ z3까지는 PaaS-TA VM이 설치되는 Zone이며, z4 ~ z6까지는 서비스가 설치되는 Zone으로 정의한다.  
3개 단위로 설정하는 이유는 서비스 3중화를 위해서이다.  
PaaS-TA를 설치하는 환경에 따라 다르게 설정해도 된다.

### <div id='1012'/>● VM Types

VM Type은 IaaS에서 정의된 VM Type이다. OpenStack의 경우에는 Flavor Type이다.

※ 다음은 OpenStack에서 정의한 Flavor Type이다.
![PaaSTa_FLAVOR_Image](https://github.com/PaaS-TA/Guide-5.0-Ravioli/blob/master/install-guide/paasta/images/flavor.png)

### <div id='1013'/>● Compilation
PaaS-TA 및 서비스 설치 시, PaaS-TA는 Compile VM을 생성하여 소스를 컴파일하고, PaaS-TA VM을 생성하여 컴파일된 파일을 대상 VM에 설치한다.  
컴파일이 끝난 VM은 삭제된다.

※ Worker 수는 Compile VM의 수로, 많을수록 컴파일 속도가 빨라진다.

### <div id='1014'/>● Disk Size
PaaS-TA 및 서비스가 설치되는 VM의 Persistent Disk Size이다.

### <div id='1015'/>● Networks
Networks는 AZ 별 Subnet Network, DNS, Security Groups, Network ID를 정의한다.  
보통 AZ 별로 256개의 IP를 정의할 수 있도록 Range Cider를 정의한다.

## <div id='1016'/>3.5. Runtime Config 설정
PaaS-TA 4.0부터 적용되는 부분으로 PaaS-TA Component에서 Consul이 대체된 Component이다.  
PaaS-TA Component 간의 통신을 위해 BOSH DNS 배포가 선행되어야 한다.


- Runtime Config 업데이트

```
$ cd ~/workspace/paasta-5.0/deployment/paasta-deployment/bosh
$ bosh -e {director_name} update-runtime-config -n runtime-configs/dns.yml
```

- Runtime Config 확인

```
$ bosh –e {director_name} runtime-config  
```

## <div id='1017'/>3.6.  PaaS-TA 환경 설정

${HOME}/workspace/paasta-5.0/deployment/paasta-deployment 이하 디렉터리에는 IaaS별 PaaS-TA 설치 Shell Script 파일이 존재하며, 이를 실행하여 PaaS-TA를 설치한다.  
파일명은 deploy-{IaaS}.sh이다.  
또한 common_vars.yml파일과 {IaaS}-vars.yml을 수정하여 BOSH 설치시 적용하는 변숫값을 변경할 수 있다.

<table>
<tr>
<td>common_vars.yml</td>
<td>PaaS-TA 및 각종 Service 설치시 적용하는 공통 변수 설정 파일</td>
</tr>
<tr>
<td>aws-vars.yml</td>
<td>AWS 환경에 PaaS-TA 설치시 적용하는 변숫값 설정 파일</td>
</tr>
<tr>
<td>azure-vars.yml</td>
<td>MS Azure 환경에 PaaS-TA 설치시 적용하는 변숫값 설정 파일</td>
</tr>
<tr>
<td>gcp-vars.yml</td>
<td>GCP(Google Cloud Platform) 환경에 PaaS-TA 설치시 적용하는 변숫값 설정 파일</td>
</tr>
<tr>
<td>openstack-vars.yml</td>
<td>OpenStack 환경에 PaaS-TA 설치시 적용하는 변숫값 설정 파일</td>
</tr>
<tr>
<td>vsphere-vars.yml</td>
<td>VMware vSphere 환경에 PaaS-TA 설치시 적용하는 변숫값 설정 파일</td>
</tr>
<tr>
<td>bosh-lite-vars.yml</td>
<td>BOSH-LITE 환경에 PaaS-TA 설치시 적용하는 변숫값 설정 파일</td>
</tr>
<tr>
<td>deploy-aws.sh</td>
<td>AWS 환경에 PaaS-TA 설치를 위한 Shell Script 파일</td>
</tr>
<tr>
<td>deploy-azure.sh</td>
<td>MS Azure 환경에 PaaS-TA 설치를 위한 Shell Script 파일</td>
</tr>
<tr>
<td>deploy-gcp.sh</td>
<td>GCP(Google Cloud Platform) 환경에 PaaS-TA 설치를 위한 Shell Script 파일</td>
</tr>
<tr>
<td>deploy-openstack.sh</td>
<td>OpenStack 환경에 PaaS-TA 설치를 위한 Shell Script 파일</td>
</tr>
<tr>
<td>deploy-vsphere.sh</td>
<td>VMware vSphere 환경에 PaaS-TA 설치를 위한 Shell Script 파일</td>
</tr>
<tr>
<td>deploy-bosh-lite.sh</td>
<td>BOSH-LITE 환경에 PaaS-TA 설치를 위한 Shell Script 파일</td>
</tr>
</table>

PaaS-TA 설치 시 명령어는 deploy로 시작한다.  
BOSH 명령어로 설치가 가능하며, IaaS 환경에 따라 Option이 달라진다.

- PaaS-TA 배포 BOSH 명령어 예시

```
$ bosh –e {director_name} –d paasta deploy {deploy.yml}
```

PaaS-TA 배포 시, 설치 Option을 추가해야 한다. 설치 Option에 대한 설명은 아래와 같다.

<table>
<tr>
<td>-e</td>
<td>BOSH Director 명</td>
</tr>
<tr>
<td>-d</td>
<td>Deployment 명 (기본값 paasta, 수정 시 다른 PaaS-TA 서비스에 영향을 준다.)</td>
</tr>   
<tr>
<td>-o</td>
<td>PaaS-TA 설치 시 적용하는 Option 파일로 IaaS별 속성, Haproxy 사용 여부, Database 설정 기능을 제공한다.
</td>
</tr>
<tr>
<td>-v</td>
<td>PaaS-TA 설치 시 적용하는 변숫값 또는 Option 파일에 변숫값을 설정할 경우 사용한다. Option 파일 속성에 따라 필수 또는 선택 항목으로 나뉜다.</td>
</tr>
<tr>
<td>-l, --var-file</td>
<td>YAML파일에 작성한 변수를 읽어올때 사용한다.</td>
</tr>
</table>

### <div id='1018'/>3.6.1. PaaS-TA 설치 Variable File


#### <div id='1019'/>● common_vars.yml
common 폴더에 있는 common_vars.yml PaaS-TA 및 각종 Service 설치시 적용하는 공통 변수 설정 파일이 존재한다.  
PaaS-TA를 설치할 때는 system_domain, paasta_admin_username, paasta_admin_password, uaa_client_admin_secret, uaa_client_portal_secret의 값을 변경 하여 설치 할 수 있다.


```
# BOSH INFO
bosh_url: "http://10.0.1.6"			# BOSH URL (e.g. "https://00.000.0.0")
bosh_client_admin_id: "admin"			# BOSH Client Admin ID
bosh_client_admin_secret: "ert7na4jpewscztsxz48"	# BOSH Client Admin Secret('echo $(bosh int ~/workspace/paasta-5.0/deployment/paasta-deployment/bosh/{iaas}/creds.yml --path /admin_password)' 명령어를 통해 확인 가능)
bosh_director_port: 25555			# BOSH Director Port
bosh_oauth_port: 8443				# BOSH OAuth Port

# PAAS-TA INFO
system_domain: "61.252.53.246.xip.io"		# Domain (xip.io를 사용하는 경우 HAProxy Public IP와 동일)
paasta_admin_username: "admin"			# PaaS-TA Admin Username
paasta_admin_password: "admin"			# PaaS-TA Admin Password
paasta_nats_ip: "10.0.1.121"
paasta_nats_port: 4222
paasta_nats_user: "nats"
paasta_nats_password: "7EZB5ZkMLMqT73h2JtxPv1fvh3UsqO"	# PaaS-TA Nats Password (CredHub 로그인후 'credhub get -n /micro-bosh/paasta/nats_password' 명령어를 통해 확인 가능)
paasta_nats_private_networks_name: "default"	# PaaS-TA Nats 의 Network 이름
paasta_database_ips: "10.0.1.123"		# PaaS-TA Database IP(e.g. "10.0.1.123")
paasta_database_port: 5524			# PaaS-TA Database Port(e.g. 5524)
paasta_cc_db_id: "cloud_controller"		# CCDB ID(e.g. "cloud_controller")
paasta_cc_db_password: "cc_admin"		# CCDB Password(e.g. "cc_admin")
paasta_uaa_db_id: "uaa"				# UAADB ID(e.g. "uaa")
paasta_uaa_db_password: "uaa_admin"		# UAADB Password(e.g. "uaa_admin")
paasta_api_version: "v3"


# UAAC INFO
uaa_client_admin_id: "admin"			# UAAC Admin Client Admin ID
uaa_client_admin_secret: "admin-secret"		# UAAC Admin Client에 접근하기 위한 Secret 변수
uaa_client_portal_secret: "clientsecret"	# UAAC Portal Client에 접근하기 위한 Secret 변수

# Monitoring INFO
metric_url: "10.0.161.101"			# Monitoring InfluxDB IP
syslog_address: "10.0.121.100"            	# Logsearch의 ls-router IP
syslog_port: "2514"                          	# Logsearch의 ls-router Port
syslog_transport: "relp"                        # Logsearch Protocol
saas_monitoring_url: "61.252.53.248"	   	# Pinpoint HAProxy WEBUI의 Public IP
monitoring_api_url: "61.252.53.241"        	# Monitoring-WEB의 Public IP

### Portal INFO
portal_web_user_ip: "52.78.88.252"
portal_web_user_url: "http://portal-web-user.52.78.88.252.xip.io" 

### ETC INFO
abacus_url: "http://abacus.61.252.53.248.xip.io"	# Abacus URL (e.g. "http://abacus.xxx.xxx.xxx.xxx.xip.io")
```

#### <div id='1020'/>● {IaaS}-vars.yml

PaaS-TA를 설치 할 때 적용되는 각종 변수값이나 배포 될 VM의 설정을 변경할 수 있다.

```
# SERVICE VARIABLE
deployment_name: paasta					# Deployment Name
network_name: default					# Default Network Name
inception_os_user_name: ubuntu				# Home User Name (Release File Path 설정 시 필요)
network_name: default					# 지정하지 않은 Default 네트워크
private_ip: "10.244.0.34"				# Proxy IP (BOSH-LITE 환경에서 설치 시 사용)
haproxy_public_ip: 52.78.32.153				# HAProxy IP (Public IP)
haproxy_public_network_name: vip			# PaaS-TA Public Network Name
haproxy_private_network_name: "private"			# PaaS-TA Private Network name(vSphere 환경에서 설치 중 use-haproxy-public-network-vsphere.yml 옵션 사용시 적용)	
cc_db_encryption_key: db-encryption-key			# Database Encryption Key (Version Upgrade 시 동일 KEY 필수)
uaa_database_password: uaa_admin			# UAA Database Password
cc_database_password: cc_admin				# CC Database Password
cert_days: 3650						# PaaS-TA 인증서 유효기간
uaa_login_logout_redirect_parameter_disable: false	
uaa_login_logout_redirect_parameter_whitelist: ["http://portal-web-user.15.165.2.88.xip.io","http://portal-web-user.15.165.2.88.xip.io/callback","http://portal-web-user.15.165.2.88.xip.io/login"]	# 포탈 페이지 이동을 위한 UAA Redirect Whitelist 등록 변수
uaa_login_branding_company_name: "PaaS-TA R&D"		# UAA 페이지 타이틀 명
uaa_login_branding_footer_legal_text: "Copyright © PaaS-TA R&D Foundation, Inc. 2017. All Rights Reserved."	# UAA 페이지 하단 영역 텍스트 
uaa_login_branding_product_logo: "iVBORw0KGgoAAAANSUhEUgAAAM0AAAAdCAYAAAAJguhGAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoV2luZG93cykiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6QUNDMTA1MTZCRDNBMTFFNjkzMTVEQjMxRkE5QjkxNUMiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6QUNDMTA1MTdCRDNBMTFFNjkzMTVEQjMxRkE5QjkxNUMiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpBQ0MxMDUxNEJEM0ExMUU2OTMxNURCMzFGQTlCOTE1QyIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpBQ0MxMDUxNUJEM0ExMUU2OTMxNURCMzFGQTlCOTE1QyIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Piy2YkgAAA9pSURBVHja7FwJeBRF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"	 		# UAA 페이지 로고 이미지 (Base64)
uaa_login_branding_square_logo: "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyhpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNi1jMTMyIDc5LjE1OTI4NCwgMjAxNi8wNC8xOS0xMzoxMzo0MCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6QkIwMjA5M0U5NEQ0MTFFNjk1M0FFQ0UxNkIxNEZFNjciIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6QkIwMjA5M0Q5NEQ0MTFFNjk1M0FFQ0UxNkIxNEZFNjciIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTUuNSAoV2luZG93cykiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpEMzRGNDdCNTgxNEIxMUU2QjJFODk1MEQzM0EzNkMxOSIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpEMzRGNDdCNjgxNEIxMUU2QjJFODk1MEQzM0EzNkMxOSIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Psx4+gAAAASbSURBVHja7FZ9aFVlGP8973vOud9Tt7nl1lzNOWailKkV/iEohYn2Vx/QHxKCQkUUmEFhREXQvxJGhSFRlERFhEk1K9PUjJk0dZJzzuGc+3B3997tfp3zfvScu0X4T1AQ/nPP5eGce17e5/l9PO9zL1lrcTMvgZt8VQFUAVQBVAE4KHbDZIYWq1P7dpiJwQ7HdYxZsOyiXLzmYxGvOwJZD6ICDFxQKQeKNgEyi6A8BYcUSE0CJKCpDkExikgyBmTLQJzXhIaVSejxfsjaZtDkeaD3M9iVu6ByKbiNc+GYsUtt5R/fPIzxoSaSUZhIADM9sN5c/WG707Z2r+jc8gJFvAz0/zOyhTrf9RImBptsOQ4bSA4P0Alma8hcOLAtOPnaT7pwbQXJ2H+vQsRaRzkis8+ci5wZAHb4+EYpErBFbgdWzpYJ1p8NHQeNnVuuj7/epca6N89spH9ZOAb+vZsf9B18Juj97osgkznk9+zfY0ojbeEaFd9tT0OV55lhycwJFGOpoxbkcoSAIxZClmHiXkCdD7/qLtr6BkSa/Z74xx6gFBOwvtSXf9mp+r5+mrJDt5IRMNIB+T5MtHHUXfvyFvnKltUbbP7KbRRzoDMSxHBp9hNetnLnTaE/6d/XmdLwUjuvuRtOKiNCALpQYWopDqMcOB43q/Zggusd6rf3PjF9X26ncr5GOGyxGwUZJiq4TmkyqXOjHXLXi8/l7eCRR0WUi3gWekowKxGaMyvjXzd+z0wp27tUjZ18TFiboljdALleNlTAEjdw4MKJp2CvdW/2T+/5VEz03FmRee4S8NECpljSUqTiv5U+53N9spM/o3TsrYN06dCDSDCLPCcb4apBaAdXjhkg3OOZmYgISLfMCdiWRPN1arz7Qzm//aCNd5wIVEPeyXZvs6d2v0N+UZhIDUztWqgreYjRiywk53QjHFzD9oI6H/mIrD4Pk0svKH+zo8tJX1hqonwCmLyeZFlzrET4pVJYQ3isgxf2iOZ3mokXWBkNlWyHbX3oLBVL31P//mcpKMFG50PVb4Y+fQZycoDJJBkAd75gFeU4bFPT2ei6nRvJls9W5qEZOrYoOLHvADIXOxHzWB62RGnoosfyJhlAimW07CNHRCK0TM6tBSX4BAlen7gASp8GBQo62XLF1G4S9ujRZuQGYNkWwX1C0Qh0jeu7i5Z/7tz7xPNCmOEZAIbP3/QgjK9a/F/3vY+x7vtlCMrjQoI3Oi4XTUE5c2CcGsDlo8XKRHhC2uJViOkxBltkLdirhnu+dToff0qd6LnDz11/wHHVLcKUha5bOCXdfA9aFh7y6u46g4aFQG4QfwPI9LGsNbD5aaHT57bq/sNPYuryCjLTDEJUpLbcmCTNjC0cllvFWrYHcWbd2idvX/+2bNq0m8HY4PhRFNrXYI6bBQpp2LZVMP2HYVIJuBEe541tQP4qnBsGh1FhIeO0rN6L1pUfmNFz99HIHxtsYXCZ1qoO0taTKgs+a4xAjguZmaLaVSNINHS5NUu+Eqn6HFTAeYIQGdtRRGW6KR/w+VkrXtM3zqrq3/IqgCqAKoCbDeBPAQYAvdcfKsxKtoUAAAAASUVORK5CYII="	# UAA 페이지 타이틀 로고 이미지 (Base64)
uaa_login_links_passwd: "http://portal-web-user.15.165.2.88.xip.io/resetpasswd"	# UAA 페이지에서 Reset Password 누를 시 이동하는 링크 주소
uaa_login_links_signup: "http://portal-web-user.15.165.2.88.xip.io/createuser"	# UAA 페이지에서 Create Account 누를 시 이동하는 링크 주소
uaa_client_portal_redirect_uri: "http://portal-web-user.15.165.2.88.xip.io,http://portal-web-user.15.165.2.88.xip.io/callback"	# UAA Portal Client의 Redirect URL 지정 변수, 포탈에서 로그인 버튼 클릭 후 UAA 페이지에서 성공적으로 로그인했을 경우 이동하는 URI 경로


# STEMCELL
stemcell_os: "ubuntu-xenial"				# Stemcell OS
stemcell_version: "315.64"				# Stemcell Version

# SMOKE-TEST
smoke_tests_azs: [z1]					# Smoke-Test 가용 존
smoke_tests_instances: 1				# Smoke-Test 인스턴스 수
smoke_tests_vm_type: minimal				# Smoke-Test VM 종류
smoke_tests_network: default				# Smoke-Test 네트워크

# NATS
nats_azs: [z1, z2]					# NATS 가용 존
nats_instances: 2					# NATS 인스턴스 수
nats_vm_type: minimal					# NATS VM 종류
nats_network: default					# NATS 네트워크

# ADAPTER
adapter_azs: [z1, z2]					# ADAPTER 가용 존
adapter_instances: 2					# ADAPTER 인스턴스 수
adapter_vm_type: minimal				# ADAPTER VM 종류
adapter_network: default				# ADAPTER 네트워크

# DATABASE
database_azs: [z1]					# DATABASE 가용 존
database_instances: 1					# DATABASE 인스턴스 수
database_vm_type: small					# DATABASE VM 종류
database_network: default				# DATABASE 네트워크
database_persistent_disk_type: 10GB			# DATABASE 영구 Disk 종류

# DIEGO-API
diego_api_azs: [z1, z2]					# DIEGO-API 가용 존
diego_api_instances: 2					# DIEGO-API 인스턴스 수
diego_api_vm_type: small				# DIEGO-API VM 종류
diego_api_network: default				# DIEGO-API 네트워크

# UAA
uaa_azs: [z1, z2]					# UAA 가용 존
uaa_instances: 2					# UAA 인스턴스 수
uaa_vm_type: minimal					# UAA VM 종류
uaa_network: default					# UAA 네트워크

# SINGLETON-BLOBSTORE
singleton_blobstore_azs: [z1]				# SINGLETON-BLOBSTORE 가용 존
singleton_blobstore_instances: 1			# SINGLETON-BLOBSTORE 인스턴스 수
singleton_blobstore_vm_type: small			# SINGLETON-BLOBSTORE VM 종류
singleton_blobstore_network: default			# SINGLETON-BLOBSTORE 네트워크
singleton_blobstore_persistent_disk_type: 100GB		# SINGLETON-BLOBSTORE 영구 Disk 종류

# API
api_azs: [z1, z2]					# API 가용 존
api_instances: 2					# API 인스턴스 수
api_vm_type: small					# API VM 종류
api_network: default					# API 네트워크
api_vm_extensions: [50GB_ephemeral_disk]		# API 영구 Disk 종류

# CC-WORKER
cc_worker_azs: [z1, z2]					# CC-WORKER 가용 존
cc_worker_instances: 2					# CC-WORKER 인스턴스 수
cc_worker_vm_type: minimal				# CC-WORKER VM 종류
cc_worker_network: default				# CC-WORKER 네트워크

# SCHEDULER
scheduler_azs: [z1, z2]					# SCHEDULER 가용 존
scheduler_instances: 2					# SCHEDULER 인스턴스 수
scheduler_vm_type: minimal				# SCHEDULER VM 종류
scheduler_network: default				# SCHEDULER 네트워크
scheduler_vm_extensions: [diego-ssh-proxy-network-properties] # SCHEDULER 영구 Disk 종류

# ROUTER
router_azs: [z1, z2]					# ROUTER 가용 존
router_instances: 2					# ROUTER 인스턴스 수
router_vm_type: minimal					# ROUTER VM 종류
router_network: default					# ROUTER 네트워크
router_vm_extensions: [cf-router-network-properties]	# ROUTER 영구 Disk 종류

# TCP-ROUTER
tcp_router_azs: [z1, z2]				# TCP-ROUTER 가용 존
tcp_router_instances: 2					# TCP-ROUTER 인스턴스 수
tcp_router_vm_type: minimal				# TCP-ROUTER VM 종류
tcp_router_network: default				# TCP-ROUTER 네트워크
tcp_router_vm_extensions: [cf-tcp-router-network-properties]	# TCP-ROUTER 영구 Disk 종류

# DOPPLER
doppler_azs: [z1, z2]					# DOPPLER 가용 존
doppler_instances: 4					# DOPPLER 인스턴스 수
doppler_vm_type: minimal				# DOPPLER VM 종류
doppler_network: default				# DOPPLER 네트워크

# DIEGO-CELL
diego_cell_azs: [z1, z2]				# DIEGO-CELL 가용 존
diego_cell_instances: 2					# DIEGO-CELL 인스턴스 수
diego_cell_vm_type: small-highmem-16GB			# DIEGO-CELL VM 종류
diego_cell_network: default				# DIEGO-CELL 네트워크
diego_cell_vm_extensions: [100GB_ephemeral_disk]	# DIEGO-CELL 영구 Disk 종류

# LOG-API
log_api_azs: [z1, z2]					# LOG-API 가용 존
log_api_instances: 2					# LOG-API 인스턴스 수
log_api_vm_type: minimal				# LOG-API VM 종류
log_api_network: default				# LOG-API 네트워크

# CREDHUB
credhub_azs: [z1, z2]					# CREDHUB 가용 존
credhub_instances: 2					# CREDHUB 인스턴스 수
credhub_vm_type: minimal				# CREDHUB VM 종류
credhub_network: default				# CREDHUB 네트워크

# ROTATE-CC-DATABASE-KEY
rotate_cc_database_key_azs: [z1]			# ROTATE-CC-DATABASE-KEY 가용 존
rotate_cc_database_key_instances: 1			# ROTATE-CC-DATABASE-KEY 인스턴스 수
rotate_cc_database_key_vm_type: minimal			# ROTATE-CC-DATABASE-KEY VM 종류
rotate_cc_database_key_network: default			# ROTATE-CC-DATABASE-KEY 네트워크

# HAPROXY
haproxy_azs: [z7]					# HAPROXY 가용 존
haproxy_instances: 1					# HAPROXY 인스턴스 수
haproxy_vm_type: minimal				# HAPROXY VM 종류
haproxy_network: default				# HAPROXY 네트워크
```


#### <div id='1021'/>● PaaS-TA 그외 Variable List

1. uaa_login_logout_redirect_parameter_whitelist : 포탈 페이지 이동을 위한 UAA Redirect Whitelist 등록 변수
```
ex) uaa_login_logout_redirect_parameter_whitelist=["{PaaS-TA PORTAL URI}","{PaaS-TA PORTAL URI}/callback","{PaaS-TA PORTAL URI}/login"]
```
> xip.io : 구글에서 지원해주는 임시 도메인, 기본 DNS 서버가 8.8.8.8로 설정되어야 한다.  
> xip.io를 사용하지 않고 DNS를 사용할 경우, Whitelist에 포탈 DNS, 포탈 DNS/callback, 포탈 DNS/login 세 개의 항목을 등록해야 한다.

2. uaa_login_links_passwd : UAA 페이지에서 Reset Password 버튼 클릭 시 이동하는 링크 주소

<img src="https://github.com/PaaS-TA/Guide-5.0-Ravioli/blob/master/install-guide/paasta/images/uaa-login.png" width="663px">

3. uaa_login_links_signup : UAA 페이지에서 Create Account 버튼 클릭 시 이동하는 링크 주소

<img src="https://github.com/PaaS-TA/Guide-5.0-Ravioli/blob/master/install-guide/paasta/images/uaa-login-2.png">

```
ex) uaa_login_links_signup="{PaaS-TA PORTAL URI}/createuser"
```

4. uaa_client_portal_redirect_uri : UAAC Portal Client의 Redirect URI 지정 변수, 포탈에서 로그인 버튼 클릭 후 UAA 페이지에서 로그인 성공 시 이동하는 URI
```
ex) uaa_client_portal_redirect_uri="{PaaS-TA PORTAL URI}, {PaaS-TA PORTAL URI}/callback"
```

5. uaa_client_portal_secret : UAAC Portal Client에 접근하기 위한 Secret 변수
```
ex) uaa_client_portal_secret="portalclient"

  paasta-portal deploy 파일 안의 portal_client_secret의 값과 일치해야 한다.
```
![PaaSTa_VALUE_Image](https://github.com/PaaS-TA/Guide-5.0-Ravioli/blob/master/install-guide/paasta/images/paasta-value.png)

6. uaa_client_admin_secret : UAAC Admin Client에 접근하기 위한 Secret 변수
```
ex) uaa_client_admin_secret="admin-secret"
```

- uaa_client_admin_secret 적용 확인 방법
    
    (1) PaaS-TA 설치 후 아래 명령어 실행한다.
    ```
    $ uaac target
    $ uaac token client get
    ```

    (2) 설정한 secret 값으로 admin token을 얻을 경우 아래와 같은 결과가 출력된다.
    ```
    ubuntu@inception:~$ uaac target
    
    Target: https://uaa.54.180.53.80.xip.io
    Context: admin, from client admin
    
    ubuntu@inception:~$ uaac token client get
    Client ID:  admin
    Client secret:  ************
    
    Successfully fetched token via client credentials grant.
    Target: https://uaa.54.180.53.80.xip.io
    Context: admin, from client admin
    ```



### <div id='1022'/>3.6.2. PaaS-TA Operation 파일

<table>
<tr>
<td>파일명</td>
<td>설명</td>
<td>요구사항</td>
</tr>
<tr>
<td>operations/use-compiled-releases.yml</td>
<td>PaaS-TA release에서 제공하는 파일로 다운로드 및 컴파일 없이 빠른 설치가 가능하다.</td>
<td></td>
</tr>
<tr>
<td>operations/use-postgres.yml</td>
<td>Database를 Postgres로 설치 <br> 
    - use-postgres.yml 미적용 시 MySQL 설치  <br>
    - 3.5 이전 버전에서 Migration 시 필수  
</td>
<td></td>
</tr>
<tr>
<td>operations/use-compiled-releases-postgres.yml</td>
<td>PaaS-TA release에서 제공하는 파일로 다운로드 및 컴파일 없이 Postgres의 빠른 설치가 가능하다.</td>
<td></td>
</tr>
<tr>
<td>operations/use-haproxy.yml</td>
<td>HAProxy 적용 <br>
    - IaaS에서 제공하는 LB를 사용하여 PaaS-TA 설치 시, Operation 파일을 제거하고 설치한다.
</td>
<td>Requires operation file: use-haproxy-public-network.yml <br>
    Requires value :  -v haproxy_private_ip
</td>
</tr>
<tr>
<td>operations/use-haproxy-public-network.yml</td>
<td>HAProxy Public Network 설정 <br>
    - IaaS에서 제공하는 LB를 사용하여 PaaS-TA 설치 시, Operation 파일을 제거하고 설치한다.
</td>
<td>Requires: use-haproxy.yml <br>
    Requires Value :  <br>
    -v haproxy_public_ip <br>
    -v haproxy_public_network_name
</td>
</tr>
<tr>
<td>operations/use-haproxy-public-network-vsphere.yml</td>
<td>HAProxy Public Network 설정 <br>
    - vsphere에서 사용하며, IaaS에서 제공하는 LB를 사용하여 PaaS-TA 설치 시, Operation 파일을 제거하고 설치한다.
</td>
<td>Requires: use-haproxy.yml <br>
    Requires Value :  <br>
    -v haproxy_public_ip <br>
    -v haproxy_public_network_name <br>
    -v haproxy_private_network_name
</td>
</tr>
<tr>
<td>operations/use-compiled-releases-haproxy.yml</td>
<td>PaaS-TA release에서 제공하는 파일로 다운로드 및 컴파일 없이 HAProxy의 빠른 설치가 가능하다.</td>
<td></td>
</tr>

</table>




### <div id='1023'/>3.6.3.   PaaS-TA 설치 Shell Scripts

paasta-deployment.yml 파일은 PaaS-TA를 배포하는 Manifest 파일이며, PaaS-TA VM에 대한 설치 정의를 하게 된다.  
PaaS-TA VM 중 singleton-blobstore, database의 AZs(zone)을 변경하면 조직(ORG), 스페이스(SPACE), 앱(APP) 정보가 모두 삭제된다. 

이미 설치된 PaaS-TA의 재배포 시, singleton-blobstore, database의 AZs(zone)을 변경하면 조직(ORG), 공간(SPACE), 앱(APP) 정보가 모두 삭제된다.

#### <div id='1024'/>● deploy-aws.sh
```
bosh -e {director_name} -d paasta -n deploy paasta-deployment.yml \	# PaaS-TA Manifest File
	-o operations/aws.yml \						# AWS 설정
	-o operations/use-compiled-releases.yml \			# PaaS-TA 설치시 공통 릴리즈 파일 Local 정보
	-o operations/use-haproxy.yml \					# HAProxy 적용
	-o operations/use-haproxy-public-network.yml \			# HAProxy Public Network 적용
	-o operations/use-compiled-releases-haproxy.yml \		# PaaS-TA 설치시 HAProxy 릴리즈 파일 Local 정보
	-o operations/use-postgres.yml \				# Database Type 설정 (3.5버전 이하에서 Migration 시 필수)
	-o operations/use-compiled-releases-postgres.yml \		# PaaS-TA 설치시 Postgres 릴리즈 파일 Local 정보
	-o operations/rename-network-and-deployment.yml \		# Rename Network and Deployment
	-l aws-vars.yml \						# AWS 환경에 PaaS-TA 설치시 적용하는 변숫값 설정 파일
	-l ../../common/common_vars.yml					# PaaS-TA 및 각종 Service 설치시 적용하는 공통 변수 설정 파일
```
#### <div id='1025'/>● deploy-azure.sh
```
bosh -e {director_name} -d paasta -n deploy paasta-deployment.yml \	# PaaS-TA Manifest File
	-o operations/azure.yml \					# MS Azure 설정
	-o operations/use-compiled-releases.yml \			# PaaS-TA 설치시 공통 릴리즈 파일 Local 정보
	-o operations/use-haproxy.yml \					# HAProxy 적용
	-o operations/use-haproxy-public-network.yml \			# HAProxy Public Network 적용
	-o operations/use-compiled-releases-haproxy.yml \		# PaaS-TA 설치시 HAProxy 릴리즈 파일 Local 정보
	-o operations/use-postgres.yml \				# Database Type 설정 (3.5버전 이하에서 Migration 시 필수)
	-o operations/use-compiled-releases-postgres.yml \		# PaaS-TA 설치시 Postgres 릴리즈 파일 Local 정보
	-o operations/rename-network-and-deployment.yml \		# Rename Network and Deployment
	-l azure-vars.yml \						# MS Azure 환경에 PaaS-TA 설치시 적용하는 변숫값 설정 파일
	-l ../../common/common_vars.yml					# PaaS-TA 및 각종 Service 설치시 적용하는 공통 변수 설정 파일
```

#### <div id='1026'/>● deploy-gcp.sh
```
bosh -e {director_name} -d paasta deploy paasta-deployment.yml \	# PaaS-TA Manifest File
	-o operations/use-compiled-releases.yml \			# PaaS-TA 설치시 공통 릴리즈 파일 Local 정보
	-o operations/use-haproxy.yml \					# HAProxy 적용
	-o operations/use-haproxy-public-network.yml \			# HAProxy Public Network 적용
	-o operations/use-compiled-releases-haproxy.yml \		# PaaS-TA 설치시 HAProxy 릴리즈 파일 Local 정보
	-o operations/use-postgres.yml \				# Database Type 설정 (3.5버전 이하에서 Migration 시 필수)
	-o operations/use-compiled-releases-postgres.yml \		# PaaS-TA 설치시 Postgres 릴리즈 파일 Local 정보
	-o operations/rename-network-and-deployment.yml \		# Rename Network and Deployment
	-l gcp-vars.yml \						# GCP 환경에 PaaS-TA 설치시 적용하는 변숫값 설정 파일
	-l ../../common/common_vars.yml					# PaaS-TA 및 각종 Service 설치시 적용하는 공통 변수 설정 파일
```

#### <div id='1027'/>● deploy-openstack.sh
```
bosh -e {director_name} -d paasta -n deploy paasta-deployment.yml \	# PaaS-TA Manifest File
	-o operations/openstack.yml \					# OpenStack 설정
	-o operations/use-compiled-releases.yml \			# PaaS-TA 설치시 공통 릴리즈 파일 Local 정보
	-o operations/use-haproxy.yml \					# HAProxy 적용
	-o operations/use-haproxy-public-network.yml \			# HAProxy Public Network 적용
	-o operations/use-compiled-releases-haproxy.yml \		# PaaS-TA 설치시 HAProxy 릴리즈 파일 Local 정보
	-o operations/use-postgres.yml \				# Database Type 설정 (3.5버전 이하에서 Migration 시 필수)
	-o operations/use-compiled-releases-postgres.yml \		# PaaS-TA 설치시 Postgres 릴리즈 파일 Local 정보
	-o operations/rename-network-and-deployment.yml \		# Rename Network and Deployment
	-l openstack-vars.yml \						# OpenStack 환경에 PaaS-TA 설치시 적용하는 변숫값 설정 파일
	-l ../../common/common_vars.yml					# PaaS-TA 및 각종 Service 설치시 적용하는 공통 변수 설정 파일
```

#### <div id='1028'/>● deploy-vsphere.sh
```
bosh -e {director_name} -d paasta -n deploy paasta-deployment.yml \	# PaaS-TA Manifest File
	-o operations/use-compiled-releases.yml \			# PaaS-TA 설치시 공통 릴리즈 파일 Local 정보
	-o operations/use-haproxy.yml \					# HAProxy 적용
	-o operations/use-haproxy-public-network-vsphere.yml \		# HAProxy Public Network 적용
	-o operations/use-compiled-releases-haproxy.yml \		# PaaS-TA 설치시 HAProxy 릴리즈 파일 Local 정보
	-o operations/use-postgres.yml \				# Database Type 설정 (3.5버전 이하에서 Migration 시 필수)
	-o operations/use-compiled-releases-postgres.yml \		# PaaS-TA 설치시 Postgres 릴리즈 파일 Local 정보
	-o operations/rename-network-and-deployment.yml \		# Rename Network and Deployment
	-l vsphere-vars.yml \						# vSphere 환경에 PaaS-TA 설치시 적용하는 변숫값 설정 파일
	-l ../../common/common_vars.yml					# PaaS-TA 및 각종 Service 설치시 적용하는 공통 변수 설정 파일
```

#### <div id='1029'/>● deploy-bosh-lite.sh
```
bosh -e {director_name} -d paasta -n deploy paasta-deployment.yml \	# PaaS-TA manifest file
	-o operations/bosh-lite.yml \					# BOSH-LITE 설정
	-o operations/use-compiled-releases.yml \			# PaaS-TA 설치시 공통 릴리즈 파일 Local 정보
	-o operations/use-postgres.yml \				# Database Type 설정 (3.5버전 이하에서 Migration 시 필수)
	-o operations/use-compiled-releases-postgres.yml \		# PaaS-TA 설치시 Postgres 릴리즈 파일 Local 정보
	-o operations/rename-network-and-deployment.yml \		# Rename Network and Deployment
	-l bosh-lite-vars.yml \						# BOSH-LITE 환경에 PaaS-TA 설치시 적용하는 변숫값 설정 파일
	-l ../../common_vars.yml					# PaaS-TA 및 각종 Service 설치시 적용하는 공통 변수 설정 파일
```

- Shell script 파일에 실행 권한 부여

```
$ chmod +x ${HOME}/workspace/paasta-5.0/deployment/paasta-deployment/paasta/*.sh
```



## <div id='1030'/>3.7.  PaaS-TA 설치
- 서버 환경에 맞추어 Deploy 스크립트 파일의 설정을 수정한다. 

> $ vi ${HOME}/workspace/paasta-5.0/deployment/paasta-deployment/paasta/deploy-aws.sh

```
bosh -e {director_name} -d paasta -n deploy paasta-deployment.yml \	# PaaS-TA Manifest File
	-o operations/aws.yml \						# AWS 설정
	-o operations/use-haproxy.yml \					# HAProxy 적용
	-o operations/use-haproxy-public-network.yml \			# HAProxy Public Network 적용
	-o operations/use-postgres.yml \				# Database Type 설정 (3.5버전 이하에서 Migration 시 필수)
	-o operations/rename-network-and-deployment.yml \		# Rename Network and Deployment
	-l aws-vars.yml \						# AWS 환경에 PaaS-TA 설치시 적용하는 변숫값 설정 파일
	-l ../../common/common_vars.yml					# PaaS-TA 및 각종 Service 설치시 적용하는 공통 변수 설정 파일
```
- PaaS-TA 설치 Shell Script 파일 실행 (BOSH 로그인 필요)

```
$ cd ${HOME}/workspace/paasta-5.0/deployment/paasta-deployment/paasta
$ ./deploy-{IaaS}.sh
```

- PaaS-TA 설치 확인

> $ bosh -e {director_name} vms -d paasta

```
ubuntu@inception:~$ bosh -e micro-bosh vms -d paasta
Using environment '10.0.1.6' as client 'admin'

Task 134. Done

Deployment 'paasta'

Instance                                                  Process State  AZ  IPs           VM CID               VM Type             Active
adapter/58948983-7e9b-4761-89bf-6f88a6b9c7e2              running        z1  10.0.1.123    i-076d0dfa6ec1f7d98  small               true
adapter/ffca4d6c-6ce4-4cf0-8084-39326e68c9eb              running        z2  10.0.41.122   i-0a61fc33453ec64d0  small               true
api/4b7cff7b-1e44-44eb-840b-732c754b921c                  running        z1  10.0.1.128    i-05767b58d1d4b957c  medium              true
api/da8ca5bd-e310-44b6-b54a-21865f7132bd                  running        z2  10.0.41.125   i-0ad626de643f5acb4  medium              true
cc-worker/7babe563-bc7a-434d-85a2-4fd67081cfd7            running        z2  10.0.41.126   i-01b845e22ffc1eb48  medium              true
cc-worker/a5475b17-af99-44dc-9241-1feb087010f3            running        z1  10.0.1.129    i-0c7e1f4e89871c8d7  medium              true
credhub/27d026fe-a409-4f4e-8a22-61f121a2aba8              running        z2  10.0.41.134   i-0570c6ce731340f08  small               true
credhub/c58fa66a-cff6-4532-9abd-d4ba3b31f60e              running        z1  10.0.1.137    i-048b62105a7373a3d  small               true
database/d4449c40-25e4-4422-ac33-3584fe70f7c3             running        z1  10.0.1.124    i-0408dcd38fb9e7346  medium              true
diego-api/3211715c-c2e3-4356-a9b0-30b5da9fb3b4            running        z2  10.0.41.123   i-09ab4c691aeb20d6a  small               true
diego-api/77e870de-e4fb-4737-82c5-5504e63df0a4            running        z1  10.0.1.125    i-097475fa6e44911ab  small               true
diego-cell/bd7cde8e-5424-4ded-8e6e-5f0513af7641           running        z2  10.0.41.132   i-0de8bdd034aaca50c  large-highmem-32GB  true
diego-cell/c14318c5-cd0f-4c9f-acd4-8ab8908c169e           running        z1  10.0.1.135    i-00feefaa1eb37afb0  large-highmem-32GB  true
doppler/10344617-d442-4e22-9af9-8cc35d8bf314              running        z2  10.0.41.130   i-0a831bffcf5d6c172  medium              true
doppler/45bbbd94-3d5f-44df-9f01-11f8cdeb48ea              running        z1  10.0.1.133    i-07ad774745c4c6ab7  medium              true
doppler/61fd7584-11be-442f-9c8a-2df1424121d8              running        z1  10.0.1.134    i-0ee286945a1939220  medium              true
doppler/89adaeb7-16ac-431e-9ba3-754e74308af7              running        z2  10.0.41.131   i-0f47381253fddd716  medium              true
haproxy/d645b06f-36eb-40d7-a828-8115794ca035              running        z7  10.0.0.121    i-0d3b17f8414573ebe  minimal             true
                                                                             54.180.53.80
log-api/c6d866b5-8350-427b-b873-cb7fbd5da943              running        z2  10.0.41.133   i-0c7de5da28f58f302  small               true
log-api/d8376424-360a-4f1b-9488-503f49fd8550              running        z1  10.0.1.136    i-07d78c5dc6d854f8e  small               true
nats/154e1623-9dfe-425f-8bea-90d9b444e1d7                 running        z1  10.0.1.122    i-0d2e6c416bd23047c  small               true
nats/9d8f7df6-c22c-4f8e-ae28-83dbe9fa0de1                 running        z2  10.0.41.121   i-0c2169e16e77af947  small               true
router/202e4d16-8044-4b47-8e7b-b6e827502b04               running        z1  10.0.1.131    i-0e08bd4fa4c54739c  small               true
router/bd268bbd-1619-441c-a401-72d3cd9e18da               running        z2  10.0.41.128   i-0d6ca756c81fec386  small               true
scheduler/33b5f3e2-83b4-4998-9e81-71cf60aaf82d            running        z1  10.0.1.130    i-0bbf05c84fc31e235  medium              true
scheduler/a0dbe4d2-6f81-4df6-992b-111e10014609            running        z2  10.0.41.127   i-0a8b481db3cd80036  medium              true
singleton-blobstore/d0aa4103-50f9-474d-b309-c0a0c402ad5c  running        z1  10.0.1.127    i-028ef29ff1c5c18ca  medium              true
tcp-router/7998c2be-d535-49ca-bba6-5477c6018d78           running        z1  10.0.1.132    i-027e51e7407ada6cd  small               true
tcp-router/e55653ea-cc33-4ead-b1d6-4b5f33fdb78b           running        z2  10.0.41.129   i-00fe2dda763b39cc9  small               true
uaa/6ea05760-f851-413a-b03d-cfe83885d935                  running        z2  10.0.41.124   i-0577911096858aa61  medium              true
uaa/d49ee04f-6f1f-4fbc-97ac-76419511b2e7                  running        z1  10.0.1.126    i-07938b838ca591170  medium              true

31 vms

Succeeded
```



## <div id='1031'/>3.8.  PaaS-TA 설치 - 다운로드 된 Release 파일 이용 방식


- 서비스 설치에 필요한 릴리즈 파일을 다운로드 받아 Local machine의 작업 경로로 위치시킨다.  
  
  - 설치 파일 다운로드 위치 : https://paas-ta.kr/download/package    

```
# 릴리즈 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta-5.0/release/paasta

# 릴리즈 파일 다운로드 및 파일 경로 확인
$ cd ${HOME}/workspace/paasta-5.0/release/paasta
$ ls
binary-buildpack-1.0.32-ubuntu-xenial-315.64-20190703-010740-177773032.tgz       loggregator-105.5-ubuntu-xenial-315.64-20190703-011056-709229397.tgz
bosh-dns-aliases-0.0.3-ubuntu-xenial-315.64-20190703-005917-45013255.tgz         loggregator-agent-3.9-ubuntu-xenial-315.64-20190703-011227-052700948.tgz
bpm-1.1.0-ubuntu-xenial-315.64-20190703-011218-840878281.tgz                     nats-27-ubuntu-xenial-315.64-20190703-011012-08860186.tgz
capi-1.83.0-ubuntu-xenial-315.64-20190703-011352-736036246.tgz                   nginx-buildpack-1.0.13-ubuntu-xenial-315.64-20190703-010158-078624017.tgz
cf-cli-1.16.0-ubuntu-xenial-315.64-20190703-010458-731652087.tgz                 nodejs-buildpack-1.6.51-ubuntu-xenial-315.64-20190703-010707-741053575.tgz
cf-networking-2.23.0-ubuntu-xenial-315.64-20190703-011056-823948638.tgz          php-buildpack-4.3.77-ubuntu-xenial-315.64-20190703-010303-196110232.tgz
cf-smoke-tests-40.0.112-ubuntu-xenial-315.64-20190709-042410-146373383.tgz       postgres-release-38.tgz
cf-syslog-drain-10.2-ubuntu-xenial-315.64-20190703-011055-842044104.tgz          pxc-0.18.0-ubuntu-xenial-315.64-20190705-211325-403851041.tgz
cflinuxfs3-0.113.0-ubuntu-xenial-315.64-20190708-232200-368636766.tgz            python-buildpack-1.6.34-ubuntu-xenial-315.64-20190703-010525-033925777.tgz
credhub-2.4.0-ubuntu-xenial-315.64-20190703-010939-442789426.tgz                 r-buildpack-1.0.10-ubuntu-xenial-315.64-20190703-010623-140937123.tgz
diego-2.34.0-ubuntu-xenial-315.64-20190703-011616-899984623.tgz                  routing-0.188.0-ubuntu-xenial-315.64-20190703-011414-513071207.tgz
dotnet-core-buildpack-2.2.12-ubuntu-xenial-315.64-20190703-010337-286489233.tgz  ruby-buildpack-1.7.40-ubuntu-xenial-315.64-20190703-010707-743703201.tgz
garden-runc-1.19.3-ubuntu-xenial-315.64-20190703-011651-220994654.tgz            silk-2.23.0-ubuntu-xenial-315.64-20190703-011145-360645247.tgz
go-buildpack-1.8.40-ubuntu-xenial-315.64-20190703-010359-639769006.tgz           staticfile-buildpack-1.4.43-ubuntu-xenial-315.64-20190703-010525-898602366.tgz
haproxy-boshrelease-9.6.1.tgz                                                    statsd-injector-1.10.0-ubuntu-xenial-315.64-20190703-010549-761652392.tgz
java-buildpack-4.19.1-ubuntu-xenial-315.64-20190709-145004-482509766.tgz         syslog-release-11.4.0.tgz
log-cache-2.2.2-ubuntu-xenial-315.64-20190703-011152-163727753.tgz               uaa-72.0-ubuntu-xenial-315.64-20190703-011111-665316203.tgz
```

- 서버 환경에 맞추어 Deploy 스크립트 파일의 설정을 수정한다. 

> $ vi ${HOME}/workspace/paasta-5.0/deployment/paasta-deployment/paasta/deploy-aws.sh

```
bosh -e {director_name} -d paasta -n deploy paasta-deployment.yml \
	-o operations/aws.yml \						
	-o operations/use-compiled-releases.yml \
	-o operations/use-haproxy.yml \					
	-o operations/use-haproxy-public-network.yml \			
	-o operations/use-compiled-releases-haproxy.yml \
	-o operations/use-postgres.yml \				
	-o operations/use-compiled-releases-postgres.yml \
	-o operations/rename-network-and-deployment.yml \		
	-l aws-vars.yml \						
	-l ../../common/common_vars.yml					
```
- PaaS-TA 설치 Shell Script 파일 실행 (BOSH 로그인 필요)

```
$ cd ${HOME}/workspace/paasta-5.0/deployment/paasta-deployment/paasta
$ ./deploy-{IaaS}.sh
```

- PaaS-TA 설치 확인

> $ bosh -e {director_name} vms -d paasta

```
ubuntu@inception:~$ bosh -e micro-bosh vms -d paasta
Using environment '10.0.1.6' as client 'admin'

Task 134. Done

Deployment 'paasta'

Instance                                                  Process State  AZ  IPs           VM CID               VM Type             Active
adapter/58948983-7e9b-4761-89bf-6f88a6b9c7e2              running        z1  10.0.1.123    i-076d0dfa6ec1f7d98  small               true
adapter/ffca4d6c-6ce4-4cf0-8084-39326e68c9eb              running        z2  10.0.41.122   i-0a61fc33453ec64d0  small               true
api/4b7cff7b-1e44-44eb-840b-732c754b921c                  running        z1  10.0.1.128    i-05767b58d1d4b957c  medium              true
api/da8ca5bd-e310-44b6-b54a-21865f7132bd                  running        z2  10.0.41.125   i-0ad626de643f5acb4  medium              true
cc-worker/7babe563-bc7a-434d-85a2-4fd67081cfd7            running        z2  10.0.41.126   i-01b845e22ffc1eb48  medium              true
cc-worker/a5475b17-af99-44dc-9241-1feb087010f3            running        z1  10.0.1.129    i-0c7e1f4e89871c8d7  medium              true
credhub/27d026fe-a409-4f4e-8a22-61f121a2aba8              running        z2  10.0.41.134   i-0570c6ce731340f08  small               true
credhub/c58fa66a-cff6-4532-9abd-d4ba3b31f60e              running        z1  10.0.1.137    i-048b62105a7373a3d  small               true
database/d4449c40-25e4-4422-ac33-3584fe70f7c3             running        z1  10.0.1.124    i-0408dcd38fb9e7346  medium              true
diego-api/3211715c-c2e3-4356-a9b0-30b5da9fb3b4            running        z2  10.0.41.123   i-09ab4c691aeb20d6a  small               true
diego-api/77e870de-e4fb-4737-82c5-5504e63df0a4            running        z1  10.0.1.125    i-097475fa6e44911ab  small               true
diego-cell/bd7cde8e-5424-4ded-8e6e-5f0513af7641           running        z2  10.0.41.132   i-0de8bdd034aaca50c  large-highmem-32GB  true
diego-cell/c14318c5-cd0f-4c9f-acd4-8ab8908c169e           running        z1  10.0.1.135    i-00feefaa1eb37afb0  large-highmem-32GB  true
doppler/10344617-d442-4e22-9af9-8cc35d8bf314              running        z2  10.0.41.130   i-0a831bffcf5d6c172  medium              true
doppler/45bbbd94-3d5f-44df-9f01-11f8cdeb48ea              running        z1  10.0.1.133    i-07ad774745c4c6ab7  medium              true
doppler/61fd7584-11be-442f-9c8a-2df1424121d8              running        z1  10.0.1.134    i-0ee286945a1939220  medium              true
doppler/89adaeb7-16ac-431e-9ba3-754e74308af7              running        z2  10.0.41.131   i-0f47381253fddd716  medium              true
haproxy/d645b06f-36eb-40d7-a828-8115794ca035              running        z7  10.0.0.121    i-0d3b17f8414573ebe  minimal             true
                                                                             54.180.53.80
log-api/c6d866b5-8350-427b-b873-cb7fbd5da943              running        z2  10.0.41.133   i-0c7de5da28f58f302  small               true
log-api/d8376424-360a-4f1b-9488-503f49fd8550              running        z1  10.0.1.136    i-07d78c5dc6d854f8e  small               true
nats/154e1623-9dfe-425f-8bea-90d9b444e1d7                 running        z1  10.0.1.122    i-0d2e6c416bd23047c  small               true
nats/9d8f7df6-c22c-4f8e-ae28-83dbe9fa0de1                 running        z2  10.0.41.121   i-0c2169e16e77af947  small               true
router/202e4d16-8044-4b47-8e7b-b6e827502b04               running        z1  10.0.1.131    i-0e08bd4fa4c54739c  small               true
router/bd268bbd-1619-441c-a401-72d3cd9e18da               running        z2  10.0.41.128   i-0d6ca756c81fec386  small               true
scheduler/33b5f3e2-83b4-4998-9e81-71cf60aaf82d            running        z1  10.0.1.130    i-0bbf05c84fc31e235  medium              true
scheduler/a0dbe4d2-6f81-4df6-992b-111e10014609            running        z2  10.0.41.127   i-0a8b481db3cd80036  medium              true
singleton-blobstore/d0aa4103-50f9-474d-b309-c0a0c402ad5c  running        z1  10.0.1.127    i-028ef29ff1c5c18ca  medium              true
tcp-router/7998c2be-d535-49ca-bba6-5477c6018d78           running        z1  10.0.1.132    i-027e51e7407ada6cd  small               true
tcp-router/e55653ea-cc33-4ead-b1d6-4b5f33fdb78b           running        z2  10.0.41.129   i-00fe2dda763b39cc9  small               true
uaa/6ea05760-f851-413a-b03d-cfe83885d935                  running        z2  10.0.41.124   i-0577911096858aa61  medium              true
uaa/d49ee04f-6f1f-4fbc-97ac-76419511b2e7                  running        z1  10.0.1.126    i-07938b838ca591170  medium              true

31 vms

Succeeded
```




## <div id='1032'/>3.9.  PaaS-TA 로그인 

CF CLI를 설치하고 PaaS-TA에 로그인한다.
CF API는 PaaS-TA 배포 시 지정했던 System Domain 명을 사용한다.

- CF CLI 설치

```
$ wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
$ echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
$ sudo apt update
$ sudo apt install cf-cli -y
$ cf --version
```

- CF API URL 설정

> $ cf api api.{system_domain} --skip-ssl-validation

```
ubuntu@inception:~$ cf api api.54.180.53.80.xip.io --skip-ssl-validation
Setting api endpoint to api.54.180.53.80.xip.io...
OK

api endpoint:   https://api.54.180.53.80.xip.io
api version:    2.138.0
```

- PaaS-TA 로그인

> $ cf login

```
ubuntu@inception:~$ cf login
API endpoint: https://api.54.180.53.80.xip.io

Email> admin

Password>
Authenticating...
OK

Select an org (or press enter to skip):
```

### <div id='1033'/> ● 통합 Monitoring을 적용한 PaaS-TA 5.0 설치
- [통합 Monitoring을 적용한 PaaS-TA 5.0 설치](../paasta-monitoring/PAAS-TA_CORE_MONITORING_INSTALL_GUIDE_V5.0.md)

[PaaSTa_BOSH_Use_Guide_Image1]:./images/bosh1.png
[PaaSTa_BOSH_Use_Guide_Image2]:./images/bosh2.png
[PaaSTa_FLAVOR_Image]:./images/flavor.png
[PaaSTa_UAA_LOGIN_Image]:./images/uaa-login.png
[PaaSTa_UAA_LOGIN_Image2]:./images/uaa-login-2.png
[PaaSTa_VALUE_Image]:./images/paasta-value.png
