# Table of Contents
1. [문서 개요](#1)
	* [목적](#2)
	* [범위](#3)
2. [플랫폼 설치 가이드](#4)
    * [인프라 설정](#5)
	* [스템셀과 릴리즈](#6)
	  * [PaaS-TA 사용자 포털 스템셀](#8)
	* [BOOTSTRAP 및 PaaS-TA 설치하기](#9)
	* [PaaS-TA 사용자 포털 배포하기](#14)
	  * [PaaS-TA 사용자 포털 스템셀 업로드](#15)
	  * [PaaS-TA 사용자 포털 릴리즈 업로드](#16)
	  * [Routing Service 설정](#17)
	  * [PaaS-TA 사용자 포털 배포 전 사전 점검](#18)
	  * [PaaS-TA 사용자 포털 배포](#19)


# <div id='1'/>1.  문서 개요

## <div id='2'/>1.1.  목적

본 문서는 CLI 기반으로 PaaS-TA 사용자 포털을 구축하는 절차에 대해 기술하였다.

## <div id='3'/>1.2.  범위

본 문서에서는 Cloudit 인프라 환경에서 Kubernetes 기반의 PaaS-TA 사용자 포털을 설치하는 방법에 대해 작성되었다.

# <div id='4'/>2.  플랫폼 설치 가이드

BOSH는 클라우드 환경에 서비스를 배포하고 소프트웨어 릴리즈를 관리해주는 오픈 소스로 Bootstrap은 하나의 VM에 설치 관리자의 모든 컴포넌트를 설치한 것으로 PaaS-TA 사용자 포털 설치를 위한 관리자 기능을 담당한다. Cloudit 환경의 Bootstrap은 물리적인 하나의 VM이 아닌 컨테이너 기반으로 동작한다.

Cloudit 클라우드 환경에 PaaS-TA포털을 설치하기 위해서는 인프라 설정, 스템셀 소프트웨어 릴리즈, Manifest 파일, 인증서 파일 5가지 요소가 필요하다. 스템셀은 클라우드 환경에 VM을 생성하기 위해 사용할 기본 이미지이고, 소프트웨어 릴리즈는 VM에 설치할 소프트웨어 패키지들을 묶어 놓은 파일이고, Manifest파일은 스템셀과 소프트웨어 릴리즈를 이용해서 서비스를 어떤 식으로 구성할지를 정의해 놓은 명세서이다. 다음 그림은 BOOTSTRAP을 이용하여 PaaS-TA 사용자 포털을 설치하는 절차이다.


![Cloudit_PaaSTa_Platform_Use_Guide_Image01]


## <div id='5'/>2.1  인프라 설정
※ BOSH 및 PaaS-TA 설치(CLOUDit) [2.1  인프라 설정][Cloudit_Infra_setting] 참조  

#### 1. Cloudit 로드밸런서 생성 – HAProxy배포 VM ([2.4.5. PaaS-TA 사용자 포털 배포](#19) 이후 진행) – 네트워크<div id='23'/>
1.1.	로드밸런서 생성 중 Router 또는 HAProxy가 배포된 VM을 멤버로 등록시엔 다음과 같은 포트로 구성한다

<table>
	<tr>
		<td>대상</td>
		<td>용도</td>
		<td>LB 포트</td>
		<td>서버 포트</td>
		<td>비고</td>
	</tr>
	<tr>
		<td rowspan="5">
			HAProxy가 배포된 VM
		</td>
		<td>포털</td>
		<td>80</td>
		<td>30602</td>
		<td></td>
	</tr>
	<tr>
		<td>유레카</td>
		<td>2221</td>
		<td>30702</td>
		<td></td>
	</tr>

</table>

1.2.	Cloudit 포탈에 접속한다. 접속 주소: <a link="https://www.cloudit.co.kr">https://www.cloudit.co.kr</a>  
1.3.	네트워크 메뉴를 클릭한다.  
1.4.	로드밸런싱 메뉴를 클릭한다.  
1.5.	로드밸런싱 화면에서 “Create” 버튼을 클릭한다.

![Cloudit_PaaSTa_Platform_Use_Guide_Image19]

1.5.1.	로드밸런싱 생성 팝업에서 기본 정책을 입력 후 다음 버튼을 클릭한다.
![Cloudit_PaaSTa_Platform_Use_Guide_Image20]

※	이름 : 로드밸런서 이름 입력  
포트 : 로드밸런서 Port 입력 (상단 1.1 포트 구성표의 [LB 포트 항목](#23) 참조)  
유형 : 로드밸런서 IP 종류 선택  
(External : 로드밸런싱에서 이용할 Public VIP로 지정하여 사용  
Internal : 로드밸런싱 서브넷에서 사용)  
IP : 로드밸런서의 IP 이며 동일 IP로 여러 개의 Port 설정 가능하다. 해당 샘플에서는 Router 또는 HAProxy가 배포된 VM에 부여할 로드밸런싱 IP를 선택한다.  
프로토콜 : TCP 또는 HTTP 프로토콜  
정책 : 4가지 Load Balancing 정책 중 선택  

<table>
	<tr>
		<td>
			<b>Round Robin</b> : 순차적으로 세션을 연결하는 정책, 거의 균등한 부하 분산이 가능하나 세션 유지 불가능<br>
			<b>Least Connection</b> : 세션 요구량이 적은 쪽으로 신규 세션을 연결해주는 정책<br>
			<b>Source Hash</b> : 출발지의 IP 주소를 기반으로 Hash를 계산하여 항상 같은 목적지로 세션을 연결해주는 정책<br>
			<b>Destination Hash</b> : 목적지의 IP 주소를 기반으로 Hash를 계산하여 항상 같은 출발지와 세션을 연결해주는 정책
		</td>
	</tr>
</table>

1.5.2.	구성할 로드밸런서의 상태 체크 설정 및 멤버 등록 후 다음 버튼을 클릭한다.
![Cloudit_PaaSTa_Platform_Use_Guide_Image21]

※	모니터 타입 : 상태 체크 프로토콜 선택  
http 경로 : 모니터 타입이 HTTP인 경우 상태 체크 할 URL 입력  
응답대기 시간 : 로드밸런싱 응답 대기 시간 입력  
정상 판단 횟수 : 응답 대기 시간 동안 응답하지 않을 때 정상 판단 횟수  
상태 확인 주기(초) : 로드밸런싱 상태 확인 주기  
비정상 판단 횟수 : 상태 확인 주기동안 응답하지 않은 때 비정상 판단 횟수  
서버 IP : 로드밸런싱 정책에 의해 작동 될 물리 VM의 IP선택  
서버 포트 : 로드밸런싱 정책에 의해 작동 될 물리 VM의 Port 선택  
(상단 [1.1 포트 구성표](#23)의 서버 포트 항목 참조)


1.5.3	구성할 로드밸런싱의 최종 정보를 확인 후 확인 버튼을 클릭한다.
![Cloudit_PaaSTa_Platform_Use_Guide_Image22]


## <div id='6'/>2.2.  스템셀과 릴리즈
### <div id='8'/>2.2.1. **PaaS-TA 사용자 포털 스템셀**
Cloudit의 Kubernetes 환경에 배포 가능한 PaaS-TA 버전은 아래와 같다.
아래의 릴리즈 버전으로 다운로드&업로드 및 설치한다.

<table>
	<tr>
		<td>릴리즈</td>
		<td>스템셀</td>
	</tr>
	<tr>
		<td rowspan="2">paasta/4.0</td>
		<td>
			https://s3.amazonaws.com/bosh-core-stemcells/warden/bosh-stemcell-3468.51-warden-boshlite-ubuntu-trusty-go_agent.tgz
		</td>
	</tr>
	<tr>
		<td>
			https://s3.amazonaws.com/bosh-core-stemcells/warden/bosh-stemcell-3468.21-warden-boshlite-ubuntu-trusty-go_agent.tgz
		</td>
	</tr>
</table>



## <div id='9'/>2.3.  **BOOTSTRAP 및 PaaS-TA 설치하기**
BOSH 및 PaaS-TA 설치(CLOUDit) [2.3  BOOTSTRAP 설치하기][Cloudit_bootStrap_install] 참조  
BOSH 및 PaaS-TA 설치(CLOUDit) [2.4. CF-Deployment 배포하기][Cloudit_cf_install] 참조  



## <div id='14'/>2.4.  **PaaS-TA 사용자 포털 배포하기**
BOSH 및 PaaS-TA 배포가 완료되면 PaaS-TA 사용자 포털을 배포할 준비가 된 상태이며 PaaS-TA 사용자 포털을 배포하는 절차는 다음과 같다.
![Cloudit_PaaSTa_Platform_Use_Guide_Image01]


### <div id='15'/>2.4.1. **PaaS-TA 사용자 포털 스템셀 업로드**
URL을 통해 bosh-stemcell-3468.51-warden-boshlite-ubuntu-trusty-go_agent.tgz, bosh-stemcell-3468.21-warden-boshlite-ubuntu-trusty-go_agent.tgz 스템셀을 다운로드 후에 해당 스템셀을 Bosh에 업로드한다.

##### 1. PaaS-TA 사용자 포털 스템셀
1.1	PaaS-TA 사용자 포털 스템셀 참조 사이트
<table>
	<tr>
		<td>인프라 환경</td>
		<td>참조 사이트 및 참조 Manifest</td>
	</tr>
	<tr>
		<td rowspan="2">paasta/4.0</td>
		<td>
			<a link="https://s3.amazonaws.com/bosh-core-stemcells/warden/bosh-stemcell-3468.21-warden-boshlite-ubuntu-trusty-go_agent.tgz">
				https://s3.amazonaws.com/bosh-core-stemcells/warden/bosh-stemcell-3468.21-warden-boshlite-ubuntu-trusty-go_agent.tgz
			</a>
		</td>
	</tr>
	<tr>
		<td>
		<a link="https://s3.amazonaws.com/bosh-core-stemcells/warden/bosh-stemcell-3468.51-warden-boshlite-ubuntu-trusty-go_agent.tgz">
			https://s3.amazonaws.com/bosh-core-stemcells/warden/bosh-stemcell-3468.51-warden-boshlite-ubuntu-trusty-go_agent.tgz
		</td>
	</tr>
</table>


1.2	스템셀을 다운로드 후 Bosh에 업로드 한다.

	$ cd ~/workspace/releases/

\# 아래 명령어를 통해 스템셀을 다운로드 한다.

	$ wget https://s3.amazonaws.com/bosh-core-stemcells/warden/bosh-stemcell-3468.51-warden-boshlite-ubuntu-trusty-go_agent.tgz
	$ wget https://s3.amazonaws.com/bosh-core-stemcells/warden/bosh-stemcell-3468.21-warden-boshlite-ubuntu-trusty-go_agent.tgz

\# 아래 명령어를 통해 스템셀을 업로드 한다.

	$ bosh -e paasta upload-stemcell bosh-stemcell-3468.21-warden-boshlite-ubuntu-trusty-go_agent.tgz
	$ bosh -e paasta upload-stemcell bosh-stemcell-3468.51-warden-boshlite-ubuntu-trusty-go_agent.tgz

1.3	정상적으로 스템셀이 업로드 되었는지 확인한다.  
\# 업로드 된 스템셀을 확인한다.

	$ bosh -e paasta stemcells

### <div id='16'/>2.4.2. **PaaS-TA 사용자 포털 릴리즈 업로드**
PaaS-TA 사용자 포털 릴리즈를 다운로드 후 bosh에 릴리즈 생성 후 릴리즈를 업로드 한다.

##### 1. PaaS-TA 사용자 포털 릴리즈
1.1	PaaS-TA 사용자 포털 릴리즈 참조 사이트
<table>
	<tr>
		<td>릴리즈명</td>
		<td>참조 사이트 및 참조 Manifest</td>
	</tr>
	<tr>
		<td rowspan="2">paasta/4.0</td>
		<td>
			https://github.com/PaaS-TA/PAAS-TA-PORTAL-RELEASE의 v4.0-container Branch
		</td>
	</tr>
	<tr>
		<td>
			소스를 통해 릴리즈를 생성한다.
		</td>
	</tr>
</table>

1.2.	아래의 Git Repository 경로를 통해 PaaS-TA 사용자 포털 Release for container를 생성하기 위한 소스를 다운로드 받는다.

	$ cd workspace
	$ git clone https://github.com/PaaS-TA/PAAS-TA-PORTAL-RELEASE -b v4.0-container && cd PAAS-TA-PORTAL-RELEASE
	$ cd ./PAAS-TA-PORTAL-RELEASE
	$ wget -O src.zip http://45.248.73.44/index.php/s/JAQRFctz7Tn26qK/download
	$ unzip src.zip
	$ rm -rf src.zip

#### 2.	PaaS-TA 사용자 포털 Release for container 생성
2.1.	릴리즈를 생성한다.  
\# PaaS-TA 사용자 포털 for Container 릴리즈 생성

	$ bosh create-release --sha2 --force --tarball ./paasta-portal-release-4.0-container.tgz --name paasta-portal-release --version 4.0-container

#### 3.	PaaS-TA 사용자 포털 릴리즈 Bosh에 업로드
3.1.	준비된 릴리즈를 Bosh에 업로드 한다.

	$ cd ~/workspace/PAAS-TA-PORTAL-RELEASE
	$ bosh -e paasta upload-release ./paasta-portal-release-4.0-container.tgz

1.2.	릴리즈가 정상적으로 업로드 되었는지 확인한다.

	$ bosh -e paasta releases

### <div id='17'/>2.4.3. **Routing Service 설정**
PaaS-TA 사용자 포털을 배포하기 전 Routing Service를 설정한다.

##### 1. Routing Service인 Portal-Proxy-External 생성
1.1.	Portal-Proxy-External Service를 생성한다.  
\# 포털에 접근하기 위한 Routing Service인 portal-proxy-external.yaml 파일 확인

	$ cd {PaaS-TA-Project}/kubernetes/assets
	$ vi portal-proxy-external.yaml
![Cloudit_PaaSTa_Platform_Use_Guide_Image45]

※ http-proxy, eureka의 NodePort 정보 확인  
http-proxy, eureka에 대한 NodePort를 확인하여 PaaS-TA 사용자 포털 배포 이후 로드밸런서와 연결한다.

\# 관련 내용은 2.1.1 인프라 설정의 [Cloudit 로드밸런서 생성](#23) 설정을 참조한다.  
\# Routing Service를 생성한다.

	$ kubectl create -f portal-proxy-external.yaml -n paasta

1.2.	Portal-External Service가 생성되었는지 확인한다.  
\# portal-proxy와 eureka에 대한 NodePort를 확인한다.

	$ kubectl get service portal-user-ingress -n paasta
![Cloudit_PaaSTa_Platform_Use_Guide_Image46]

\# portal-proxy와 eureka에 대한 NodePort를 상세 확인한다.

	$ kubectl describe service portal-proxy-ingress -n paasta
![Cloudit_PaaSTa_Platform_Use_Guide_Image47]




### <div id='18'/>2.4.4. **PaaS-TA 사용자 포털 배포 전 사전 점검**
PaaS-TA 사용자 포털 배포 전 배포되는 릴리즈, IaaS 관련 Network/Storage/VM 관련 설정들을 정의하는 Cloud-Config 등의 Manifest 사전 점검을 한다.

#### 1.	PaaS-TA 사용자 포털 릴리즈 버전 점검
1.1	PaaS-TA 사용자 포털 Manifest를 확인한다.  
\# 아래 명령어를 통해 Manifest 내용을 점검한다.

	$ vi ~/workspace/{PaaS-TA-Project}/paasta-portal-4.0-container.yml
![Cloudit_PaaSTa_Platform_Use_Guide_Image48]

#### 2.	Cloud-config의 vm_extensions 점검
2.1	Cloud-config 내용을 확인한다.  
\# 아래 명령어를 통해 cloud-config의 vm_extensions 항목의 내용을 확인한다.

	$ bosh -e paasta cloud-config
![Cloudit_PaaSTa_Platform_Use_Guide_Image49]

#### 3. UAA portalclient 생성
3.1	portalclient를 생성한다.

	$ uaac target https://uaa.192.168.x.x.xip.io --skip-ssl-validation
![Cloudit_PaaSTa_Platform_Use_Guide_Image50]

\# admin_client_secet은 {PaaS-TA-Project}/cf-kubernetes/creds.yml 에서 확인 가능하다.

	$ vi ~/workspace/{PaaS-TA-Project}/cf-kubernetes/creds.yml
![Cloudit_PaaSTa_Platform_Use_Guide_Image51]

	$ uaac token client get admin -s admin_client_secret
![Cloudit_PaaSTa_Platform_Use_Guide_Image52]

	# client를 추가한다.
	$ uaac client add \
  	--name portalclient \
  	--scope cloud_controller_service_permissions.read,openid,cloud_controller.read,cloud_controller.write,cloud_controller.admin \
  	--authorities uaa.resource \
  	--redirect_uri http://portal-web-user.192.168.x.x.xip.io,http://portal-web-user.192.168.x.x.xip.io/callback \
  	--authorized_grant_types authorization_code,client_credentials,refresh_token  \
  	--secret portalclient \
	--autoapprove openid,cloud_controller_service_permissions.read \

※ 옵션에 대한 정보는 다음과 같다
--name 은 client의 이름이다.
--redirect_uri의 ip주소는 user-portal이 사용할 로드밸런서의 IP가 된다.
--secret은 client가 사용할 secret 명이다.

\# portalclient를 확인한다.

	$ uaac token client get portalclient -s portalclient
![Cloudit_PaaSTa_Platform_Use_Guide_Image53]


### <div id='19'/>2.4.5. **PaaS-TA 사용자 포털 배포**
PaaS-TA 포털을 설치하기 전 배포 관련된 각종 환경들을 스크립트에 설정 후 PaaS-TA 사용자 포털을 설치한다.

#### 1.	Kubernetes Cluster에 PaaS-TA 사용자 포털 배포
1.1.	PaaS-TA 사용자 포털을 배포하기 위한 정의파일과 옵션에 대해 수행 스크립트를 작성한다.

	$ cd ~/workspace/{PaaS-TA-Project}

\# PaaS-TA 사용자 포털 배포를 위한 스크립트를 다음과 같이 정의한다.

	$ vi paasta-portal-deploy-kubernetes.sh
![Cloudit_PaaSTa_Platform_Use_Guide_Image54]

※ 스크립트의 옵션 정보는 다음과 같다.

	# PaaS-TA 사용자 포털의 deployment에 대한 정의이며 -d 옵션은 PaaS-TA 사용자 포털 deployment 명을 지정한다.
	bosh -e paasta -d portal deploy -n paasta-portal-deployment/paastaportal-4.0-container.yml
	--vars-store paasta-portal-deployment/vars.yml
	-v releases_name="paasta-portal-release"           # 배포에 사용될 릴리즈 명을 명시한다.
	-v stemcell_os="ubuntu-trusty"                     # 배포에 사용될 스템셀 명을 명시한다.
	-v stemcell_version="3468.51"                      # 배포에 사용될 스템셀의 버전을 명시한다.
	-v stemcell_alias="default"                        # 스템셀 alias 지정
	-v vm_type_tiny="minimal"                          # vm의 tiny type 지정
	-v vm_type_small="small"                           # vm의 small type 지정
	-v vm_type_medium="small-highmem"                  # vm의 medium type 지정
	-v internal_networks_name="default"                # internal 네트워크명 지정
	-v external_networks_name="default"                # external 네트워크명 지정
	-v mariadb_disk_type="10GB"                        # mariadb의 disk type 지정
	-v mariadb_port="3306"                             # mariadb에서 사용할 port
	-v mariadb_user_password="password12"              # mariadb에서 사용할 user password 지정
	-v binary_storage_disk_type="10GB"                 # binary storage의 disk size 지정
	-v binary_storage_username="paasta-portal"         # binary storage의 user명 지정
	-v binary_storage_password="paasta"                # binary storage의 password 지정
	-v binary_storage_tenantname="paasta-portal"       # binary storage의 tenant명 지정
	-v binary_storage_email="paasta@paasta.com"        # binary storage의 email 지정

	# haproxy_public_ip : 표기되는 IP주소는 PaaS-TA 사용자 포털 deployment의 haproxy instance랑 연결되어질 로드밸런서의 IP 주소이다.
	# PaaS-TA 사용자 포털 배포 이전에 Cloudit 포탈의 가용한 로드밸런서의 IP를 미리 확보 후, 해당 IP(사용할)를 입력한다.
	# PaaS-TA 사용자 포털 배포 이후 아래 옵션에 입력된 haproxy_public_ip의 IP를 2.1.1 인프라 설정의 [Cloudit 로드밸런서 생성](#23) 항목을 참고하여 로드밸런싱 구성을 한다.
	-v haproxy_public_ip="192.168.x.x"

	# cf_db_ips : PaaS-TA Core(CF Deployment)의 배포된 instance 중 database에 해당하는 IP를 지정한다.
	# database instance의 IP 확인은 다음과 같다.
	# $ bosh -e paasta -d cf(CF 배포명) vms

![Cloudit_PaaSTa_Platform_Use_Guide_Image55]

	-v cf_db_ips="10.244.5.117"
	-v cf_db_port="5524"                              # cf database의 port 지정
	-v cc_db_id="cloud_controller"                    # cf database의 id 지정

	# cc_db_password : cloud controller의 db password 이며 PaaS-TA Core(CF)의 cloud controller가 배포가
	# 되어 있어야 한다. cloud controller의 password는 다음의 경로에서 확인 가능하다.
	# $ vi {PaaS-TA-Project}/cf-kubernetes/creds.yml

![Cloudit_PaaSTa_Platform_Use_Guide_Image56]

	-v cc_db_password="sd4ttnf384dfkculs616"
	-v cc_driver_name="mysql"                         # cloud controller의 database driver를 지정한다.
	-v uaa_db_id="uaa"                                # uaa database의 유저명을 지정한다.

	# uaa_db_password : uaa의 db password 이며 PaaS-TA Core(CF)의 uaa가 배포가 되어 있어야 한다.
	# uaa database의 password는 다음의 경로에서 확인 가능하다.
	# $ vi {PaaS-TA-Project}/cf-kubernetes/creds.yml

![Cloudit_PaaSTa_Platform_Use_Guide_Image57]

	-v uaa_db_password="2n93lzsqlixn9vds3w73"
	-v uaa_driver_name="mysql"                        # uaa 의 database driver를 지정한다.

	# cf_uaa_url : 표기되는 IP주소는 PaaS-TA Core(CF) deployment시 정의된 system_domain의 IP 주소와 동일하다.
	-v cf_uaa_url="https://uaa.192.168.x.x.xip.io"
	-v cf_uaa_logouturl="logout.do"                   # cf uaa 로그아웃시의 url을 지정한다.

	# cf_api_url : 표기되는 IP주소는 PaaS-TA Core(CF) deployment의 정의된 system_domain의 IP 주소와 동일하다.
	-v cf_api_url=https://api.192.168.x.x.xip.io

	# cf_admin_password : cf의 admin password 이며 PaaS-TA Core(CF) 가 배포가 되어 있어야 한다.
	# cf의 admin password는 다음의 경로에서 확인 가능하다.
	# $ vi {PaaS-TA-Project}cf-kubernetes/creds.yml

![Cloudit_PaaSTa_Platform_Use_Guide_Image58]

	-v cf_admin_password="oh8zwobgd1uxxsi3zq7c"

	# uaa_admin_client_secret : cf의 uaa admin secret 이며 PaaS-TA Core(CF)의 uaa가 배포가 되어 있어야 한다.
	# cf의 uaa admin client secret은 다음의 경로에서 확인 가능하다.
	# $ vi {PaaS-TA-Project}/cf-kubernetes/creds.yml

![Cloudit_PaaSTa_Platform_Use_Guide_Image59]

	-v uaa_admin_client_secret=”44sf9e5ss2dldqg17xx”
	# portal_client_secet의 값은 2.5.4.3. uaa portalclient 생성 참고한다.
	-v portal_client_secret="portalsecret"

	# paas_ta_web_user_url :  상기 옵션 중 haproxy_public_ip과 동일한 IP 주소를 입력한다.
	-v paas_ta_web_user_url="http://portal-web-user.192.168.150.28.xip.io"
	-v abacus_url="http://abacus.192.168.x.x"                  # 현재는 사용하지 않음. 임의의 값을 입력한다. 업데이트 예정  
	-v portal_webuser_quantity=false                           # portal webuser quantity. Default false.
	-v monitoring_api_url="http://monitoring.192.168.x.x"      # 현재는 사용하지 않음. 임의의 값을 입력한다. 업데이트 예정
	-v portal_webuser_monitoring=false                         # portal webuser monitoring. Default false.
	-v mail_smtp_host="smtp.gmail.com"                         # 메일 전송 서버를 지정한다.
	-v mail_smtp_port="465"                                    # 메일 전송 서버의 Port를 지정한다.
	-v mail_smtp_username="PaaS-TA"                            # 메일 전송 서버의 유저 명을 지정한다.
	-v mail_smtp_password="smtppassword"                       # 메일 전송 서버의 패스워드를 지정한다.
	-v mail_smtp_useremail="openpasta@gmail.com"               # 메일 전송 서버의 유저 메일을 지정한다.
	-v mail_smtp_properties_starttls_enable="true"             # 메일 전송 시 TLS 활성 유무를 지정한다.
	-v mail_smtp_properties_auth="true"                        # 메일 전송 시 인증 유무를 지정한다.
	-v mail_smtp_properties_starttls_required="true"           # 메일 전송 시 TLS 필수 값 유무를 지정한다.
	-v portal_webuser_automaticapproval=false                   
	-v mail_smtp_properties_subject="PaaS-TA User Potal"       # 메일 전송 시 제목을 지정한다.
	-v infra_admin=false

스크립트에 대한 실행 권한을 부여한다.

	$ chmod 755 paasta-portal-deploy-kubernetes.sh

1.2.	PaaS-TA 사용자 포털을 배포한다.

	$ cd ~/workspace/{PaaS-TA-Project}

PaaS-TA 사용자 포털 배포 스크립트를 수행한다.

	$ ./paasta-portal-deploy-kubernetes.sh

PaaS-TA 사용자 포털 배포를 실행하고 배포 진행 과정에 대해 정상적으로 배포가 수행되는지 로그를 필히 확인한다.

#### 2.	Cloudit 로드밸런싱 설정<div id='24'/>
2.1.	PaaS-TA 사용자 포털 배포 이후 사용자 및 운영자 포털을 접속하기 위해 HAProxy가 배포된 VM을 확인한다.  
\# bosh를 통해 배포되어 사용중인 VM을 확인한다.

	$ bosh -e paasta -d paasta-portal vms

\# HAProxy가 배포된 inctance의 VM CID를 참고한다.
![Cloudit_PaaSTa_Platform_Use_Guide_Image60]

아래 명령어를 통해 위에서 얻은 VM CID 값으로 haproxy가 어느 Worker node에 배포되었는지 확인한다.
아래 예제의 경우는 NODE 컬럼을 통해 paasta-4 node에 haproxy가 배포 되어 있는 것을 확인할 수 있다.

	$ kubectl get pod -o wide -n paasta | grep vm-4a925467-3b98-4d19-7950-62fdbac337e7
![Cloudit_PaaSTa_Platform_Use_Guide_Image61]

2.2.	Cloudit 로드밸런서 생성에 따라 로드밸런싱 설정을 확인한다.
※ [2.1.5 Cloudit 로드밸런서 생성 – HAProxy 배포 VM](#23)

※ 로드밸런싱 설정 시 다음의 정보를 따른다.
1.	로드밸런서의 IP는 PaaS-TA 사용자 포털 배포시 사용했던 haproxy_public_ip의 IP주소를 입력한다.
2.	로드밸런서 구성 요소 중 서버IP 항목의 물리 VM은 haproxy가 배포된 VM을 지정한다.
3.	로드밸런서 구성 요소 중 멤버 항목의 서버포트에 대한 정보는 portal-proxy-ingress 항목을 참고한다.
80(proxy)과 2221(eureka)에 대한 nodePort를 지정한다.

ingress 정보 확인  
\# 80과 2221 포트와 매핑 된 NodePort에 대해 로드밸런싱 포트를 추가한다.  
\# 아래 예제에선 80:30602/TCP의 내용과 2221:30702/TCP의 내용이 여기에 해당된다.


		$ kubectl get service portal-proxy-ingress -n paasta
![Cloudit_PaaSTa_Platform_Use_Guide_Image62]

#### 3.	최종 포털 사용을 위한 Service 확인
3.1.	등록된 Service를 확인한다.
아래 명령어를 통해 등록된 Service가 다음과 같은지 확인한다.

	$ kubectl get services -n paasta -o wide
![Cloudit_PaaSTa_Platform_Use_Guide_Image63]

#### 4.	PaaS-TA 사용자 포털 접속
4.1.	PaaS-TA 사용자 포털에 접속한다.
아래 명령어를 통해 배포된 PaaS-TA 사용자 포털에 접속한다.
PaaS-TA 사용자 포털 배포 후 등록했던 로드밸런서 IP를 입력하거나 도메인 주소를 입력한다.
Public IP와 매핑이 되어 있다면, 브라우저를 통해 Public IP로 접속을 한다

	$ curl http://portal-web-user.192.168.x.x.xip.io
![Cloudit_PaaSTa_Platform_Use_Guide_Image64]


#### 5.	PaaS-TA 운영자 포털 접속
5.1.	PaaS-TA 운영자 포털에 접속한다.
아래 명령어를 통해 배포된 PaaS-TA 운영자 포털에 접속한다.
PaaS-TA 사용자 포털 배포 후 등록했던 로드밸런서 IP를 입력한다.
Public IP와 매핑이 되어 있다면, 브라우저를 통해 Public IP로 접속을 한다

	$ curl http://portal-web-admin.192.168.x.x.xip.io
![Cloudit_PaaSTa_Platform_Use_Guide_Image65]

#### 6.	관리용 Eureka 접속
6.1.	Eureka web에 접속한다.
아래 명령어를 통해 Eureka web에 접속한다.
PaaS-TA 사용자 포털 배포 후 등록했던 로드밸런서 IP를 입력한다.
Public IP와 매핑이 되어 있다면, 브라우저를 통해 Public IP로 접속을 한다

	$ curl 192.168.x.x:2221
![Cloudit_PaaSTa_Platform_Use_Guide_Image66]

![Cloudit_PaaSTa_Platform_Use_Guide_Image67]

위와 같이  Application 목록의 URL이 표시되어야 한다.





[Cloudit_Infra_setting]:./PAAS-TA_PLATFORM_INSTALL_AUTOMATION_CLOUDIT_v1.0.md#5
[Cloudit_bootStrap_install]:./PAAS-TA_PLATFORM_INSTALL_AUTOMATION_CLOUDIT_v1.0.md#9
[Cloudit_cf_install]:./PAAS-TA_PLATFORM_INSTALL_AUTOMATION_CLOUDIT_v1.0.md#14
[Cloudit_DCE–PaaS-TA]:./cloudit/CLOUDIT_DCE-PAAS-TA_INTEGRATION_GUIDE.docx
[Cloudit_PaaSTa_Platform_Use_Guide_Image01]:./images/install-guide/cloudit/install_portal_flow.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image02]:./images/install-guide/cloudit/infra/inception_list_server.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image03]:./images/install-guide/cloudit/infra/inception_choice_os.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image04]:./images/install-guide/cloudit/infra/inception_choice_spec.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image05]:./images/install-guide/cloudit/infra/inception_choice_securitygroup.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image06]:./images/install-guide/cloudit/infra/inception_choice_clustertype.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image07]:./images/install-guide/cloudit/infra/inception_choice_vminfo.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image08]:./images/install-guide/cloudit/infra/inception_verify_finalinfo.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image09]:./images/install-guide/cloudit/infra/docker_list_cluster.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image10]:./images/install-guide/cloudit/infra/docker_choice_master_spec.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image11]:./images/install-guide/cloudit/infra/docker_choice_worker_spec.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image12]:./images/install-guide/cloudit/infra/docker_choice_security_group.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image13]:./images/install-guide/cloudit/infra/docker_choice_vminfo.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image14]:./images/install-guide/cloudit/infra/docker_verify_finalinfo.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image15]:./images/install-guide/cloudit/infra/lb_bosh_list_lb.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image16]:./images/install-guide/cloudit/infra/lb_bosh_choice_basicpolicy.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image17]:./images/install-guide/cloudit/infra/lb_bosh_add_member.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image18]:./images/install-guide/cloudit/infra/lb_bosh_verify_finalinfo.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image19]:./images/install-guide/cloudit/infra/lb_cf_list_lb.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image20]:./images/install-guide/cloudit/infra/lb_portal_choice_basicpolicy.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image21]:./images/install-guide/cloudit/infra/lb_portal_add_member.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image22]:./images/install-guide/cloudit/infra/lb_portal_verify_finalinfo.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image23]:./images/install-guide/cloudit/install_bootstrap_flow.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image24]:./images/install-guide/cloudit/bootstrapinstall/kubernetes_make_kubeconfig.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image25]:./images/install-guide/cloudit/bootstrapinstall/kubernetes_verify_cluterinfo.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image26]:./images/install-guide/cloudit/bootstrapinstall/kubernetes_verify_node.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image27]:./images/install-guide/cloudit/bootstrapinstall/kubernetes_verify_storageclass.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image28]:./images/install-guide/cloudit/bootstrapinstall/kubernetes_verify_assets.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image29]:./images/install-guide/cloudit/bootstrapinstall/kubernetes_verify_namespaces.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image30]:./images/install-guide/cloudit/bootstrapinstall/kubernetes_verify_role.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image31]:./images/install-guide/cloudit/bootstrapinstall/kubernetes_verify_role_1.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image32]:./images/install-guide/cloudit/bootstrapinstall/kubernetes_verify_role_2.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image33]:./images/install-guide/cloudit/bootstrapinstall/kubernetes_verify_rolebinding.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image34]:./images/install-guide/cloudit/bootstrapinstall/kubernetes_verify_rolebinding_1.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image35]:./images/install-guide/cloudit/bootstrapinstall/kubernetes_verify_boshexternal.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image36]:./images/install-guide/cloudit/bootstrapinstall/kubernetes_verify_boshexternal_1.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image37]:./images/install-guide/cloudit/bootstrapinstall/kubernetes_verify_secret.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image38]:./images/install-guide/cloudit/bootstrapinstall/kubernetes_verify_bosh.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image39]:./images/install-guide/cloudit/bootstrapinstall/kubernetes_create_env_bosh.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image40]:./images/install-guide/cloudit/bootstrapinstall/kubernetes_create_env_bosh_1.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image41]:./images/install-guide/cloudit/bootstrapinstall/kubernetes_verify_nodeport.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image42]:./images/install-guide/cloudit/bootstrapinstall/kubernetes_verify_bosh_vm.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image43]:./images/install-guide/cloudit/bootstrapinstall/kubernetes_verify_bosh_env.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image44]:./images/install-guide/cloudit/install_cf_flow.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image45]:./images/install-guide/cloudit/portalinstall/kubernetes_verify_portalexternal.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image46]:./images/install-guide/cloudit/portalinstall/kubernetes_verify_portalexternal_1.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image47]:./images/install-guide/cloudit/portalinstall/kubernetes_verify_portalexternal_2.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image48]:./images/install-guide/cloudit/portalinstall/kubernetes_verify_container_yaml.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image49]:./images/install-guide/cloudit/portalinstall/kubernetes_verify_cloudconfig.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image50]:./images/install-guide/cloudit/portalinstall/kubernetes_create_uaa_portalclient.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image51]:./images/install-guide/cloudit/portalinstall/kubernetes_verify_uaa_adminclient.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image52]:./images/install-guide/cloudit/portalinstall/kubernetes_verify_uaa_admin.token.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image53]:./images/install-guide/cloudit/portalinstall/kubernetes_verify_uaa_portalclient_token.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image54]:./images/install-guide/cloudit/portalinstall/kubernetes_create_portal_deployscript.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image55]:./images/install-guide/cloudit/portalinstall/kubernetes_verify_cf_db_instance.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image56]:./images/install-guide/cloudit/portalinstall/kubernetes_verify_cf_db_password.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image57]:./images/install-guide/cloudit/portalinstall/kubernetes_verify_uaa_db_password.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image58]:./images/install-guide/cloudit/portalinstall/kubernetes_verify_cf_admin_password.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image59]:./images/install-guide/cloudit/portalinstall/kubernetes_verify_uaa_admin_password.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image60]:./images/install-guide/cloudit/portalinstall/kubernetes_verify_haproxy_instance_id.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image61]:./images/install-guide/cloudit/portalinstall/kubernetes_verify_haproxy_instance_id_1.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image62]:./images/install-guide/cloudit/portalinstall/kubernetes_verify_proxy_ingress.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image63]:./images/install-guide/cloudit/portalinstall/kubernetes_verify_svc.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image64]:./images/install-guide/cloudit/portalinstall/kubernetes_verify_portal_connection.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image65]:./images/install-guide/cloudit/portalinstall/kubernetes_verify_admin_connection.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image66]:./images/install-guide/cloudit/portalinstall/kubernetes_verify_eureka_connection.png
[Cloudit_PaaSTa_Platform_Use_Guide_Image67]:./images/install-guide/cloudit/portalinstall/kubernetes_verify_eureka_url.png
