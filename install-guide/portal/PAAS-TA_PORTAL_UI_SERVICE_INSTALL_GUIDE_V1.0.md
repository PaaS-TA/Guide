## Table of Contents
1. [문서 개요](#1-문서-개요)
    *  [1.1 목적](#11-목적)
    *  [1.2 범위](#12-범위)
    *  [1.3 시스템 구성도](#13-시스템-구성도)
    *  [1.4 참고자료](#14-참고자료)
2. [PaaS-TA Portal 설치](#2-paas-ta-portal-설치)
    *  [2.1 설치전 준비사항](#21-설치전-준비사항)
    *  [2.2 PaaS-TA Portal UI 릴리즈 업로드](#22-paas-ta-portal-ui-릴리즈-업로드)
    *  [2.3 PaaS-TA Portal UI Deployment 배포](#23-paas-ta-portal-ui-deployment-배포)
    *  [2.4 사용자의 조직 생성 Flag 활성화](#24-사용자의-조직-생성-flag-활성화)
    *  [2.5 사용자포탈 UAA페이지 오류](#25-사용자포탈-uaa페이지-오류)
    *  [2.6 운영자포탈 유저페이지 오류](#26-운영자-포탈-유저-페이지-조회-오류)
3. [PaaS-TA Portal 운영](#3-paas-ta-portal-운영)
    *  [3.1 Log](#31-log)
    *  [3.2 카탈로그 적용](#32-카탈로그-적용)
    *  [3.3 모니터링 및 오토스케일링 적용](#33-모니터링-및-오토스케일링-적용)

# 1. 문서 개요
### 1.1. 목적

본 문서(PaaS-TA Portal Release 설치 가이드)는 전자정부표준프레임워크 기반의 PaaS-TA에서 제공되는 PaaS-TA Portal Release를 Bosh2.0을 이용하여 설치 하는 방법을 기술하였다.
PaaS-TA 3.5 버전부터는 Bosh2.0 기반으로 deploy를 진행하며 내부 네트워크는 link를 적용시켜 자동으로 Ip가 할당이 된다. 기존 Bosh1.0 기반으로 설치를 원할경우에는 PaaS-TA 3.1 이하 버전의 문서를 참고한다.

### 1.2. 범위
설치 범위는 PaaS-TA Portal Release를 검증하기 위한 기본 설치를 기준으로 작성하였다.

### 1.3. 시스템 구성도
본 문서의 설치된 시스템 구성도이다. Binary Storage, Mariadb, Proxy, Gateway Api, Registration Api, Portal Api, Common Api, Log Api, Storage Api, Webadmin, Webuser로 최소사항을 구성하였다.

![시스템구성도][paas-ta-portal-01]
* Paas-TA Portal 설치할때 cloud config에 추가적으로 정의한 VM_Tpye명과 스펙 

| VM_Type | 스펙 |
|--------|-------|
|portal_tiny| 1vCPU / 256MB RAM / 4GB Disk|
|portal_medium| 1vCPU / 1GB RAM / 4GB Disk|
|portal_small| 1vCPU / 512MB RAM / 4GB Disk|


* Paas-TA Portal각 Instance의 Resource Pool과 스펙

| 구분 | Resource Pool | 스펙 |
|--------|-------|-------|
| haproxy |portal_small| 1vCPU / 512MB RAM / 4GB Disk|
| mariadb | portal_small | 1vCPU / 512MB RAM / 4GB Disk +10GB(영구적 Disk) |
| paas-ta-portal-webadmin | portal_small | 1vCPU / 512MB RAM / 4GB Disk |
| paas-ta-portal-webuser |portal_small| 1vCPU / 512MB RAM / 4GB Disk|

### 1.4. 참고자료
[**http://bosh.io/docs**](http://bosh.io/docs)  
[**http://docs.cloudfoundry.org/**](http://docs.cloudfoundry.org/)

# 2. PaaS-TA Portal 설치

### 2.1. 설치전 준비사항

본 설치 가이드는 Linux 환경에서 설치하는 것을 기준으로 하였다.
서비스팩 설치를 위해서는 먼저 BOSH CLI v2 가 설치 되어 있어야 하고 BOSH 에 로그인이 되어 있어야 한다.<br>
BOSH CLI v2 가 설치 되어 있지 않을 경우 먼저 BOSH2.0 설치 가이드 문서를 참고 하여 BOSH CLI v2를 설치를 하고 사용법을 숙지 해야 한다.<br>

- BOSH2.0 사용자 가이드
>BOSH2 사용자 가이드 : **<https://github.com/PaaS-TA/Guide-4.0-ROTELLE/blob/master/PaaS-TA_BOSH2_사용자_가이드v1.0.md>**

>BOSH CLI V2 사용자 가이드 : **<https://github.com/PaaS-TA/Guide-4.0-ROTELLE/blob/master/Use-Guide/Bosh/PaaS-TA_BOSH_CLI_V2_사용자_가이드v1.0.md>**

- PaaS-TA에서 제공하는 압축된 릴리즈 파일들을 다운받는다.

- 다운로드 방법
1. 릴리즈된 파일받는방법

        $ wget -O download.zip http://45.248.73.44/index.php/s/DiqGmxMk6sDjA2z/download
        $ unzip download.zip 

2. PAAS-TA-PORTAL-UI-RELEASE 다운받아  직접 릴리즈 생성및 업로드 하는 방법

        $ git clone https://github.com/PaaS-TA/PAAS-TA-PORTAL-UI-RELEASE.git
        $ cd ~/PAAS-TA-PORTAL-UI-RELEASE
	      $ wget -O src.zip http://45.248.73.44/index.php/s/GDWgAMRQ7tnH7eo/download
	      $ unzip src.zip
	      $ rm -rf src.zip
	      $ sh start.sh
	
        
3. bosh envs 명령어를 통해 사용할 bosh env를 확인한다.        
        
        $ bosh envs
        URL       Alias  
        10.0.1.7  micro-bosh  
        
        1 environments
        
        Succeeded
        
4. bosh runtime-config 확인 및 수정
> 1. 명령어를 통해 bosh-dns include deployments 에 paasta가 있는지 확인한다.

     $ bosh -e micro-bosh runtime-config
     Using environment '10.0.50.90' as client 'admin'
     
     ---
     addons:
     - include:
         deployments:
         - paasta
         stemcell:
         - os: ubuntu-trusty
         - os: ubuntu-xenial
       jobs:
       - name: bosh-dns
         properties:
           api:
             client:
               tls: "((/dns_api_client_tls))"
             server:
               tls: "((/dns_api_server_tls))"
           cache:
             enabled: true
           health:
             client:
               tls: "((/dns_healthcheck_client_tls))"
             enabled: true
             server:
               tls: "((/dns_healthcheck_server_tls))"
         release: bosh-dns
       name: bosh-dns
     - include:
         stemcell:
         - os: windows2012R2
         - os: windows2016
         - os: windows1803
       jobs:
       - name: bosh-dns-windows
         properties:
           api:
             client:
               tls: "((/dns_api_client_tls))"
             server:
               tls: "((/dns_api_server_tls))"
           cache:
             enabled: true
           health:
             client:
               tls: "((/dns_healthcheck_client_tls))"
             enabled: true
             server:
               tls: "((/dns_healthcheck_server_tls))"
         release: bosh-dns
       name: bosh-dns-windows
     releases:
     - name: bosh-dns
       sha1: d1aadbda5d60c44dec4a429cda872cf64f6d8d0b
       url: https://bosh.io/d/github.com/cloudfoundry/bosh-dns-release?v=1.10.0
       version: 1.10.0
     variables:
     - name: "/dns_healthcheck_tls_ca"
       options:
         common_name: dns-healthcheck-tls-ca
         is_ca: true
       type: certificate
     - name: "/dns_healthcheck_server_tls"
       options:
         ca: "/dns_healthcheck_tls_ca"
         common_name: health.bosh-dns
         extended_key_usage:
         - server_auth
       type: certificate
     - name: "/dns_healthcheck_client_tls"
       options:
         ca: "/dns_healthcheck_tls_ca"
         common_name: health.bosh-dns
         extended_key_usage:
         - client_auth
       type: certificate
     - name: "/dns_api_tls_ca"
       options:
         common_name: dns-api-tls-ca
         is_ca: true
       type: certificate
     - name: "/dns_api_server_tls"
       options:
         ca: "/dns_api_tls_ca"
         common_name: api.bosh-dns
         extended_key_usage:
         - server_auth
       type: certificate
     - name: "/dns_api_client_tls"
       options:
         ca: "/dns_api_tls_ca"
         common_name: api.bosh-dns
         extended_key_usage:
         - client_auth
       type: certificate
     
     Succeeded

> 2. bosh-dns include deployments에 paasta가 없다면 ~/workspace/paasta-5.0/deployment/bosh-deployment/runtime-configs 의 dns.yml 을 열어서 paasta를 추가해야한다.

       addons:
      - name: bosh-dns
        jobs:
        - name: bosh-dns
          release: bosh-dns
          properties:
            cache:
              enabled: true
            health:
              enabled: true
              server:
                tls: ((/dns_healthcheck_server_tls))
              client:
                tls: ((/dns_healthcheck_client_tls))
            api:
              server:
                tls: ((/dns_api_server_tls))
              client:
                tls: ((/dns_api_client_tls))
        include:
          deployments:
          - paasta
          stemcell:
          - os: ubuntu-trusty
          - os: ubuntu-xenial


> 3. dns.yml의 bosh-dns addons 설정 부분이다. Incoude.deployments에 paasta를 위와같이 추가시킨다. 
> 4. yml설정을 한 후에 ~/workspace/paasta-5.0/deployment/bosh-deployment/update-runtime-config.sh을 실행시키면 runtime-config가 업데이트가 된다.
> 5. 다시 bosh runtime-config 명령어를 통해 bosh-dns include deployments 에 paasta가 있는지 확인 후 성공적으로 등록이 되었으면 ppaasta-portal-ui-release 릴리즈 업로드 및 deploy를 진행한다.
### 2.2. PaaS-TA Portal UI 릴리즈 업로드

-	업로드 되어 있는 릴리즈 목록을 확인한다.

- **사용 예시**

		$ bosh -e micro-bosh releases
    		Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)

		Name                              Version   Commit Hash  
    		binary-buildpack                  1.0.21*   d714741  
    		bpm                               0.9.0*    c9b7136  
    		caas-release                      1.0*      empty+  
    		capi                              1.62.0*   22a608c  
	    	cf-networking                     2.8.0*    479f4a66  
	    	cf-smoke-tests                    40.0.5*   d6aaf1f  
	    	cf-syslog-drain                   7.0*      71b995a  
	    	cflinuxfs2                        1.227.0*  60128e1  
	    	consul                            195*      67cdbcd  
	    	diego                             2.13.0*   b5644d9  
	    	dotnet-core-buildpack             2.1.3*    46a41cd  
	    	garden-runc                       1.15.1*   75107e7+  
	    	go-buildpack                      1.8.25*   40c60a0  
	    	haproxy                           8.8.0*    9292573  
	    	java-buildpack                    4.13*     c2749d3  
	    	loggregator                       103.0*    05da4e3d  
	    	loggregator-agent                 2.0*      2382c90  
	    	nats                              24*       30e7a82  
	    	nodejs-buildpack                  1.6.28*   4cfdb7b    
	    	paasta-delivery-pipeline-release  1.0*      b3ee8f48+  
	    	paasta-pinpoint                   2.0*      2dbb8bf3+  
	    	php-buildpack                     4.3.57*   efc48f3  
	    	postgres                          29*       5de4d63d+  
	    	python-buildpack                  1.6.18*   bcc4f26  
	    	routing                           0.179.0*  18155a5  
	    	ruby-buildpack                    1.7.21*   9d69600  
	    	silk                              2.9.0*    eebed55  
	    	staticfile-buildpack              1.4.29*   8a82e63  
	    	statsd-injector                   1.3.0*    39e5179  
	    	uaa                               60.2*     ebb5895  

	    	(*) Currently deployed
	    	(+) Uncommitted changes

	    	30 releases

	    	Succeeded

- paasta-portal-ui-release(ver 1.0)이 업로드 되어 있지 않은 것을 확인

- PaaS-TA Portal 릴리즈 파일을 업로드한다.
> 명령어 : bosh -e "bosh env" upload-release "release file"

        릴리즈 파일 위치 : PAAS-TA-PORTAL-RELEASE/paasta-portal-ui-release-1.0.tgz
            


- **사용 예시**

		$ bosh -e micro-bosh upload-release paasta-portal-ui-release-1.0.tgz
		Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)

		######################################################## 100.00% 153.81 MiB/s 3s
        Task 4687
        
        Task 4687 | 02:09:08 | Extracting release: Extracting release (00:00:05)
        Task 4687 | 02:09:13 | Verifying manifest: Verifying manifest (00:00:00)
        Task 4687 | 02:09:14 | Resolving package dependencies: Resolving package dependencies (00:00:00)
        Task 4687 | 02:09:14 | Creating new packages: paas-ta-portal-webadmin/a74db51496832a2b1e1e947c424d08b33fb46c83 (00:00:01)
        Task 4687 | 02:09:20 | Creating new packages: haproxy/14b0441f6d68c89612f53ce4334a65c80d601e51 (00:00:00)
        Task 4687 | 02:09:28 | Creating new packages: paas-ta-portal-webuser/e3901a2d9e9cd349a06fee226bc3230e1c91b430 (00:00:02)
        Task 4687 | 02:09:32 | Creating new packages: java/86d8b8f8115418addf836753c1735abe547d4105 (00:00:03)
        Task 4687 | 02:09:35 | Creating new packages: mariadb/59a218308c6c7dcf8795b531b53aa4a1c666ce00 (00:00:23)
        Task 4687 | 02:09:58 | Creating new jobs: paas-ta-portal-webadmin/233eb71833ed12faef66b4ef1b298bee0f6f10d2 (00:00:01)
        Task 4687 | 02:09:59 | Creating new jobs: haproxy/6fb2bf3eefc2ec935bbb6a1d05ed92ba66ea7988 (00:00:00)
        Task 4687 | 02:09:59 | Creating new jobs: paas-ta-portal-webuser/e866e3a0fb36020dd8f207a0db5f7bd22be18d2b (00:00:00)
        Task 4687 | 02:09:59 | Creating new jobs: binary_storage/8315c60cb8259e61fb0df4742e72cb2093dd32e4 (00:00:00)
        Task 4687 | 02:09:59 | Creating new jobs: mariadb/3810edf74d908d7fb1cd284ce69a172b5fb51225 (00:00:01)
        Task 4687 | 02:10:00 | Release has been created: paasta-portal-ui-release/1.0 (00:00:00)
        Task 4687 Started  Mon Sep  3 02:09:08 UTC 2018
        Task 4687 Finished Mon Sep  3 02:10:00 UTC 2018
        Task 4687 Duration 00:00:52
        Task 4687 done
        
        Succeeded

-	PaaS-TA Portal UI 릴리즈를 확인한다.

- **사용 예시**

		$ bosh -e micro-bosh releases
    		Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)

		Name                              Version   Commit Hash  
    	binary-buildpack                  1.0.21*   d714741  
		bpm                               0.9.0*    c9b7136  
		caas-release                      1.0*      empty+  
		capi                              1.62.0*   22a608c  
		cf-networking                     2.8.0*    479f4a66  
		cf-smoke-tests                    40.0.5*   d6aaf1f  
		cf-syslog-drain                   7.0*      71b995a  
		cflinuxfs2                        1.227.0*  60128e1  
		consul                            195*      67cdbcd  
		diego                             2.13.0*   b5644d9  
		dotnet-core-buildpack             2.1.3*    46a41cd  
		garden-runc                       1.15.1*   75107e7+  
		go-buildpack                      1.8.25*   40c60a0  
		haproxy                           8.8.0*    9292573  
		java-buildpack                    4.13*     c2749d3  
		loggregator                       103.0*    05da4e3d  
		loggregator-agent                 2.0*      2382c90  
		nats                              24*       30e7a82  
		nodejs-buildpack                  1.6.28*   4cfdb7b  
		paasta-portal-ui-release          1.0*      235c329+  
		paasta-delivery-pipeline-release  1.0*      b3ee8f48+  
		paasta-pinpoint                   2.0*      2dbb8bf3+  
		php-buildpack                     4.3.57*   efc48f3  
		postgres                          29*       5de4d63d+  
		python-buildpack                  1.6.18*   bcc4f26  
		routing                           0.179.0*  18155a5  
		ruby-buildpack                    1.7.21*   9d69600  
		silk                              2.9.0*    eebed55  
		staticfile-buildpack              1.4.29*   8a82e63  
		statsd-injector                   1.3.0*    39e5179  
		uaa                               60.2*     ebb5895  

	    	(*) Currently deployed
	    	(+) Uncommitted changes
	    	31 releases
	    	Succeeded

		
-	PaaS-TA Portal 릴리즈가 업로드 되어 있는 것을 확인

-	Deploy시 사용할 Stemcell을 확인한다.

- **사용 예시**

		$ bosh -e micro-bosh stemcells
		Name                                       Version  OS             CPI  CID  
		bosh-openstack-kvm-ubuntu-xenial-go_agent  315.64*  ubuntu-xenial  -    fb08e389-2350-4091-9b29-41743495e62c  

		(*) Currently deployed

		1 stemcells

		Succeeded
		
>Stemcell 목록이 존재 하지 않을 경우 Stemcell을 업로드를 해야 한다.
         
### 2.3. PaaS-TA Portal UI Deployment 배포

BOSH Deployment manifest 는 components 요소 및 배포의 속성을 정의한 YAML 파일이다.
Deployment manifest 에는 sotfware를 설치 하기 위해서 어떤 Stemcell (OS, BOSH agent) 을 사용할것이며 Release (Software packages, Config templates, Scripts) 이름과 버전, VMs 용량, Jobs params 등을 정의가 되어 있다.

deployment 파일에서 사용하는 network, vm_type 등은 cloud config 를 활용하고 해당 가이드는 Bosh2.0 가이드를 참고한다.

-	 cloud config 내용 조회
> 명령어 bosh -e "bosh env" cloud-config

- **사용 예시**

		bosh -e micro-bosh cloud-config
		Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)

		azs:
		- cloud_properties:
		    datacenters:
		    - clusters:
		      - BD-HA:
			  resource_pool: CF_BOSH2_Pool
		      name: BD-HA
		  name: z1
		- cloud_properties:
		    datacenters:
		    - clusters:
		      - BD-HA:
			  resource_pool: CF_BOSH2_Pool
		      name: BD-HA
		  name: z2
		- cloud_properties:
		    datacenters:
		    - clusters:
		      - BD-HA:
			  resource_pool: CF_BOSH2_Pool
		      name: BD-HA
		  name: z3
		- cloud_properties:
		    datacenters:
		    - clusters:
		      - BD-HA:
			  resource_pool: CF_BOSH2_Pool
		      name: BD-HA
		  name: z4
		- cloud_properties:
		    datacenters:
		    - clusters:
		      - BD-HA:
			  resource_pool: CF_BOSH2_Pool
		      name: BD-HA
		  name: z5
		- cloud_properties:
		    datacenters:
		    - clusters:
		      - BD-HA:
			  resource_pool: CF_BOSH2_Pool
		      name: BD-HA
		  name: z6
		compilation:
		  az: z1
		  network: default
		  reuse_compilation_vms: true
		  vm_type: large
		  workers: 5
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
		networks:
		- name: default
		  subnets:
		  - azs:
		    - z1
		    - z2
		    - z3
		    - z4
		    - z5
		    - z6
		    cloud_properties:
		      name: Internal
		    dns:
		    - 8.8.8.8
		    gateway: 10.30.20.23
		    range: 10.30.0.0/16
		    reserved:
		    - 10.30.0.0 - 10.30.111.40
		- name: public
		  subnets:
		  - azs:
		    - z1
		    - z2
		    - z3
		    - z4
		    - z5
		    - z6
		    cloud_properties:
		      name: External
		    dns:
		    - 8.8.8.8
		    gateway: 115.68.46.177
		    range: 115.68.46.176/28
		    reserved:
		    - 115.68.46.176 - 115.68.46.188
		    static:
		    - 115.68.46.189 - 115.68.46.190
		  type: manual
		- name: service_private
		  subnets:
		  - azs:
		    - z1
		    - z2
		    - z3
		    - z4
		    - z5
		    - z6
		    cloud_properties:
		      name: Internal
		    dns:
		    - 8.8.8.8
		    gateway: 10.30.20.23
		    range: 10.30.0.0/16
		    reserved:
		    - 10.30.0.0 - 10.30.106.255
		    static:
		    - 10.30.107.1 - 10.30.107.255
		- name: service_public
		  subnets:
		  - azs:
		    - z1
		    - z2
		    - z3
		    - z4
		    - z5
		    - z6
		    cloud_properties:
		      name: External
		    dns:
		    - 8.8.8.8
		    gateway: 115.68.47.161
		    range: 115.68.47.160/24
		    reserved:
		    - 115.68.47.161 - 115.68.47.174
		    static:
		    - 115.68.47.175 - 115.68.47.185
		  type: manual
		- name: portal_service_public
		  subnets:
		  - azs:
		    - z1
		    - z2
		    - z3
		    - z4
		    - z5
		    - z6
		    cloud_properties:
		      name: External
		    dns:
		    - 8.8.8.8
		    gateway: 115.68.46.209
		    range: 115.68.46.208/28
		    reserved:
		    - 115.68.46.216 - 115.68.46.222
		    static:
		    - 115.68.46.214
		  type: manual
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
		    disk: 51200
		  name: small-50GB
		- cloud_properties:
		    disk: 102400
		  name: small-highmem-100GB
		vm_types:
		- cloud_properties:
		    cpu: 1
		    disk: 8192
		    ram: 1024
		  name: minimal
		- cloud_properties:
		    cpu: 1
		    disk: 10240
		    ram: 2048
		  name: default
		- cloud_properties:
		    cpu: 1
		    disk: 30720
		    ram: 4096
		  name: small
		- cloud_properties:
		    cpu: 2
		    disk: 20480
		    ram: 4096
		  name: medium
		- cloud_properties:
		    cpu: 2
		    disk: 20480
		    ram: 8192
		  name: medium-memory-8GB
		- cloud_properties:
		    cpu: 4
		    disk: 20480
		    ram: 8192
		  name: large
		- cloud_properties:
		    cpu: 8
		    disk: 20480
		    ram: 16384
		  name: xlarge
		- cloud_properties:
		    cpu: 2
		    disk: 51200
		    ram: 4096
		  name: small-50GB
		- cloud_properties:
		    cpu: 2
		    disk: 51200
		    ram: 4096
		  name: small-50GB-ephemeral-disk
		- cloud_properties:
		    cpu: 4
		    disk: 102400
		    ram: 8192
		  name: small-100GB-ephemeral-disk
		- cloud_properties:
		    cpu: 4
		    disk: 102400
		    ram: 8192
		  name: small-highmem-100GB-ephemeral-disk
		- cloud_properties:
		    cpu: 8
		    disk: 20480
		    ram: 16384
		  name: small-highmem-16GB
		- cloud_properties:
		    cpu: 1
		    disk: 4096
		    ram: 2048
		  name: caas_small
		- cloud_properties:
		    cpu: 1
		    disk: 4096
		    ram: 1024
		  name: caas_small_api
		- cloud_properties:
		    cpu: 1
		    disk: 4096
		    ram: 4096
		  name: caas_medium
		- cloud_properties:
		    cpu: 2
		    disk: 8192
		    ram: 4096
		  name: service_medium
		- cloud_properties:
            cpu: 2
            disk: 10240
            ram: 2048
          name: service_medium_2G
        - cloud_properties:
            cpu: 1
            disk: 4096
            ram: 512
          name: portal_small
        - cloud_properties:
            cpu: 1
            disk: 4096
            ram: 1024
          name: portal_medium
        - cloud_properties:
            cpu: 1
            disk: 4096
            ram: 2048
          name: portal_large


		Succeeded


-  Deployment 파일을 서버 환경에 맞게 수정한다.
> deployment 파일 위치 : PAAS-TA-PORTAL-RELEASE/deployments/paas-ta-portal-bosh2.0-vsphere.yml
-  azs의 경우 z5 ~ z6 로 설정한다.
-  "(())" 구문은 bosh deploy 할 때 변수로 받아서 처리하는 구문이므로 이 부분의 수정 방법은 아래의 deploy-portal-bosh2.0.sh 참고 예) os : ((stemcell_os))
 
```yml
# paas-ta-portal-bosh2.0.yml 설정 파일 내용
---
name: paasta-portal-ui                      # 서비스 배포이름(필수) bosh deployments 로 확인 가능한 이름

stemcells:
- alias: ((stemcell_alias))
  os: ((stemcell_os))
  version: ((stemcell_version))

releases:
- name: "((releases_name))"                   # 서비스 릴리즈 이름(필수) bosh releases로 확인 가능
  version: "1.0"                                              # 서비스 릴리즈 버전(필수):latest 시 업로드된 서비스 릴리즈 최신버전

update:
  canaries: 1                                               # canary 인스턴스 수(필수)
  canary_watch_time: 5000-120000                            # canary 인스턴스가 수행하기 위한 대기 시간(필수)
  update_watch_time: 5000-120000                            # non-canary 인스턴스가 수행하기 위한 대기 시간(필수)
  max_in_flight: 1                                          # non-canary 인스턴스가 병렬로 update 하는 최대 개수(필수)
  serial: false

instance_groups:
########## INFRA ##########
- name: mariadb
  azs:
  - z6
  instances: 1
  vm_type: "((vm_type_small))"
  stemcell: "((stemcell_alias))"
  persistent_disk_type: "((mariadb_disk_type))"
  networks:
  - name: ((internal_networks_name))
  jobs:
  - name: mariadb
    release: "((releases_name))" 
  syslog_aggregator: null

- name: haproxy
  azs:
  - z7
  instances: 1
  vm_type: "((vm_type_tiny))"
  stemcell: "((stemcell_alias))"
  networks:
  - name: ((internal_networks_name))
  - name: ((external_networks_name))
    static_ips: ((haproxy_public_ip))
  jobs:
  - name: haproxy
    release: "((releases_name))"
  syslog_aggregator: null
  properties:
    infra:
      admin:
        enable: "((infra_admin))"

######## WEB SERVICE ########

- name: paas-ta-portal-webadmin
  azs:
  - z6
  instances: 1
  vm_type: "((vm_type_small))"
  stemcell: "((stemcell_alias))"
  networks:
  - name: ((internal_networks_name))
  jobs:
  - name: paas-ta-portal-webadmin
    release: "((releases_name))"
  syslog_aggregator: null
  properties:
    java_opts: "-Xmx450m -Xss1M -XX:MaxMetaspaceSize=93382K -XX:ReservedCodeCacheSize=240m -XX:+UseCompressedOops -Djdk.tls.ephemeralDHKeySize=2048 -Dfile.encoding=UTF-8 -XX:+UseConcMarkSweepGC -XX:SoftRefLRUPolicyMSPerMB=50 -Dsun.io.useCanonCaches=false -Djava.net.preferIPv4Stack=true -XX:+HeapDumpOnOutOfMemoryError -XX:-OmitStackTraceInFastThrow -Xverify:none -XX:ErrorFile=/var/vcap/sys/log/java_error_in_idea_%p.log -XX:HeapDumpPath=/var/vcap/sys/log/java_error_in_idea.hprof"
    api:
      url: "((default_portal_api_url))"
    port: 8090

- name: paas-ta-portal-webuser
  azs:
  - z6
  instances: 1
  vm_type: "((vm_type_tiny))"
  stemcell: "((stemcell_alias))"
  networks:
  - name: ((internal_networks_name))
  jobs:
  - name: paas-ta-portal-webuser
    release: "((releases_name))"
  syslog_aggregator: null
  properties:
    logPath: "/var/vcap/sys/log/paas-ta-portal-webuser"   # WEBUSER는 아파치를 사용함, APACHE 로그 위치
    webDir: "/var/vcap/packages/apache2/htdocs"           # WEBUSER는 아파치를 사용함, APACHE 웹 디렉토리 설정
    cf:
      uaa:
        clientsecret: ((portal_client_secret))
    monitoring: ((portal_webuser_monitoring))
    quantity: ((portal_webuser_quantity))
    automaticApproval: ((portal_webuser_automaticapproval))

properties:
  mariadb:                                                # MARIA DB SERVER 설정 정보
    port: ((mariadb_port))                                            # MARIA DB PORT 번호
    admin_user:
      password: '((mariadb_user_password))'                             # MARIA DB ROOT 계정 비밀번호
    host_names:
    - mariadb0
  portal_default:
    name: "((default_portal_api_name))"
    url: "((default_portal_api_url))"
    uaa_url: "((default_portal_uaa_url))"
    header_auth: "((default_portal_header_auth))"
    desc: "((default_portal_api_desc))"
  cf_api_version: "((cf_api_version))"
  webadmin_ips: "((haproxy_public_ip))"

```

-	vsphere : deploy-portal-bosh2.0-vsphere.sh
-	openstack : deploy-portal-bosh2.0-openstack.sh
-	aws : deploy-portal-bosh2.0-aws.sh 

> 각 IaaS 환경에 맞춰 수정후 shell 파일을 실행한다..

> bosh 명령문 후에 주석(#)을 사용할경우 오류가 발생한다.
> 밑의 예시는 vsphere의 환경에서 테스트한 환경이다. 
```sh
#!/bin/bash
bosh -n -d paasta-portal-ui deploy --no-redact paasta-portal-bosh2.0.yml \
   -o use-public-network-vsphere.yml \
   -v releases_name="paasta-portal-ui-release"\
   -v stemcell_os="ubuntu-xenial"\
   -v stemcell_version="315.64"\
   -v stemcell_alias="default"\
   -v vm_type_tiny="portal_tiny"\
   -v vm_type_small="portal_small"\
   -v vm_type_medium="portal_medium"\
   -v internal_networks_name=service_private \
   -v external_networks_name=service_public \
   -v mariadb_disk_type="10GB"\
   -v mariadb_port=3306\
   -v mariadb_user_password="password"\
   -v haproxy_public_ip="115.68.46.180"\
   -v portal_client_secret="password"\
   -v portal_webuser_quantity=false\
   -v portal_webuser_monitoring=false\
   -v portal_webuser_automaticapproval=true\
   -v infra_admin=false\
   -v default_portal_api_url="http://115.68.46.179:2225"\
   -v default_portal_api_name="PaaS-TA 5.0"\
   -v default_portal_uaa_url="https://uaa.115.68.46.178.xip.io"\
   -v default_portal_header_auth="Basic YWRtaW46b3BlbnBhYXN0YQ=="\
   -v default_portal_api_desc="PaaS-TA 5.0 install infra"\
   -v cf_api_version="v3"

```
> release_version : 릴리즈 버전을 입력한다. $bosh releases 명령문으로 확인가능
 
    - $ bosh releases
      Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)
      Name                              Version   Commit Hash  
      paasta-portal-ui-release            1.0*       235c329+  

> stemcell_os : 스템셀 OS를 입력한다. $bosh stemcells 명령문으로 확인가능\
> stemcell_version : 스템셀 버전을 입력한다. $bosh stemcells 명령문으로 확인가능\
> stemcell_alias : bosh deploy시 사용할 스템셀 명칭을 정한다.

    - $ bosh stemcells
      Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)
      Name                                      Version  OS             CPI  CID  
      bosh-vsphere-esxi-ubuntu-xenial-go_agent  315.64*  ubuntu-xenial  -    sc-66428140-1807-4ca7-894f-d8ffec86d623  
      
      (*) Currently deployed
      
      1 stemcells
      
      
> internal_networks_name : 내부 ip 할당할 network name $ bosh -e micro-bosh cloud-config로 확인가능\
> external_networks_name : 외부 ip 할당할 network name $ bosh -e micro-bosh cloud-config로 확인가능
      
      $ bosh -e micro-bosh cloud-config
      - name: service_private
        subnets:
        - azs:
          - z1
          - z2
          - z3
          - z4
          - z5
          - z6
          cloud_properties:
            name: Internal
          dns:
          - 8.8.8.8
          gateway: 10.30.20.23
          range: 10.30.0.0/16
          reserved:
          - 10.30.0.0 - 10.30.106.255
          static:
          - 10.30.107.1 - 10.30.107.255
      - name: service_public
        subnets:
        - azs:
          - z1
          - z2
          - z3
          - z4
          - z5
          - z6
          cloud_properties:
            name: External
          dns:
          - 8.8.8.8
          gateway: 115.68.47.161
          range: 115.68.47.160/24
          reserved:
          - 115.68.47.161 - 115.68.47.174
          static:
          - 115.68.47.175 - 115.68.47.185
        type: manual

> mariadb_disk_type: Mariadb의 persistent_disk용량을 정한다.\
  mariadb_port: Mariadb의 port를 정한다.\
  mariadb_user_password: Mariadb의 비밀번호를 설정한다.(임의값 가능)\
  haproxy_ips: Haproxy의 ip 할당, internal_networks_name에 할당된 ip를 사용해야한다.
 
> cf_admin_password: CF 관리자 계정 비밀번호를 입력한다.

>cf_uaa_admin_client_secret: uaac admin client의 secret를 입력한다.\
 portal_client_secret: uaac portalclient의 secret를 입력한다.
   
>portal_webuser_automaticapproval: 회원가입시 cf에 접속가능 여부 true일경우 관리자포탈에서 승인을 해주어야 접근 가능하다.\
 portal_webuser_monitoring : 모니터링 사용 여부 true일경우 앱 상세정보에서 모니터링창이 활성화가 된다.\
 portal_webuser_quantity : 사용량 조회 창 활성화 여부
 
 -	PaaS-TA Portal을 배포한다.

- **사용 예시**

		$ ./deploy-vsphere.sh
		Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)
        
        Using deployment 'paasta-portal-ui'
        
        + azs:
        + - cloud_properties:
        +     datacenters:
        +     - clusters:
        +       - BD-HA:
        +           resource_pool: CF_BOSH2_Pool
        +       name: BD-HA
        +   name: z1
        + - cloud_properties:
        +     datacenters:
        +     - clusters:
        +       - BD-HA:
        +           resource_pool: CF_BOSH2_Pool
        +       name: BD-HA
        +   name: z2
        + - cloud_properties:
        +     datacenters:
        +     - clusters:
        +       - BD-HA:
        +           resource_pool: CF_BOSH2_Pool
        +       name: BD-HA
        +   name: z3
        + - cloud_properties:
        +     datacenters:
        +     - clusters:
        +       - BD-HA:
        +           resource_pool: CF_BOSH2_Pool
        +       name: BD-HA
        +   name: z4
        + - cloud_properties:
        +     datacenters:
        +     - clusters:
        +       - BD-HA:
        +           resource_pool: CF_BOSH2_Pool
        +       name: BD-HA
        +   name: z5
        + - cloud_properties:
        +     datacenters:
        +     - clusters:
        +       - BD-HA:
        +           resource_pool: CF_BOSH2_Pool
        +       name: BD-HA
        +   name: z6
          
        + vm_types:
        + - cloud_properties:
        +     cpu: 1
        +     disk: 8192
        +     ram: 1024
        +   name: minimal
        + - cloud_properties:
        +     cpu: 1
        +     disk: 10240
        +     ram: 2048
        +   name: default
        + - cloud_properties:
        +     cpu: 1
        +     disk: 30720
        +     ram: 4096
        +   name: small
        + - cloud_properties:
        +     cpu: 2
        +     disk: 20480
        +     ram: 4096
        +   name: medium
        + - cloud_properties:
        +     cpu: 2
        +     disk: 20480
        +     ram: 8192
        +   name: medium-memory-8GB
        + - cloud_properties:
        +     cpu: 4
        +     disk: 20480
        +     ram: 8192
        +   name: large
        + - cloud_properties:
        +     cpu: 8
        +     disk: 20480
        +     ram: 16384
        +   name: xlarge
        + - cloud_properties:
        +     cpu: 2
        +     disk: 51200
        +     ram: 4096
        +   name: small-50GB
        + - cloud_properties:
        +     cpu: 2
        +     disk: 51200
        +     ram: 4096
        +   name: small-50GB-ephemeral-disk
        + - cloud_properties:
        +     cpu: 4
        +     disk: 102400
        +     ram: 8192
        +   name: small-100GB-ephemeral-disk
        + - cloud_properties:
        +     cpu: 4
        +     disk: 102400
        +     ram: 8192
        +   name: small-highmem-100GB-ephemeral-disk
        + - cloud_properties:
        +     cpu: 8
        +     disk: 20480
        +     ram: 16384
        +   name: small-highmem-16GB
        + - cloud_properties:
        +     cpu: 1
        +     disk: 4096
        +     ram: 2048
        +   name: caas_small
        + - cloud_properties:
        +     cpu: 1
        +     disk: 4096
        +     ram: 1024
        +   name: caas_small_api
        + - cloud_properties:
        +     cpu: 1
        +     disk: 4096
        +     ram: 4096
        +   name: caas_medium
        + - cloud_properties:
        +     cpu: 2
        +     disk: 8192
        +     ram: 4096
        +   name: service_medium
        + - cloud_properties:
        +     cpu: 2
        +     disk: 10240
        +     ram: 2048
        +   name: service_medium_2G
          
        + vm_extensions:
        + - cloud_properties:
        +     ports:
        +     - host: 3306
        +   name: mysql-proxy-lb
        + - name: cf-router-network-properties
        + - name: cf-tcp-router-network-properties
        + - name: diego-ssh-proxy-network-properties
        + - name: cf-haproxy-network-properties
        + - cloud_properties:
        +     disk: 51200
        +   name: small-50GB
        + - cloud_properties:
        +     disk: 102400
        +   name: small-highmem-100GB
          
        + compilation:
        +   az: z1
        +   network: default
        +   reuse_compilation_vms: true
        +   vm_type: large
        +   workers: 5
          
        + networks:
        + - name: default
        +   subnets:
        +   - azs:
        +     - z1
        +     - z2
        +     - z3
        +     - z4
        +     - z5
        +     - z6
        +     cloud_properties:
        +       name: Internal
        +     dns:
        +     - 8.8.8.8
        +     gateway: 10.30.20.23
        +     range: 10.30.0.0/16
        +     reserved:
        +     - 10.30.0.0 - 10.30.111.40
        + - name: public
        +   subnets:
        +   - azs:
        +     - z1
        +     - z2
        +     - z3
        +     - z4
        +     - z5
        +     - z6
        +     cloud_properties:
        +       name: External
        +     dns:
        +     - 8.8.8.8
        +     gateway: 115.68.46.177
        +     range: 115.68.46.176/28
        +     reserved:
        +     - 115.68.46.176 - 115.68.46.188
        +     static:
        +     - 115.68.46.189 - 115.68.46.190
        +   type: manual
        + - name: service_private
        +   subnets:
        +   - azs:
        +     - z1
        +     - z2
        +     - z3
        +     - z4
        +     - z5
        +     - z6
        +     cloud_properties:
        +       name: Internal
        +     dns:
        +     - 8.8.8.8
        +     gateway: 10.30.20.23
        +     range: 10.30.0.0/16
        +     reserved:
        +     - 10.30.0.0 - 10.30.106.255
        +     static:
        +     - 10.30.107.1 - 10.30.107.255
        + - name: service_public
        +   subnets:
        +   - azs:
        +     - z1
        +     - z2
        +     - z3
        +     - z4
        +     - z5
        +     - z6
        +     cloud_properties:
        +       name: External
        +     dns:
        +     - 8.8.8.8
        +     gateway: 115.68.47.161
        +     range: 115.68.47.160/24
        +     reserved:
        +     - 115.68.47.161 - 115.68.47.174
        +     static:
        +     - 115.68.47.175 - 115.68.47.185
        +   type: manual
        + - name: portal_service_public
        +   subnets:
        +   - azs:
        +     - z1
        +     - z2
        +     - z3
        +     - z4
        +     - z5
        +     - z6
        +     cloud_properties:
        +       name: External
        +     dns:
        +     - 8.8.8.8
        +     gateway: 115.68.46.209
        +     range: 115.68.46.208/28
        +     reserved:
        +     - 115.68.46.216 - 115.68.46.222
        +     static:
        +     - 115.68.46.214
        +   type: manual
          
        + disk_types:
        + - disk_size: 1024
        +   name: default
        + - disk_size: 1024
        +   name: 1GB
        + - disk_size: 2048
        +   name: 2GB
        + - disk_size: 4096
        +   name: 4GB
        + - disk_size: 5120
        +   name: 5GB
        + - disk_size: 8192
        +   name: 8GB
        + - disk_size: 10240
        +   name: 10GB
        + - disk_size: 20480
        +   name: 20GB
        + - disk_size: 30720
        +   name: 30GB
        + - disk_size: 51200
        +   name: 50GB
        + - disk_size: 102400
        +   name: 100GB
        + - disk_size: 1048576
        +   name: 1TB
          
        + stemcells:
        + - alias: default
        +   os: ubuntu-xenial
        +   version: 'latest'
          
        + releases:
        + - name: paas-ta-portal-release
        +   version: '2.0'
          
        + update:
        +   canaries: 1
        +   canary_watch_time: 5000-120000
        +   max_in_flight: 1
        +   serial: false
        +   update_watch_time: 5000-120000
          
        + instance_groups:
        + - azs:
        +   - z3
        +   instances: 1
        +   name: mariadb
        +   networks:
        +   - name: service_private
        +     static_ips:
        +     - 10.30.107.211
        +   persistent_disk_type: 10GB
        +   stemcell: default
        +   syslog_aggregator: 
        +   templates:
        +   - name: mariadb
        +     release: paas-ta-portal-release
        +   vm_type: portal_large
        + - azs:
        +   - z5
        +   instances: 1
        +   name: binary_storage
        +   networks:
        +   - name: service_private
        +     static_ips:
        +     - 10.30.107.212
        +   persistent_disk_type: 10GB
        +   stemcell: default
        +   syslog_aggregator: 
        +   templates:
        +   - name: binary_storage
        +     release: paas-ta-portal-release
        +   vm_type: portal_large
        + - azs:
        +   - z5
        +   instances: 1
        +   name: haproxy
        +   networks:
        +   - name: service_private
        +     static_ips:
        +     - 10.30.107.213
        +   - default:
        +     - dns
        +     - gateway
        +     name: portal_service_public
        +     static_ips: 115.68.46.214
        +   stemcell: default
        +   syslog_aggregator: 
        +   templates:
        +   - name: haproxy
        +     release: paas-ta-portal-release
        +   vm_type: portal_large
        + - azs:
        +   - z5
        +   instances: 1
        +   name: paas-ta-portal-gateway
        +   networks:
        +   - name: service_private
        +     static_ips:
        +     - 10.30.107.214
        +   properties:
        +     eureka:
        +       client:
        +         serviceUrl:
        +           defaultZone: "<redacted>"
        +   stemcell: default
        +   syslog_aggregator: 
        +   templates:
        +   - name: paas-ta-portal-gateway
        +     release: paas-ta-portal-release
        +   vm_type: portal_medium
        + - azs:
        +   - z5
        +   instances: 1
        +   name: paas-ta-portal-registration
        +   networks:
        +   - name: service_private
        +     static_ips:
        +     - 10.30.107.215
        +   properties:
        +     infra:
        +       admin:
        +         enable: "<redacted>"
        +     java_opts: "<redacted>"
        +     server:
        +       port: "<redacted>"
        +   stemcell: default
        +   syslog_aggregator: 
        +   templates:
        +   - name: paas-ta-portal-registration
        +     release: paas-ta-portal-release
        +   vm_type: portal_small
        + - azs:
        +   - z5
        +   instances: 1
        +   name: paas-ta-portal-api
        +   networks:
        +   - name: service_private
        +     static_ips:
        +     - 10.30.107.217
        +   properties:
        +     abacus:
        +       url: "<redacted>"
        +     cloudfoundry:
        +       authorization: "<redacted>"
        +       cc:
        +         api:
        +           sslSkipValidation: "<redacted>"
        +           uaaUrl: "<redacted>"
        +           url: "<redacted>"
        +       user:
        +         admin:
        +           password: "<redacted>"
        +           username: "<redacted>"
        +         uaaClient:
        +           adminClientId: "<redacted>"
        +           adminClientSecret: "<redacted>"
        +           clientId: "<redacted>"
        +           clientSecret: "<redacted>"
        +           loginClientId: "<redacted>"
        +           loginClientSecret: "<redacted>"
        +           skipSSLValidation: "<redacted>"
        +     eureka:
        +       client:
        +         serviceUrl:
        +           defaultZone: "<redacted>"
        +     monitoring:
        +       api:
        +         url: "<redacted>"
        +     paasta:
        +       api:
        +         portal:
        +           zuul:
        +             url: "<redacted>"
        +   stemcell: default
        +   syslog_aggregator: 
        +   templates:
        +   - name: paas-ta-portal-api
        +     release: paas-ta-portal-release
        +   vm_type: portal_large
        + - azs:
        +   - z5
        +   instances: 1
        +   name: paas-ta-portal-log-api
        +   networks:
        +   - name: service_private
        +     static_ips:
        +     - 10.30.107.218
        +   properties:
        +     cloudfoundry:
        +       authorization: "<redacted>"
        +       cc:
        +         api:
        +           sslSkipValidation: "<redacted>"
        +           uaaUrl: "<redacted>"
        +           url: "<redacted>"
        +       user:
        +         admin:
        +           password: "<redacted>"
        +           username: "<redacted>"
        +         uaaClient:
        +           adminClientId: "<redacted>"
        +           adminClientSecret: "<redacted>"
        +           clientId: "<redacted>"
        +           clientSecret: "<redacted>"
        +           loginClientId: "<redacted>"
        +           loginClientSecret: "<redacted>"
        +           skipSSLValidation: "<redacted>"
        +     eureka:
        +       client:
        +         serviceUrl:
        +           defaultZone: "<redacted>"
        +     paasta:
        +       api:
        +         portal:
        +           zuul:
        +             url: "<redacted>"
        +   stemcell: default
        +   syslog_aggregator: 
        +   templates:
        +   - name: paas-ta-portal-log-api
        +     release: paas-ta-portal-release
        +   vm_type: portal_medium
        + - azs:
        +   - z5
        +   instances: 1
        +   name: paas-ta-portal-common-api
        +   networks:
        +   - name: service_private
        +     static_ips:
        +     - 10.30.107.219
        +   properties:
        +     datasource:
        +       cc:
        +         driver-class-name: "<redacted>"
        +         password: "<redacted>"
        +         url: "<redacted>"
        +         username: "<redacted>"
        +       portal:
        +         driver-class-name: "<redacted>"
        +         password: "<redacted>"
        +         url: "<redacted>"
        +         username: "<redacted>"
        +       uaa:
        +         driver-class-name: "<redacted>"
        +         password: "<redacted>"
        +         url: "<redacted>"
        +         username: "<redacted>"
        +     eureka:
        +       client:
        +         serviceUrl:
        +           defaultZone: "<redacted>"
        +     mail:
        +       smtp:
        +         host: "<redacted>"
        +         password: "<redacted>"
        +         port: "<redacted>"
        +         properties:
        +           auth: "<redacted>"
        +           authUrl: "<redacted>"
        +           charset: "<redacted>"
        +           createUrl: "<redacted>"
        +           expiredUrl: "<redacted>"
        +           inviteUrl: "<redacted>"
        +           maximumTotalQps: "<redacted>"
        +           starttls:
        +             enable: "<redacted>"
        +             required: "<redacted>"
        +           subject: "<redacted>"
        +         useremail: "<redacted>"
        +         username: "<redacted>"
        +     paasta:
        +       api:
        +         portal:
        +           zuul:
        +             url: "<redacted>"
        +   stemcell: default
        +   syslog_aggregator: 
        +   templates:
        +   - name: paas-ta-portal-common-api
        +     release: paas-ta-portal-release
        +   vm_type: portal_medium
        + - azs:
        +   - z5
        +   instances: 1
        +   name: paas-ta-portal-storage-api
        +   networks:
        +   - name: service_private
        +     static_ips:
        +     - 10.30.107.220
        +   properties:
        +     eureka:
        +       client:
        +         serviceUrl:
        +           defaultZone: "<redacted>"
        +     objectStorage:
        +       swift:
        +         authMethod: "<redacted>"
        +         authUrl: "<redacted>"
        +         container: "<redacted>"
        +         password: "<redacted>"
        +         preferredRegion: "<redacted>"
        +         tenantName: "<redacted>"
        +         username: "<redacted>"
        +   stemcell: default
        +   syslog_aggregator: 
        +   templates:
        +   - name: paas-ta-portal-storage-api
        +     release: paas-ta-portal-release
        +   vm_type: portal_medium
        + - azs:
        +   - z5
        +   instances: 1
        +   name: paas-ta-portal-webadmin
        +   networks:
        +   - name: service_private
        +     static_ips:
        +     - 10.30.107.221
        +   properties:
        +     eureka:
        +       client:
        +         serviceUrl:
        +           defaultZone: "<redacted>"
        +     paasta:
        +       api:
        +         portal:
        +           zuul:
        +             url: "<redacted>"
        +   stemcell: default
        +   syslog_aggregator: 
        +   templates:
        +   - name: paas-ta-portal-webadmin
        +     release: paas-ta-portal-release
        +   vm_type: portal_medium
        + - azs:
        +   - z5
        +   instances: 1
        +   name: paas-ta-portal-webuser
        +   networks:
        +   - name: service_private
        +     static_ips:
        +     - 10.30.107.222
        +   properties:
        +     cf:
        +       uaa:
        +         clientsecret: "<redacted>"
        +         url: "<redacted>"
        +     gatewayserver:
        +       ip: "<redacted>"
        +     logPath: "<redacted>"
        +     portallogapi:
        +       ip: "<redacted>"
        +     webDir: "<redacted>"
        +   stemcell: default
        +   syslog_aggregator: 
        +   templates:
        +   - name: paas-ta-portal-webuser
        +     release: paas-ta-portal-release
        +   vm_type: portal_medium
          
        + name: paasta-portal-ui
          
        + properties:
        +   binary_storage:
        +     auth_port: "<redacted>"
        +     binary_desc:
        +     - "<redacted>"
        +     container:
        +     - "<redacted>"
        +     email:
        +     - "<redacted>"
        +     password:
        +     - "<redacted>"
        +     proxy_ip: "<redacted>"
        +     proxy_port: "<redacted>"
        +     tenantname:
        +     - "<redacted>"
        +     username:
        +     - "<redacted>"
        +   eurekaserver:
        +     ip: "<redacted>"
        +   gatewayserver:
        +     ip: "<redacted>"
        +   infradmin:
        +     ip: "<redacted>"
        +   mariadb:
        +     admin_user:
        +       password: "<redacted>"
        +     haproxy:
        +       urls:
        +       - "<redacted>"
        +     host: "<redacted>"
        +     host_ips:
        +     - "<redacted>"
        +     host_names:
        +     - "<redacted>"
        +     port: "<redacted>"
        +   webadmin:
        +     ip: "<redacted>"
        +   webuser:
        +     ip: "<redacted>"

		Continue? [yN]: y
        
        Task 4773
        Task 4773 | 06:55:36 | Preparing deployment: Preparing deployment (00:00:03)
        Task 4773 | 06:55:43 | Preparing package compilation: Finding packages to compile (00:00:00)
        Task 4773 | 06:55:43 | Compiling packages: paas-ta-portal-webuser/e3901a2d9e9cd349a06fee226bc3230e1c91b430
        Task 4773 | 06:55:43 | Compiling packages: paas-ta-portal-webadmin/a74db51496832a2b1e1e947c424d08b33fb46c83
        Task 4773 | 06:58:39 | Compiling packages: paas-ta-portal-webadmin/a74db51496832a2b1e1e947c424d08b33fb46c83 (00:02:56)
        Task 4773 | 06:58:59 | Compiling packages: paas-ta-portal-webuser/e3901a2d9e9cd349a06fee226bc3230e1c91b430 (00:03:16)
        Task 4773 | 06:59:03 | Compiling packages: haproxy/14b0441f6d68c89612f53ce4334a65c80d601e51
        Task 4773 | 06:59:18 | Compiling packages: java/86d8b8f8115418addf836753c1735abe547d4105
        Task 4773 | 07:00:07 | Compiling packages: mariadb/59a218308c6c7dcf8795b531b53aa4a1c666ce00
        Task 4773 | 07:00:10 | Compiling packages: java/86d8b8f8115418addf836753c1735abe547d4105 (00:00:52)
        Task 4773 | 07:00:17 | Compiling packages: haproxy/14b0441f6d68c89612f53ce4334a65c80d601e51 (00:01:14)
        Task 4773 | 07:01:16 | Compiling packages: mariadb/59a218308c6c7dcf8795b531b53aa4a1c666ce00 (00:01:09)
        Task 4773 | 07:05:04 | Creating missing vms: mariadb/ecb93167-602a-45d7-bcbc-502a3802c1f1 (0)
        Task 4773 | 07:05:04 | Creating missing vms: haproxy/d579d961-90bc-437c-96b8-6c23db2884ca (0)
        Task 4773 | 07:05:04 | Creating missing vms: paas-ta-portal-webadmin/969fcecc-943a-4f50-a00d-3d5f1bc65609 (0)
        Task 4773 | 07:05:04 | Creating missing vms: paas-ta-portal-webuser/07db9f77-faa8-4490-afdf-3287a82a497d (0) (00:03:32)
        Task 4773 | 07:08:38 | Creating missing vms: mariadb/ecb93167-602a-45d7-bcbc-502a3802c1f1 (0) (00:03:34)
        Task 4773 | 07:08:54 | Creating missing vms: paas-ta-portal-webadmin/969fcecc-943a-4f50-a00d-3d5f1bc65609 (0) (00:03:50)
        Task 4773 | 07:08:55 | Creating missing vms: haproxy/d579d961-90bc-437c-96b8-6c23db2884ca (0) (00:03:51)
        Task 4773 | 07:09:02 | Updating instance mariadb: mariadb/ecb93167-602a-45d7-bcbc-502a3802c1f1 (0) (canary)
        Task 4773 | 07:09:02 | Updating instance paas-ta-portal-webuser: paas-ta-portal-webuser/07db9f77-faa8-4490-
        Task 4773 | 07:09:02 | Updating instance haproxy: haproxy/d579d961-90bc-437c-96b8-6c23db2884ca (0) (canary)
        Task 4773 | 07:09:02 | Updating instance paas-ta-portal-webadmin: paas-ta-portal-webadmin/969fcecc-943a-4f50-a00d-3d5f1bc65609 (0) (canary)
        Task 4773 | 07:09:53 | Updating instance paas-ta-portal-webuser: paas-ta-portal-webuser/07db9f77-faa8-4490-afdf-3287a82a497d (0) (canary) (00:00:51)
        Task 4773 | 07:09:56 | Updating instance haproxy: haproxy/d579d961-90bc-437c-96b8-6c23db2884ca (0) (canary) (00:00:54)
        Task 4773 | 07:10:12 | Updating instance paas-ta-portal-webadmin: paas-ta-portal-webadmin/969fcecc-943a-4f50-a00d-3d5f1bc65609 (0) (canary) (00:01:10)
        Task 4773 | 07:12:09 | Updating instance mariadb: mariadb/ecb93167-602a-45d7-bcbc-502a3802c1f1 (0) (canary) (00:03:07)
        
        
        Task 4773 Started  Mon Sep  3 06:55:36 UTC 2018
        Task 4773 Finished Mon Sep  3 07:13:13 UTC 2018
        Task 4773 Duration 00:17:37
        Task 4773 done
        
        Succeeded



-	배포된 PaaS-TA Portal UI를 확인한다.

- **사용 예시**

```
    bosh -e micro-bosh -d paasta-portal-ui vms
    Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)
    
    Task 4823. Done
    
    Deployment 'paasta-portal-ui'
    
    Instance                                                      Process State  AZ  IPs            VM CID                                   VM Type       Active  
    haproxy/5c30c643-94d1-491c-9f6c-e72de4b0e6a4                  running        z7  10.30.56.10    vm-891ff2dd-4ee0-4c42-8fa8-b2d0cf0b8537  portal_tiny   true  
                                                                                     115.68.46.180                                                           
    mariadb/19bf81a9-cde9-432b-87ca-cbac1f28854a                  running        z6  10.30.56.9     vm-7a6f8042-e9b8-434c-abbf-776bbfd3386d  portal_small  true  
    paas-ta-portal-webadmin/bc536f61-10bd-4702-af5f-5e63500e110e  running        z6  10.30.56.11    vm-176ccac5-f154-4420-b821-9ed30a18f3e2  portal_small  true  
    paas-ta-portal-webuser/409c038b-d013-41d3-b6b2-aebb4a02d908   running        z6  10.30.56.12    vm-d9cf481f-64c7-45fd-aadb-e4eb1b31945a  portal_tiny   true  
    
    4 vms
    
    Succeeded

```
### 2.4. 사용자의 조직 생성 Flag 활성화
PaaS-TA는 기본적으로 일반 사용자는 조직을 생성할 수 없도록 설정되어 있다. 포털 배포를 위해 조직 및 공간을 생성해야 하고 또 테스트를 구동하기 위해서도 필요하므로 사용자가 조직을 생성할 수 있도록 user_org_creation FLAG를 활성화 한다. FLAG 활성화를 위해서는 PaaS-TA 운영자 계정으로 로그인이 필요하다.

```
$ cf enable-feature-flag user_org_creation
```
```
Setting status of user_org_creation as admin...
OK

Feature user_org_creation Enabled.
```

### 2.5. 사용자포탈 UAA페이지 오류
>![paas-ta-portal-31]
1. uaac portalclient가 등록이 되어있지 않다면 해당 화면과 같이 redirect오류가 발생한다.
2. uaac client add를 통해 potalclient를 추가시켜주어야 한다.
    > $ uaac target\
    $ uaac token client get\
        Client ID:  admin\
        Client secret:  *****
        
3. uaac client add portalclient –s “portalclient Secret” 
>--redirect_uri "사용자포탈 Url, 사용자포탈 Url/callback"\
$ uaac client add portalclient -s xxxxx --redirect_uri "http://portal-web-user.xxxx.xip.io, http://portal-web-user.xxxx.xip.io/callback" \
--scope "cloud_controller_service_permissions.read , openid , cloud_controller.read , cloud_controller.write , cloud_controller.admin" \
--authorized_grant_types "authorization_code , client_credentials , refresh_token" \
--authorities="uaa.resource" \
--autoapprove="openid , cloud_controller_service_permissions.read"

 >![paas-ta-portal-32]
1. uaac portalclient가 url이 잘못 등록되어있다면 해당 화면과 같이 redirect오류가 발생한다. 
2. uaac client update를 통해 url을 수정해야한다.
   > $ uaac target\
    $ uaac token client get\
   Client ID:  admin\
   Client secret:  *****
3. uaac client update portalclient --redirect_uri "사용자포탈 Url, 사용자포탈 Url/callback"
    >$ uaac client update portalclient --redirect_uri "http://portal-web-user.xxxx.xip.io, http://portal-web-user.xxxx.xip.io/callback"

### 2.6. 운영자 포탈 유저 페이지 조회 오류
1. 페이지 이동시 정보를 가져오지 못하고 오류가 났을 경우 common-api VM으로 이동후에 DB 정보 config를 수정후 재시작을 해 주어야 한다.


# 3. PaaS-TA Portal 운영
### 3.1. Log
Paas-TA Portal 각각 Instance의 log를 확인 할 수 있다.
1. 로그를 확인할 Instance에 접근한다.
    > bosh ssh -d [deployment name] [instance name]
       
       Instance                                                          Process State  AZ  IPs            VM CID                                   VM Type        Active   
       haproxy/8cc2d633-2b43-4f3d-a2e8-72f5279c11d5                      running        z5  10.30.107.213  vm-315bfa1b-9829-46de-a19d-3bd65e9f9ad4  portal_large   true  
                                                                                            115.68.46.214                                                            
       mariadb/117cbf05-b223-4133-bf61-e15f16494e21                      running        z5  10.30.107.211  vm-bc5ae334-12d4-41d4-8411-d9315a96a305  portal_large   true  
       paas-ta-portal-webadmin/8047fcbd-9a98-4b61-b161-0cbb277fa643      running        z5  10.30.107.221  vm-188250fd-e918-4aab-9cbe-7d368852ea8a  portal_medium  true  
       paas-ta-portal-webuser/cb206717-81c9-49ed-a0a8-e6c3b957cb66       running        z5  10.30.107.222  vm-822f68a5-91c8-453a-b9b3-c1bbb388e377  portal_medium  true  
       
       11 vms
       
       Succeeded
       inception@inception:~$ bosh ssh -d paas-ta-portal-ui paas-ta-portal-webadmin  << instance 접근(bosh ssh) 명령어 입력
       Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)
       
       Using deployment 'paas-ta-portal-webadmin'
       
       Task 5195. Done
       Unauthorized use is strictly prohibited. All access and activity
       is subject to logging and monitoring.
       Welcome to Ubuntu 14.04.5 LTS (GNU/Linux 4.4.0-92-generic x86_64)
       
        * Documentation:  https://help.ubuntu.com/
       
       The programs included with the Ubuntu system are free software;
       the exact distribution terms for each program are described in the
       individual files in /usr/share/doc/*/copyright.
       
       Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
       applicable law.
       
       Last login: Tue Sep  4 07:11:42 2018 from 10.30.20.28
       To run a command as administrator (user "root"), use "sudo <command>".
       See "man sudo_root" for details.
       
       paas-ta-portal-webadmin/48fa0c5a-52eb-4ae8-a7b9-91275615318c:~$ 

2. 로그파일이 있는 폴더로 이동한다.
    > 위치 : /var/vcap/sys/log/[job name]/
    
         paas-ta-portal-webadmin/48fa0c5a-52eb-4ae8-a7b9-91275615318c:~$ cd /var/vcap/sys/log/paas-ta-portal-webadmin/
         paas-ta-portal-webadmin/48fa0c5a-52eb-4ae8-a7b9-91275615318c:/var/vcap/sys/log/paas-ta-portal-webadmin$ ls
         paas-ta-portal-webadmin.stderr.log  paas-ta-portal-webadmin.stdout.log

3. 로그파일을 열어 내용을 확인한다.
    > vim [job name].stdout.log
        
        예)
        vim paas-ta-portal-webadmin.stdout.log
        2018-09-04 02:08:42.447 ERROR 7268 --- [nio-2222-exec-1] p.p.a.e.GlobalControllerExceptionHandler : Error message : Response : org.springframework.security.web.firewall.FirewalledResponse@298a1dc2
        Occured an exception : 403 Access token denied.
        Caused by...
        org.cloudfoundry.client.lib.CloudFoundryException: 403 Access token denied. (error="access_denied", error_description="Access token denied.")
                at org.cloudfoundry.client.lib.oauth2.OauthClient.createToken(OauthClient.java:114)
                at org.cloudfoundry.client.lib.oauth2.OauthClient.init(OauthClient.java:70)
                at org.cloudfoundry.client.lib.rest.CloudControllerClientImpl.initialize(CloudControllerClientImpl.java:187)
                at org.cloudfoundry.client.lib.rest.CloudControllerClientImpl.<init>(CloudControllerClientImpl.java:163)
                at org.cloudfoundry.client.lib.rest.CloudControllerClientFactory.newCloudController(CloudControllerClientFactory.java:69)
                at org.cloudfoundry.client.lib.CloudFoundryClient.<init>(CloudFoundryClient.java:138)
                at org.cloudfoundry.client.lib.CloudFoundryClient.<init>(CloudFoundryClient.java:102)
                at org.openpaas.paasta.portal.api.service.LoginService.login(LoginService.java:47)
                at org.openpaas.paasta.portal.api.controller.LoginController.login(LoginController.java:51)
                at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
                at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
                at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
                at java.lang.reflect.Method.invoke(Method.java:498)
                at org.springframework.web.method.support.InvocableHandlerMethod.doInvoke(InvocableHandlerMethod.java:205)
                at org.springframework.web.method.support.InvocableHandlerMethod.invokeForRequest(InvocableHandlerMethod.java:133)
                at org.springframework.web.servlet.mvc.method.annotation.ServletInvocableHandlerMethod.invokeAndHandle(ServletInvocableHandlerMethod.java:97)
                at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.invokeHandlerMethod(RequestMappingHandlerAdapter.java:827)
                at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.handleInternal(RequestMappingHandlerAdapter.java:738)
                at org.springframework.web.servlet.mvc.method.AbstractHandlerMethodAdapter.handle(AbstractHandlerMethodAdapter.java:85)
                at org.springframework.web.servlet.DispatcherServlet.doDispatch(DispatcherServlet.java:967)
                at org.springframework.web.servlet.DispatcherServlet.doService(DispatcherServlet.java:901)
                at org.springframework.web.servlet.FrameworkServlet.processRequest(FrameworkServlet.java:970)
                at org.springframework.web.servlet.FrameworkServlet.doPost(FrameworkServlet.java:872)
                at javax.servlet.http.HttpServlet.service(HttpServlet.java:661)
                at org.springframework.web.servlet.FrameworkServlet.service(FrameworkServlet.java:846)
                at javax.servlet.http.HttpServlet.service(HttpServlet.java:742)
                at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:231)
                at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166)
                at org.apache.tomcat.websocket.server.WsFilter.doFilter(WsFilter.java:52)
                at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193)
                at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166)

### 3.2. 카탈로그 적용
##### 1. Catalog 빌드팩, 서비스팩 추가
Paas-TA Portal 설치 후에 관리자 포탈에서 빌드팩, 서비스팩을 등록해야 사용자 포탈에서 사용이 가능하다.
 
 1. 관리자 포탈에 접속한다.(portal-web-admin.[public ip].xip.io)
    >![paas-ta-portal-15]
 2. 운영관리를 누른다.
    >![paas-ta-portal-16]
 2. 카탈로그 페이지에 들어간다.
    >![paas-ta-portal-17]
 3. 빌드팩, 서비스팩 상세화면에 들어가서 각 항목란에 값을 입력후에 저장을 누른다.
    >![paas-ta-portal-18]
 4. 사용자포탈에서 변경된값이 적용되어있는지 확인한다.
    >![paas-ta-portal-19] 
    
### 3.3. 모니터링 및 오토스케일링 적용
##### 1. 포탈 설치 이전 모니터링 설정 적용
###### PaaS-TA 에서 제공하고있는 모니터링을 미리 설치를 한 후에 진행해야 한다.
 1. Paas-TA Portal 설치전 2.3. PaaS-TA Portal Deployment 배포의 deploy-{Iaas}.sh 설정단계에서 
    monitoring_api_url= 모니터링 url, portal_webuser_monitoring = true로 적용한 후 배포를 하면 정상적으로
    모니터링 페이지 및 오토스케일링을 사용할 수 있다.
##### 2. 포탈 설치 이후 모니터링 설정 적용
 1. 사용자 포탈의 앱 상세 페이지로 이동한다.
    >![paas-ta-portal-30]
 2. ① 상세페이지 레이아웃 하단의 모니터링 버튼을 누른다.
    
 3. ② 모니터링 오토 스케일링 화면
    
 4. ③ 모니터링 알람 설정 화면
    
 5. 추이차트 탭에서 디스크 메모리 네트워크 사용량을 인스턴스 별로 확인이 가능하다.        
    
[paas-ta-portal-01]:../../install-guide/portal/images/Paas-TA-Portal_01.png
[paas-ta-portal-02]:../../install-guide/portal/images/Paas-TA-Portal_02.png
[paas-ta-portal-03]:../../install-guide/portal/images/Paas-TA-Portal_03.png
[paas-ta-portal-04]:../../install-guide/portal/images/Paas-TA-Portal_04.png
[paas-ta-portal-05]:../../install-guide/portal/images/Paas-TA-Portal_05.png
[paas-ta-portal-06]:../../install-guide/portal/images/Paas-TA-Portal_06.png
[paas-ta-portal-07]:../../install-guide/portal/images/Paas-TA-Portal_07.png
[paas-ta-portal-08]:../../install-guide/portal/images/Paas-TA-Portal_08.png
[paas-ta-portal-09]:../../install-guide/portal/images/Paas-TA-Portal_09.png
[paas-ta-portal-10]:../../install-guide/portal/images/Paas-TA-Portal_10.png
[paas-ta-portal-11]:../../install-guide/portal/images/Paas-TA-Portal_11.png
[paas-ta-portal-12]:../../install-guide/portal/images/Paas-TA-Portal_12.png
[paas-ta-portal-13]:../../install-guide/portal/images/Paas-TA-Portal_13.png
[paas-ta-portal-14]:../../install-guide/portal/images/Paas-TA-Portal_14.png
[paas-ta-portal-15]:../../install-guide/portal/images/Paas-TA-Portal_15.png
[paas-ta-portal-16]:../../install-guide/portal/images/Paas-TA-Portal_16.png
[paas-ta-portal-17]:../../install-guide/portal/images/Paas-TA-Portal_17.png
[paas-ta-portal-18]:../../install-guide/portal/images/Paas-TA-Portal_18.png
[paas-ta-portal-19]:../../install-guide/portal/images/Paas-TA-Portal_19.png
[paas-ta-portal-20]:../../install-guide/portal/images/Paas-TA-Portal_20.png
[paas-ta-portal-21]:../../install-guide/portal/images/Paas-TA-Portal_21.png
[paas-ta-portal-22]:../../install-guide/portal/images/Paas-TA-Portal_22.png
[paas-ta-portal-23]:../../install-guide/portal/images/Paas-TA-Portal_23.png
[paas-ta-portal-24]:../../install-guide/portal/images/Paas-TA-Portal_24.png
[paas-ta-portal-25]:../../install-guide/portal/images/Paas-TA-Portal_25.png
[paas-ta-portal-26]:../../install-guide/portal/images/Paas-TA-Portal_26.png
[paas-ta-portal-27]:../../install-guide/portal/images/Paas-TA-Portal_27.PNG
[paas-ta-portal-28]:../../install-guide/portal/images/Paas-TA-Portal_28.PNG
[paas-ta-portal-29]:../../install-guide/portal/images/Paas-TA-Portal_29.png
[paas-ta-portal-30]:../../install-guide/portal/images/Paas-TA-Portal_30.png
[paas-ta-portal-31]:../../install-guide/portal/images/Paas-TA-Portal_27.jpg
[paas-ta-portal-32]:../../install-guide/portal/images/Paas-TA-Portal_28.jpg
