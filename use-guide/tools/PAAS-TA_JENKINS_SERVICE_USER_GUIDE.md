# Table of Contents
[1. 문서 개요](#)
- [1.1 목적](#2)
- [1.2 범위](#3)  

[2. Jenkins 서비스 생성](#)    

- [2.1 사용자 포털 계정 생성 및 로그인](#5)
- [2.2 Jenkis 서비스 생성 및 접속](#6)  

[3. Jenkins 기본 설정](#)

- [3.1 Jenkins 기본 설정](#7)  

[4. CF 빌드 및 배포](#)

- [4.1 빌드](#8)
- [4.2 CF Deploy](#9)
- [4.3 CF Deploy(Blue&Green)](#10)
- [4.4 CF Deploy(Rolliing)](#11)  

[5. Kubernets 빌드 및 배포](#)

- [5.1 K8S_Setting](#12)
- [5.2 K8S_Build(Docker Build)](#13)
- [5.3 K8S_Deploy](#14)
- [5.4 K8S_Deploy(Blue&Green)](#15)
- [5.5 K8S_Deploy(Rolling)](#16)
<br><br>
# <div id='1'/>1.  문서 개요
<br>

### <div id='2'/>1.1.  목적

본 문서는 Jenkins 서비스를 사용할 사용자의 사용 방법에 대해 기술하였다.
<br>

### <div id='3'/>1.2.  범위

본 문서는 Jenkins 서비스를 사용할 사용자의 CF 빌드 및 배포, Kubernetes & Docker 빌드 및 배포에 관해서 작성되어 있다. 배포 종류로는 일반 배포, Blue & Green 배포, Rolling배포에 대해서도 작성되어 있다.
<br><br>

# <div id='4'/> 2.Jenkins 서비스 생성

<br>

### <div id='5'/>2.1  사용자 포털 계정 생성 및 로그인
※ PaaS-TA 사용자 포탈 계정 생성 가이드
- https://github.com/PaaS-TA/Guide-4.0-ROTELLE/blob/master/Use-Guide/portal/PaaS-TA%20%EC%82%AC%EC%9A%A9%EC%9E%90%20%ED%8F%AC%ED%83%88%20%EA%B0%80%EC%9D%B4%EB%93%9C_v1.1.md#4

<br>

### <div id='6'/>2.2  Jenkis 서비스 생성 및 접속

1.	사용자 포탈 – 카탈로그 페이지에서, Jenkins서비스를 선택한다.
![JENKINS_1]
2.	서비스 이름을 입력 후 생성을 선택한다.
3.	대시보드에 서비스탭에서 생성 유무를 확인한다.
![JENKINS_2]
4.	대시보드 버튼을 클릭하여, 접속한다.
5.	초기 패스워드와 계정은 admin/admin이다.

<br><br>

# 3. Jenkins 기본 설정
본 장에서는 Jenkins 기본 설정에 대해서 기술하였다. 
<br>

### <div id='7'/>3.1  Jenkins 기본 설정
Jenkins 관리 -> 시스템 설정 으로 이동한다.
![JENKINS_3]  
1.	기본 시스템 설정
	-	Jenkins Location 설정에서 Jenkins URL이 사용자가 접속한 주소가 아닐 경우, 사용자가 접속한 주소로 수정한다. 
![JENKINS_4]  
2.	Workspace Sharing
	-	기본적으로 Sample용으로 Template_CF와 Template_K8S를 제공하고 있다. 추후에 필요한 경우 추가를 이용하여, 사용자에 맞게 늘려서 사용하면 된다. 

<br><br>

# 4.	CF 빌드 및 배포
Jenkins 서비스를 이용하여, 빌드 및 CF 배포에 관해서 기술되어 있다.

배포종류
- Deploy
- Deploy(Blue&Green)
- Deploy(Rolling)
<br>

### <div id='8'/> 4.1.	빌드
![JENKINS_5]  

빌드는 소스를 형상관리에서 끌어와, 소스를 빌드를 하는 스탭이다. 기본 설정탭에서 다음과 같이 설정한다. Shared Workspace -> Template_CF을 설정한다. 

- Shared Workspace는 Job별로 공간을 생성하지 않고, 한 공간에서 Job을 진행할 수 있도록 제공되는 기능이다. Shared Workspace는 Jenkis 관리 -> 시스템 설정에서 설정 해야한다.

소스 코드 관리탭으로 이동하여, Git(SCM,Github )을 선택 후 Repository URL을 입력한다. Branch탭에 Branch명을 뜰때까지 대기한다.

![JENKINS_6]  
- 예제 소스는 Gradle로 구성되어, Gradle 구성으로 설명한다.

Add build step을 클릭하여 Gradle script를 선택하여, 스탭을 추가한다. Invoke Gradle에서 버전을 선택 후 Tasks에 빌드 방식을 입력한다. Clearn build -x test(삭제O 테스트 X 빌드 O)를 입력한다.
Add build step을 클릭하여, Execute Shell 를 선택하여 스탭을 추가한다. (기본 예제 소스 붙여넣기)
Execute shell탭에서 CF배포에 필요한 Manifest 파일을 작성한다.  
(참조: https://docs.cloudfoundry.org/devguide/deploy-apps/manifest.html)  
저장 버튼을 선택하여, 설정을 종료한다.
<br>
```
	cat > manifest.yml << EOF -> 매니페스트 파일을 생성하는 단계이다. 사용자의 맞게 메니페스트 파일을 설정한다.
	---  
	applications:  
	- name: portal-registration  
	  memory: 1G  
	  instances: 5  
	  path: ./build/libs/paas-ta-portal-registration.jar  
	  buildpacks:   
	    - java_buildpack  
	  env:  
	    eureka_instance_hostname: localhost  
	    eureka_client_registerWithEureka: false  
	    eureka_client_fetchRegistry: false  
	    eureka_client_healthcheck_enabled: true  
	    eureka_server_enableSelfPreservation: true  
	    server_port: 2221  
	EOF
```
### <div id='9'/> 4.2. CF Deploy
![JENKINS_7]  
Deploy는 빌드에서 생성된 빌드파일을 CF 배포하는 스탭이다. 기본 설정탭에서 다음과 같이 설정한다. Shared Workspace -> Template_CF을 설정한다. 

- Shared Workspace는 Job별로 공간을 생성하지 않고, 한 공간에서 Job을 진행할 수 있도록 제공되는 기능이다. Shared Workspace는 Jenkis 관리 -> 시스템 설정에서 설정 해야한다.
![JENKINS_8]  

Add build step을 클릭하여, Execute Shell 를 선택하여 스탭을 추가한다. (기본 예제 소스 붙여넣기)

	CF_API=https://api. CF 도메인 -> 예) https://api.10.0.0.1.xip.io
	CF_DOMAIN=CF 도메인 -> 예) 10.0.0.1.xip.io
	CF_ADMIN= 사용자 계정 -> 예) admin
	CF_ADMIN_PW= 사용자 패스워드 -> 예) admin
	CF_ORG= 사용자 ORG -> 예) system
	CF_SPACE= 사용자 Space ->예) dev
	BLUE= 배포후에 접속할 서브도메인 이름 -> 예) portal-registration 일 경우 접속시 portal-regostration.10.0.0.1.xip.io 접속

	cf login -a ${CF_API} -u ${CF_ADMIN} -p ${CF_ADMIN_PW} -o ${CF_ORG} -s ${CF_SAPCE}
	-> 특정 ORG & SPACE 사용자 계정으로 로그인 후 접속 

	cf push $BLUE -f manifest.yml --hostname $BLUE
	-> 빌드에서 생성된 스팩으로 BLUE 설정의 이름으로 배포


본인의 설정으로 변경 후 저장한다.
빌드를 실행 후 정상 배포여부를 확인하다.

<br>

### <div id='10'/>4.3	CF Deploy(Blue&Green)

Blue&Green 배포란? 무중단 배포를 의미하는 용어이다. 
Blue&Green 배포 프로세스
  
  1. 신규 서비스를 새로운 이름으로 배포한다. 
  2. 신규 서비스에 새로운 라우터를 부여한다.
  3. 신규 서비스에 정상여부를 확인한다.
  4. 신규 서비스에 기존 서비스 라우터를 부여하고, 새로운 라우터를 제거한다.
  5. 기존 서비스를 제거하고, 신규서비스를 주 서비스로 운영한다.
	

![JENKINS_9]  

![JENKINS_10]  

Deploy(Blue&Green)는 빌드에서 생성된 빌드파일을 CF 배포하는 스탭이다.. 기본 설정탭에서 다음과 같이 설정한다. Shared Workspace -> Template_CF을 설정한다. 

![JENKINS_11]  
	Add build step을 클릭하여, Execute Shell 를 선택하여 스탭을 추가한다. (기본 예제 소스 붙여넣기)

	CF_API=https://api. CF 도메인 -> 예) https://api.10.0.0.1.xip.io
	CF_DOMAIN=CF 도메인 -> 예) 10.0.0.1.xip.io
	CF_ADMIN= 사용자 계정 -> 예) admin
	CF_ADMIN_PW= 사용자 패스워드 -> 예) admin
	CF_ORG= 사용자 ORG -> 예) system
	CF_SPACE= 사용자 Space ->예) dev
	BLUE= 배포후에 접속할 서브도메인 이름 -> 예) portal-registration 일 경우 접속시 portal-regostration.10.0.0.1.xip.io 접속
	GREEN=${BLUE}-copy

	cf login -a ${CF_API} -u ${CF_ADMIN} -p ${CF_ADMIN_PW} -o ${CF_ORG} -s ${CF_SAPCE}
	-> 특정 ORG & SPACE 사용자 계정으로 로그인 후 접속 

	cf push $GREEN -f manifest.yml --hostname $GREEN
	-> 빌드에서 생성된 스팩으로 GREEN으로 배포

	curl --fail -k -l “http://${GREEN}.${CF_DOMAIN}
	-> 서비스 정상 여부 확인

	cf routes | tail -n +4 | grep ${BLUE} | awk ‘{“print $3” | --hostname $2}’ | xargs -n 3 cf map-route ${GREEN}
	-> 기존에 사용하고 라우터정보를 취득하여, 새로운 서비스에 부여
	cf delete $BLUE -f
	-> 기존 서비스를 제거

	cf rename $GREEN $BLUE
	-> 신규 서비스의 이름 기존 서비스 이름으로 변경

	cf delete-route $CF_DOMAIN -n $GREEN -f
	-> 신규서비스에 부여한 임시 라우터 삭제
	
<br>

### <div id='11'/> 4.4	CF Deploy(Rolling)
Rolling Update란? Blue&Green과 비슷한 형태의 배포로 동일한 이름의 인스턴스를 내부적으로 생성하여, 자동으로 기존 서비스와 신규서비스를 교체하는 업데이트이다. 

![JENKINS_12]  
Deploy(Blue&Green)는 빌드에서 생성된 빌드파일을 CF 배포하는 스탭이다. 기본 설정탭에서 다음과 같이 설정한다. Shared Workspace -> Template_CF을 설정한다. 
 
![JENKINS_13]  
Add build step을 클릭하여, Execute Shell 를 선택하여 스탭을 추가한다. (기본 예제 소스 붙여넣기)

	CF_API=https://api. CF 도메인 -> 예) https://api.10.0.0.1.xip.io
	CF_DOMAIN=CF 도메인 -> 예) 10.0.0.1.xip.io
	CF_ADMIN= 사용자 계정 -> 예) admin
	CF_ADMIN_PW= 사용자 패스워드 -> 예) admin
	CF_ORG= 사용자 ORG -> 예) system
	CF_SPACE= 사용자 Space ->예) dev
	BLUE= 배포후에 접속할 서브도메인 이름 -> 예) portal-registration 일 경우 접속시 portal-regostration.10.0.0.1.xip.io 접속

	cf login -a ${CF_API} -u ${CF_ADMIN} -p ${CF_ADMIN_PW} -o ${CF_ORG} -s ${CF_SAPCE}
	-> 특정 ORG & SPACE 사용자 계정으로 로그인 후 접속 

	cf push $GREEN -f manifest.yml --hostname $GREEN
	-> 빌드에서 생성된 스팩으로 GREEN으로 배포

	Cf v3-zdt-puth ${BLUE} -p /build/libs/paasta-registration.jar
	-> ${BLUE}명을 가진 서비스에 동일한 스팩으로 새로운 빌드파일을 등록하여, 자동으로 변경 

<br><br>

# 5.	Kubernets 빌드 및 배포
Jenkins 서비스를 이용하여, 빌드 및 Kubernetes 배포에 관해서 기술되어 있다. 이기능을 사용하기위해서는 PaaS-TA CaaS 서비스를 사용하고 있어야 정상적으로 예제를 이용하여, 배포할 수 있다.

배포종류
- Setting
- Deploy
- Deploy(Blue&Green)
- Deploy(Rolling)
 예제 소스를 제공한다.
<br>

### <div id='12'/> 5.1.	K8S_Setting
![JENKINS_15]  

Setting은 K8S 접속하기 위하여, Kubectl을 설정하는 과정이다.  기본 설정탭에서 다음과 같이 설정한다. Shared Workspace -> Template_K8S를 설정한다. 

![JENKINS_16]  
CaaS에서 제공하는 Access페이지의 정보를 모두 입력한다.  
![JENKINS_17]  

Pem파일을 열어 내용을 cert.crt에 입력한다.
다음과 같이 설정후 저장한다.

<br>

### <div id='13'/> 5.2. K8S_Build(Docker Build)
Build은 K8S 배포하기 위하여, 소스 빌드 및 Docker Image 생성을 위한 설정이다. 기본 설정탭에서 다음과 같이 설정한다. Shared Workspace -> Template_K8S를 설정한다. 

이미지 구성 프로세스
  1.	소스를 빌드한다.
  2.	배포되어 필요한 설정파일을 생성한다. (GIT에 설정파일이 등록되어 있을 경우 필요없음)
  3.	Dockerfile을 생성한다.
  4.	Docker Build를 진행한다.
  5.	Docker Push를 진행하여, 레파지토리 서버에 등록한다.  

![JENKINS_18]  

![JENKINS_19]  

	Cat > application.yml << EOF
	spring:
	 application:
	    name: PortalRegistration
	eureka:
	  server:
	    enableSelfPreservation: true
	  instance:
	    appname: \${spring.application.name}
	    hostname: \${spring.cloud.client.hostname}
	    preferIpAddress: true
	  client:  
	    registerWithEureka: false
	    fetchRegistry: false
	    serviceUrl:  
	      defaultZone: http://127.0.0.1:2221/eureka/
	    healthcheck:
	      enabled: true
	server:
	  port: \${PORT:2221}   
		EOF 
	-> 서비스에 필요한 설정파일을 생성한다.사용자에 맞게 수정한다트

	cat < Dockerfile << EOF
	FROM ubuntu:18.04
	RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf
	RUN apt update
	RUN apt install -y openjdk-8-jdk
	ADD build/libs/paas-ta-portal-registration.jar app.jar
	ADD application.yml application.yml
	ENV JAVA_OPTS="org.springframework.boot.loader.WarLauncher -Dspring.config.location=application.yml -Xms512m -Xmx1024m -XX:ReservedCodeCacheSize=240m -XX:+UseCompressedOops -Dfile.encoding=UTF-8 -XX:+UseConcMarkSweepGC -XX:SoftRefLRUPolicyMSPerMB=50 -Dsun.io.useCanonCaches=false -Djava.net.preferIPv4Stack=true -XX:+HeapDumpOnOutOfMemoryError -XX:-OmitStackTraceInFastThrow -Xverify:none"
	ENTRYPOINT ["java","-jar","/app.jar"]
	EOF
	-> 생성할 Docker image 스팩을 정의한다. 사용자에 맞게 Dockerfile 설정을 수정한다.

	docker build -f Dockerfile -t paastateam/portalregistration:$BUILD_NUMBER
	-> Docker image를 빌드한다. $BUILD_NUMBER 변수는 JENKINS에서 제공하는 시스템 변수이다.
	현재 빌드하고 있는 순번의 값을 제공한다.
	
	DOCKER_ID=[사용자 ID]
	DOCKER_PW=[사용자 패스워드]
	
	docker login -u ${DOCKER_ID} -p ${DOCKER_PW}
	docker push paastateam/portalregistration:$BUILD_NUMBER
	-> Docker image를 DockerRepository서버 업로드한다.
<br>

### <div id='14'/> 5.3.	K8S_Deploy
![JENKINS_20]    

Deploy은 K8S 배포 위한 기본 설정이다. 기본 설정탭에서 다음과 같이 설정한다. Shared Workspace -> Template_K8S를 설정한다.   

![JENKINS_21]  

	BEFOREJOB_BUILD_NUMBER=$((($cat /hoem/jenkins_home/jobs/Template_K8S_Build/nextBuildNumber) -1))
	-> 이전 JOB의 빌드번호를 가져온다. 이 예제에서는 이전 JOB은 빌드를 의미한다.

	DEPLOYMENT_NAME=paasta-deployment
	-> K8S에 생성 될 Deployment 이름.

	APP_NAME=$DEPLOYMENT_NAME
	-> K8S에 Service에 사용될 이름을 정의
	
	INTERNAL_SERVICE_PORT=2221
	-> K8S에 내부에서 동장되는 서비스의 Port

	INTANCE=1
	-> K8S에 생성 Pods의 갯수
	
	IMAGE=paastateam/portalregistration
	-> K8S에 사용 이미지 이름
	
	TIME=$(date +%Y%m%m%d%H%M)

	DEPLOYMENT_NAME=${DEPLOYMNET_NAME}-${TIME}
	SERVICE_NAME=${DEPLOYMNET_NAME}-service

	cat > k8s_deploy.yml << EOF
	---
	apiVersion: apps/v1
	kind: Deployment
	metadata:
	  name: ${DEPLOYMENT_NAME}
	  labels:
	    app: ${APP_NAME}
	spec:
	  replicas: ${INSTANCE}
	  selector:
	    matchLabels:
	      app: ${APP_NAME}
	  template:
	    metadata:
	      labels:
		app: ${APP_NAME}
	    spec:
	      containers:
	      - name: ${APP_NAME}
		image: ${IMAGE}:${BEFOREJOB_BUILD_NUMBER}
		ports:
		- containerPort: ${INTERNAL_SERVICE_PORT}       
	EOF



	cat > k8s_deploy_service.yml << EOF
	---
	kind: Service
	apiVersion: v1
	metadata:
	  name: ${SERVICE_NAME}
	spec:
	  type: NodePort
	  selector:
	    app: ${APP_NAME}
	  ports:
	    - protocol: TCP
	      port: ${INTERNAL_SERVICE_PORT}
	      targetPort: ${INTERNAL_SERVICE_PORT}
	      name: ${APP_NAME}       
	EOF



	Kubectl create -f k8s_deploy.yml

	-> K8S에 Deployment를 생성한다. – create -> apply로 변경하여 사용 가능하다.(Rolling Update) Create를 하는 이유는 잘못된 배포를 차단하기 위해서, 기존 Deployment가 있을 경우 에러가 나도록 설정하였다.


	If [$(kubectl get servcie | grep \w ${SERVICE_NAME}) == “” ]; then
	Kubectl create -f k8s_deploy_service.yml
	Else
	Kubectl apply -f k8s_deploy_service.yml
	fi
	-> K8S에 Service를 생성한다. 기존에 삭제된 Deployment에 Servicer가 남아 있을경우를 대비하여, Service를 확인 후 생성 또는 업데이트를 진행하도록 설정하였다.

	Kubectl get pods
	-> 정상 배포여부를 확인한다.
<br>

### <div id='15'/> 5.4.	K8S_Deploy(Blue&Green)  

![JENKINS_23]  

Deploy은 K8S 배포 위한 기본 설정이다. 기본 설정탭에서 다음과 같이 설정한다. Shared Workspace -> Template_K8S을 설정한다.   

![JENKINS_24]  

	BEFOREJOB_BUILD_NUMBER=$((($cat /var/jenkins_home/jobs/Template_K8S_Build/nextBuildNumber) -1))
	-> 이전 JOB의 빌드번호를 가져온다. 이 예제에서는 이전 JOB은 빌드를 의미한다.
	SERVER_IP=xxx.xxx.xxx.xxx
	-> 서비스 정상여부를 확인하기 위하여, K8S에 등록된 기존 서비스의 접속주소의 정보를 입력한다.

	DEPLOYMENT_NAME=paasta-deployment
	-> K8S에 생성 될 Deployment 이름.

	APP_NAME=paasta
	-> K8S에 Service에 사용될 이름을 정의
	
	INTERNAL_SERVICE_PORT=2221
	-> K8S에 내부에서 동장되는 서비스의 Port

	INTANCE=1
	-> K8S에 생성 Pods의 갯수

	TIME=$(date +%Y%m%m%d%H%M)
	DEPLOYMENT_NAME=${DEPLOYMNET_NAME}-${TIME}
	SERVICE_NAME=${DEPLOYMNET_NAME}-service
	APP_NAME=$APP_NAME-${TIME}
	DEPLOYMENT_NAME_GREEN=${DEPLOYMENT_NAME}-${TIME}
	DEPLOYMENT_NAME_BLUE=$( kubectl get deployment | grep ${DEPLOYMENT_NAME} | awk ‘{print $1 ;exit}’)
	SERVICE_GREEN=${SERVICE_NAME}-${TIME}

	cat > green.yml << EOF
	---
	apiVersion: apps/v1
	kind: Deployment
	metadata:
	  name: ${DEPLOYMENT_NAME_GREEN}
	  labels:
	    app: ${APP_NAME_GREEN}
	spec:
	  replicas: 1
	  selector:
	    matchLabels:
	      app: ${APP_NAME_GREEN}
	  template:
	    metadata:
	      labels:
		app: ${APP_NAME_GREEN}
	    spec:
	      containers:
	      - name: ${APP_NAME_GREEN}
		image: ${IMAGE}:${BEFOREJOB_BUILD_NUMBER}
		ports:
		- containerPort: 2221
	EOF


	cat > green_service.yml << EOF
	---
	kind: Service
	apiVersion: v1
	metadata:
	  name: ${SERVICE_GREEN}
	spec:
	  type: NodePort
	  selector:
	    app: ${APP_NAME_GREEN}
	  ports:
	    - protocol: TCP
	      port: ${INTERNAL_SERVICE_PORT}
	      targetPort: ${INTERNAL_SERVICE_PORT}
	      name: ${APP_NAME_GREEN}       
	EOF


	cat > blue_service.yml << EOF
	---
	kind: Service
	apiVersion: v1
	metadata:
	  name: ${SERVICE_NAME}
	spec:
	  type: NodePort
	  selector:
	    app: ${APP_NAME_GREEN}
	  ports:
	    - protocol: TCP
	      port: ${INTERNAL_SERVICE_PORT}
	      targetPort: ${INTERNAL_SERVICE_PORT}
	      name: ${APP_NAME_GREEN}       
	EOF

	Kubectl create -f greeen.yml
	-> K8S에 green을 배포한다.

	Kubectl create -f green_service.yml
	-> K8S에 green에 외부 서비스포트를 연결한다.

	Kubectl get pods
	-> 배포된 Green의 정상유무를 확인한다.


	Sleep 10

	PORT=${kubectl get service | grep -w ${SERVICE_NAME} | awk ‘{print $5}’ | awk -F “[ :]” ‘{print $2}’ | awk -F “[/]” ‘{print $1}’}

	Curl –fail -k -l http://${SERVER_IP}:$PORT
	-> 배포된 Green이 정상접속이 되는지 확인한다.

	Kubectl apply -f blue_service.yml
	-> Blue의 서비스를 Green에 할당한다.

	Kubectl delete service ${SERVICE_GREEN}
	-> Green에 설정된 서비스를 제거한다.

	Kubectl delete deployment ${DEPLOYMENT_NAME_BLUE}
	-> Blue Deployment를 삭제한다.

<br>

### <div id='16'/> 5.5.	K8S_Deploy(Rolling)
Rolling Update란? Blue&Green과 비슷한 형태의 배포로 동일한 이름의 인스턴스를 내부적으로 생성하여, 자동으로 기존 서비스와 신규서비스를 교체하는 업데이트이다.   
![JENKINS_25]  
Deploy은 K8S 배포 위한 기본 설정이다. 기본 설정탭에서 다음과 같이 설정한다. Shared Workspace -> Template_K8S을 설정한다.   
![JENKINS_26]  

	BEFOREJOB_BUILD_NUMBER=$((($cat /home/jenkins_home/jobs/Template_K8S_Build/nextBuildNumber) -1))
	-> 이전 JOB의 빌드번호를 가져온다. 이 예제에서는 이전 JOB은 빌드를 의미한다.

	DEPLOYMENT_NAME=[업데이트할 Deployment ]
	-> K8S에 생성 될 Deployment 이름.

	APP_NAME=paasta
	-> K8S에 Service에 사용될 이름을 정의
	
	INTERNAL_SERVICE_PORT=2221
	-> K8S에 내부에서 동장되는 서비스의 Port

	INTANCE=1
	-> K8S에 생성 Pods의 갯수

	TIME=$(date +%Y%m%m%d%H%M)

	DEPLOYMENT_NAME=${DEPLOYMNET_NAME}-${TIME}
	SERVICE_NAME=${APP_NAME}-service

	cat > k8s_deploy.yml << EOF
	---
	apiVersion: apps/v1
	kind: Deployment
	metadata:
	  name: ${DEPLOYMENT_NAME}
	  labels:
	    app: ${APP_NAME}
	spec:
	  strategy:
	    type: RollingUpdate
	    rollingUpdate:
		maxSurge: 1
		maxUnavailable: 0
	  replicas: ${INSTANCE}
	  selector:
	    matchLabels:
	      app: ${APP_NAME}
	  template:
	    metadata:
	      labels:
		app: ${APP_NAME}
	    spec:
	      containers:
	      - name: ${APP_NAME}
		image: ${IMAGE}:${BEFOREJOB_BUILD_NUMBER}
		ports:
		- containerPort: ${INTERNAL_SERVICE_PORT}  
	EOF



	cat > k8s_deploy_service.yml << EOF
	K8S 서비스 스팩 -> 배포된 Jenkins 서비스 샘플 예제 참조
	EOF

	Kubectl apply -f k8s_deploy.yml
	-> K8S에 Deployment를 생성(Rolling Update)를 진행한다. 

	Kubectl get pods
	-> 정상 배포여부를 확인한다.





































[JENKINS_1]:/use-guide/images/jenkins/IMAGE1.png
[JENKINS_2]:/use-guide/images/jenkins/IMAGE2.png
[JENKINS_3]:/use-guide/images/jenkins/IMAGE3.png
[JENKINS_4]:/use-guide/images/jenkins/IMAGE4.png
[JENKINS_5]:/use-guide/images/jenkins/IMAGE5.png
[JENKINS_6]:/use-guide/images/jenkins/IMAGE6.png
[JENKINS_7]:/use-guide/images/jenkins/IMAGE7.png
[JENKINS_8]:/use-guide/images/jenkins/IMAGE8.png
[JENKINS_9]:/use-guide/images/jenkins/IMAGE9.png
[JENKINS_10]:/use-guide/images/jenkins/IMAGE10.png
[JENKINS_11]:/use-guide/images/jenkins/IMAGE11.png
[JENKINS_12]:/use-guide/images/jenkins/IMAGE12.png
[JENKINS_13]:/use-guide/images/jenkins/IMAGE13.png
[JENKINS_14]:/use-guide/images/jenkins/IMAGE14.png
[JENKINS_15]:/use-guide/images/jenkins/IMAGE15.png
[JENKINS_16]:/use-guide/images/jenkins/IMAGE16.png
[JENKINS_17]:/use-guide/images/jenkins/IMAGE17.png
[JENKINS_18]:/use-guide/images/jenkins/IMAGE18.png
[JENKINS_19]:/use-guide/images/jenkins/IMAGE19.png
[JENKINS_20]:/use-guide/images/jenkins/IMAGE20.png
[JENKINS_21]:/use-guide/images/jenkins/IMAGE21.png
[JENKINS_22]:/use-guide/images/jenkins/IMAGE22.png
[JENKINS_23]:/use-guide/images/jenkins/IMAGE23.png
[JENKINS_24]:/use-guide/images/jenkins/IMAGE24.png
[JENKINS_25]:/use-guide/images/jenkins/IMAGE25.png
[JENKINS_26]:/use-guide/images/jenkins/IMAGE26.png

