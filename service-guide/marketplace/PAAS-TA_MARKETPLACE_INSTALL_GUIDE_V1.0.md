## Table of Contents

[1. 문서 개요](#1)

  -  [1.1. 목적](#11)
  -  [1.2. 범위](#12)
  -  [1.3. 시스템 구성도](#13)

[2. 마켓플레이스 배포](#2)

  -  [2.1. 설치 전 준비사항](#21)
  -  [2.1.1. App 파일 및 Manifest 파일 다운로드](#211)
  -  [2.2. 마켓플레이스 Manifest 파일 수정 및 App 배포](#22)
  -  [2.2.1. CF 공간 설정 및 백엔드 서비스 설정](#221)
  -  [2.2.2. manifest 파일 설정](#222)
  -  [2.2.3. 마켓플레이스 App 배포](#223)
  -  [2.3. 마켓플레이스 UAA Client Id 등록](#23)
  -  [2.4. 마켓플레이스 서비스 관리](#24)

# <div id='1'/> 1. 문서 개요

### <div id='11'/> 1.1. 목적
본 문서(마켓플레이스 설치 가이드)는 개방형 PaaS 플랫폼 고도화 및 개발자 지원 환경 기반의 Open PaaS에서 마켓플레이스를 설치하는 방법을 기술하였다.


### <div id='12'/> 1.2. 범위
설치 범위는 마켓플레이스 기본 설치를 기준으로 작성하였다.


### <div id='13'/> 1.3. 시스템 구성도
본 문서의 설치된 시스템 구성도이다. 마켓플레이스 Server, DB, Object Storage 로 최소사항을 구성하였다.

![Architecture]

<br>
<br>

# <div id='2'/> 2. 마켓플레이스 배포

### <div id='21'/> 2.1. 설치 전 준비사항
본 설치 가이드는 Linux 환경에서 설치하는 것을 기준으로 하였다.
마켓플레이스를 설치하기 위해서는 BOSH 2.0과 PaaS-TA 5.0, PaaS-TA 포털이 설치되어 있어야 한다.

##### 마켓플레이스 설치에 필요한 Object Storage(Swift) 및 DB 정보를 설정하기 위해서는 paasta-marketplace-env-release가 필수적으로 설치되어 있어야 한다.

> **[PaaS-TA Marketplace Environment Release 설치](https://github.com/PaaS-TA/PAAS-TA-MARKETPLACE-ENV-RELEASE)**
  
#### <div id='211'/> 2.1.1. App 파일 및 Manifest 파일 다운로드

마켓플레이스 설치에 필요한 App 파일 및 Manifest 파일을 다운로드 받아 서비스 설치 작업 경로로 위치시킨다.

-	설치 파일 다운로드 위치 : https://paas-ta.kr/download/package  
- 설치 작업 경로 및 디렉토리 (파일) 구성  
```  
### 설치 작업 경로  
${HOME}/workspace/paasta-5.0/release/service/marketplace  

### 설치 디렉토리 (파일) 구성  
marketplace
├── marketplace-api  
│   ├── manifest.yml  
│   └── marketplace-api.jar  
├── marketplace-webadmin  
│   ├── manifest.yml  
│   └── marketplace-web-admin.war  
├── marketplace-webseller  
│   ├── manifest.yml  
│   └── marketplace-web-seller.war  
└── marketplace-webuser  
    ├── manifest.yml  
    └── marketplace-web-user.war  
```  

### <div id='22'/> 2.2. 마켓플레이스 Manifest 파일 수정 및 App 배포
### <div id='221'/> 2.2.1. CF 공간 설정 및 백엔드 서비스 설정

마켓플레이스는 파스-타에 애플리케이션으로 서비스가 배포된다. 마켓플레이스 서비스 배포 및 마켓플레이스의 상품 배포를 위한 조직과 공간 설정 진행을 위해 조직과 공간을 생성하고 설정할 수 있는 권한을 가진 관리자 계정으로 로그인 되어 있어야 한다.

1) 마켓플레이스 배포를 위한 조직 및 공간을 생성하고 설정을 진행한다.

  ```
  ### 마켓플래이스 배포를 위한 조직 및 공간 생성 및 설정 
  $ cf create-quota marketplace_quota -m 100G -i -1 -s -1 -r -1 --reserved-route-ports -1 --allow-paid-service-plans
  $ cf create-org marketplace -q marketplace_quota
  $ cf create-space system -o marketplace  
  ```

2) 마켓플레이스의 상품 배포를 위한 조직 및 공간을 생성하고 설정을 진행한다.
  ```
  ### 마켓플래이스 상품 배포를 위한 조직 및 공간 생성 및 설정 
  $ cf create-org marketplace-org -q marketplace_quota
  $ cf create-space marketplace-space -o marketplace-org
  ```  
  
3) 생성한 조직과 공간, 쿼타에 대한 GUID 를 확인한다.
  ```
  ### 조직 GUID 확인 
  $ cf org marketplace-org --guid
  
  ### 공간 GUID 확인 
  $ cf space marketplace-space --guid
  
  ### 쿼타 GUID 확인 ("marketplace_quota"에 해당하는 GUID 확인)
  $ cf curl "/v2/quota_definitions"
  
  ### 도메인 GUID 확인  
  $ cf curl "/v2/domains"
  ```

4) 마켓플레이스에 필요한 Object Storage(Swift) 및 DB 환경 정보를 확인한다.

  - 위 2.1 설치 전 준비사항에서 사전 설치한 마켓플레이스 환경 정보를 확인하여 Object Storage(Swift) 및 DB 정보를 추출한다.  
    ++ [PaaS-TA Marketplace Environment Release 설치 가이드](https://github.com/PaaS-TA/PAAS-TA-MARKETPLACE-ENV-RELEASE/blob/master/README.md#-33-marketplace-environment-deployment-파일-수정-및-배포)
  ```
  ## 마켓플레이스에 필요한 Object Storage(Swift) 및 DB 접속 URL 확인
  
  $ bosh -e micro-bosh -d paasta-marketplace-env vms
  Deployment 'paasta-marketplace-env'
  
  Instance                                             Process State  AZ  IPs              VM CID                                   VM Type  Active
binary_storage/66e5bf20-da8d-42b4-a325-fba5f6e326e8  running        z2  10.174.1.56      vm-a81d9fe1-e9e8-4729-9786-bbb5f1518234  medium   true
mariadb/01ce2b6f-1038-468d-92f8-f68f72f7ea77         running        z2  10.174.1.57      vm-ce5deeed-ba4e-49d1-b6ab-1f07c779e776  small    true
  
  ==========================================================================================
  ## DB 접속 정보 확인 > PAAS-TA-MARKETPLACE-ENV-RELEASE :: deploy-paasta-marketplace-env.sh 
  
  $ cat PAAS-TA-MARKETPLACE-ENV-RELEASE/deployment/deploy-paasta-marketplace-env.sh
  
  bosh -e micro-bosh -d paasta-marketplace-env deploy paasta-marketplace-env.yml \
    -v default_network_name=default \
    -v stemcell_os=ubuntu-xenial \
    -v vm_type_small=small \
    -v vm_type_medium=medium \
    -v db_port=3306 \                                  ## DB port 설정
    -v db_admin_password="admin!password"              ## DB Admin 패스워드 설정
  
  ==========================================================================================
  ## Object Storage(Swift) 접속 정보 확인 > PAAS-TA-MARKETPLACE-ENV-RELEASE :: paasta-marketplace-env.yml 의 PROPERTIES 영역
  
  $ cat PAAS-TA-MARKETPLACE-ENV-RELEASE/deployment/paasta-marketplace-env.yml
  
  ######### PROPERTIES ##########
  properties:
  mariadb:                                                 # MARIA DB SERVER 설정 정보
    port: ((db_port))
    admin_user:
      password: ((db_admin_password))                      # MARIA DB ADMIN USER PASSWORD
  binary_storage:                                          # BINARY STORAGE SERVER 설정 정보
    proxy_port: 10008                                      # 프록시 서버 Port(Object Storage 접속 Port)
    auth_port: 5000
    username:                                              # 최초 생성되는 유저이름(Object Storage 접속 유저이름)
      - paasta-marketplace
    password:                                              # 최초 생성되는 유저 비밀번호(Object Storage 접속 유저 비밀번호)
      - paasta
    tenantname:                                            # 최초 생성되는 테넌트 이름(Object Storage 접속 테넌트 이름)
      - paasta-marketplace
    email:                                                 # 최소 생성되는 유저의 이메일
      - email@email.com
    binary_desc:                                           # objectStorage_swift_container
      - 'marketplace-container'                                 
  ``` 
  
  - **마켓플레이스 Object Storage(Swift) 및 DB 환경 정보**
  ```
  ## Object Storage(Swift)
    OBJECT STORAGE TENANTNAME : paasta-marketplace
    OBJECT STORAGE USERNAME : paasta-marketplace
    OBJECT STORAGE PASSWORD : paasta
    OBJECT STORAGE AUTHURL : http://<OBJECT_STORAGE_IP>:5000/v2.0/tokens
    OBJECT STORAGE CONTAINER : marketplace-container
    
  ## DB 정보
    DB PORT : 3306
    DB ADMIN PASSWORD : "admin!password"
  ``` 
  
### <div id='222'/> 2.2.2. manifest 파일 설정
- 마켓플레이스 manifest는 Components 요소 및 배포의 속성을 정의한 YAML 파일이다. manifest 파일에는 어떤 name, memory, instance, host, path, buildpack, env 등을 사용 할 것인지 정의가 되어 있다.

  1) marketplace-api 의 manifest 파일을 환경에 맞게 수정한다.
    
  ```
  $ cd ${HOME}/workspace/paasta-5.0/release/service/marketplace/marketplace-api
  $ vi manifest.yml
  
  ---
  applications:
  - name: marketplace-api
    memory: 2G
    disk_quota: 2G
    instances: 1
    buildpacks:
    - java_buildpack
    path: ./marketplace-api.jar
    env:
      server_port: 8777
      spring_application_name: marketplace-api
      spring_security_username: admin
      spring_security_password: openpaasta
      spring_datasource_driver-class-name: com.mysql.cj.jdbc.Driver
      spring_datasource_url: jdbc:mysql://<DB_IP>:<DB_PORT>/marketplace?characterEncoding=utf8&autoReconnect=true&serverTimezone=Asia/Seoul         
      spring_datasource_username: root
      spring_datasource_password: <DB_ADMIN_PASSWORD>
      spring_jpa_database: mysql
      spring_jpa_hibernate_ddl-auto: update
      spring_jpa_hibernate_use-new-id-generator-mappings: false
      spring_jpa_show-sql: true
      spring_jpa_database-platform: org.hibernate.dialect.MySQL5InnoDBDialect
      spring_jpa_properties_hibernate_jdbc: Asia/Seoul
      spring_jackson_serialization_fail-on-empty-beans: false
      spring_jackson_default-property-inclusion: NON_NULL
      spring_servlet_multipart_max-file-size: 100MB
      spring_servlet_multipart_max-request-size: 100MB
      
      cloudfoundry_cc_api_url: https://api.<DOMAIN>
      cloudfoundry_cc_api_uaaUrl: https://uaa.<DOMAIN>
      cloudfoundry_cc_api_sslSkipValidation: true
      cloudfoundry_cc_api_proxyUrl: ""
      cloudfoundry_cc_api_host: ".<DOMAIN>"
      cloudfoundry_user_admin_username: admin
      cloudfoundry_user_admin_password: 'admin'
      cloudfoundry_user_uaaClient_clientId: admin
      cloudfoundry_user_uaaClient_clientSecret: admin-secret
      cloudfoundry_user_uaaClient_adminClientId: admin
      cloudfoundry_user_uaaClient_adminClientSecret: admin-secret
      cloudfoundry_user_uaaClient_loginClientId: admin
      cloudfoundry_user_uaaClient_loginClientSecret: admin-secret
      cloudfoundry_user_uaaClient_skipSSLValidation: true
      cloudfoundry_authorization: cf-Authorization

      market_org_name: "marketplace-org"
      market_org_guid: "<marketplace-org 조직 GUID>"
      market_space_name: "marketplace-space"
      market_space_guid: "<marketplace-space 공간 GUID>"
      market_domain_guid: "<도메인 GUID>"
      market_quota_guid: "<marketplace_quota 쿼타 GUID>"
      market_naming-type: "Auto"

      objectStorage_swift_tenantName: <OBJECT_STORAGE_TENANTNAME>
      objectStorage_swift_username: <OBJECT_STORAGE_USERNAME>
      objectStorage_swift_password: <OBJECT_STORAGE_PASSWORD>
      objectStorage_swift_authUrl: http://<OBJECT_STORAGE_IP>:5000/v2.0/tokens
      objectStorage_swift_authMethod: keystone
      objectStorage_swift_preferredRegion: Public
      objectStorage_swift_container: <OBJECT_STORAGE_CONTAINER>
    
      provisioning_pool-size: 3
      provisioning_try-count: 7
      provisioning_timeout: 3600000
      provisioning_ready-fixed-rate: 10000
      provisioning_ready-initial-delay: 3000
      provisioning_progress-fixed-rate: 10000
      provisioning_progress-initial-delay: 5000
      provisioning_timeout-fixed-rate: 30000
      provisioning_timeout-initial-delay: 1700

      deprovisioning_pool-size: 3
      deprovisioning_try-count: 7
      deprovisioning_timeout: 3600000
      deprovisioning_ready-fixed-rate: 10000
      deprovisioning_ready-initial-delay: 7000
      deprovisioning_progress-fixed-rate: 10000
      deprovisioning_progress-initial-delay: 13000
      deprovisioning_timeout-fixed-rate: 30000
      deprovisioning_timeout-initial-delay: 1700

      task_execution_restrict-to-same-host: false
      
      java_opts: '-XX:MaxMetaspaceSize=256000K -Xss349K -Xms1G -XX:MetaspaceSize=256000K -Xmx1G'

  ```
  <br>
  
  2) marketplace-webadmin 의 manifest 파일을 환경에 맞게 수정한다.  
    
  ```
  $ cd ${HOME}/workspace/paasta-5.0/release/service/marketplace/marketplace-webadmin
  $ vi manifest.yml
  
  ---
  applications:
  - name: marketplace-webadmin
    memory: 1G
    instances: 1
    buildpacks:
    - java_buildpack
    path: ./marketplace-web-admin.war
    env:
      server_port: 8778
      spring_application_name: marketplace-webadmin
      spring_servlet_multipart_max-file-size: 1024MB
      spring_servlet_multipart_max-request-size: 1024MB
      spring_session_store-type: jdbc
      spring_session_jdbc_initialize-schema: always
      spring_session_jdbc_schema: classpath:org/springframework/session/jdbc/schema-mysql.sql
      spring_mvc_static-path-pattern: /static/**
      spring_datasource_driver-class-name: com.mysql.cj.jdbc.Driver
      spring_datasource_url: jdbc:mysql://<DB_IP>:<DB_PORT>/marketplace_admin?characterEncoding=utf8&autoReconnect=true
      spring_datasource_username: root
      spring_datasource_password: <DB_ADMIN_PASSWORD>

      marketplace_api_url: http://marketplace-api.<DOMAIN>   # 'marketplace-api' App 의 urls
      marketplace_registration: cf
      marketplace_client-id: marketclient
      marketplace_client-secret: clientsecret
      marketplace_redirect-uri: http://marketplace-webadmin.<DOMAIN>/login/oauth2/code/cf
      marketplace_uaa-logout-url: https://uaa.<DOMAIN>/logout.do
      marketplace_uaa-logout-rediredct-url: http://marketplace-webadmin.<DOMAIN>/main
      
      marketplace_authorization-uri: https://uaa.<DOMAIN>/oauth/authorize
      marketplace_token-uri: https://uaa.<DOMAIN>/oauth/token
      marketplace_user-info-uri: https://uaa.<DOMAIN>/userinfo
      marketplace_jwk-set-uri: https://uaa.<DOMAIN>/token_keys
      cloudfoundry_cc_api_host: ".<DOMAIN>"
  ```
  <br>
  
  3) marketplace-webseller 의 manifest 파일을 환경에 맞게 수정한다.  
    
  ```
  $ cd ${HOME}/workspace/paasta-5.0/release/service/marketplace/marketplace-webseller
  $ vi manifest.yml
  
  ---
  applications:
  - name: marketplace-webseller
    memory: 1G
    instances: 1
    buildpacks:
    - java_buildpack
    path: ./marketplace-web-seller.war
    env:
      server_port: 8780
      spring_application_name: marketplace-webseller
      spring_servlet_multipart_max-file-size: 1024MB
      spring_servlet_multipart_max-request-size: 1024MB
      spring_session_store-type: jdbc
      spring_session_jdbc_initialize-schema: always
      spring_session_jdbc_schema: classpath:org/springframework/session/jdbc/schema-mysql.sql
      spring_mvc_static-path-pattern: /static/**
      spring_thymeleaf_cache: false
      spring_datasource_driver-class-name: com.mysql.cj.jdbc.Driver
      spring_datasource_url: jdbc:mysql://<DB_IP>:<DB_PORT>/marketplace_seller?characterEncoding=utf8&autoReconnect=true
      spring_datasource_username: root
      spring_datasource_password: <DB_ADMIN_PASSWORD>

      marketplace_api_url: http://marketplace-api.<DOMAIN>   # 'marketplace-api' App 의 urls
      marketplace_registration: cf
      marketplace_client-id: marketclient
      marketplace_client-secret: clientsecret
      marketplace_redirect-uri: http://marketplace-webseller.<DOMAIN>/login/oauth2/code/cf
      marketplace_uaa-logout-url: https://uaa.<DOMAIN>/logout.do
      marketplace_uaa-logout-rediredct-url: http://marketplace-webseller.<DOMAIN>/main
      marketplace_authorization-uri: https://uaa.<DOMAIN>/oauth/authorize
      marketplace_token-uri: https://uaa.<DOMAIN>/oauth/token
      marketplace_user-info-uri: https://uaa.<DOMAIN>/userinfo
      marketplace_jwk-set-uri: https://uaa.<DOMAIN>/token_keys

      # 파일 업로드 Swift
      objectStorage_swift_tenantName: <OBJECT_STORAGE_TENANTNAME>
      objectStorage_swift_username: <OBJECT_STORAGE_USERNAME>
      objectStorage_swift_password: <OBJECT_STORAGE_PASSWORD>
      objectStorage_swift_authUrl: http://<OBJECT_STORAGE_IP>:5000/v2.0/tokens
      objectStorage_swift_authMethod: keystone
      objectStorage_swift_preferredRegion: Public
      objectStorage_swift_container: <OBJECT_STORAGE_CONTAINER>
  ```
  <br>

  4) marketplace-webuser 의 manifest 파일을 환경에 맞게 수정한다.  
    
  ```
  $ cd ${HOME}/workspace/paasta-5.0/release/service/marketplace/marketplace-webuser
  $ vi manifest.yml
  
  ---
  applications:
  - name: marketplace-webuser
    memory: 2G
    instances: 1
    buildpacks:
    - java_buildpack
    path: ./marketplace-web-user.war
    env:
      server_port: 8779
      spring_application_name: marketplace-webuser
      spring_servlet_multipart_max-file-size: 1024MB
      spring_servlet_multipart_max-request-size: 1024MB
      spring_session_store-type: jdbc
      spring_session_jdbc_initialize-schema: always
      spring_session_jdbc_schema: classpath:org/springframework/session/jdbc/schema-mysql.sql
      spring_mvc_static-path-pattern: /static/**
      spring_datasource_driver-class-name: com.mysql.cj.jdbc.Driver
      spring_datasource_url: jdbc:mysql://<DB_IP>:<DB_PORT>/marketplace_user?characterEncoding=utf8&autoReconnect=true
      spring_datasource_username: root
      spring_datasource_password: <DB_ADMIN_PASSWORD>

      marketplace_api_url: http://marketplace-api.<DOMAIN>   # 'marketplace-api' App 의 urls
      marketplace_registration: cf
      marketplace_client-id: marketclient
      marketplace_client-secret: clientsecret
      marketplace_redirect-uri: http://marketplace-webuser.<DOMAIN>/login/oauth2/code/cf
      marketplace_uaa-logout-url: https://uaa.<DOMAIN>/logout.do
      marketplace_uaa-logout-rediredct-url: http://marketplace-webuser.<DOMAIN>/main

      marketplace_authorization-uri: https://uaa.<DOMAIN>/oauth/authorize
      marketplace_token-uri: https://uaa.<DOMAIN>/oauth/token
      marketplace_user-info-uri: https://uaa.<DOMAIN>/userinfo
      marketplace_jwk-set-uri: https://uaa.<DOMAIN>/token_keys
  ```
<br>

### <div id='223'/> 2.2.3. 마켓플레이스 App 배포

  - 마켓플레이스 배포용 조직 및 공간으로 target을 설정한다.  
  ```
  $ cf target -o marketplace -s system
  ```  
  
  - 마켓플레이스 API (marketplace-api) 배포  
   > 마켓플레이스 API는 공통적으로 사용되는 App으로 가장 먼저 배포한다.  
   
  ```
  $ cd ${HOME}/workspace/paasta-5.0/release/service/marketplace/marketplace-api
  $ cf push marketplace-api -f manifest.yml

  Pushing from manifest to org marketplace / space system as admin...
  Using manifest file /home/ubuntu/workspacepaasta-5.0/release/service/marketplace/marketplace-api/manifest.yml
  Getting app info...
  Creating app with these attributes...
  + name:         marketplace-api
    path:         /home/ubuntu/workspacepaasta-5.0/release/service/marketplace/marketplace-api/marketplace-api.jar
    buildpacks:
  +   java_buildpack
  + disk quota:   2G
  + instances:    1
  + memory:       2G
    env:
  +   cloudfoundry_authorization
  +   cloudfoundry_cc_api_host
  +   cloudfoundry_cc_api_proxyUrl
  +   cloudfoundry_cc_api_sslSkipValidation
  +   cloudfoundry_cc_api_uaaUrl
  +   cloudfoundry_cc_api_url

  ... ((생략)) ... 

  Creating app marketplace-api...
  Mapping routes...
  Comparing local files to remote cache...
  Packaging files to upload...
  Uploading files...
   951.66 KiB / 951.66 KiB [======================================================] 100.00% 1s

  Waiting for API to complete processing files...

  Staging app and tracing logs...
     Downloading java_buildpack...
     Downloaded java_buildpack

  ... ((생략)) ... 

  Waiting for app to start...

  name:              marketplace-api
  requested state:   started
  routes:            marketplace-api.<DOMAIN>
  last uploaded:     Tue 24 Dec 06:42:41 UTC 2019
  stack:             cflinuxfs3
  buildpacks:        java_buildpack

  type:            web
  instances:       1/1
  memory usage:    2048M
  start command:   JAVA_OPTS="-agentpath:$PWD/.java-buildpack/open_jdk_jre/bin/jvmkill-1.16.0_RELEASE=printHeapHistogram=1
                   -Djava.io.tmpdir=$TMPDIR -XX:ActiveProcessorCount=$(nproc)
                   -javaagent:$PWD/BOOT-INF/lib/aspectjweaver-1.9.2.jar
                   -Djava.ext.dirs=$PWD/.java-buildpack/container_security_provider:$PWD/.java-buildpack/open_jdk_jre/lib/ext
                   -Djava.security.properties=$PWD/.java-buildpack/java_security/java.security
                   $JAVA_OPTS" &&
                   CALCULATED_MEMORY=$($PWD/.java-buildpack/open_jdk_jre/bin/java-buildpack-memory-calculator-3.13.0_RELEASE
                   -totMemory=$MEMORY_LIMIT -loadedClasses=22691 -poolType=metaspace
                   -stackThreads=250 -vmOptions="$JAVA_OPTS") && echo JVM Memory
                   Configuration: $CALCULATED_MEMORY && JAVA_OPTS="$JAVA_OPTS
                   $CALCULATED_MEMORY" && MALLOC_ARENA_MAX=2 SERVER_PORT=$PORT eval exec
                   $PWD/.java-buildpack/open_jdk_jre/bin/java $JAVA_OPTS -cp $PWD/.
                   org.springframework.boot.loader.JarLauncher
       state     since                  cpu      memory         disk           details
  #0   running   2019-12-24T06:43:09Z   304.5%   823.5M of 2G   170.5M of 2G   
     
  ```

  - 마켓플레이스 Web Admin (marketplace-webadmin) 배포
  
  ```
  $ cd ${HOME}/workspace/paasta-5.0/release/service/marketplace/marketplace-webadmin
  $ cf push marketplace-webadmin -f manifest.yml

  Pushing from manifest to org marketplace / space system as admin...
  Using manifest file /home/ubuntu/workspace/release/service/marketplace/marketplace-webadmin/manifest.yml
  Getting app info...
  Creating app with these attributes...
  + name:         marketplace-webadmin
    path:         /home/ubuntu/workspace/release/service/marketplace/marketplace-webadmin/marketplace-web-admin.war
    buildpacks:
  +   java_buildpack
  + instances:    1
  + memory:       1G
    env:
  +   cloudfoundry_cc_api_host
  +   marketplace_api_url
  +   marketplace_authorization-uri
  +   marketplace_client-id

    ... ((생략)) ...

  Creating app marketplace-webadmin...
  Mapping routes...
  Comparing local files to remote cache...
  Packaging files to upload...
  Uploading files...
   1.67 MiB / 1.67 MiB [==========================================================] 100.00% 1s

  Waiting for API to complete processing files...

  Staging app and tracing logs...
     Downloading java_buildpack...
     Downloaded java_buildpack

    ... ((생략)) ...

  Waiting for app to start...

  name:              marketplace-webadmin
  requested state:   started
  routes:            marketplace-webadmin.<DOMAIN>
  last uploaded:     Tue 24 Dec 06:50:05 UTC 2019
  stack:             cflinuxfs3
  buildpacks:        java_buildpack

  type:            web
  instances:       1/1
  memory usage:    1024M
  start command:   JAVA_OPTS="-agentpath:$PWD/.java-buildpack/open_jdk_jre/bin/jvmkill-1.16.0_RELEASE=printHeapHistogram=1
                   -Djava.io.tmpdir=$TMPDIR -XX:ActiveProcessorCount=$(nproc)
                   -Djava.ext.dirs=$PWD/.java-buildpack/container_security_provider:$PWD/.java-buildpack/open_jdk_jre/lib/ext
                   -Djava.security.properties=$PWD/.java-buildpack/java_security/java.security
                   $JAVA_OPTS" &&
                   CALCULATED_MEMORY=$($PWD/.java-buildpack/open_jdk_jre/bin/java-buildpack-memory-calculator-3.13.0_RELEASE
                   -totMemory=$MEMORY_LIMIT -loadedClasses=21980 -poolType=metaspace
                   -stackThreads=250 -vmOptions="$JAVA_OPTS") && echo JVM Memory
                   Configuration: $CALCULATED_MEMORY && JAVA_OPTS="$JAVA_OPTS
                   $CALCULATED_MEMORY" && MALLOC_ARENA_MAX=2 SERVER_PORT=$PORT eval exec
                   $PWD/.java-buildpack/open_jdk_jre/bin/java $JAVA_OPTS -cp $PWD/.
                   org.springframework.boot.loader.WarLauncher
       state     since                  cpu    memory         disk           details
  #0   running   2019-12-24T06:50:23Z   0.0%   151.7M of 1G   222.7M of 1G   
  
  ```

  - 마켓플레이스 Web Seller (marketplace-webseller) 배포
  ```
  $ cd ${HOME}/workspace/paasta-5.0/release/service/marketplace/marketplace-webseller
  $ cf push marketplace-webseller -f manifest.yml
  
  Pushing from manifest to org marketplace / space system as admin...
  Using manifest file /home/ubuntu/workspace/paasta-5.0/release/service/marketplace/marketplace-webseller/manifest.yml
  Getting app info...
  Creating app with these attributes...
  + name:         marketplace-webseller
    path:         /home/ubuntu/workspace/paasta-5.0/release/service/marketplace/marketplace-webseller/marketplace-web-seller.war
    buildpacks:
  +   java_buildpack
  + instances:    1
  + memory:       1G
    env:
  +   marketplace_api_url
  +   marketplace_authorization-uri
  +   marketplace_client-id

  ... ((생략)) ...

  Creating app marketplace-webseller...
  Mapping routes...
  Comparing local files to remote cache...
  Packaging files to upload...
  Uploading files...
   1.71 MiB / 1.71 MiB [==========================================================] 100.00% 1s

  Waiting for API to complete processing files...

  Staging app and tracing logs...
     Downloading java_buildpack...
     Downloaded java_buildpack

  ... ((생략)) ...

  Waiting for app to start...

  name:              marketplace-webseller
  requested state:   started
  routes:            marketplace-webseller.<DOMAIN>
  last uploaded:     Tue 24 Dec 06:56:23 UTC 2019
  stack:             cflinuxfs3
  buildpacks:        java_buildpack

  type:            web
  instances:       1/1
  memory usage:    1024M
  start command:   JAVA_OPTS="-agentpath:$PWD/.java-buildpack/open_jdk_jre/bin/jvmkill-1.16.0_RELEASE=printHeapHistogram=1
                   -Djava.io.tmpdir=$TMPDIR -XX:ActiveProcessorCount=$(nproc)
                   -Djava.ext.dirs=$PWD/.java-buildpack/container_security_provider:$PWD/.java-buildpack/open_jdk_jre/lib/ext
                   -Djava.security.properties=$PWD/.java-buildpack/java_security/java.security
                   $JAVA_OPTS" &&
                   CALCULATED_MEMORY=$($PWD/.java-buildpack/open_jdk_jre/bin/java-buildpack-memory-calculator-3.13.0_RELEASE
                   -totMemory=$MEMORY_LIMIT -loadedClasses=22334 -poolType=metaspace
                   -stackThreads=250 -vmOptions="$JAVA_OPTS") && echo JVM Memory
                   Configuration: $CALCULATED_MEMORY && JAVA_OPTS="$JAVA_OPTS
                   $CALCULATED_MEMORY" && MALLOC_ARENA_MAX=2 SERVER_PORT=$PORT eval exec
                   $PWD/.java-buildpack/open_jdk_jre/bin/java $JAVA_OPTS -cp $PWD/.
                   org.springframework.boot.loader.WarLauncher
       state     since                  cpu    memory      disk           details
  #0   running   2019-12-24T06:56:44Z   0.0%   43M of 1G   228.3M of 1G  
  ```  
  
  - 마켓플레이스 Web User (marketplace-webuser) 배포
  ```
  $ cd ${HOME}/workspace/paasta-5.0/release/service/marketplace/marketplace-webuser
  $ cf push marketplace-webuser -f manifest.yml
  
  Pushing from manifest to org marketplace / space system as admin...
  Using manifest file /home/ubuntu/workspace/paasta-5.0/release/service/marketplace/marketplace-webuser/manifest.yml
  Getting app info...
  Creating app with these attributes...
  + name:         marketplace-webuser
    path:         /home/ubuntu/workspace/paasta-5.0/release/service/marketplace/marketplace-webuser/marketplace-web-user.war
    buildpacks:
  +   java_buildpack
  + instances:    1
  + memory:       2G
    env:
  +   marketplace_api_url
  +   marketplace_authorization-uri
  +   marketplace_client-id

  ... ((생략)) ...

  Creating app marketplace-webuser...
  Mapping routes...
  Comparing local files to remote cache...
  Packaging files to upload...
  Uploading files...
   1.60 MiB / 1.60 MiB [==========================================================] 100.00% 1s

  Waiting for API to complete processing files...

  Staging app and tracing logs...
     Downloading java_buildpack...
     Downloaded java_buildpack

  ... ((생략)) ...

  Waiting for app to start...

  name:              marketplace-webuser
  requested state:   started
  routes:            marketplace-webuser.<DOMAIN>
  last uploaded:     Tue 24 Dec 07:01:08 UTC 2019
  stack:             cflinuxfs3
  buildpacks:        java_buildpack

  type:            web
  instances:       1/1
  memory usage:    2048M
  start command:   JAVA_OPTS="-agentpath:$PWD/.java-buildpack/open_jdk_jre/bin/jvmkill-1.16.0_RELEASE=printHeapHistogram=1
                   -Djava.io.tmpdir=$TMPDIR -XX:ActiveProcessorCount=$(nproc)
                   -Djava.ext.dirs=$PWD/.java-buildpack/container_security_provider:$PWD/.java-buildpack/open_jdk_jre/lib/ext
                   -Djava.security.properties=$PWD/.java-buildpack/java_security/java.security
                   $JAVA_OPTS" &&
                   CALCULATED_MEMORY=$($PWD/.java-buildpack/open_jdk_jre/bin/java-buildpack-memory-calculator-3.13.0_RELEASE
                   -totMemory=$MEMORY_LIMIT -loadedClasses=21979 -poolType=metaspace
                   -stackThreads=250 -vmOptions="$JAVA_OPTS") && echo JVM Memory
                   Configuration: $CALCULATED_MEMORY && JAVA_OPTS="$JAVA_OPTS
                   $CALCULATED_MEMORY" && MALLOC_ARENA_MAX=2 SERVER_PORT=$PORT eval exec
                   $PWD/.java-buildpack/open_jdk_jre/bin/java $JAVA_OPTS -cp $PWD/.
                   org.springframework.boot.loader.WarLauncher
       state     since                  cpu    memory         disk           details
  #0   running   2019-12-24T07:01:29Z   0.0%   212.9M of 2G   220.1M of 1G 
  ```
<br>


- 배포된 마켓플레이스 App을 확인한다.

  ```
  $ cf apps
  Getting apps in org marketplace / space system as admin...
  OK

  name                    requested state   instances   memory   disk   urls
  marketplace-api         started           1/1         2G       2G     marketplace-api.<DOMAIN>
  marketplace-webadmin    started           1/1         1G       1G     marketplace-webadmin.<DOMAIN>
  marketplace-webuser     started           1/1         2G       1G     marketplace-webuser.<DOMAIN>
  marketplace-webseller   started           1/1         1G       1G     marketplace-webseller.<DOMAIN>

  ```

### <div id='23'/> 2.3. 마켓플레이스 UAA Client Id 등록
UAA 계정 등록 절차에 대한 순서를 확인한다.

- uaac server의 endpoint를 설정한다.

  ```
  $ uaac target

  Target: https://uaa.<DOMAIN>
  Context: admin, from client admin
  ```

- URL을 변경하고 싶을 경우 아래와 같이 입력하여 변경 가능하다. <br>
  ```
  uaac target https://uaa.<DOMAIN>
  ```

- UAAC 로그인을 한다.

  ```
  $ uaac token client get
  Client ID: ****************
  Client secret: ****************

  Successfully fetched token via client credentials grant.
  Target: https://uaa.<DOMAIN>
  Context: admin, from client admin
  ```

- Marketplace 서비스 계정 생성을 한다. (계정이 이미 있는 경우 다음 항목을 참조한다.)

> $ uaac client add marketclient -s {클라이언트 비밀번호} --redirect_uri {마켓플레이스 서비스 대시보드 URI} --scope {퍼미션 범위} --authorized_grant_types {권한 타입} --authorities={권한 퍼미션} --autoapprove={자동승인권한}
> - 클라이언트 비밀번호 : uaac 클라이언트 비밀번호를 입력한다.
> - 마켓플레이스 서비스 대시보드 URI : 성공적으로 리다이렉션 할 마켓플레이스 서비스 대시보드 URI를 입력한다.
> - 퍼미션 범위: 클라이언트가 사용자를 대신하여 얻을 수있는 허용 범위 목록을 입력한다.
> - 권한 타입 : 서비스팩이 제공하는 API를 사용할 수 있는 권한 목록을 입력한다.
> - 권한 퍼미션 : 클라이언트에 부여 된 권한 목록을 입력한다.
> - 자동승인권한: 사용자 승인이 필요하지 않은 권한 목록을 입력한다.

  ```
  $ uaac client add marketclient -s clientsecret --redirect_uri "http://marketplace-webseller.<DOMAIN> http://marketplace-webseller.<DOMAIN>/main http://marketplace-webuser.<DOMAIN> http://marketplace-webuser.<DOMAIN>/main http://marketplace-webadmin.<DOMAIN> http://marketplace-webadmin.<DOMAIN>/main" --scope "cloud_controller_service_permissions.read , openid , cloud_controller.read , cloud_controller.write , cloud_controller.admin" --authorized_grant_types "authorization_code , client_credentials , refresh_token" --authorities="uaa.resource" --autoapprove="openid , cloud_controller_service_permissions.read"
  ```


- Marketplace 서비스 계정 정보를 수정한다. (이미 uaac client가 등록되어 있는 경우)

> $ uaac client update marketclient --redirect_uri={마켓플레이스 서비스 대시보드 URI}
>
> - 마켓플레이스 서비스 대시보드 URI : 성공적으로 리다이렉션 할 마켓플레이스 서비스 대시보드 URI를 입력한다.

  ```
  $ uaac client update marketclient --redirect_uri="http://marketplace-webseller.<DOMAIN> http://marketplace-webseller.<DOMAIN>/main http://marketplace-webuser.<DOMAIN> http://marketplace-webuser.<DOMAIN>/main http://marketplace-webadmin.<DOMAIN> http://marketplace-webadmin.<DOMAIN>/main"
  ```

### <div id='24'/> 2.4. 마켓플레이스 서비스 관리
PaaS-TA 운영자 포탈을 통해 마켓플레이스 서비스를 등록 및 공개하면, PaaS-TA 운영자/사용자 포탈을 통해 진입 하여 사용할 수 있다.

>1. PaaS-TA 운영자 포탈에 접속하여 로그인한다.  

![AdminPortal_login]
<br>

>2. 운영관리 > 코드 관리 페이지에서 Group Table의 "등록" 버튼을 클릭한다.

![AdminPortal_Group]
<br>

>3. Group Table 코드 상세를 등록한다.

>3.1. 마켓플레이스 URL 항목을 등록한다.

![AdminPortal_GroupUser]
<br>

>3.2. 마켓플레이스 어드민 URL 항목을 등록한다.

![AdminPortal_GroupAdmin]
<br>

>4. 사용자/판매자 Group Table 항목을 클릭하고 Detail Table의 "등록" 버튼을 클릭한다.

![AdminPortal_Detail]
<br>

>5. Detail Table 코드 상세를 등록한다.

>5.1. 사용자 마켓플레이스 항목을 등록한다.  

![AdminPortal_DetailUser]
<br>

>5.2. 판매자 마켓플레이스 항목을 등록한다.  

![AdminPortal_DetailSeller]
<br>

>6. 관리자 Group Table의 Detail Table 코드 상세를 등록한다.

>6.1. 관리자 마켓플레이스 항목을 등록한다.

![AdminPortal_DetailAdmin]
<br>

[Architecture]:./images/Market_Place_Architecture.png
[AdminPortal_login]:./images/AdminPortal_login.png
[AdminPortal_Group]:./images/AdminPortal_Group.png
[AdminPortal_GroupUser]:./images/AdminPortal_GroupUser.png
[AdminPortal_GroupAdmin]:./images/AdminPortal_GroupAdmin.png
[AdminPortal_Detail]:./images/AdminPortal_Detail.png
[AdminPortal_DetailUser]:./images/AdminPortal_DetailUser.png
[AdminPortal_DetailSeller]:./images/AdminPortal_DetailSeller.png
[AdminPortal_DetailAdmin]:./images/AdminPortal_DetailAdmin.png
