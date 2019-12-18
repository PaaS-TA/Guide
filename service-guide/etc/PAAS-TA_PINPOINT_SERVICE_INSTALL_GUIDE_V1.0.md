## Table of Contents
1. [문서 개요](#1)
  - 1.1. [목적](#11)
  - 1.2. [범위](#12)
  - 1.3. [시스템 구성도](#13)
  - 1.4. [참고자료](#14)
2. [Pinpoint 서비스팩 설치](#2)
  - 2.1. [설치전 준비사항](#21)
  - 2.2. [Pinpoint 서비스 릴리즈 업로드](#22)
  - 2.3. [Pinpoint 서비스 Deployment 파일 수정 및 배포](#23)
  - 2.4. [Pinpoint 서비스 브로커 등록](#24)
3. [Sample Web App 연동 Pinpoint 연동](#3)
  - 3.1. [Sample Web App 구조](#31)
  - 3.2. [PaaS-TA에서 서비스 신청](#32)
  - 3.3. [Sample Web App에 서비스 바인드 신청 및 App 확인](#33)

# <div id='1'> 1. 문서 개요
### <div id='11'> 1.1. 목적

본 문서(Pinpoint 서비스팩 설치 가이드)는 전자정부표준프레임워크 기반의 PaaS-TA에서 제공되는 서비스팩인 Pinpoint 서비스팩을 Bosh2.0을 이용하여 설치 하는 방법과 PaaS-TA의 SaaS 형태로 제공하는 Application 에서 Pinpoint 서비스를 사용하는 방법을 기술하였다.
PaaS-TA 3.5 버전부터는 Bosh2.0 기반으로 deploy를 진행하며 기존 Bosh1.0 기반으로 설치를 원할경우에는 PaaS-TA 3.1 이하 버전의 문서를 참고한다.

### <div id='12'> 1.2. 범위
설치 범위는 Pinpoint 서비스팩을 검증하기 위한 기본 설치를 기준으로 작성하였다.

### <div id='13'> 1.3. 시스템 구성도

본 문서의 설치된 시스템 구성도입니다. Pinpoint Server, HBase의 HBase Master2, HBase Slave2, Collector 2, Pinpoint 서비스 브로커, WebUI3로 최소사항을 구성하였다.

![시스템구성도][pinpoint_image_01]

<table>
  <tr>
    <th>구분</th>
    <th>Resource Pool</th>
    <th>스펙</th>
  </tr>
  <tr>
  <td>Collector/0      </td><td>pinpoint\_medium</td><td>2vCPU / 2GB RAM / 8GB Disk</td>
  </tr>
  <tr>
  <td>Collector/1      </td><td>pinpoint\_medium</td><td>2vCPU / 2GB RAM / 8GB Disk</td>
  </tr>
  <tr>
  <td>h\_master/0      </td><td>pinpoint\_medium</td><td>2vCPU / 2GB RAM / 8GB Disk</td>
  </tr>
  <tr>
  <td>h\_secondary     </td><td>pinpoint\_ small</td><td>1vCPU / 1GB RAM / 4GB Disk</td>
  </tr>
  <tr>
  <td>h\_slave/0       </td><td>services-small </td><td>1vCPU / 1GB RAM / 4GB Disk</td>
  </tr>
  <tr>
  <td>h\_slave/1       </td><td>services-small </td><td>1vCPU / 1GB RAM / 4GB Disk</td>
  </tr>
  <tr>
  <td>haproxy\_webui/0 </td><td>services-small </td><td>1vCPU / 1GB RAM / 4GB Disk</td>
  </tr>
  <tr>
  <td>pinpoint\_broker/0</<td>services-small </td><td>1vCPU / 1GB RAM / 4GB Disk</td>
  </tr>
  <tr>
  <td>webui/0          </0><td>services-small </td><td>1vCPU / 1GB RAM / 4GB Disk</td>
  </tr>
  <tr>
  <td>webui/1          </td><td>services-small </td><td>1vCPU / 1GB RAM / 4GB Disk</td>
  </tr>
</table>

### <div id='14'> 1.4. 참고자료
[**http://bosh.io/docs**](http://bosh.io/docs)
[**http://docs.cloudfoundry.org/**](http://docs.cloudfoundry.org/)

# <div id='2'> 2. Pinpoint 서비스팩 설치

### <div id='21'> 2.1. 설치전 준비사항

본 설치 가이드는 Linux 환경에서 설치하는 것을 기준으로 하였다.
서비스팩 설치를 위해서는 BOSH 2.0과 PaaS-TA 5.0, PaaS-TA 포털이 설치되어 있어야 한다.

- PaaS-TA에서 제공하는 압축된 릴리즈 파일들을 다운받는다. (PaaSTA-Deployment.zip, PaaSTA-Sample-Apps.zip, PaaSTA-Services.zip)

- 다운로드 위치
>Download : **<https://paas-ta.kr/download/package>**

### <div id='22'> 2.2. Pinpoint 서비스 릴리즈 업로드

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
	    	paas-ta-portal-release            1.0*      non-git
	    	paasta-delivery-pipeline-release  1.0*      b3ee8f48+
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

-	Pinpoint 서비스 릴리즈가 업로드 되어 있지 않은 것을 확인

-	Pinpoint 서비스 릴리즈 파일을 업로드한다.

- **사용 예시**

		$ bosh -e micro-bosh upload-release paasta-pinpoint-release.tgz
        Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)

		######################################################## 100.00% 119.48 MiB/s 6s
        Task 604436

        Task 604436 | 06:38:45 | Extracting release: Extracting release (00:00:05)
        Task 604436 | 06:38:51 | Verifying manifest: Verifying manifest (00:00:00)
        Task 604436 | 06:38:51 | Resolving package dependencies: Resolving package dependencies (00:00:00)
        Task 604436 | 06:38:51 | Creating new packages: bosh-helpers/e818e2120b03e3340d2813ee8e8a0627f6750d52329f54c1b932843a3aa9cc3f (00:00:00)
        Task 604436 | 06:38:51 | Creating new packages: broker/7b93b205d289989b2fc57ab775331f7938a3150f44247b4f6a77661db961b226 (00:00:00)
        Task 604436 | 06:38:51 | Creating new packages: collector/a833cd6414788c05ea4633965aee8393290b2bf0c4c5d8118e13788c50d5f334 (00:00:01)
        Task 604436 | 06:38:52 | Creating new packages: hadoop/54a95c16685fefc6f80757d663b0f0f80d64f454ca1fef5e7f60fff288409bdf (00:00:04)
        Task 604436 | 06:38:56 | Creating new packages: haproxy/36b96cd676e6369d65ea2458b8700b9545927c445bc47de6653de51ef779a3d5 (00:00:00)
        Task 604436 | 06:38:56 | Creating new packages: hbase/2f41aa099754a83cf9eaee352568928abe28c421b54e74a9fd6aec9da8d72b55 (00:00:02)
        Task 604436 | 06:38:58 | Creating new packages: java/0b3dcab5e65a3de7ab25f0b356578300a138bbf7d068b94d158927ea76f15165 (00:00:02)
        Task 604436 | 06:39:01 | Creating new packages: pinpoint_web/fe6382870b3ea67157ee0dc30874450b230de52d36c57262f1c7a63fd7fe8b38 (00:00:01)
        Task 604436 | 06:39:02 | Creating new packages: tomcat/c8b9799b07a35c301a885ba9fb23f1568d3d0f466d2d9f0c3b37ca99fea51b9d (00:00:00)
        Task 604436 | 06:39:02 | Creating new jobs: broker/350ed3e701721b348ffc4b2a903e16944bf8cee01c3ddafc539b75a5db476ff9 (00:00:00)
        Task 604436 | 06:39:02 | Creating new jobs: collector/3134bb21112e6c1ae3074cd025bbb4bab987028175f755f8c84b8ca049eda308 (00:00:00)
        Task 604436 | 06:39:02 | Creating new jobs: h_master/f8db37c7eeab582e4b0e124b10c239941476161832c74cdaa689f192477fe2d7 (00:00:01)
        Task 604436 | 06:39:03 | Creating new jobs: haproxy_webui/0f3c3e1bfb49d4e32b2d3ee142d26b14d0f380e38439de45bf69fa7c25b53285 (00:00:00)
        Task 604436 | 06:39:03 | Creating new jobs: pinpoint_web/c0ccf5e7794c113ef9984cbab8456cf08d022d6c62fd3e42da646898332f12e3 (00:00:00)
        Task 604436 | 06:39:03 | Release has been created: paasta-pinpoint-release/1.0 (00:00:00)

        Task 604436 Started  Fri Sep  6 06:38:45 UTC 2019
        Task 604436 Finished Fri Sep  6 06:39:03 UTC 2019
        Task 604436 Duration 00:00:18
        Task 604436 done

        Succeeded


-	업로드 된 Pinpoint 릴리즈를 확인한다.

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
		paas-ta-portal-release            2.0*      non-git
		paasta-delivery-pipeline-release  1.0*      b3ee8f48+
		paasta-mysql                      2.0       85e3f01e+
		paasta-pinpoint                   1.0*      2dbb8bf3+
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

-	Pinpoint 서비스 릴리즈가 업로드 되어 있는 것을 확인

-	Deploy시 사용할 Stemcell을 확인한다.

- **사용 예시**

		$ bosh -e micro-bosh stemcells
		Name                                       Version  OS             CPI  CID
		bosh-openstack-kvm-ubuntu-xenial-go_agent  315.64*  ubuntu-xenial  -    240752b1-b1f9-43ed-8e96-7f3e4f269d71

		(*) Currently deployed

		 stemcells

		Succeeded


### <div id='23'> 2.3. Pinpoint 서비스 Deployment 파일 및 deploy-pinpoint-bosh2.0.sh 수정 및 배포

BOSH Deployment manifest 는 components 요소 및 배포의 속성을 정의한 YAML 파일이다.
Deployment manifest 에는 sotfware를 설치 하기 위해서 어떤 Stemcell (OS, BOSH agent) 을 사용할것이며 Release (Software packages, Config templates, Scripts) 이름과 버전, VMs 용량, Jobs params 등을 정의가 되어 있다.

deployment 파일에서 사용하는 network, vm_type 등은 cloud config 를 활용하고 해당 가이드는 Bosh2.0 가이드를 참고한다.

-	cloud config 내용 조회

- **사용 예시**

		$ bosh -e micro-bosh cloud-config
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

		Succeeded


-	Deployment 파일을 서버 환경에 맞게 수정한다.

```yaml
# paasta-pinpoint-vsphere 설정 파일 내용
name: "((deployment_name))"                           # 서비스 배포이름(필수)

update:
  canaries: 1                            # canary 인스턴스 수(필수)
  canary_watch_time: 120000              # canary 인스턴스가 수행하기 위한 대기 시간(필수)
  update_watch_time: 120000              # non-canary 인스턴스가 수행하기 위한 대기 시간(필수)
  max_in_flight: 8                       # non-canary 인스턴스가 병렬로 update 하는 최대 개수(필수)

stemcells:
- alias: "((stemcell_alias))"
  os: "((stemcell_os))"
  version: "((stemcell_version))"

releases:
- name: "((releases_name))"                  # 서비스 릴리즈 이름(필수) bosh releases로 확인 가능
  version: "latest"                                             # 서비스 릴리즈 버전(필수):latest 시 업로드된 서비스 릴리즈 최신버전

instance_groups:
- name: h_master                          #작업 이름(필수)
  azs:
  - z3
  instances: 1                            # job 인스턴스 수(필수)
  vm_type: "((vm_type))"
  stemcell: "((stemcell_alias))"
  persistent_disk_type: "((mariadb_disk_type))"
  networks:                               # 네트워크 구성정보
  - name: "((internal_networks_name))"                         # Networks block에서 선언한 network 이름(필수)
  jobs:
  - name: h_master
    release: "((releases_name))"
  syslog_aggregator: null
  properties:
    pem_key: ((pem_key))
    PemSSH: ((PemSSH))

- name: collector                          #작업 이름(필수)
  azs:
  - z3
  instances: 1                            # job 인스턴스 수(필수)
  vm_type: "((vm_type))"
  stemcell: "((stemcell_alias))"
  persistent_disk_type: "((mariadb_disk_type))"
  networks:                               # 네트워크 구성정보
  - name: "((internal_networks_name))"                         # Networks block에서 선언한 network 이름(필수)
  jobs:
  - name: collector
    release: "((releases_name))"
  syslog_aggregator: null

- name: pinpoint_web                          #작업 이름(필수)
  azs:
  - z3
  instances: 1                            # job 인스턴스 수(필수)
  vm_type: "((vm_type))"
  stemcell: "((stemcell_alias))"
  persistent_disk_type: "((mariadb_disk_type))"
  networks:                               # 네트워크 구성정보
  - name: "((internal_networks_name))"                         # Networks block에서 선언한 network 이름(필수)
  jobs:
  - name: pinpoint_web
    release: "((releases_name))"
  syslog_aggregator: null

- name: broker                          #작업 이름(필수)
  azs:
  - z3
  instances: 1                            # job 인스턴스 수(필수)
  vm_type: "((vm_type))"
  stemcell: "((stemcell_alias))"
  persistent_disk_type: "((mariadb_disk_type))"
  networks:                               # 네트워크 구성정보
  - name: "((internal_networks_name))"                         # Networks block에서 선언한 network 이름(필수)
  jobs:
  - name: broker
    release: "((releases_name))"
  syslog_aggregator: null

- name: haproxy_webui                          #작업 이름(필수)
  azs:
  - z7
  instances: 1                            # job 인스턴스 수(필수)
  vm_type: "((vm_type))"
  stemcell: "((stemcell_alias))"
  persistent_disk_type: "((mariadb_disk_type))"
  networks:                               # 네트워크 구성정보
  - name: "((internal_networks_name))"                         # Networks block에서 선언한 network 이름(필수)
  - name: "((external_networks_name))"
    static_ips: "((haproxy_public_ip))"
  jobs:
  - name: haproxy_webui
    release: "((releases_name))"
  syslog_aggregator: null

properties:                                # Pinpoint 설정정보
  master:                                  # Pinpoint master 설정정보
    replication: 1                         # Pinpoint master 복제개수
    tcp_listen_port: 29994                 # Pinpoint master tcp port
  broker:                                  # Pinpoint broker 설정정보
    collector_tcp_port: 29994              # Pinpoint collector tcp port 설정정보
    collector_stat_port: 29995             # Pinpoint collector stat port 설정정보
    collector_span_port: 29996             # Pinpoint collector span port 설정정보
    dashboard_uri: http://((haproxy_public_ip)):80/#/main   # Pinpoint dashboard url 설정정보
  yarn:                                    # Pinpoint yarn 설정정보
    resource_tracker_port: 8025            # Pinpoint yarn resource_tracker_port
    scheduler_port: 8030                   # Pinpoint yarn scheduler_port
    resourcemanager_port: 8040             # Pinpoint yarn resourcemanager_port

```

-	deploy-pinpoint-bosh2.0.sh 파일을 서버 환경에 맞게 수정한다.

```sh
#!/bin/bash
# 프로퍼티 설정은 pinpoint_property.yml을 통해 수정을 한다.

bosh -e micro-bosh -d paasta-pinpoint-service deploy paasta_pinpoint_bosh2.0.yml \
     -o use-public-network-vsphere.yml \
     -l pinpoint_property.yml\
     -l pem.yml

```

```paata_pinpoint.yml
#!/bin/bash

---
### Pinpoint Bosh Deployment Name Setting ###
deployment_name: paasta-pinpoint-service                       #PinPoint_Deployment name
#
#### Main Stemcells Setting ###
stemcell_os: ubuntu-xenial                                      # Deployment Main Stemcell OS
stemcell_version: latest                                       # Main Stemcell Version
stemcell_alias: default                                         # Main Stemcell Alias
#
#### VM Type
vm_type: caas_small_highmem
#
#### Pinpoint Release Deployment Setting ###
releases_name :  paasta-pinpoint-release                              # Pinpoint Release Name
internal_networks_name : default                        # Some Network From Your 'bosh cloud-config(cc)'
external_networks_name : vip
haproxy_public_ip : xx.xx.xxx.xxx
mariadb_disk_type : 30GB # MariaDB Disk Type 'bosh cloud-config(cc)'
PemSSH : true                                           # BOSH VM 접속할 SSH PemKey를 설정했으면 true 아닐경우 false를 입력한다.  true 설정시 pem.yml에 pemkey값을 넣는다.
#
```



-	Pinpoint 서비스팩을 배포한다.

- **사용 예시**

		$ ./deploy-pinpoint-bosh2.0.sh
		Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)

		Using deployment 'paasta-pinpoint-service'

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

		+ name: paasta-pinpoint-service

		Continue? [yN]: y

		Task 4506

		Task 4506 | 06:04:10 | Preparing deployment: Preparing deployment (00:00:01)
		Task 4506 | 06:04:12 | Preparing package compilation: Finding packages to compile (00:00:00)
		Task 4506 | 06:04:12 | Compiling packages: cli/24305e50a638ece2cace4ef4803746c0c9fe4bb0
		Task 4506 | 06:04:12 | Compiling packages: openjdk-1.8.0_45/57e0ee876ea9d90f5470e3784ae1171bccee850a
		Task 4506 | 06:04:12 | Compiling packages: op-mysql-java-broker/3bf47851b2c0d3bea63a0c58452df58c14a15482
		Task 4506 | 06:04:12 | Compiling packages: syslog_aggregator/078da6dcb999c1e6f5398a6eb739182ccb4aba25
		Task 4506 | 06:04:12 | Compiling packages: common/ba480a46c4b2aa9484fb24ed01a8649453573e6f
		Task 4506 | 06:06:53 | Compiling packages: syslog_aggregator/078da6dcb999c1e6f5398a6eb739182ccb4aba25 (00:02:41)
		Task 4506 | 06:06:53 | Compiling packages: golang/f57ddbc8d55d7a0f08775bf76bb6a27dc98c7ea7
		Task 4506 | 06:06:55 | Compiling packages: common/ba480a46c4b2aa9484fb24ed01a8649453573e6f (00:02:43)
		Task 4506 | 06:06:55 | Compiling packages: python/4e255efa754d91b825476b57e111345f200944e1
		Task 4506 | 06:06:55 | Compiling packages: cli/24305e50a638ece2cace4ef4803746c0c9fe4bb0 (00:02:43)
		Task 4506 | 06:06:55 | Compiling packages: check/d6811f25e9d56428a9b942631c27c9b24f5064dc
		Task 4506 | 06:07:05 | Compiling packages: op-mysql-java-broker/3bf47851b2c0d3bea63a0c58452df58c14a15482 (00:02:53)
		Task 4506 | 06:07:05 | Compiling packages: boost/3eb8bdb1abb7eff5b63c4c5bdb41c0a778925c31
		Task 4506 | 06:07:10 | Compiling packages: openjdk-1.8.0_45/57e0ee876ea9d90f5470e3784ae1171bccee850a (00:02:58)
		Task 4506 | 06:07:53 | Compiling packages: golang/f57ddbc8d55d7a0f08775bf76bb6a27dc98c7ea7 (00:01:00)
		Task 4506 | 06:07:53 | Compiling packages: switchboard/fad565dadbb37470771801952001c7071e55a364
		Task 4506 | 06:07:53 | Compiling packages: route-registrar/f3fdfb8c940e7227a96c06e413ae6827aba8eeda
		Task 4506 | 06:07:55 | Compiling packages: check/d6811f25e9d56428a9b942631c27c9b24f5064dc (00:01:00)
		Task 4506 | 06:07:55 | Compiling packages: gra-log-purger/f02fa5774ab54dbb1b1c3702d03cb929b85d60e6
		Task 4506 | 06:08:30 | Compiling packages: route-registrar/f3fdfb8c940e7227a96c06e413ae6827aba8eeda (00:00:37)
		Task 4506 | 06:08:30 | Compiling packages: galera-healthcheck/3da4dedbcd7d9f404a19e7720e226fd472002266
		Task 4506 | 06:08:31 | Compiling packages: gra-log-purger/f02fa5774ab54dbb1b1c3702d03cb929b85d60e6 (00:00:36)
		Task 4506 | 06:08:31 | Compiling packages: mariadb_ctrl/7658290da98e2cad209456f174d3b9fa143c87fc
		Task 4506 | 06:08:32 | Compiling packages: switchboard/fad565dadbb37470771801952001c7071e55a364 (00:00:39)
		Task 4506 | 06:08:58 | Compiling packages: galera-healthcheck/3da4dedbcd7d9f404a19e7720e226fd472002266 (00:00:28)
		Task 4506 | 06:08:59 | Compiling packages: mariadb_ctrl/7658290da98e2cad209456f174d3b9fa143c87fc (00:00:28)
		Task 4506 | 06:09:42 | Compiling packages: boost/3eb8bdb1abb7eff5b63c4c5bdb41c0a778925c31 (00:02:37)
		Task 4506 | 06:11:27 | Compiling packages: python/4e255efa754d91b825476b57e111345f200944e1 (00:04:32)
		Task 4506 | 06:11:27 | Compiling packages: scons/11e7ad3b28b43a96de3df7aa41afddde582fcc38 (00:00:22)
		Task 4506 | 06:11:49 | Compiling packages: galera/d15a1d2d15e5e7417278d4aa1b908566022b9623 (00:13:18)
		Task 4506 | 06:25:07 | Compiling packages: mariadb/43aa3547bc5a01dd51f1501e6b93c215dd7255e9 (00:18:49)
		Task 4506 | 06:43:56 | Compiling packages: xtrabackup/2e701e7a9e4241b28052d984733de36aae152275 (00:10:26)
		Task 4506 | 06:55:22 | Creating missing vms: mysql/ea075ae6-6326-478b-a1ba-7fbb0b5b0bf5 (0)
		Task 4506 | 06:55:22 | Creating missing vms: mysql/e8c52bf2-cd48-45d0-9553-f6367942a634 (2)
		Task 4506 | 06:55:22 | Creating missing vms: proxy/023edddd-418e-46e4-8d40-db452c694e16 (0)
		Task 4506 | 06:55:22 | Creating missing vms: mysql/8a830154-25b6-432a-ad39-9ff09d015760 (1)
		Task 4506 | 06:55:22 | Creating missing vms: paasta-mysql-java-broker/bb5676ca-efba-48fc-bc11-f464d0ae9c78 (0)
		Task 4506 | 06:57:18 | Creating missing vms: mysql/ea075ae6-6326-478b-a1ba-7fbb0b5b0bf5 (0) (00:01:56)
		Task 4506 | 06:57:23 | Creating missing vms: proxy/023edddd-418e-46e4-8d40-db452c694e16 (0) (00:02:01)
		Task 4506 | 06:57:23 | Creating missing vms: mysql/e8c52bf2-cd48-45d0-9553-f6367942a634 (2) (00:02:01)
		Task 4506 | 06:57:23 | Creating missing vms: paasta-mysql-java-broker/bb5676ca-efba-48fc-bc11-f464d0ae9c78 (0) (00:02:01)
		Task 4506 | 06:57:23 | Creating missing vms: mysql/8a830154-25b6-432a-ad39-9ff09d015760 (1) (00:02:01)
		Task 4506 | 06:57:24 | Updating instance mysql: mysql/ea075ae6-6326-478b-a1ba-7fbb0b5b0bf5 (0) (canary) (00:02:32)
		Task 4506 | 06:59:56 | Updating instance mysql: mysql/8a830154-25b6-432a-ad39-9ff09d015760 (1) (00:03:03)
		Task 4506 | 07:02:59 | Updating instance mysql: mysql/e8c52bf2-cd48-45d0-9553-f6367942a634 (2) (00:03:04)
		Task 4506 | 07:06:03 | Updating instance proxy: proxy/023edddd-418e-46e4-8d40-db452c694e16 (0) (canary) (00:01:01)
		Task 4506 | 07:07:04 | Updating instance paasta-mysql-java-broker: paasta-mysql-java-broker/bb5676ca-efba-48fc-bc11-f464d0ae9c78 (0) (canary) (00:01:02)

		Task 4506 Started  Fri Aug 31 06:04:10 UTC 2018
		Task 4506 Finished Fri Aug 31 07:08:06 UTC 2018
		Task 4506 Duration 01:03:56
		Task 4506 done

		Succeeded

-	배포된 Pinpoint 서비스팩을 확인한다.

- **사용 예시**

		$ bosh -e micro-bosh -d paasta-pinpoint-service vms
		Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)

		Task 5006. Done

		Deployment 'paasta-pinpoint-service'

		Instance                                              Process State  AZ  IPs            VM CID                                   VM Type  Active
		collector/5f10f9cf-67ed-4c08-8c14-99d7f7a818c2        running        z5  10.30.107.145  vm-1714d225-85fa-4236-94db-7ed26baa52b3  minimal  true
		h_master/723a34d6-0756-41e2-b11e-1530596cbb09         running        z5  10.30.107.175  vm-037e021b-3dba-4ea3-961c-6bd259d25c4b  minimal  true
		haproxy_webui/22999f9c-0798-43a5-b93b-bc5d44c4d210    running        z5  10.30.107.178  vm-294e229c-aa89-4a5c-9960-4009579bbf54  minimal  true
											 xxx.xx.xx.xx3
		pinpoint_broker/7a9d8423-c5f9-4e3c-be16-42e9215f8268  running        z5  10.30.107.182  vm-1b9b0891-8a02-45af-8b0c-ca21bf56e64e  minimal  true
		webui/30f7c9cf-ab03-4f78-a9bf-96c5148a9ec1            running        z5  10.30.107.180  vm-62d5e876-2ab4-4327-ba54-2f74b53e3da9  minimal  true

		5 vms

		Succeeded


### <div id='24'> 2.4. Pinpoint 서비스 브로커 등록

Pinpoint 서비스팩 배포가 완료 되었으면 Application에서 서비스 팩을 사용하기 위해서 먼저 Pinpoint 서비스 브로커를 등록해 주어야 한다.

서비스 브로커 등록시 PaaS-TA에서 서비스브로커를 등록 할 수 있는 사용자로 로그인이 되어 있어야 한다.

-   서비스 브로커 목록을 확인한다.

```
$ cf service-brokers
```
```
Getting service brokers as admin...

name   url
No service brokers found
```

-   Pinpoint 서비스 브로커를 등록한다.

```
$ cf create-service-broker {서비스브로커 이름} {서비스브로커 사용자ID} {서비스브로커 사용자비밀번호} http://{서비스브로커 URL(IP)}
```
```
서비스브로커 이름 : 서비스브로커 관리를 위해 PaaS-TA에서 보여지는 명칭이다. 서비스 Marketplace에서는 각각의 API 서비스 명이 보여지니 여기서 명칭은 서비스브로커 명칭이다.

서비스브로커 사용자ID / 비밀번호 : 서비스팩에 접근할 수 있는 사용자 ID입니다. 서비스브로커도 하나의 API 서버이기 때문에 아무나 접근을 허용할 수 없어 접근이 가능한 ID/비밀번호를 입력한다.

서비스브로커 URL : 서비스브로커가 제공하는 API를 사용할 수 있는 URL을 입력한다.
```

```
$ cf create-service-broker pinpoint-service-broker admin cloudfoundry http://<URL(IP)>:8080
```
```
Creating service broker pinpoint-service-broker as admin...
OK
```

-   등록된 Pinpoint 서비스 브로커를 확인한다.

```
$ cf service-brokers
```
```
Getting service brokers as admin...
name url
pinpoint-service-broker http://URL(IP):8080
```

-   접근 가능한 서비스 목록을 확인한다.

```
$ cf service-access
```
```
Getting service access as admin...
broker: Pinpoint-service-broker
service plan access orgs
Pinpoint Pinpoint\_standard none
```
서비스 브로커 생성시 디폴트로 접근을 허용하지 않는다.

-   특정 조직에 해당 서비스 접근 허용을 할당하고 접근 서비스 목록을 다시 확인한다. (전체 조직)

```
$ cf enable-service-access Pinpoint
```

```
Enabling access to all plans of service Pinpoint for all orgs as admin...
OK
```

서비스 접근 허용을 확인한다.
```
$ cf service-access
```
```
Getting service access as admin...
broker: Pinpoint-service-broker
service plan access orgs
Pinpoint Pinpoint\_standard all
```

#  <div id='3'> 3. Sample Web App 연동 Pinpoint 연동

본 Sample Web App은 개방형 클라우드 플랫폼에 배포되며 Pinpoint의 서비스를 Provision과 Bind를 한 상태에서 사용이 가능하다.

### <div id='31'> 3.1. Sample Web App 구조

Sample Web App은 PaaS-TA에 App으로 배포가 된다. 배포된 App에 Pinpoint 서비스 Bind 를 통하여 초기 데이터를 생성하게 된다. 바인드 완료 후 연결 url을 통하여 브라우저로 해당 App에 대한 Pinpoint 서비스 모니터링을 할 수 있다.

-   Spring-music App을 이용하여 Pinpoint 모니터링을 테스트 하였다.
-   앱을 다운로드 후 –b 옵션을 주어 buildpack을 지정하여 push 해 놓는다.

```
$ cf push -b java_buildpack_pinpoint --no-start
```

```
Using manifest file /home/ubuntu/workspace/bd_test/spring-music/manifest.yml

Creating app spring-music-pinpoint in org org / space space as admin...
OK

Creating route spring-music-pinpoint.monitoring.open-paas.com...
OK

Binding spring-music-pinpoint.monitoring.open-paas.com to spring-music-pinpoint...
OK

Uploading spring-music-pinpoint...
Uploading app files from: /tmp/unzipped-app175965484
Uploading 21.2M, 126 files
Done uploading
OK
```

```
$ cf apps
```
```
Getting apps in org org / space space as admin...
OK

name                    requested state   instances   memory   disk   urls
php-demo                started           1/1         256M     1G     php-demo.monitoring.open-paas.com
spring-music            stopped           0/1         512M     1G     spring-music.monitoring.open-paas.com
spring-music-pinpoint   stopped           0/1         512M     1G     spring-music-pinpoint.monitoring.open-paas.com
```

### <div id='32'> 3.2. PaaS-TA에서 서비스 신청

Sample Web App에서 Pinpoint 서비스를 사용하기 위해서는 서비스 신청(Provision)을 해야 한다.

\*참고: 서비스 신청시 PaaS-TA에서 서비스를 신청 할 수 있는
사용자로 로그인이 되어 있어야 한다.

-   먼저 PaaS-TA Marketplace에서 서비스가 있는지 확인을 한다.

```
$ cf marketplace
```

```
Getting services from marketplace in org org / space space as admin...
OK

service    plans               description
Pinpoint   Pinpoint_standard   A simple pinpoint implementation
```

-   Marketplace에서 원하는 서비스가 있으면 서비스 신청(Provision)을 하여 서비스 인스턴스를 생성한다.

```
$ cf create-service {서비스명} {서비스플랜} {내서비스명}
```
```
서비스명 : p-Pinpoint로 Marketplace에서 보여지는 서비스 명칭이다.
서비스플랜 : 서비스에 대한 정책으로 plans에 있는 정보 중 하나를 선택한다. Pinpoint 서비스는 10 connection, 100 connection 를 지원한다.
내서비스명 : 내 서비스에서 보여지는 명칭이다. 이 명칭을 기준으로 환경설정정보를 가져온다.

```

```
$ cf create-service Pinpoint Pinpoint_standard PS1
```
```
Creating service instance PS1 in org org / space space as admin...
OK
```

-   생성된 Pinpoint 서비스 인스턴스를 확인한다.

```
$ cf services
```
```
Getting services in org org / space space as admin...
OK

name                     service                  plan                 bound apps   last
PS1                      Pinpoint                 Pinpoint_standard                 create succeeded   pinpoint-service-broker
```

### <div id='33'> 3.3. Sample Web App에 서비스 바인드 신청 및 App 확인

서비스 신청이 완료되었으면 Sample Web App 에서는 생성된 서비스 인스턴스를 Bind 하여 App에서 Pinpoint 서비스를 이용한다.

\*참고: 서비스 Bind 신청시 PaaS-TA 플랫폼에서 서비스 Bind신청 할 수 있는 사용자로 로그인이 되어 있어야 한다.

-   Sample Web App에서 생성한 서비스 인스턴스 바인드 신청을 한다.

- 서비스 인스턴스 확인
```
$ cf s
```
```
Getting services in org org / space space as admin...
OK

name                     service                  plan                 bound apps   last
PS1                      Pinpoint                 Pinpoint_standard                 create
my_rabbitmq_service      p-rabbitmq               standard                          create succeeded   rabbitmq-service-broker

```
- 서비스 바인드
```:q!

$ cf bind-service spring-music-pinpoint PS1 -c '{"application_name":"spring-music"}'
```
```
Binding service PS1 to app spring-music-pinpoint in org org / space space as admin...
OK
TIP: Use 'cf restage spring-music-pinpoint' to ensure your env variable changes take effect
```

**cf cli 리눅스 버전 :**
```
cf bind-service <application이름> PS1 -c ‘{"application_name\":"<application이름>"}
```

**cf cli window 버전 :**
```
cf bind-service <application이름> PS1 -c "{\"application_name\":\"<application이름>\"}"
```

-   바인드가 적용되기 위해서 App을 restage한다.

```
$ cf restage spring-music-pinpoint
```
```

Restaging app spring-music-pinpoint in org org / space space as admin...
Downloading binary_buildpack...
Downloading go_buildpack...
Downloading staticfile_buildpack...
Downloading java_buildpack...
Downloading ruby_buildpack...
Downloading nodejs_buildpack...
Downloading python_buildpack...
Downloading php_buildpack...
Downloaded python_buildpack
Downloaded binary_buildpack
Downloaded go_buildpack
Downloaded java_buildpack
Downloaded ruby_buildpack
Downloaded nodejs_buildpack
Downloaded staticfile_buildpack
Downloaded php_buildpack
Creating container
Successfully created container
Downloading app package...
Downloaded app package (24.5M)
Downloading build artifacts cache...
Downloaded build artifacts cache (54.1M)
Staging...
-----> Java Buildpack Version: v3.7.1 | https://github.com/cloudfoundry/java-buildpack.git#78c3d0a
-----> Downloading Open Jdk JRE 1.8.0_91-unlimited-crypto from https://java-buildpack.cloudfoundry.org/openjdk/trusty/x86_64/openjdk-1.8.0_91-unlimited-crypto.tar.gz (found in cache)
     Expanding Open Jdk JRE to .java-buildpack/open_jdk_jre (1.6s)
-----> Downloading Open JDK Like Memory Calculator 2.0.2_RELEASE from https://java-buildpack.cloudfoundry.org/memory-calculator/trusty/x86_64/memory-calculator-2.0.2_RELEASE.tar.gz (found in cache)
     Memory Settings: -XX:MaxMetaspaceSize=64M -Xss995K -Xmx382293K -Xms382293K -XX:MetaspaceSize=64M
-----> Downloading Spring Auto Reconfiguration 1.10.0_RELEASE from https://java-buildpack.cloudfoundry.org/auto-reconfiguration/auto-reconfiguration-1.10.0_RELEASE.jar (found in cache)
-----> Downloading Tomcat Instance 8.0.39 from https://java-buildpack.cloudfoundry.org/tomcat/tomcat-8.0.39.tar.gz (found in cache)
     Expanding Tomcat Instance to .java-buildpack/tomcat (0.1s)
-----> Downloading Tomcat Lifecycle Support 2.5.0_RELEASE from https://java-buildpack.cloudfoundry.org/tomcat-lifecycle-support/tomcat-lifecycle-support-2.5.0_RELEASE.jar (found in cache)
-----> Downloading Tomcat Logging Support 2.5.0_RELEASE from https://java-buildpack.cloudfoundry.org/tomcat-logging-support/tomcat-logging-support-2.5.0_RELEASE.jar (found in cache)
-----> Downloading Tomcat Access Logging Support 2.5.0_RELEASE from https://java-buildpack.cloudfoundry.org/tomcat-access-logging-support/tomcat-access-logging-support-2.5.0_RELEASE.jar (found in cache)
Exit status 0
Staging complete
Uploading droplet, build artifacts cache...
Uploading droplet...
Uploading build artifacts cache...
Uploaded build artifacts cache (54.1M)
Uploaded droplet (77.3M)
Uploading complete

0 of 1 instances running, 1 starting
0 of 1 instances running, 1 starting
0 of 1 instances running, 1 starting
1 of 1 instances running

App started


OK
```

-   App이 정상적으로 Pinpoint 서비스를 사용하는지 확인한다.

![pinpoint_image_03]


-  환경변수 확인

```
$ cf env spring-music-pinpoint
```
```
Getting env variables for app spring-music-pinpoint in org org / space space as admin...
OK

System-Provided:
{
"VCAP_SERVICES": {
"Pinpoint": [
 {
  "credentials": {
   "application_name": "spring-music",
   "collector_host": "10.244.2.30",
   "collector_span_port": 29996,
   "collector_stat_port": 29995,
   "collector_tcp_port": 29994
  },
  "label": "Pinpoint",
  "name": "PS1",
  "plan": "Pinpoint_standard",
  "provider": null,
  "syslog_drain_url": null,
  "tags": [
   "pinpoint"
  ],
  "volume_mounts": []
 }
]
}
}

{
"VCAP_APPLICATION": {
"application_id": "b010e6e9-5431-4198-81f8-7d6ba9c14f40",
"application_name": "spring-music-pinpoint",
"application_uris": [
 "spring-music-pinpoint.monitoring.open-paas.com"
],
"application_version": "9a600116-97bd-45da-a33e-3b0d5592b1d0",
"limits": {
 "disk": 1024,
 "fds": 16384,
 "mem": 512
},
"name": "spring-music-pinpoint",
"space_id": "bc70b951-d870-49ca-b57d-5c7137060e5e",
"space_name": "space",
"uris": [
 "spring-music-pinpoint.monitoring.open-paas.com"
],
"users": null,
"version": "9a600116-97bd-45da-a33e-3b0d5592b1d0"
}
}

No user-defined env variables have been set

No running env variables have been set

No staging env variables have been set
```

- App 정상 구동 확인
```
$ curl http://<URL(IP)>/#/main/spring-music-pinpoint@TOMCAT
```

[pinpoint_image_01]:/service-guide/images/pinpoint/pinpoint-image1.png
[pinpoint_image_02]:/service-guide/images/pinpoint/pinpoint-image2.png
[pinpoint_image_03]:/service-guide/images/pinpoint/pinpoint-image3.png
