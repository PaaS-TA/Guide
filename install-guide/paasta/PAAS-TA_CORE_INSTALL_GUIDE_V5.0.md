## Table of Contents

1. [개요](#1)  
　● [목적](#1.1)  
　● [범위](#1.2)  
　● [참고 자료](#1.3)  
2. [PaaS-TA 5.5.3 AP](#2)  
3. [PaaS-TA 5.5.3 AP 설치](#3)  
　3.1. [Prerequisite](#3.1)  
　3.2. [설치 파일 다운로드](#3.2)  
　3.3. [Stemcell 업로드](#3.3)  
　3.4. [Runtime Config 설정](#3.4)  
　3.5. [Cloud Config 설정](#3.5)  
　　●  [AZs](#3.5.1)  
　　●  [VM types](#3.5.2)  
　　●  [Compilation](#3.5.3)  
　　●  [Disk Size](#3.5.4)  
　　●  [Networks](#3.5.5)  
　3.6. [PaaS-TA AP 설치 파일](#3.6)  
　　3.6.1. [PaaS-TA AP 설치 Variable 파일](#3.6.1)    
　　　●  [common_vars.yml](#3.6.1.1)  
　　　●  [vars.yml](#3.6.1.2)  
　　　●  [PaaS-TA AP 그외 Variable List](#3.6.1.3)  
　　3.6.2. [PaaS-TA AP Operation 파일](#3.6.2)  
　　3.6.3. [PaaS-TA AP 설치 Shell Scripts](#3.6.3)  
　　　●  [deploy-aws.sh](#3.6.3.1)  
　　　●  [deploy-openstack.sh](#3.6.3.2)  
　3.7. [PaaS-TA AP 설치](#3.7)  
　3.8. [PaaS-TA AP 설치 - 다운로드 된 Release 파일 이용 방식](#3.8)  
　3.9. [PaaS-TA AP 로그인](#3.9)   

## Executive Summary

본 문서는 PaaS-TA 5.5.3 Application Platform(이하 PaaS-TA AP)을 수동으로 설치하기 위한 가이드를 제공하는 데 그 목적이 있다.

# <div id='1'/>1.  문서 개요 

## <div id='1.1'/>● 목적
본 문서는 Inception 환경(설치환경)에서 BOSH2(이하 BOSH) 설치 후, BOSH를 기반으로 Monitoring을 적용하지 않은 PaaS-TA AP를 설치하기 위한 가이드를 제공하는 데 그 목적이 있다.


## <div id='1.2'/>● 범위
본 문서는 cf-deployment v16.14.0을 기준으로 작성되었다.  
PaaS-TA AP는 bosh-deployment를 기반으로 한 BOSH 환경에서 설치한다.  

PaaS-TA AP 설치 시 필요한 Stemcell은 기존 ubuntu-xenial-621.94에서 ubuntu-xenial-621.125로 변경되었다.  

PaaS-TA AP는 VMware vSphere, Google Cloud Platform, Amazon Web Services EC2, OpenStack, Microsoft Azure 등의 IaaS를 지원한다.  

현재 PaaS-TA 5.5.3 AP에서 검증한 IaaS 환경은 AWS, OpenStack 환경이다.

## <div id='1.3'/>● 참고 자료

본 문서는 Cloud Foundry의 BOSH Document와 Cloud Foundry Document를 참고로 작성하였다.

BOSH Document: [http://bosh.io](http://bosh.io)

Cloud Foundry Document: [https://docs.cloudfoundry.org](https://docs.cloudfoundry.org)

BOSH Deployment: [https://github.com/cloudfoundry/bosh-deployment](https://github.com/cloudfoundry/bosh-deployment)

CF Deployment: [https://github.com/cloudfoundry/cf-deployment](https://github.com/cloudfoundry/cf-deployment)

# <div id='2'/>2. PaaS-TA 5.5.3 AP

PaaS-TA AP는 BOSH를 기반으로 설치된다. BOSH CLI를 사용하여 BOSH를 생성한 후, paasta-deployment로 PaaS-TA AP를 배포한다. 

PaaS-TA 3.1 버전까지는 PaaS-TA Container, Controller를 각각의 deployment로 설치했지만, PaaS-TA 3.5 버전부터 paasta-deployment 하나로 통합되었으며, 한 번에 PaaS-TA AP를 설치한다. 

![PaaSTa_BOSH_Use_Guide_Image2]  

# <div id='3'/>3. PaaS-TA 5.5.3 AP 설치
## <div id='3.1'/>3.1. Prerequisite

- BOSH2 기반의 BOSH를 설치한다.
- PaaS-TA AP 설치는 BOSH를 설치한 Inception(설치 환경)에서 작업한다.
- PaaS-TA AP 설치를 위해 BOSH LOGIN을 진행한다. ([BOSH 로그인](../bosh/PAAS-TA_BOSH2_INSTALL_GUIDE_V5.0.md#3.3.7))

## <div id='3.2'/>3.2. 설치 파일 다운로드
- PaaS-TA AP를 설치하기 위한 deployment가 존재하지 않는다면 다운로드 받는다

```
$ mkdir -p ~/workspace/paasta-5.5.3/deployment
$ cd ~/workspace/paasta-5.5.3/deployment
$ git clone https://github.com/PaaS-TA/common.git
$ cd ~/workspace/paasta-5.5.3/deployment
$ git clone https://github.com/PaaS-TA/paasta-deployment.git -b v5.6.0
```

## <div id='3.3'/>3.3. Stemcell 업로드
Stemcell은 배포 시 생성되는 PaaS-TA AP VM Base OS Image이며, PaaS-TA 5.5.3 AP는 Ubuntu xenial stemcell 621.125를 기반으로 한다.  
기본적인 Stemcell 업로드 명령어는 다음과 같다.  
```                     
$ bosh -e ${BOSH_ENVIRONMENT} upload-stemcell {URL}
```

PaaS-TA 5.5.3 AP는 Stemcell 업로드 스크립트를 지원하며, BOSH 로그인 후 다음 명령어를 수행하여 Stemcell을 올린다.  
BOSH_ENVIRONMENT는 BOSH 설치 시 사용한 Director 명이고, CURRENT_IAAS는 배포된 환경 IaaS(aws, azure, gcp, openstack, vsphere, 그외 입력시 bosh-lite)에 맞게 입력을 한다. 
<br>(PaaS-TA AP에서 제공되는 create-bosh-login.sh을 이용하여 BOSH LOGIN시 BOSH_ENVIRONMENT와 CURRENT_IAAS는 자동입력된다.)

- Stemcell 업로드 Script의 설정 수정 (BOSH_ENVIRONMENT 수정)

> $ vi ~/workspace/paasta-5.5.3/deployment/paasta-deployment/bosh/upload-stemcell.sh
```                     
#!/bin/bash
STEMCELL_VERSION=621.125
CURRENT_IAAS="${CURRENT_IAAS}"				# IaaS Information (PaaS-TA에서 제공되는 create-bosh-login.sh 미 사용시 aws/azure/gcp/openstack/vsphere 입력)
BOSH_ENVIRONMENT="${BOSH_ENVIRONMENT}"			# bosh director alias name (PaaS-TA에서 제공되는 create-bosh-login.sh 미 사용시 bosh envs에서 이름을 확인하여 입력)

if [[ ${CURRENT_IAAS} = "aws" ]]; then
        bosh -e ${BOSH_ENVIRONMENT} upload-stemcell https://s3.amazonaws.com/bosh-core-stemcells/${STEMCELL_VERSION}/bosh-stemcell-${STEMCELL_VERSION}-aws-xen-hvm-ubuntu-xenial-go_agent.tgz -n
elif [[ ${CURRENT_IAAS} = "azure" ]]; then
        bosh -e ${BOSH_ENVIRONMENT} upload-stemcell https://bosh-core-stemcells.s3-accelerate.amazonaws.com/${STEMCELL_VERSION}/bosh-stemcell-${STEMCELL_VERSION}-azure-hyperv-ubuntu-xenial-go_agent.tgz -n
elif [[ ${CURRENT_IAAS} = "gcp" ]]; then
        bosh -e ${BOSH_ENVIRONMENT} upload-stemcell https://bosh-core-stemcells.s3-accelerate.amazonaws.com/${STEMCELL_VERSION}/bosh-stemcell-${STEMCELL_VERSION}-google-kvm-ubuntu-xenial-go_agent.tgz -n
elif [[ ${CURRENT_IAAS} = "openstack" ]]; then
        bosh -e ${BOSH_ENVIRONMENT} upload-stemcell https://s3.amazonaws.com/bosh-core-stemcells/${STEMCELL_VERSION}/bosh-stemcell-${STEMCELL_VERSION}-openstack-kvm-ubuntu-xenial-go_agent.tgz -n
elif [[ ${CURRENT_IAAS} = "vsphere" ]]; then
        bosh -e ${BOSH_ENVIRONMENT} upload-stemcell https://s3.amazonaws.com/bosh-core-stemcells/${STEMCELL_VERSION}/bosh-stemcell-${STEMCELL_VERSION}-vsphere-esxi-ubuntu-xenial-go_agent.tgz -n
else
        bosh -e ${BOSH_ENVIRONMENT} upload-stemcell https://s3.amazonaws.com/bosh-core-stemcells/${STEMCELL_VERSION}/bosh-stemcell-${STEMCELL_VERSION}-warden-boshlite-ubuntu-xenial-go_agent.tgz -n
fi
```

- Stemcell 업로드 Script 실행

```
$ cd ~/workspace/paasta-5.5.3/deployment/paasta-deployment/bosh
$ source upload-stemcell.sh
```

- [PaaS-TA 5.5.3 AP 스템셀 통합 다운로드](https://nextcloud.paas-ta.org/index.php/s/axmrx6ddPBnJNZ8/download)  
- 만약 오프라인 환경에 저장한 스템셀을 사용 하고 싶다면, Stemcell을 저장 한 뒤 경로를 설정 후 Stemcell 업로드 Script를 실행한다. 

```  
# 폴더 생성 및 이동
$ mkdir -p ~/workspace/paasta-5.5.3/stemcell/paasta
$ cd ~/workspace/paasta-5.5.3/stemcell/paasta/

# 개별 Stemcell 다운로드 
## AWS의 경우
$ wget https://s3.amazonaws.com/bosh-core-stemcells/621.125/bosh-stemcell-621.125-aws-xen-hvm-ubuntu-xenial-go_agent.tgz

## AZURE의 경우
$ wget https://bosh-core-stemcells.s3-accelerate.amazonaws.com/621.125/bosh-stemcell-621.125-azure-hyperv-ubuntu-xenial-go_agent.tgz

## GCP의 경우
$ wget https://bosh-core-stemcells.s3-accelerate.amazonaws.com/621.125/bosh-stemcell-621.125-google-kvm-ubuntu-xenial-go_agent.tgz

## OPENSTACK의 경우
$ wget https://s3.amazonaws.com/bosh-core-stemcells/621.125/bosh-stemcell-621.125-openstack-kvm-ubuntu-xenial-go_agent.tgz

## VSHPERE의 경우
$ wget https://s3.amazonaws.com/bosh-core-stemcells/621.125/bosh-stemcell-621.125-vsphere-esxi-ubuntu-xenial-go_agent.tgz

## BOSH-LITE의 경우
$ wget https://s3.amazonaws.com/bosh-core-stemcells/621.125/bosh-stemcell-621.125-warden-boshlite-ubuntu-xenial-go_agent.tgz

# 통합 다운로드의 경우
$ cd ~/workspace/paasta-5.5.3
$ wget https://nextcloud.paas-ta.org/index.php/s/axmrx6ddPBnJNZ8/download  --content-disposition
$ unzip stemcell.zip
```

- 오프라인 Stemcell 업로드 Script의 설정 수정 (BOSH_ENVIRONMENT, STEMCELL_DIR 수정)

> $ vi ~/workspace/paasta-5.5.3/deployment/paasta-deployment/bosh/offline-upload-stemcell.sh
```                     
#!/bin/bash
STEMCELL_VERSION=621.125
STEMCELL_DIR="/home/ubuntu/workspace/paasta-5.5.3/stemcell/paasta"
CURRENT_IAAS="${CURRENT_IAAS}"				# IaaS Information (PaaS-TA에서 제공되는 create-bosh-login.sh 미 사용시 aws/azure/gcp/openstack/vsphere 입력, 미 입력시 bosh-lite)
BOSH_ENVIRONMENT="${BOSH_ENVIRONMENT}"			# bosh director alias name (PaaS-TA에서 제공되는 create-bosh-login.sh 미 사용시 bosh envs에서 이름을 확인하여 입력)

if [[ ${CURRENT_IAAS} = "aws" ]]; then
        bosh -e ${BOSH_ENVIRONMENT} upload-stemcell ${STEMCELL_DIR}/bosh-stemcell-${STEMCELL_VERSION}-aws-xen-hvm-ubuntu-xenial-go_agent.tgz -n
elif [[ ${CURRENT_IAAS} = "azure" ]]; then
        bosh -e ${BOSH_ENVIRONMENT} upload-stemcell ${STEMCELL_DIR}/bosh-stemcell-${STEMCELL_VERSION}-azure-hyperv-ubuntu-xenial-go_agent.tgz -n
elif [[ ${CURRENT_IAAS} = "gcp" ]]; then
        bosh -e ${BOSH_ENVIRONMENT} upload-stemcell ${STEMCELL_DIR}/bosh-stemcell-${STEMCELL_VERSION}-google-kvm-ubuntu-xenial-go_agent.tgz -n
elif [[ ${CURRENT_IAAS} = "openstack" ]]; then
        bosh -e ${BOSH_ENVIRONMENT} upload-stemcell ${STEMCELL_DIR}/bosh-stemcell-${STEMCELL_VERSION}-openstack-kvm-ubuntu-xenial-go_agent.tgz -n
elif [[ ${CURRENT_IAAS} = "vsphere" ]]; then
        bosh -e ${BOSH_ENVIRONMENT} upload-stemcell ${STEMCELL_DIR}/bosh-stemcell-${STEMCELL_VERSION}-vsphere-esxi-ubuntu-xenial-go_agent.tgz -n
else
        bosh -e ${BOSH_ENVIRONMENT} upload-stemcell ${STEMCELL_DIR}/bosh-stemcell-${STEMCELL_VERSION}-warden-boshlite-ubuntu-xenial-go_agent.tgz -n
fi
```

- 오프라인 Stemcell 업로드 Script 실행

```
$ cd ~/workspace/paasta-5.5.3/deployment/paasta-deployment/bosh
$ source offline-upload-stemcell.sh
```



## <div id='3.4'/>3.4. Runtime Config 설정 
Runtime config는 BOSH로 배포되는 VM에 적용되는 설정이다.
기본적인 Runtime Config 설정 명령어는 다음과 같다.  
```                     
$ bosh -e ${BOSH_ENVIRONMENT} update-runtime-config {PATH} --name={NAME}
```

PaaS-TA AP에서 적용하는 Runtime Config는 다음과 같다.  

- DNS Runtime Config  
  PaaS-TA 4.0부터 적용되는 부분으로 PaaS-TA Component에서 Consul이 대체된 Component이다.  
  PaaS-TA Component 간의 통신을 위해 BOSH DNS 배포가 선행되어야 한다.  

- OS Configuration Runtime Config  
  BOSH Linux OS 구성 릴리스를 이용하여 sysctl을 구성한다.  

PaaS-TA 5.5.3 AP는 Runtime Config 설정 스크립트를 지원하며, BOSH 로그인 후 다음 명령어를 수행하여 Runtime Config를 설정한다.  

  - Runtime Config 업데이트 Script 수정 (BOSH_ENVIRONMENT 수정)
> $ vi ~/workspace/paasta-5.5.3/deployment/paasta-deployment/bosh/update-runtime-config.sh
```                     
#!/bin/bash

BOSH_ENVIRONMENT="${BOSH_ENVIRONMENT}"			 # bosh director alias name (PaaS-TA에서 제공되는 create-bosh-login.sh 미 사용시 bosh envs에서 이름을 확인하여 입력)

bosh -e ${BOSH_ENVIRONMENT} update-runtime-config -n runtime-configs/dns.yml
bosh -e ${BOSH_ENVIRONMENT} update-runtime-config -n --name=os-conf runtime-configs/os-conf.yml
```
- Runtime Config 업데이트 Script 실행
```                     
$ cd ~/workspace/paasta-5.5.3/deployment/paasta-deployment/bosh
$ source update-runtime-config.sh
```

  - Runtime Config 확인  
  ```  
  $ bosh -e ${BOSH_ENVIRONMENT} runtime-config
  $ bosh -e ${BOSH_ENVIRONMENT} runtime-config --name=os-conf
  ```


- 만약 오프라인 환경에 저장한 릴리즈를 사용 하고 싶다면, 릴리즈를 저장 한 뒤 경로를 설정 후 update-runtime-config 업로드 Script를 실행한다. 
- [bosh-dns-release-1.27.0 다운로드](https://bosh.io/d/github.com/cloudfoundry/bosh-dns-release?v=1.29.0)
- [os-conf-release-22.1.1 다운로드](https://bosh.io/d/github.com/cloudfoundry/os-conf-release?v=22.1.1)

```  
# 폴더 생성 및 이동
$ mkdir -p ~/workspace/paasta-5.5.3/release/bosh
$ cd ~/workspace/paasta-5.5.3/release/bosh

# bosh-dns-release 1.29.0 다운로드 
$ wget https://bosh.io/d/github.com/cloudfoundry/bosh-dns-release?v=1.29.0 --content-disposition

# os-conf 22.1.1 다운로드 
$ wget https://bosh.io/d/github.com/cloudfoundry/os-conf-release?v=22.1.1 --content-disposition
```

- 오프라인 Runtime Config 업데이트 Script 수정 (BOSH_ENVIRONMENT, RELEASE_DIR 수정)

> $ vi ~/workspace/paasta-5.5.3/deployment/paasta-deployment/bosh/offline-update-runtime-config.sh
```                     
#!/bin/bash
  
BOSH_ENVIRONMENT="${BOSH_ENVIRONMENT}"                    # bosh director alias name (PaaS-TA에서 제공되는 create-bosh-login.sh 미 사용시 bosh envs에서 이름을 확인하여 입력)
RELEASE_DIR="/home/ubuntu/workspace/paasta-5.5.3/release" # Release Directory (offline으로 릴리즈 다운받아 사용시 설정)

bosh -e ${BOSH_ENVIRONMENT} update-runtime-config -n runtime-configs/dns-offline.yml \
                -v releases_dir=${RELEASE_DIR}
bosh -e ${BOSH_ENVIRONMENT} update-runtime-config -n --name=os-conf runtime-configs/os-conf-offline.yml \
                -v releases_dir=${RELEASE_DIR}
```

- 오프라인 Runtime Config 업데이트 Script 실행

```
$ cd ~/workspace/paasta-5.5.3/deployment/paasta-deployment/bosh
$ source offline-update-runtime-config.sh
```




## <div id='3.5'/>3.5. Cloud Config 설정

PaaS-TA AP를 설치하기 위한 IaaS 관련 Network, Storage, VM 관련 설정을 Cloud Config로 정의한다.  
PaaS-TA AP 설치 파일을 내려받으면 ~/workspace/paasta-5.5.3/deployment/paasta-deployment/cloud-config 디렉터리 이하에 IaaS별 Cloud Config 예제를 확인할 수 있으며, 예제를 참고하여 cloud-config.yml을 IaaS에 맞게 수정한다.  
PaaS-TA AP 배포 전에 Cloud Config를 BOSH에 적용해야 한다. 

- AWS을 기준으로 한 cloud-config.yml 예제

```
## azs :: 가용 영역(Availability Zone)을 정의한다.
azs:
- cloud_properties:
    availability_zone: ap-northeast-2a
  name: z1
- cloud_properties:
    availability_zone: ap-northeast-2a
  name: z2
- cloud_properties:
    availability_zone: ap-northeast-2a
  name: z3
- cloud_properties:
    availability_zone: ap-northeast-2a
  name: z4
- cloud_properties:
    availability_zone: ap-northeast-2a
  name: z5
- cloud_properties:
    availability_zone: ap-northeast-2a
  name: z6
- cloud_properties:
    availability_zone: ap-northeast-2a
  name: z7

## compilation :: 컴파일 가상머신이 생성될 가용 영역 및 가상머신 유형 등을 정의한다.
compilation:
  az: z4
  network: default
  reuse_compilation_vms: true
  vm_type: xlarge
  workers: 5


## disk_types :: 디스크 유형(Disk Type, Persistent Disk)을 정의한다.
disk_types:
- disk_size: 1024
  name: default
- disk_size: 1024
  name: 1GB
- disk_size: 2048
  name: 2GB
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
- disk_size: 512000
  name: 500GB
- cloud_properties:
    type: gp2
  disk_size: 20000
  name: 2GB_GP2
- cloud_properties:
    type: gp2
  disk_size: 50000
  name: 5GB_GP2
- cloud_properties:
    type: gp2
  disk_size: 100000
  name: 10GB_GP2
- cloud_properties:
    type: gp2
  disk_size: 500000
  name: 50GB_GP2

## networks :: 네트워크(Network)를 정의한다. (AWS 경우, Subnet 및 Security Group, DNS, Gateway 등 설정)
networks:
- name: default
  subnets:
  - az: z1
    cloud_properties:
      security_groups: paasta-v50-security
      subnet: subnet-XXXXXXXXXXXXXXXXX
    dns:
    - 8.8.8.8
    gateway: 10.0.1.1
    range: 10.0.1.0/24
    reserved:
    - 10.0.1.2 - 10.0.1.9
    static:
    - 10.0.1.10 - 10.0.1.120
  - az: z2
    cloud_properties:
      security_groups: paasta-v50-security
      subnet: subnet-XXXXXXXXXXXXXXXXX
    dns:
    - 8.8.8.8
    gateway: 10.1.41.1
    range: 10.1.41.0/24
    reserved:
    - 10.1.41.1 - 10.1.41.9
    static:
    - 10.1.41.10 - 10.1.41.120
  - az: z3
    cloud_properties:
      security_groups: paasta-v50-security
      subnet: subnet-XXXXXXXXXXXXXXXXX
    dns:
    - 8.8.8.8
    gateway: 10.2.81.1
    range: 10.2.81.0/24
    reserved:
    - 10.2.81.1 - 10.2.81.9
    static:
    - 10.2.81.10 - 10.2.81.120
  - az: z4
    cloud_properties:
      security_groups: paasta-v50-security
      subnet: subnet-XXXXXXXXXXXXXXXXX
    dns:
    - 8.8.8.8
    gateway: 10.3.121.1
    range: 10.3.121.0/24
    reserved:
    - 10.3.121.1 - 10.3.121.9
    static:
    - 10.3.121.10 - 10.3.121.120
  - az: z5
    cloud_properties:
      security_groups: paasta-v50-security
      subnet: subnet-XXXXXXXXXXXXXXXXX
    dns:
    - 8.8.8.8
    gateway: 10.4.161.1
    range: 10.4.161.0/24
    reserved:
    - 10.4.161.1 - 10.4.161.9
    static:
    - 10.4.161.10 - 10.4.161.120
  - az: z6
    cloud_properties:
      security_groups: paasta-v50-security
      subnet: subnet-XXXXXXXXXXXXXXXXX
    dns:
    - 8.8.8.8
    gateway: 10.5.201.1
    range: 10.5.201.0/24
    reserved:
    - 10.5.201.1 - 10.5.201.9
    static:
    - 10.5.201.10 - 10.5.201.120
  - az: z7
    cloud_properties:
      security_groups: paasta-v50-security
      subnet: subnet-XXXXXXXXXXXXXXXXX
    dns:
    - 8.8.8.8
    gateway: 10.6.0.1
    range: 10.6.0.0/24
    reserved:
    - 10.6.0.1 - 10.6.0.9
    static:
    - 10.6.0.10 - 10.6.0.120
  type: manual

- name: vip
  type: vip

properties:
  aws:
    access_key_id: 'XXXXXXXXXXXXXXXXXXX'
    default_key_name: aws-paasta-rnd-v50-inception.pem
    default_security_groups:
    - paasta-v50-security
    region: ap-northeast-2
    secret_access_key: 'XXXXXXXXXXXXXXXXXXXXXX'

## vm_extentions :: 임의의 특정 IaaS 구성을 지정하는 가상머신 구성을 정의한다. (Security Groups 및 Load Balancers 등)
vm_extensions:
- name: cf-router-network-properties
- name: cf-tcp-router-network-properties
- name: diego-ssh-proxy-network-properties
- name: cf-haproxy-network-properties
- cloud_properties:
    ephemeral_disk:
      size: 51200
      type: gp2
  name: 50GB_ephemeral_disk
- cloud_properties:
    ephemeral_disk:
      size: 102400
      type: gp2
  name: 100GB_ephemeral_disk
- name: ssh-proxy-and-router-lb
  cloud_properties:
    ports:
    - host: 80
    - host: 443
    - host: 2222

## vm_type :: 가상머신 유형(VM Type)을 정의한다. (AWS 경우, Instance type 설정)
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
- cloud_properties:
    ephemeral_disk:
      size: 50000
      type: gp2
    instance_type: t2.medium
  name: medium
- cloud_properties:
    ephemeral_disk:
      size: 50000
      type: gp2
    instance_type: t2.large
  name: large
- cloud_properties:
    ephemeral_disk:
      size: 50000
      type: gp2
    instance_type: t2.xlarge
  name: xlarge
- cloud_properties:
    ephemeral_disk:
      size: 30000
      type: gp2
    instance_type: t2.xlarge
  name: small-highmem-16GB
- cloud_properties:
    ephemeral_disk:
      size: 30000
      type: gp2
    instance_type: t2.2xlarge
  name: large-highmem-32GB
- cloud_properties:
    ephemeral_disk:
      size: 3000
      type: gp2
    instance_type: t2.small
  name: service_tiny
- cloud_properties:
    ephemeral_disk:
      size: 3000
      type: gp2
    instance_type: t2.small
  name: service_small
- cloud_properties:
    ephemeral_disk:
      size: 10000
      type: gp2
    instance_type: t2.small
  name: service_medium_1CPU_2G
- cloud_properties:
    ephemeral_disk:
      size: 8000
      type: gp2
    instance_type: t2.medium
  name: service_medium
- cloud_properties:
    ephemeral_disk:
      size: 10000
      type: gp2
    instance_type: t2.medium
  name: service_medium_2G
- cloud_properties:
    ephemeral_disk:
      size: 3000
      type: gp2
    instance_type: t2.small
  name: portal_tiny
- cloud_properties:
    ephemeral_disk:
      size: 3000
      type: gp2
    instance_type: t2.small
  name: portal_small
- cloud_properties:
    ephemeral_disk:
      size: 4096
      type: gp2
    instance_type: t2.small
  name: portal_medium
- cloud_properties:
    ephemeral_disk:
      size: 4096
      type: gp2
    instance_type: t2.small
  name: portal_large
- cloud_properties:
    ephemeral_dist:
      size: 4096
      type: gp2
    instance_type: t2.small
  name: caas_small
- cloud_properties:
    ephemeral_dist:
      size: 30000
      type: gp2
    instance_type: m4.xlarge
  name: caas_small_highmem
```

- Cloud Config 업데이트

```
$ bosh -e ${BOSH_ENVIRONMENT} update-cloud-config ~/workspace/paasta-5.5.3/deployment/paasta-deployment/cloud-config/{iaas}-cloud-config.yml
```

- Cloud Config 확인

```
$ bosh -e ${BOSH_ENVIRONMENT} cloud-config  
```

### <div id='3.5.1'/>● AZs

PaaS-TA AP에서 제공되는 Cloud Config 예제는 z1 ~ z6까지 설정되어 있다.  
z1 ~ z3까지는 PaaS-TA AP VM이 설치되는 Zone이며, z4 ~ z6까지는 서비스가 설치되는 Zone으로 정의한다.  
3개 단위로 설정하는 이유는 서비스 3중화를 위해서이다.  
PaaS-TA AP를 설치하는 환경에 따라 다르게 설정해도 된다.

### <div id='3.5.2'/>● VM Types

VM Type은 IaaS에서 정의된 VM Type이다.  

※ 다음은 AWS에서 정의한 Instance Type이다.
![PaaSTa_FLAVOR_Image]

### <div id='3.5.3'/>● Compilation
PaaS-TA AP 및 서비스 설치 시, PaaS-TA AP는 Compile VM을 생성하여 소스를 컴파일하고, PaaS-TA AP VM을 생성하여 컴파일된 파일을 대상 VM에 설치한다.  
컴파일이 끝난 VM은 삭제된다.

※ Worker 수는 Compile VM의 수로, 많을수록 컴파일 속도가 빨라진다.

### <div id='3.5.4'/>● Disk Size
PaaS-TA AP 및 서비스가 설치되는 VM의 Persistent Disk Size이다.

### <div id='3.5.5'/>● Networks
Networks는 AZ 별 Subnet Network, DNS, Security Groups, Network ID를 정의한다.  
보통 AZ 별로 256개의 IP를 정의할 수 있도록 Range Cider를 정의한다.


## <div id='3.6'/>3.6.  PaaS-TA AP 설치 파일

common_vars.yml파일과 vars.yml을 수정하여 PaaS-TA AP 설치시 적용하는 변수를 설정할 수 있다.

<table>
<tr>
<td>common_vars.yml</td>
<td>PaaS-TA AP 및 각종 Service 설치시 적용하는 공통 변수 설정 파일</td>
</tr>
<tr>
<td>vars.yml</td>
<td>PaaS-TA AP 설치시 적용하는 변수 설정 파일</td>
</tr>
<tr>
<td>deploy-aws.sh</td>
<td>AWS 환경에 PaaS-TA AP 설치를 위한 Shell Script 파일</td>
</tr>
<tr>
<td>deploy-openstack.sh</td>
<td>OpenStack 환경에 PaaS-TA AP 설치를 위한 Shell Script 파일</td>
</tr>
<tr>
<td>paasta-deployment.yml</td>
<td>PaaS-TA AP을 배포하는 Manifest 파일</td>
</tr>
</table>



### <div id='3.6.1'/>3.6.1. PaaS-TA AP 설치 Variable File


#### <div id='3.6.1.1'/>● common_vars.yml
~/workspace/paasta-5.5.3/deployment/common 폴더에 있는 common_vars.yml PaaS-TA AP 및 각종 Service 설치시 적용하는 공통 변수 설정 파일이 존재한다.  
PaaS-TA 5.5.3 AP 설치할 때는 system_domain, paasta_admin_username, paasta_admin_password, uaa_client_admin_secret, uaa_client_portal_secret, paasta_database_port의 값을 변경 하여 설치 할 수 있다.

> $ vi ~/workspace/paasta-5.5.3/deployment/common/common_vars.yml

```
# BOSH INFO
bosh_ip: "10.0.1.6"                        		# BOSH IP
bosh_url: "http://10.0.1.6"				# BOSH URL (e.g. "https://00.000.0.0")
bosh_client_admin_id: "admin"				# BOSH Client Admin ID
bosh_client_admin_secret: "ert7na4jpewsczt"		# BOSH Client Admin Secret('echo $(bosh int ~/workspace/paasta-5.5.3/deployment/paasta-deployment/bosh/{iaas}/creds.yml —path /admin_password))' 명령어를 통해 확인 가능)
bosh_director_port: 25555				# BOSH Director Port
bosh_oauth_port: 8443					# BOSH OAuth Port
bosh_version: 271.2					# BOSH version('bosh env' 명령어를 통해 확인 가능, on-demand service용, e.g. "271.2")

# PAAS-TA INFO
system_domain: "xx.xx.xxx.xxx.nip.io"			# Domain (nip.io를 사용하는 경우 HAProxy Public IP와 동일)
paasta_admin_username: "admin"				# PaaS-TA Admin Username
paasta_admin_password: "admin"				# PaaS-TA Admin Password
paasta_nats_ip: "10.0.1.121"				# PaaS-TA Nats IP(e.g. "10.0.1.121")
paasta_nats_port: 4222					# PaaS-TA Nats Port(e.g. "4222")
paasta_nats_user: "nats"				# PaaS-TA Nats User(e.g. "nats")
paasta_nats_password: "7EZB5ZkMLMqT73h2JtxPqO"		# PaaS-TA Nats Password (CredHub 로그인후 'credhub get -n /micro-bosh/paasta/nats_password' 명령어를 통해 확인 가능)
paasta_nats_private_networks_name: "default"		# PaaS-TA Nats 의 Network 이름
paasta_database_ips: "10.0.1.123"			# PaaS-TA Database IP(e.g. "10.0.1.123")
paasta_database_port: 5524				# PaaS-TA Database Port (e.g. 5524(postgresql)/13307(mysql)) -- Do Not Use "3306"&"13306" in mysql
paasta_cc_db_id: "cloud_controller"			# CCDB ID(e.g. "cloud_controller")
paasta_cc_db_password: "cc_admin"			# CCDB Password(e.g. "cc_admin")
paasta_uaa_db_id: "uaa"					# UAADB ID(e.g. "uaa")
paasta_uaa_db_password: "uaa_admin"			# UAADB Password(e.g. "uaa_admin")
paasta_api_version: "v3"


# UAAC INFO
uaa_client_admin_id: "admin"				# UAAC Admin Client Admin ID
uaa_client_admin_secret: "admin-secret"			# UAAC Admin Client에 접근하기 위한 Secret 변수
uaa_client_portal_secret: "clientsecret"		# UAAC Portal Client에 접근하기 위한 Secret 변수

# Monitoring INFO
metric_url: "10.0.161.101"				# Monitoring InfluxDB IP
elasticsearch_master_ip: "10.0.1.146"			# Logsearch의 elasticsearch master IP
elasticsearch_master_port: 9200				# Logsearch의 elasticsearch master Port
syslog_address: "10.0.121.100"            		# Logsearch의 ls-router IP
syslog_port: "2514"                          		# Logsearch의 ls-router Port
syslog_transport: "relp"                        	# Logsearch Protocol
saas_monitoring_url: "xx.xx.xxx.xxx"	   		# Pinpoint HAProxy WEBUI의 Public IP
monitoring_api_url: "xx.xx.xxx.xxx"        		# Monitoring-WEB의 Public IP

### Portal INFO
portal_web_user_ip: "52.78.88.252"
portal_web_user_url: "http://portal-web-user.xx.xx.xxx.xxx.nip.io" 

### ETC INFO
abacus_url: "http://abacus.xx.xx.xxx.xxx.nip.io"	# Abacus URL (e.g. "http://abacus.xxx.xxx.xxx.xxx.nip.io")
```

#### <div id='3.6.1.2'/>● vars.yml

PaaS-TA AP를 설치 할 때 적용되는 각종 변수값이나 배포 될 VM의 설정을 변경할 수 있다.

> $ vi ~/workspace/paasta-5.5.3/deployment/paasta-deployment/paasta/vars.yml
```
# SERVICE VARIABLE
deployment_name: "paasta"			# Deployment Name
network_name: "default"				# VM에 별도로 지정하지 않는 Default Network Name
releases_dir: "/home/ubuntu/workspace/paasta-5.5.3/release"	# Release Directory (offline으로 릴리즈 다운받아 사용시 설정)
haproxy_public_ip: "52.78.32.153"		# HAProxy IP (Public IP, HAproxy VM 배포시 필요)
haproxy_public_network_name: "vip"		# PaaS-TA Public Network Name
haproxy_private_network_name: "private" 	# PaaS-TA Private Network Name (vSphere use-haproxy-public-network-vsphere.yml 포함 배포시 설정 필요)
cc_db_encryption_key: "db-encryption-key"	# Database Encryption Key (Version Upgrade 시 동일 KEY 필수)
cert_days: 3650					# PaaS-TA 인증서 유효기간
private_ip: "10.244.0.34"   			# Proxy IP (Private IP, BOSH-LITE 사용시 설정 필요)
uaa_login_logout_redirect_parameter_disable: "false"	
uaa_login_logout_redirect_parameter_whitelist: ["http://portal-web-user.15.165.2.88.nip.io","http://portal-web-user.15.165.2.88.nip.io/callback","http://portal-web-user.15.165.2.88.nip.io/login"]	# 포탈 페이지 이동을 위한 UAA Redirect Whitelist 등록 변수
uaa_login_branding_company_name: "PaaS-TA R&D"	# UAA 페이지 타이틀 명
uaa_login_branding_footer_legal_text: "Copyright © PaaS-TA R&D Foundation, Inc. 2017. All Rights Reserved."	# UAA 페이지 하단 영역 텍스트 
uaa_login_branding_product_logo: "iVBORw0KGgoAAAANSUhEUgAAAM0AAAAdCAYAAAAJguhGAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoV2luZG93cykiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6QUNDMTA1MTZCRDNBMTFFNjkzMTVEQjMxRkE5QjkxNUMiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6QUNDMTA1MTdCRDNBMTFFNjkzMTVEQjMxRkE5QjkxNUMiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpBQ0MxMDUxNEJEM0ExMUU2OTMxNURCMzFGQTlCOTE1QyIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpBQ0MxMDUxNUJEM0ExMUU2OTMxNURCMzFGQTlCOTE1QyIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Piy2YkgAAA9pSURBVHja7FwJeBRF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"	 # UAA 페이지 로고 이미지 (Base64)
uaa_login_branding_square_logo: "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyhpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNi1jMTMyIDc5LjE1OTI4NCwgMjAxNi8wNC8xOS0xMzoxMzo0MCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6QkIwMjA5M0U5NEQ0MTFFNjk1M0FFQ0UxNkIxNEZFNjciIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6QkIwMjA5M0Q5NEQ0MTFFNjk1M0FFQ0UxNkIxNEZFNjciIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTUuNSAoV2luZG93cykiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpEMzRGNDdCNTgxNEIxMUU2QjJFODk1MEQzM0EzNkMxOSIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpEMzRGNDdCNjgxNEIxMUU2QjJFODk1MEQzM0EzNkMxOSIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Psx4+gAAAASbSURBVHja7FZ9aFVlGP8973vOud9Tt7nl1lzNOWailKkV/iEohYn2Vx/QHxKCQkUUmEFhREXQvxJGhSFRlERFhEk1K9PUjJk0dZJzzuGc+3B3997tfp3zfvScu0X4T1AQ/nPP5eGce17e5/l9PO9zL1lrcTMvgZt8VQFUAVQBVAE4KHbDZIYWq1P7dpiJwQ7HdYxZsOyiXLzmYxGvOwJZD6ICDFxQKQeKNgEyi6A8BYcUSE0CJKCpDkExikgyBmTLQJzXhIaVSejxfsjaZtDkeaD3M9iVu6ByKbiNc+GYsUtt5R/fPIzxoSaSUZhIADM9sN5c/WG707Z2r+jc8gJFvAz0/zOyhTrf9RImBptsOQ4bSA4P0Alma8hcOLAtOPnaT7pwbQXJ2H+vQsRaRzkis8+ci5wZAHb4+EYpErBFbgdWzpYJ1p8NHQeNnVuuj7/epca6N89spH9ZOAb+vZsf9B18Juj97osgkznk9+zfY0ojbeEaFd9tT0OV55lhycwJFGOpoxbkcoSAIxZClmHiXkCdD7/qLtr6BkSa/Z74xx6gFBOwvtSXf9mp+r5+mrJDt5IRMNIB+T5MtHHUXfvyFvnKltUbbP7KbRRzoDMSxHBp9hNetnLnTaE/6d/XmdLwUjuvuRtOKiNCALpQYWopDqMcOB43q/Zggusd6rf3PjF9X26ncr5GOGyxGwUZJiq4TmkyqXOjHXLXi8/l7eCRR0WUi3gWekowKxGaMyvjXzd+z0wp27tUjZ18TFiboljdALleNlTAEjdw4MKJp2CvdW/2T+/5VEz03FmRee4S8NECpljSUqTiv5U+53N9spM/o3TsrYN06dCDSDCLPCcb4apBaAdXjhkg3OOZmYgISLfMCdiWRPN1arz7Qzm//aCNd5wIVEPeyXZvs6d2v0N+UZhIDUztWqgreYjRiywk53QjHFzD9oI6H/mIrD4Pk0svKH+zo8tJX1hqonwCmLyeZFlzrET4pVJYQ3isgxf2iOZ3mokXWBkNlWyHbX3oLBVL31P//mcpKMFG50PVb4Y+fQZycoDJJBkAd75gFeU4bFPT2ei6nRvJls9W5qEZOrYoOLHvADIXOxHzWB62RGnoosfyJhlAimW07CNHRCK0TM6tBSX4BAlen7gASp8GBQo62XLF1G4S9ujRZuQGYNkWwX1C0Qh0jeu7i5Z/7tz7xPNCmOEZAIbP3/QgjK9a/F/3vY+x7vtlCMrjQoI3Oi4XTUE5c2CcGsDlo8XKRHhC2uJViOkxBltkLdirhnu+dToff0qd6LnDz11/wHHVLcKUha5bOCXdfA9aFh7y6u46g4aFQG4QfwPI9LGsNbD5aaHT57bq/sNPYuryCjLTDEJUpLbcmCTNjC0cllvFWrYHcWbd2idvX/+2bNq0m8HY4PhRFNrXYI6bBQpp2LZVMP2HYVIJuBEe541tQP4qnBsGh1FhIeO0rN6L1pUfmNFz99HIHxtsYXCZ1qoO0taTKgs+a4xAjguZmaLaVSNINHS5NUu+Eqn6HFTAeYIQGdtRRGW6KR/w+VkrXtM3zqrq3/IqgCqAKoCbDeBPAQYAvdcfKsxKtoUAAAAASUVORK5CYII="	# UAA 페이지 타이틀 로고 이미지 (Base64)
uaa_login_links_passwd: "http://portal-web-user.15.165.2.88.nip.io/resetpasswd"	# UAA 페이지에서 Reset Password 누를 시 이동하는 링크 주소
uaa_login_links_signup: "http://portal-web-user.15.165.2.88.nip.io/createuser"	# UAA 페이지에서 Create Account 누를 시 이동하는 링크 주소
uaa_client_portal_redirect_uri: "http://portal-web-user.15.165.2.88.nip.io,http://portal-web-user.15.165.2.88.nip.io/callback"	# UAA Portal Client의 Redirect URI 지정 변수, 포탈에서 로그인 버튼 클릭 후 UAA 페이지에서 성공적으로 로그인했을 경우 이동하는 URI 경로

syslog_custom_rule: 'if ($msg contains "DEBUG") then stop'	# [MONITORING] PaaS-TA Logging Agent에서 전송할 Custom Rule
syslog_fallback_servers: []					# [MONITORING] PaaS-TA Syslog Fallback Servers


# STEMCELL
stemcell_os: "ubuntu-xenial"		# Stemcell OS
stemcell_version: "621.125"		# Stemcell Version

# SMOKE-TEST
smoke_tests_azs: ["z1"]			# Smoke-Test 가용 존
smoke_tests_instances: 1		# Smoke-Test 인스턴스 수
smoke_tests_vm_type: "minimal"		# Smoke-Test VM 종류
smoke_tests_network: "default"		# Smoke-Test 네트워크

# NATS
nats_azs: ["z1", "z2"]			# Nats 가용 존
nats_instances: 2			# Nats 인스턴스 수
nats_vm_type: "minimal"			# Nats VM 종류
nats_network: "default"			# Nats 네트워크

# DATABASE
database_azs: ["z1"]			# Database 가용 존
database_instances: 1			# Database 인스턴스 수
database_vm_type: "small"		# Database VM 종류
database_network: "default"		# Database 네트워크
database_persistent_disk_type: "10GB"	# Database 영구 Disk 종류

# DIEGO-API
diego_api_azs: ["z1", "z2"]		# Diego-API 가용 존
diego_api_instances: 2			# Diego-API 인스턴스 수
diego_api_vm_type: "small"		# Diego-API VM 종류
diego_api_network: "default"		# Diego-API 네트워크

# UAA
uaa_azs: ["z1", "z2"]			# UAA 가용 존
uaa_instances: 2			# UAA 인스턴스 수
uaa_vm_type: "minimal"			# UAA VM 종류
uaa_network: "default"			# UAA 네트워크

# SINGLETON-BLOBSTORE
singleton_blobstore_azs: ["z1"]		# Singleton-Blobstore 가용 존
singleton_blobstore_instances: 1	# Singleton-Blobstore 인스턴스 수
singleton_blobstore_vm_type: "small"	# Singleton-Blobstore VM 종류
singleton_blobstore_network: "default"	# Singleton-Blobstore 네트워크
singleton_blobstore_persistent_disk_type: "100GB"	# Singleton-Blobstore 영구 Disk 종류

# API
api_azs: ["z1", "z2"]			# API 가용 존
api_instances: 2			# API 인스턴스 수
api_vm_type: "small"			# API VM 종류
api_network: "default"			# API 네트워크
api_vm_extensions: ["50GB_ephemeral_disk"]	# API VM 확장

# CC-WORKER
cc_worker_azs: ["z1", "z2"]		# CC-Worker 가용 존
cc_worker_instances: 2			# CC-Worker 인스턴스 수
cc_worker_vm_type: "minimal"		# CC-Worker VM 종류
cc_worker_network: "default"		# CC-Worker 네트워크

# SCHEDULER
scheduler_azs: ["z1", "z2"]		# Scheduler 가용 존
scheduler_instances: 2			# Scheduler 인스턴스 수
scheduler_vm_type: "minimal"		# Scheduler VM 종류
scheduler_network: "default"		# Scheduler 네트워크
scheduler_vm_extensions: ["diego-ssh-proxy-network-properties"] # Scheduler VM 확장

# ROUTER
router_azs: ["z1", "z2"]		# Router 가용 존
router_instances: 2			# Router 인스턴스 수
router_vm_type: "minimal"		# Router VM 종류
router_network: "default"		# Router 네트워크
router_vm_extensions: ["cf-router-network-properties"]	# Router VM 확장

# TCP-ROUTER
tcp_router_azs: ["z1", "z2"]		# TCP-Router 가용 존
tcp_router_instances: 2			# TCP-Router 인스턴스 수
tcp_router_vm_type: "minimal"		# TCP-Router VM 종류
tcp_router_network: "default"		# TCP-Router 네트워크
tcp_router_vm_extensions: ["cf-tcp-router-network-properties"]	# TCP-Router VM 확장

# DOPPLER
doppler_azs: ["z1", "z2"]		# Doppler 가용 존
doppler_instances: 4			# Doppler 인스턴스 수
doppler_vm_type: "minimal"		# Doppler VM 종류
doppler_network: "default"		# Doppler 네트워크

# DIEGO-CELL
diego_cell_azs: ["z1", "z2"]		# Diego-Cell 가용 존
diego_cell_instances: 3			# Diego-Cell 인스턴스 수
diego_cell_vm_type: "small-highmem-16GB"		# Diego-Cell VM 종류
diego_cell_network: "default"		# Diego-Cell 네트워크
diego_cell_vm_extensions: ["100GB_ephemeral_disk"]	# Diego-Cell VM 확장

# LOG-API
log_api_azs: ["z1", "z2"]		# Log-API 가용 존
log_api_instances: 2			# Log-API 인스턴스 수
log_api_vm_type: "minimal"		# Log-API VM 종류
log_api_network: "default"		# Log-API 네트워크

# CREDHUB
credhub_azs: ["z1", "z2"]		# CredHub 가용 존
credhub_instances: 2			# CredHub 인스턴스 수
credhub_vm_type: "minimal"		# CredHub VM 종류
credhub_network: "default"		# CredHub 네트워크

# ROTATE-CC-DATABASE-KEY
rotate_cc_database_key_azs: ["z1"]	# Rotate-CC-Database-Key 가용 존
rotate_cc_database_key_instances: 1	# Rotate-CC-Database-Key 인스턴스 수
rotate_cc_database_key_vm_type: "minimal"	# Rotate-CC-Database-Key VM 종류
rotate_cc_database_key_network: "default"	# Rotate-CC-Database-Key 네트워크

# HAPROXY
haproxy_azs: ["z7"]			# HAProxy 가용 존
haproxy_instances: 1			# HAProxy 인스턴스 수
haproxy_vm_type: "minimal"		# HAProxy VM 종류
haproxy_network: "default"		# HAProxy 네트워크
```


#### <div id='3.6.1.3'/>● PaaS-TA AP 그외 Variable List

1. uaa_login_logout_redirect_parameter_whitelist : 포탈 페이지 이동을 위한 UAA Redirect Whitelist 등록 변수

```
ex) uaa_login_logout_redirect_parameter_whitelist=["{PaaS-TA PORTAL URI}","{PaaS-TA PORTAL URI}/callback","{PaaS-TA PORTAL URI}/login"]
```

> nip.io : 임시 도메인, 기본 DNS 서버가 8.8.8.8로 설정되어야 한다.  
> nip.io를 사용하지 않고 DNS를 사용할 경우, Whitelist에 포탈 DNS, 포탈 DNS/callback, 포탈 DNS/login 세 개의 항목을 등록해야 한다.

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

![PaaSTa_VALUE_Image]

6. uaa_client_admin_secret : UAAC Admin Client에 접근하기 위한 Secret 변수

```
ex) uaa_client_admin_secret="admin-secret"
```

- uaa_client_admin_secret 적용 확인 방법

  (1) PaaS-TA AP 설치 후 아래 명령어 실행한다.

  ```
  $ uaac target
  $ uaac token client get
  ```

  (2) 설정한 secret 값으로 admin token을 얻을 경우 아래와 같은 결과가 출력된다.

  ```
  ubuntu@inception:~$ uaac target
  
  Target: https://uaa.54.180.53.80.nip.io
  Context: admin, from client admin
  
  ubuntu@inception:~$ uaac token client get
  Client ID:  admin
  Client secret:  ************
  
  Successfully fetched token via client credentials grant.
  Target: https://uaa.54.180.53.80.nip.io
  Context: admin, from client admin
  ```



### <div id='3.6.2'/>3.6.2. PaaS-TA AP Operation 파일

<table>
<tr>
<td>파일명</td>
<td>설명</td>
<td>요구사항</td>
</tr>
<tr>
<td>operations/use-compiled-releases.yml</td>
<td>인터넷이 연결된 환경에서 컴파일 없이 빠른 설치가 가능하다.</td>
<td></td>
</tr>
<tr>
<td>operations/use-offline-releases.yml</td>
<td>paasta-deployment.yml에서 사용되는 릴리즈를 오프라인에 저장된 릴리즈로 설치가 가능하다.</td>
<td>Requires value :  -v releases_dir</td>
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
<td>operations/use-offline-releases-postgres.yml</td>
<td>use-postgres.yml에서 사용되는 릴리즈를 오프라인에 저장된 릴리즈로 설치가 가능하다.</td>
<td>Requires: use-postgres.yml<br>
    Requires value :  -v releases_dir</td>
</tr>
<tr>
<td>operations/use-haproxy.yml</td>
<td>HAProxy 적용 <br>
    - IaaS에서 제공하는 LB를 사용하여 PaaS-TA AP 설치 시, Operation 파일을 제거하고 설치한다.
</td>
<td>Requires operation file: use-haproxy-public-network.yml <br>
    Requires value :  -v haproxy_private_ip
</td>
</tr>
<tr>
<td>operations/use-haproxy-public-network.yml</td>
<td>HAProxy Public Network 설정 <br>
    - IaaS에서 제공하는 LB를 사용하여 PaaS-TA AP 설치 시, Operation 파일을 제거하고 설치한다.
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
    - vsphere에서 사용하며, IaaS에서 제공하는 LB를 사용하여 PaaS-TA AP 설치 시, Operation 파일을 제거하고 설치한다.
</td>
<td>Requires: use-haproxy.yml <br>
    Requires Value :  <br>
    -v haproxy_public_ip <br>
    -v haproxy_public_network_name <br>
    -v haproxy_private_network_name
</td>
</tr>
<tr>
<td>operations/use-offline-releases-haproxy.yml</td>
<td>use-haproxy.yml에서 사용되는 릴리즈를 오프라인에 저장된 릴리즈로 설치가 가능하다.</td>
<td>Requires: use-haproxy.yml<br>
    Requires value :  -v releases_dir</td>
</tr>
<tr>
<td>operations/cce.yml</td>
<td>CCE 조치를 적용하여 설치한다.</td>
<td></td>
</tr>
<tr>
<td>operations/use-offline-releases-cce.yml</td>
<td>cce.yml에서 사용되는 릴리즈를 오프라인에 저장된 릴리즈로 설치가 가능하다.</td>
<td>Requires: cce.yml<br>
    Requires value :  -v releases_dir</td>
</tr>
</table>

### <div id='3.6.3'/>3.6.3.   PaaS-TA AP설치 Shell Scripts
paasta-deployment.yml 파일은 PaaS-TA AP를 배포하는 Manifest 파일이며, PaaS-TA AP VM에 대한 설치 정의를 하게 된다.  
PaaS-TA AP VM 중 singleton-blobstore, database의 AZs(zone)을 변경하면 조직(ORG), 스페이스(SPACE), 앱(APP) 정보가 모두 삭제된다. 

이미 설치된 PaaS-TA AP의 재배포 시, singleton-blobstore, database의 AZs(zone)을 변경하면 조직(ORG), 공간(SPACE), 앱(APP) 정보가 모두 삭제된다.

**※ PaaS-TA AP 설치 시 명령어는 BOSH deploy를 사용한다. (IaaS 환경에 따라 Option이 다름)**

PaaS-TA AP 배포 BOSH 명령어 예시

```
$ bosh -e ${BOSH_ENVIRONMENT} -d paasta deploy paasta-deployment.yml
```

PaaS-TA AP 배포 시, 설치 Option을 추가해야 한다. 설치 Option에 대한 설명은 아래와 같다.

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
<td>PaaS-TA 설치 시 적용하는 변수 또는 Option 파일에 변수를 설정할 경우 사용한다. Option 파일 속성에 따라 필수 또는 선택 항목으로 나뉜다.</td>
</tr>
<tr>
<td>-l, --var-file</td>
<td>YAML파일에 작성한 변수를 읽어올때 사용한다.</td>
</tr>
</table>



### 

#### <div id='3.6.3.1'/>● deploy-aws.sh
```
BOSH_ENVIRONMENT="${BOSH_ENVIRONMENT}"					 # bosh director alias name (PaaS-TA에서 제공되는 create-bosh-login.sh 미 사용시 bosh envs에서 이름을 확인하여 입력)

bosh -e ${BOSH_ENVIRONMENT} -d paasta -n deploy paasta-deployment.yml \	# PaaS-TA Manifest File
	-o operations/aws.yml \						# AWS 설정
	-o operations/use-haproxy.yml \					# HAProxy 적용
	-o operations/use-haproxy-public-network.yml \			# HAProxy Public Network 적용
	-o operations/use-postgres.yml \				# Database Type 설정 (3.5버전 이하에서 Migration 시 필수)
	-o operations/cce.yml \						# CCE 조치 적용
	-o operations/rename-network-and-deployment.yml \		# Rename Network and Deployment
	-l vars.yml \							# 환경에 PaaS-TA 설치시 적용하는 변수 설정 파일
	-l ../../common/common_vars.yml					# PaaS-TA 및 각종 Service 설치시 적용하는 공통 변수 설정 파일
```

#### <div id='3.6.3.2'/>● deploy-openstack.sh
```
BOSH_ENVIRONMENT="${BOSH_ENVIRONMENT}"					 # bosh director alias name (PaaS-TA에서 제공되는 create-bosh-login.sh 미 사용시 bosh envs에서 이름을 확인하여 입력)

bosh -e ${BOSH_ENVIRONMENT} -d paasta -n deploy paasta-deployment.yml \	# PaaS-TA Manifest File
	-o operations/openstack.yml \					# OpenStack 설정
	-o operations/use-haproxy.yml \					# HAProxy 적용
	-o operations/use-haproxy-public-network.yml \			# HAProxy Public Network 적용
	-o operations/use-postgres.yml \				# Database Type 설정 (3.5버전 이하에서 Migration 시 필수)
	-o operations/cce.yml \						# CCE 조치 적용
	-o operations/rename-network-and-deployment.yml \		# Rename Network and Deployment
	-l vars.yml \							# PaaS-TA 설치시 적용하는 변수 설정 파일
	-l ../../common/common_vars.yml					# PaaS-TA 및 각종 Service 설치시 적용하는 공통 변수 설정 파일
```

- Shell script 파일에 실행 권한 부여

```
$ chmod +x ~/workspace/paasta-5.5.3/deployment/paasta-deployment/paasta/*.sh
```



## <div id='3.7'/>3.7.  PaaS-TA AP 설치
- 서버 환경에 맞추어 [common_vars.yml](#3.6.1.1)와 [vars.yml](#3.6.1.2)을 수정 한 뒤, Deploy 스크립트 파일의 설정을 수정한다. 

> $ vi ~/workspace/paasta-5.5.3/deployment/paasta-deployment/paasta/deploy-aws.sh

```
BOSH_ENVIRONMENT="${BOSH_ENVIRONMENT}"			 		# bosh director alias name (PaaS-TA에서 제공되는 create-bosh-login.sh 미 사용시 bosh envs에서 이름을 확인하여 입력)

bosh -e ${BOSH_ENVIRONMENT} -d paasta -n deploy paasta-deployment.yml \	# PaaS-TA Manifest File
	-o operations/aws.yml \						# AWS 설정
	-o operations/use-haproxy.yml \					# HAProxy 적용
	-o operations/use-haproxy-public-network.yml \			# HAProxy Public Network 적용
	-o operations/use-postgres.yml \				# Database Type 설정 (3.5버전 이하에서 Migration 시 필수)
	-o operations/cce.yml \						# CCE 조치 적용
	-o operations/rename-network-and-deployment.yml \		# Rename Network and Deployment
	-l vars.yml \							# 환경에 PaaS-TA 설치시 적용하는 변수 설정 파일
	-l ../../common/common_vars.yml					# PaaS-TA 및 각종 Service 설치시 적용하는 공통 변수 설정 파일
```

- PaaS-TA AP 설치 시 Shell Script 파일 실행 (BOSH 로그인 필요)

```
$ cd ~/workspace/paasta-5.5.3/deployment/paasta-deployment/paasta
$ ./deploy-{IaaS}.sh
```

- PaaS-TA AP 설치 확인

> $ bosh -e ${BOSH_ENVIRONMENT} vms -d paasta

```
ubuntu@inception:~$ bosh -e micro-bosh vms -d paasta
Using environment '10.0.1.6' as client 'admin'

Task 134. Done

Deployment 'paasta'

Instance                                                  Process State  AZ  IPs           VM CID               VM Type             Active  Stemcell  
api/918da8e3-36c9-4144-b457-f48792041ece                  running        z1  10.0.31.206   i-093920c2caf43fe63  small               true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
api/c01d1a66-56c0-4dfb-87cd-b4e7323012ec                  running        z2  10.0.32.204   i-0bd6841ee37df618b  small               true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
cc-worker/30aa88de-8b5c-4e3a-a0ae-b2933f3af492            running        z1  10.0.31.207   i-02a7032164038f09b  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
cc-worker/31a465bd-64af-49c6-a867-3439d98b2014            running        z2  10.0.32.205   i-0d8345c5348a42fdd  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
credhub/0d2da1ef-dbdc-47d8-9514-69c1e0e83f82              running        z2  10.0.32.213   i-0f21b57a610868775  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
credhub/a43132d5-ab04-4fe3-8b75-b8194f28678b              running        z1  10.0.31.216   i-0ea2f77eb95a32f21  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
database/07b7ba09-7ace-4428-b4d4-a80163aaf82c             running        z1  10.0.31.202   i-0c532e0a7a53015c2  small               true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
diego-api/a05bbf7b-f513-48f0-8444-c90cd4b63ae2            running        z2  10.0.32.202   i-0b982d70a8debde41  small               true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
diego-api/ba388ba5-e6df-4d5e-9c6e-3af6b1fdc319            running        z1  10.0.31.203   i-0a5dfee4dc8ba1b68  small               true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
diego-cell/15378660-b457-4b6e-a9cb-5729b091c675           running        z1  10.0.31.213   i-095a00b9cb171c444  small-highmem-16GB  true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
diego-cell/7d7ed58e-c82e-429e-a6ce-18e4d70cca29           running        z2  10.0.32.211   i-02d836e28133368a1  small-highmem-16GB  true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
diego-cell/eb3b22f3-2905-4ef5-81d0-1ba6974b7316           running        z1  10.0.31.214   i-0a26ae4105e8ef6f4  small-highmem-16GB  true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
doppler/75577265-7f33-45c0-b4de-b24a881462bf              running        z1  10.0.31.211   i-01b19951e2ed96a55  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
doppler/82956ad8-d103-4223-b426-cebc793c45ee              running        z2  10.0.32.209   i-01e7d7cf7d117bf96  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
doppler/8d1fa381-c9d4-4b51-b195-c25d5d7a1a55              running        z1  10.0.31.212   i-048de3c6ad38a0184  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
doppler/ece4a895-03b9-47a1-9b48-9eaabaf258ef              running        z2  10.0.32.210   i-09a3cf0e5ac171012  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
haproxy/abb270ef-01e8-4d4c-941c-2187ca2cc8ad              running        z7  10.0.30.201   i-08af20c6712d54dd6  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
                                                                             54.180.53.80                                                    
log-api/7b45f808-22c4-45ff-a81c-74a20bac852a              running        z1  10.0.31.215   i-0b11b17bdbc23553e  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
log-api/dac3304c-f0a2-4c20-999d-db08ee39c7a7              running        z2  10.0.32.212   i-0b8426cba9bc7db7a  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
nats/35b3ab92-453f-4e9f-adf8-04477f41ee80                 running        z2  10.0.32.201   i-05a787d09b5a2df0a  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
nats/d08e1c80-bdf4-40c8-9134-16fb4a34ee11                 running        z1  10.0.31.201   i-04eddc4dfa9f9793e  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
router/0c77c858-f0c7-400c-868d-e96cd2dff4a9               running        z1  10.0.31.209   i-075290e50e0ef541d  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
router/5458b789-8ed0-4ba8-8093-6155ba1fa9b1               running        z2  10.0.32.207   i-02bc3f58d3c0306c9  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
scheduler/348e2a4e-2da7-47a3-92f8-8bf3b00e9bf0            running        z1  10.0.31.208   i-0a0b2bd3e712f0b26  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
scheduler/f56a196b-1f76-4ecc-b721-9b7fd04b8a94            running        z2  10.0.32.206   i-0c0917f591ce872f5  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
singleton-blobstore/af6b0c3a-27d0-46ef-b432-0b5c8e81519d  running        z1  10.0.31.205   i-0c519ef6d50d74d1e  small               true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
tcp-router/891c0b3e-4de6-44a5-a98b-96dd0490cac3           running        z2  10.0.32.208   i-084e044926e602669  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
tcp-router/ff3e0a98-092c-4e4c-a20c-0c0abf094a44           running        z1  10.0.31.210   i-076ef16b4d4114f83  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
uaa/3e0f17c1-cd11-4ce6-b3b8-bf1b0f45aa9f                  running        z1  10.0.31.204   i-0454401aa5fcf61fb  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
uaa/f8f6b0e8-2bbf-4be5-8f69-ac8dc7a3d943                  running        z2  10.0.32.203   i-0abd8df56336a799e  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  

30 vms

Succeeded
```

## <div id='3.8'/>3.8.  PaaS-TA AP 설치 - 다운로드 된 Release 파일 이용 방식


- 서비스 설치에 필요한 릴리즈 파일을 다운로드 받아 Local machine의 작업 경로로 위치시킨다.  
  
  - PaaS-TA 5.5.3 AP 설치 릴리즈 파일 다운로드 : [paasta.zip](https://nextcloud.paas-ta.org/index.php/s/XwaqjrzYn3tNSGp/download)

```
# 릴리즈 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta-5.5.3/release

# 릴리즈 파일 다운로드 및 파일 경로 확인
$ cd ~/workspace/paasta-5.5.3/release
$ wget https://nextcloud.paas-ta.org/index.php/s/XwaqjrzYn3tNSGp/download --content-disposition
$ unzip paasta.zip
$ cd ~/workspace/paasta-5.5.3/release/paasta
$ ls
binary-buildpack-release-1.0.37.tgz       garden-runc-release-1.19.23.tgz      postgres-release-43.tgz
bosh-dns-aliases-release-0.0.3.tgz        go-buildpack-release-1.9.29.tgz      pxc-release-0.34.0-PaaS-TA.tgz
bpm-release-1.1.9.tgz                     haproxy-boshrelease-10.5.0.tgz       pxc-release-0.34.0.tgz
capi-release-1.109.0-PaaS-TA.tgz          java-buildpack-release-4.37.tgz      python-buildpack-release-1.7.37.tgz
capi-release-1.109.0.tgz                  log-cache-release-2.10.0.tgz         r-buildpack-release-1.1.16.tgz
cf-cli-release-1.32.0.tgz                 loggregator-agent-release-6.2.0.tgz  routing-release-0.213.0-PaaS-TA.tgz
cf-networking-release-2.36.0-PaaS-TA.tgz  loggregator-release-106.5.0.tgz      routing-release-0.213.0.tgz
cf-networking-release-2.36.0.tgz          metrics-discovery-release-3.0.3.tgz  ruby-buildpack-release-1.8.37.tgz
cf-smoke-tests-release-41.0.2.tgz         nats-release-39.tgz                  silk-release-2.36.0-PaaS-TA.tgz
cflinuxfs3-release-0.236.0.tgz            nginx-buildpack-release-1.1.24.tgz   silk-release-2.36.0.tgz
credhub-release-2.9.0-PaaS-TA.tgz         nodejs-buildpack-release-1.7.48.tgz  staticfile-buildpack-release-1.5.19.tgz
credhub-release-2.9.0.tgz                 os-conf-release-22.1.0.tgz           statsd-injector-release-1.11.15.tgz
diego-release-2.49.0-PaaS-TA.tgz          paasta-conf-release-1.0.2.tgz        uaa-release-75.1.0-PaaS-TA.tgz
diego-release-2.49.0.tgz                  php-buildpack-release-4.4.36.tgz     uaa-release-75.1.0.tgz
dotnet-core-buildpack-release-2.3.26.tgz  postgres-release-43-PaaS-TA.tgz
```

- 서버 환경에 맞추어 [common_vars.yml](#3.6.1.1)와 [vars.yml](#3.6.1.2)을 수정 한 뒤, Deploy 스크립트 파일의 설정을 수정한다.   

> $ vi ~/workspace/paasta-5.5.3/deployment/paasta-deployment/paasta/deploy-aws.sh

```
BOSH_ENVIRONMENT="${BOSH_ENVIRONMENT}"			 		# bosh director alias name (PaaS-TA에서 제공되는 create-bosh-login.sh 미 사용시 bosh envs에서 이름을 확인하여 입력)

bosh -e ${BOSH_ENVIRONMENT} -d paasta -n deploy paasta-deployment.yml \	# PaaS-TA Manifest File
	-o operations/aws.yml \						# AWS 설정
	-o operations/use-haproxy.yml \					# HAProxy 적용
	-o operations/use-haproxy-public-network.yml \			# HAProxy Public Network 적용
	-o operations/use-postgres.yml \				# Database Type 설정 (3.5버전 이하에서 Migration 시 필수)
	-o operations/cce.yml \						# CCE 조치 적용
	-o operations/rename-network-and-deployment.yml \		# Rename Network and Deployment
	-o operations/use-offline-releases.yml \ 			# paasta-deployment.yml의 오프라인 릴리즈 사용
	-o operations/use-offline-releases-haproxy.yml \		# use-haproxy.yml의 오프라인 릴리즈 사용
	-o operations/use-offline-releases-postgres.yml \		# use-postgres.yml의 오프라인 릴리즈 사용
	-o operations/use-offline-releases-cce.yml \			# cce.yml의 오프라인 릴리즈 사용
	-l vars.yml \							# 환경에 PaaS-TA 설치시 적용하는 변수 설정 파일
	-l ../../common/common_vars.yml					# PaaS-TA 및 각종 Service 설치시 적용하는 공통 변수 설정 파일
```

- PaaS-TA AP 설치 시 Shell Script 파일 실행 (BOSH 로그인 필요)

```
$ cd ~/workspace/paasta-5.5.3/deployment/paasta-deployment/paasta
$ ./deploy-{IaaS}.sh
```

- PaaS-TA AP 설치 확인

> $ bosh -e ${BOSH_ENVIRONMENT} vms -d paasta

```
ubuntu@inception:~$ bosh -e micro-bosh vms -d paasta
Using environment '10.0.1.6' as client 'admin'

Task 134. Done

Deployment 'paasta'

Instance                                                  Process State  AZ  IPs           VM CID               VM Type             Active  Stemcell  
api/918da8e3-36c9-4144-b457-f48792041ece                  running        z1  10.0.31.206   i-093920c2caf43fe63  small               true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
api/c01d1a66-56c0-4dfb-87cd-b4e7323012ec                  running        z2  10.0.32.204   i-0bd6841ee37df618b  small               true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
cc-worker/30aa88de-8b5c-4e3a-a0ae-b2933f3af492            running        z1  10.0.31.207   i-02a7032164038f09b  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125  
cc-worker/31a465bd-64af-49c6-a867-3439d98b2014            running        z2  10.0.32.205   i-0d8345c5348a42fdd  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
credhub/0d2da1ef-dbdc-47d8-9514-69c1e0e83f82              running        z2  10.0.32.213   i-0f21b57a610868775  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
credhub/a43132d5-ab04-4fe3-8b75-b8194f28678b              running        z1  10.0.31.216   i-0ea2f77eb95a32f21  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
database/07b7ba09-7ace-4428-b4d4-a80163aaf82c             running        z1  10.0.31.202   i-0c532e0a7a53015c2  small               true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
diego-api/a05bbf7b-f513-48f0-8444-c90cd4b63ae2            running        z2  10.0.32.202   i-0b982d70a8debde41  small               true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
diego-api/ba388ba5-e6df-4d5e-9c6e-3af6b1fdc319            running        z1  10.0.31.203   i-0a5dfee4dc8ba1b68  small               true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
diego-cell/15378660-b457-4b6e-a9cb-5729b091c675           running        z1  10.0.31.213   i-095a00b9cb171c444  small-highmem-16GB  true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
diego-cell/7d7ed58e-c82e-429e-a6ce-18e4d70cca29           running        z2  10.0.32.211   i-02d836e28133368a1  small-highmem-16GB  true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
diego-cell/eb3b22f3-2905-4ef5-81d0-1ba6974b7316           running        z1  10.0.31.214   i-0a26ae4105e8ef6f4  small-highmem-16GB  true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
doppler/75577265-7f33-45c0-b4de-b24a881462bf              running        z1  10.0.31.211   i-01b19951e2ed96a55  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
doppler/82956ad8-d103-4223-b426-cebc793c45ee              running        z2  10.0.32.209   i-01e7d7cf7d117bf96  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
doppler/8d1fa381-c9d4-4b51-b195-c25d5d7a1a55              running        z1  10.0.31.212   i-048de3c6ad38a0184  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
doppler/ece4a895-03b9-47a1-9b48-9eaabaf258ef              running        z2  10.0.32.210   i-09a3cf0e5ac171012  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
haproxy/abb270ef-01e8-4d4c-941c-2187ca2cc8ad              running        z7  10.0.30.201   i-08af20c6712d54dd6  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
                                                                             54.180.53.80                                                    
log-api/7b45f808-22c4-45ff-a81c-74a20bac852a              running        z1  10.0.31.215   i-0b11b17bdbc23553e  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
log-api/dac3304c-f0a2-4c20-999d-db08ee39c7a7              running        z2  10.0.32.212   i-0b8426cba9bc7db7a  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
nats/35b3ab92-453f-4e9f-adf8-04477f41ee80                 running        z2  10.0.32.201   i-05a787d09b5a2df0a  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
nats/d08e1c80-bdf4-40c8-9134-16fb4a34ee11                 running        z1  10.0.31.201   i-04eddc4dfa9f9793e  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
router/0c77c858-f0c7-400c-868d-e96cd2dff4a9               running        z1  10.0.31.209   i-075290e50e0ef541d  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
router/5458b789-8ed0-4ba8-8093-6155ba1fa9b1               running        z2  10.0.32.207   i-02bc3f58d3c0306c9  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
scheduler/348e2a4e-2da7-47a3-92f8-8bf3b00e9bf0            running        z1  10.0.31.208   i-0a0b2bd3e712f0b26  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
scheduler/f56a196b-1f76-4ecc-b721-9b7fd04b8a94            running        z2  10.0.32.206   i-0c0917f591ce872f5  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
singleton-blobstore/af6b0c3a-27d0-46ef-b432-0b5c8e81519d  running        z1  10.0.31.205   i-0c519ef6d50d74d1e  small               true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
tcp-router/891c0b3e-4de6-44a5-a98b-96dd0490cac3           running        z2  10.0.32.208   i-084e044926e602669  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
tcp-router/ff3e0a98-092c-4e4c-a20c-0c0abf094a44           running        z1  10.0.31.210   i-076ef16b4d4114f83  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
uaa/3e0f17c1-cd11-4ce6-b3b8-bf1b0f45aa9f                  running        z1  10.0.31.204   i-0454401aa5fcf61fb  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 
uaa/f8f6b0e8-2bbf-4be5-8f69-ac8dc7a3d943                  running        z2  10.0.32.203   i-0abd8df56336a799e  minimal             true    bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.125 

30 vms

Succeeded
```



## <div id='3.9'/>3.9.  PaaS-TA AP 로그인 

CF CLI를 설치하고 PaaS-TA AP에 로그인한다.  
CF CLI는 v6과 v7중 선택해서 설치를 한다.  
CF API는 PaaS-TA AP 배포 시 지정했던 System Domain 명을 사용한다.

- CF CLI v6 설치

```
$ wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
$ echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
$ sudo apt update
$ sudo apt install cf-cli -y
$ cf --version
```

- CF CLI v7 설치 (PaaS-TA AP 5.1.0 이상)

```
$ wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
$ echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
$ sudo apt update
$ sudo apt install cf7-cli -y
$ cf --version
```

- CF API URL 설정

> $ cf api api.{system_domain} --skip-ssl-validation

```
ubuntu@inception:~$ cf api api.54.180.53.80.nip.io --skip-ssl-validation
Setting api endpoint to api.54.180.53.80.nip.io...
OK

api endpoint:   https://api.54.180.53.80.nip.io
api version:    3.87.0
```

- PaaS-TA AP 로그인

> $ cf login

```
ubuntu@inception:~$ cf login
API endpoint: https://api.54.180.53.80.nip.io

Email> admin

Password>
Authenticating...
OK

Select an org (or press enter to skip):
```

[PaaSTa_BOSH_Use_Guide_Image1]:https://github.com/PaaS-TA/Guide-5.0-Ravioli/blob/master/install-guide/paasta/images/bosh1.png?raw=true
[PaaSTa_BOSH_Use_Guide_Image2]:./images/bosh2-1.png
[PaaSTa_FLAVOR_Image]:https://github.com/PaaS-TA/Guide-5.0-Ravioli/blob/master/install-guide/paasta/images/aws-vmtype.PNG?raw=true
[PaaSTa_FLAVOR_Image_2]:https://github.com/PaaS-TA/Guide/blob/monitoring-5.1/install-guide/paasta-monitoring/images/flavor_openstack.png?raw=true
[PaaSTa_UAA_LOGIN_Image]:https://github.com/PaaS-TA/Guide-5.0-Ravioli/blob/master/install-guide/paasta/images/uaa-login.png?raw=true
[PaaSTa_UAA_LOGIN_Image2]:https://raw.githubusercontent.com/PaaS-TA/Guide-5.0-Ravioli/master/install-guide/paasta/images/uaa-login-2.png
[PaaSTa_VALUE_Image]:https://github.com/PaaS-TA/Guide-5.0-Ravioli/blob/master/install-guide/paasta/images/paasta-value.png?raw=true
