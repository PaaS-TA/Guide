## Table of Contents

[1. 문서 개요](#1)

  -  [1.1. 목적](#11)
  -  [1.2. 범위](#12)
  -  [1.3. 시스템 구성도](#13)

[2. 마켓플레이스 배포](#2)

  -  [2.1. 설치 전 준비사항](#21)
  -  [2.1.1. App 파일 및 Manifest 파일 다운로드](#211)
  -  [2.2. 마켓플레이스 Manifest 파일 수정 및 App 배포](#22)
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

##### 마켓플레이스 설치에 필요한 Object Storage(Swift)의 정보를 설정하기 위해서는 paasta-marketplace-env-release가 설치되어 있어야 한다.
-	설치 가이드 및 사용자 가이드
  > PaaS-TA Marketplace Environment Release 설치: https://github.com/PaaS-TA/PAAS-TA-MARKETPLACE-ENV-RELEASE
  
#### <div id='211'/> 2.1.1. App 파일 및 Manifest 파일 다운로드

마켓플레이스 설치에 필요한 App 파일 및 Manifest 파일을 다운로드 받아 서비스 설치 작업 경로로 위치시킨다.

-	설치 파일 다운로드 위치 : https://paas-ta.kr/download/package
-	App, Manifest 파일은 /home/{user_name}/workspace/paasta-5.0/release/service/marketplace 이하에 다운로드 받아야 한다.
-	설치 작업 경로 생성 및 파일 다운로드

> Marketplace 관련 프로젝트 폴더
  >> marketplace-api<br>
  >> marketplace-webuser<br>
  >> marketplace-webseller<br>
  >> marketplace-webadmin<br>

* 각 폴더 내부에는 manifest.yml 파일과 jar/war 파일로 구성되어 있습니다.
>	Manifest 파일
 >> manifest.yml

> Application 파일
 >> marketplace-api.jar<br>
 >> marketplace-web-user.war<br>
 >> marketplace-web-seller.war<br>
 >> marketplace-web-admin.war<br>

 ```
 - Application 파일 다운로드 파일 위치 경로 생성
 $ mkdir -p ~/workspace/paasta-5.0/release/service/marketplace
 ```

 -	Marketplace 관련 폴더들을 다운로드 받아 ~/workspace/paasta-5.0/release/service/marketplace 이하 디렉토리에 이동한다.


### <div id='22'/> 2.2. 마켓플레이스 Manifest 파일 수정 및 App 배포
### <div id='221'/> 2.2.1. CF 공간 설정 및 백엔드 서비스 설정
1) 마켓플레이스를 설치할 CF 공간을 설정하기 위해 PaaS-TA 어드민 계정으로 CF에 로그인한 후 Marketplace를 배포할 조직 및 공간을 생성하고, 배포할 공간으로 target 설정을 한다. 아래는 cf login 후 신규로 설정하는 명령어 모음이다.
  ```
  $ cf create-quota marketplace_quota -m 100G -i -1 -s -1 -r -1 --reserved-route-ports -1 --allow-paid-service-plans
  $ cf create-org marketplace -q marketplace_quota
  $ cf create-space system -o marketplace
  ```

2) 아래는 마켓플레이스의 상품을 배포할 CF 공간을 설정하기 위해 PaaS-TA 어드민 계정으로 CF에 로그인한 후 상품 배포용 조직 및 공간을 생성하는 명령어 모음이다.
  ```
  $ cf create-org marketplace-org -q marketplace_quota
  $ cf create-space marketplace-space -o marketplace-org
  $ cf target -o marketplace-org -s marketplace-space
  ```
3) 생성한 조직과 공간, 쿼타에 대한 GUID 를 확인한다.
  ```
  - 조직 GUID : $ cf org marketplace-org --guid
  - 공간 GUID : $ cf space marketplace-space --guid
  - 쿼타 GUID : $ cf curl "/v2/quota_definitions"
    => 생성한 쿼타명에 해당하는 resources.metadata.guid
  - 도메인 GUID : $ cf curl "/v2/domains"
    => resources.metadata.guid
  ```

4) 마켓플레이스에 필요한 DBMS 를 신청한다.
  ```
  $ cf service-brokers

  $ cf service-access -b mysql-service-broker

  $ cf create-service <서비스명> <서비스플랜> <내 서비스명>
  예시) $ cf create-service Mysql-DB Mysql-Plan2-100con marketplace-mysql
  ```
  > MySQL 서비스 신청 참고 : https://github.com/PaaS-TA/Guide-5.0-Ravioli/blob/master/service-guide/dbms/PAAS-TA_MYSQL_SERVICE_INSTALL_GUIDE_V1.0.md

  또는

  > PaaS-TA 사용자 포탈 참고 : https://github.com/PaaS-TA/Guide-5.0-Ravioli/blob/master/use-guide/portal/PAAS-TA_USER_PORTAL_USE_GUIDE_V1.1.md

<br>

5) 마켓플레이스에 필요한 Object Storage(Swift) 정보를 확인한다.
  ```
  1) 아래 URL을 참고하여 Swift 를 설치한다.
     https://docs.openstack.org/swift/latest/development_saio.html

  2) 설치를 모두 마친 뒤 아래와 같이 Marketplace Api 와 Marketplace Seller 프로젝트의 manifest.yml 에 Swfit 정보를 수정해 준다.

    *******************************< manifest.yml >*******************************
    objectStorage.swift.tenantName: <생성한 Object Storage tenant 이름>
    objectStorage.swift.username: <생성한 Object Storage account 사용자 이름>
    objectStorage.swift.password: <생성한 Object Storage account password>
    objectStorage.swift.authUrl: <생성한 Object Storage API 엔드포인트>
    objectStorage.swift.authMethod: <Object Storage 인증 메서드>
    objectStorage.swift.preferredRegion: <설정해준 Region>
    objectStorage.swift.container: <생성한 Object Storage Container 이름>
    ******************************************************************************

  ```

### <div id='222'/> 2.2.2. manifest 파일 설정
- 마켓플레이스 manifest는 Components 요소 및 배포의 속성을 정의한 YAML 파일이다. manifest 파일에는 어떤 name, memory, instance, host, path, buildpack, env 등을 사용 할 것인지 정의가 되어 있다.
  >1) 마켓플레이스의 각 프로젝트 별 manifest 파일을 확인한다. 본 가이드에서 manifest 파일 및 cf 명령문에서 사용되는각 마켓플레이스 앱의 이름은 다음과 같다.
  >>- marketplace-api
  >>- marketplace-webuser
  >>- marketplace-webseller
  >>- marketplace-webadmin


  > 2) 마켓플레이스 App 을 배포하기 위해 필요한  manifest 파일에 앞서 확인하였던 Object Storage 정보, 마켓플레이스 DBMS 신청 서비스 정보 들을 아래의 manifest 파일에 수정하여 넣는다.
     >>- 조직
     >>- 공간
     >>- 쿼타 GUID
     >>- Object Storage 정보
     >>- 마켓플레이스 DBMS 신청 서비스 정보
  > 3) marketplace api 와는 달리 marketplace web-user/ web-seller / web-admin 의 경우에는 'marketplace_api_url' 에 미리 배포하였던 marketplace-api 의 url 을 넣어 수정한다.

  <strong>[ marketplace-api/manifest.yml ]</strong>
  ```
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
      spring_datasource_url: jdbc:${vcap.services.Mysql-DB.credentials.uri}/marketplace?characterEncoding=utf8&autoReconnect=true&serverTimezone=Asia/Seoul
      spring_datasource_username: ${vcap.services.Mysql-DB.credentials.username}
      spring_datasource_password: ${vcap.services.Mysql-DB.credentials.password}
      spring_jpa_database: mysql
      spring_jpa_hibernate_ddl-auto: update
      spring_jpa_hibernate_use-new-id-generator-mappings: false
      spring_jpa_show-sql: true
      spring_jpa_database-platform: org.hibernate.dialect.MySQL5InnoDBDialect
      spring_jpa_properties_hibernate_jdbc: Asia/Seoul
      spring_jackson_serialization_fail-on-empty-beans: false
      spring_jackson_default-property-inclusion: NON_NULL
      spring_servlet_multipart_max-file-size: 100MB

      ### 수정 필요 ###
      cloudfoundry_cc_api_url: https://api.<DOMAIN>.xip.io
      cloudfoundry_cc_api_uaaUrl: https://<DOMAIN>.xip.io
      cloudfoundry_cc_api_sslSkipValidation: true
      cloudfoundry_cc_api_proxyUrl: ""
      cloudfoundry_cc_api_host: ".<DOMAIN>.xip.io"
      cloudfoundry_user_admin_username: admin
      cloudfoundry_user_admin_password: 'admin'
      cloudfoundry_user_uaaClient_clientId: login
      cloudfoundry_user_uaaClient_clientSecret: login-secret
      cloudfoundry_user_uaaClient_adminClientId: admin
      cloudfoundry_user_uaaClient_adminClientSecret: admin-secret
      cloudfoundry_user_uaaClient_loginClientId: login
      cloudfoundry_user_uaaClient_loginClientSecret: login-secret
      cloudfoundry_user_uaaClient_skipSSLValidation: true
      cloudfoundry_authorization: cf-Authorization

      ### 수정 필요 ###
      market_org_name: <조직 이름>
      market_org_guid: <조직 GUID>
      market_space_name: <공간 이름>
      market_space_guid: <공간 GUID>
      market_quota_guid: <쿼타 GUID>
      market_domain_guid: <도메인 GUID>
      market_naming-type: "Auto"

      ### 수정 필요 ###
      objectStorage_swift_tenantName: <생성한 Object Storage tenant 이름>
      objectStorage_swift_username: <생성한 Object Storage account 사용자 이름>
      objectStorage_swift_password: <생성한 Object Storage account password>
      objectStorage_swift_authUrl: <생성한 Object Storage API 엔드포인트>
      objectStorage_swift_authMethod: keystone
      objectStorage_swift_preferredRegion: Public
      objectStorage_swift_container: <생성한 Object Storage Container 이름>

      provisioning_pool-size: 3
      provisioning_try-count: 3
      provisioning_timeout: 3600000
      provisioning_ready-fixed-rate: 10000
      provisioning_ready-initial-delay: 3000
      provisioning_progress-fixed-rate: 10000
      provisioning_progress-initial-delay: 5000
      provisioning_timeout-fixed-rate: 30000
      provisioning_timeout-initial-delay: 1700

      deprovisioning_pool-size: 3
      deprovisioning_try-count: 3
      deprovisioning_timeout: 3600000
      deprovisioning_ready-fixed-rate: 10000
      deprovisioning_ready-initial-delay: 7000
      deprovisioning_progress-fixed-rate: 10000
      deprovisioning_progress-initial-delay: 13000
      deprovisioning_timeout-fixed-rate: 30000
      deprovisioning_timeout-initial-delay: 1700

      task_execution_restrict-to-same-host: false

  ```
  <br>

  <strong>[ marketplace-webadmin/manifest.yml ]</strong>
  ```
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
      spring_datasource_url: jdbc:${vcap.services.Mysql-DB.credentials.uri}/marketplace_admin?characterEncoding=utf8&autoReconnect=true
      spring_datasource_username: ${vcap.services.Mysql-DB.credentials.username}
      spring_datasource_password: ${vcap.services.Mysql-DB.credentials.password}
      spring_datasource_validationQuery: SELECT 1
      spring_datasource_hikari_idle-timeout: 300000
      spring_datasource_hikari_max-lifetime: 1200000
      spring_datasource_hikari_connection-timeout: 30000

      ### thymeleaf 자동반영 설정
      spring_devtools_livereload_enabled: true
      spring_devtools_restart_enabled: true

      marketplace_api_url: http://marketplace-api.<DOMAIN>.xip.io   # 먼저 배포한 'marketplace-api' App 의 urls
      marketplace_registration: cf
      marketplace_client-id: marketclient
      marketplace_client-secret: ********
      marketplace_redirect-uri: "{baseUrl}/login/oauth2/code/{registrationId}"
      marketplace_uaa-logout-url: https://<DOMAIN>.xip.io/logout.do
      marketplace_uaa-logout-rediredct-url: http://marketplace-webadmin.<DOMAIN>.xip.io/main
      marketplace_authorization-uri: https://<DOMAIN>/oauth/authorize
      marketplace_token-uri: https://<DOMAIN>/oauth/token
      marketplace_user-info-uri: https://<DOMAIN>/userinfo
      marketplace_jwk-set-uri: https://<DOMAIN>/token_keys
      cloudfoundry_cc_api_host: ".<DOMAIN>.xip.io"
  ```
  <br>

  <strong>[ marketplace-webseller/manifest.yml ]</strong>
  ```
  ---
  applications:
  - name: marketplace-webseller
    memory: 1G
    instances: 1
    buildpacks:
    - java_buildpack
    path: ./marketplace-web-seller.war
    env:
      server_port: 8778
      spring_application_name: marketplace-webseller
      spring_servlet_multipart_max-file-size: 1024MB
      spring_servlet_multipart_max-request-size: 1024MB
      spring_session_store-type: jdbc
      spring_session_jdbc_initialize-schema: always
      spring_session_jdbc_schema: classpath:org/springframework/session/jdbc/schema-mysql.sql
      spring_mvc_static-path-pattern: /static/**
      spring_thymeleaf_cache: false
      spring_datasource_driver-class-name: com.mysql.cj.jdbc.Driver
      spring_datasource_url: jdbc:${vcap.services.Mysql-DB.credentials.uri}/marketplace_seller?characterEncoding=utf8&autoReconnect=true
      spring_datasource_username: ${vcap.services.Mysql-DB.credentials.username}
      spring_datasource_password: ${vcap.services.Mysql-DB.credentials.password}
      spring_datasource_validationQuery: SELECT 1
      spring_datasource_hikari_idle-timeout: 300000
      spring_datasource_hikari_max-lifetime: 1200000
      spring_datasource_hikari_connection-timeout: 30000

      marketplace_api_url: http://marketplace-api.<DOMAIN>.xip.io   # 먼저 배포한 'marketplace-api' App 의 urls
      marketplace_registration: cf
      marketplace_client-id: marketclient
      marketplace_client-secret: ********
      marketplace_redirect-uri: "{baseUrl}/login/oauth2/code/{registrationId}"
      marketplace_uaa-logout-url: https://<DOMAIN>.xip.io/logout.do
      marketplace_uaa-logout-rediredct-url: http://marketplace-webseller.<DOMAIN>.xip.io/main
      marketplace_authorization-uri: https://<DOMAIN>/oauth/authorize
      marketplace_token-uri: https://<DOMAIN>/oauth/token
      marketplace_user-info-uri: https://<DOMAIN>/userinfo
      marketplace_jwk-set-uri: https://<DOMAIN>/token_keys

      # 파일 업로드 Swift
      objectStorage_swift_tenantName: paasta-swift
      objectStorage_swift_username: swift
      objectStorage_swift_password: swift
      objectStorage_swift_authUrl: http://<DOMAIN>:5000/v2.0/tokens
      objectStorage_swift_authMethod: keystone
      objectStorage_swift_preferredRegion: Public
      objectStorage_swift_container: paasta-container
  ```

   <strong>[ marketplace-webuser/manifest.yml ]</strong>
  ```
  ---
  applications:
  - name: marketplace-webuser
    memory: 2G
    instances: 1
    buildpacks:
    - java_buildpack
    path: ./marketplace-web-user.war
    env:
      server_port: 8778
      spring_application_name: marketplace-webuser
      spring_servlet_multipart_max-file-size: 1024MB
      spring_servlet_multipart_max-request-size: 1024MB
      spring_session_store-type: jdbc
      spring_session_jdbc_initialize-schema: always
      spring_session_jdbc_schema: classpath:org/springframework/session/jdbc/schema-mysql.sql
      spring_mvc_static-path-pattern: /static/**
      spring_datasource_driver-class-name: com.mysql.cj.jdbc.Driver
      spring_datasource_url: jdbc:${vcap.services.Mysql-DB.credentials.uri}/marketplace_user?characterEncoding=utf8&autoReconnect=true
      spring_datasource_username: ${vcap.services.Mysql-DB.credentials.username}
      spring_datasource_password: ${vcap.services.Mysql-DB.credentials.password}
      spring_datasource_validationQuery: SELECT 1
      spring_datasource_hikari_idle-timeout: 300000
      spring_datasource_hikari_max-lifetime: 1200000
      spring_datasource_hikari_connection-timeout: 30000

      marketplace_api_url: http://marketplace-api.<DOMAIN>.xip.io   # 먼저 배포한 'marketplace-api' App 의 urls
      marketplace_registration: cf
      marketplace_client-id: marketclient
      marketplace_client-secret: ********
      marketplace_redirect-uri: "{baseUrl}/login/oauth2/code/{registrationId}"
      marketplace_uaa-logout-url: https://<DOMAIN>.xip.io/logout.do
      marketplace_uaa-logout-rediredct-url: http://marketplace-webuser.<DOMAIN>.xip.io/main

      marketplace_authorization-uri: https://<DOMAIN>/oauth/authorize
      marketplace_token-uri: https://<DOMAIN>/oauth/token
      marketplace_user-info-uri: https://<DOMAIN>/userinfo
      marketplace_jwk-set-uri: https://<DOMAIN>/token_keys

<br>
<br>

### <div id='223'/> 2.2.3. 마켓플레이스 App 배포
* 처음 배포 시에 --no-start 옵션을 넣어준다. 이후 DB서비스를 Bind 한 후 앱을 start 한다.

  - 마켓플레이스 API 배포
  ```
  $ cf push marketplace-api -f manifest.yml --no-start
  ```
  ```
  Pushing from manifest to org market-org / space dev as admin...
  Using manifest file manifest-test.yml
  Getting app info...
  Creating app with these attributes...
  + name:         marketplace-api
    path:         /home/ubuntu/workspace/user/hrjin/marketplace/api/marketplace-api.jar
    buildpacks:
  +   java_buildpack
  + instances:    1
  + memory:       2G
    env:
  +   cloudfoundry.authorization
  +   cloudfoundry.cc.api.host
  +   cloudfoundry.cc.api.proxyUrl
  +   cloudfoundry.cc.api.sslSkipValidation
  +   cloudfoundry.cc.api.uaaUrl
  +   cloudfoundry.cc.api.url
  +   cloudfoundry.user.admin.password
  +   cloudfoundry.user.admin.username
  +   cloudfoundry.user.uaaClient.adminClientId
  +   cloudfoundry.user.uaaClient.adminClientSecret
  +   cloudfoundry.user.uaaClient.clientId
  +   cloudfoundry.user.uaaClient.clientSecret
  +   cloudfoundry.user.uaaClient.loginClientId
  +   cloudfoundry.user.uaaClient.loginClientSecret
  +   cloudfoundry.user.uaaClient.skipSSLValidation
  +   deprovisioning.pool-size
  +   deprovisioning.progress-fixed-rate
  +   deprovisioning.progress-initial-delay
  +   deprovisioning.ready-fixed-rate
  +   deprovisioning.ready-initial-delay
  +   deprovisioning.timeout
  +   deprovisioning.timeout-fixed-rate
  +   deprovisioning.timeout-initial-delay
  +   deprovisioning.try-count
  +   market.domain_guid
  +   market.naming-type
  +   market.org.guid
  +   market.org.name
  +   market.quota_guid
  +   market.space.guid
  +   market.space.name
  +   objectStorage.swift.authMethod
  +   objectStorage.swift.authUrl
  +   objectStorage.swift.container
  +   objectStorage.swift.password
  +   objectStorage.swift.preferredRegion
  +   objectStorage.swift.tenantName
  +   objectStorage.swift.username
  +   provisioning.pool-size
  +   provisioning.progress-fixed-rate
  +   provisioning.progress-initial-delay
  +   provisioning.ready-fixed-rate
  +   provisioning.ready-initial-delay
  +   provisioning.timeout
  +   provisioning.timeout-fixed-rate
  +   provisioning.timeout-initial-delay
  +   provisioning.try-count
  +   server_port
  +   spring_application_name
  +   spring_datasource_driver-class-name
  +   spring_datasource_password
  +   spring_datasource_url
  +   spring_datasource_username
  +   spring_jackson_default-property-inclusion
  +   spring_jackson_serialization_fail-on-empty-beans
  +   spring_jpa_database
  +   spring_jpa_database-platform
  +   spring_jpa_hibernate_ddl-auto
  +   spring_jpa_hibernate_use-new-id-generator-mappings
  +   spring_jpa_show-sql
  +   spring_security_password
  +   spring_security_username
  +   spring_servlet_multipart_max-file-size
  +   spring_servlet_multipart_max-request-size
  +   task.execution.restrict-to-same-host
    routes:
  +   marketplace-api.<DOMAIN>.xip.io

  Creating app marketplace-api...
  Mapping routes...
  Comparing local files to remote cache...
  Packaging files to upload...
  Uploading files...
   938.31 KiB / 938.31 KiB [=================================================================================================================================================================================] 100.00% 1s

  Waiting for API to complete processing files...

  name:              marketplace-api
  requested state:   stopped
  routes:            marketplace-api.<DOMAIN>.xip.io
  last uploaded:     
  stack:             
  buildpacks:        

  type:           web
  instances:      0/1
  memory usage:   1024M
       state   since                  cpu    memory   disk     details
  #0   down    2019-09-25T01:40:24Z   0.0%   0 of 0   0 of 0     
  ```

  - 마켓플레이스 Web 앱 배포
    > - marketplace-webadmin 배포에 대한 예시이다.
  ```
  $ cf push marketplace-webadmin -f manifest.yml --no-start
  ```
  ```
  Pushing from manifest to org market-org / space dev as admin...
  Using manifest file manifest-test.yml
  Getting app info...
  Creating app with these attributes...
  + name:         marketplace-webadmin
    path:         /home/ubuntu/workspace/user/hrjin/marketplace/admin/marketplace-web-admin.war
    buildpacks:
  +   java_buildpack
  + instances:    1
  + memory:       1G
    env:
  +   marketplace_api_url
  +   marketplace_authorization-uri
  +   marketplace_client-id
  +   marketplace_client-secret
  +   marketplace_jwk-set-uri
  +   marketplace_redirect-uri
  +   marketplace_registration
  +   marketplace_token-uri
  +   marketplace_user-info-uri
  +   server_port
  +   spring_application_name
  +   spring_datasource_driver-class-name
  +   spring_datasource_password
  +   spring_datasource_url
  +   spring_datasource_username
  +   spring_mvc_static-path-pattern
  +   spring_servlet_multipart_max-file-size
  +   spring_servlet_multipart_max-request-size
  +   spring_session_jdbc_initialize-schema
  +   spring_session_jdbc_schema
  +   spring_session_store-type
    routes:
  +   marketplace-webadmin.<DOMAIN>.xip.io

  Creating app marketplace-webadmin...
  Mapping routes...
  Comparing local files to remote cache...
  Packaging files to upload...
  Uploading files...
   1.66 MiB / 1.66 MiB [=====================================================================================================================================================================================] 100.00% 1s

  Waiting for API to complete processing files...

  name:              marketplace-webadmin
  requested state:   stopped
  routes:            marketplace-webadmin.<DOMAIN>.xip.io
  last uploaded:     
  stack:             
  buildpacks:        

  type:           web
  instances:      0/1
  memory usage:   1024M
       state   since                  cpu    memory   disk     details
  #0   down    2019-09-25T06:25:07Z   0.0%   0 of 0   0 of 0   
  ```

  > - marketplace-webseller 와 marketplace-webuser 도 동일하게 배포한다.
  ```
  $ cf push marketplace-webseller -f manifest.yml --no-start
  ```
  ```
  $ cf push marketplace-webuser -f manifest.yml --no-start
  ```
<br>

* 생성된 Marketplace 앱 목록을 확인한다.
  ```
  $ cf apps
  ```
  ```
  Getting apps in org market-org / space dev as admin...
  OK

  name                   requested state   instances   memory   disk   urls
  marketplace-api        stopped           0/1         2G       2G     marketplace-api.<DOMAIN>.xip.io
  marketplace-webadmin   stopped           0/1         1G       1G     marketplace-webadmin.<DOMAIN>.xip.io
  marketplace-webuser    stopped           0/1         2G       1G     marketplace-webuser.<DOMAIN>.xip.io
  marketplace-webseller  stopped           0/1         1G       1G     marketplace-webseller.<DOMAIN>.xip.io
  ```


<br>

- 신청한 백엔드 서비스를 생성한 4개의 App 과 하나씩 각각 바인딩한다.
  ```
  $ cf services
  ```
  ```
  Getting services in org market-org / space dev as admin...

  name                service    plan                bound apps        last operation     broker                 upgrade available
  marketplace-mysql   Mysql-DB   Mysql-Plan1-10con   marketplace-api   create succeeded   mysql-service-broker   


  $ cf bind-service <생성한 App 이름> <신청한 서비스>

  예시)
  $ cf bind-service marketplace-api marketplace-mysql
  $ cf bind-service marketplace-webadmin marketplace-mysql
  $ cf bind-service marketplace-webseller marketplace-mysql
  $ cf bind-service marketplace-webuser marketplace-mysql

  ```

<br>

- 바인딩을 완료 한 후 앱을 구동한다. marketplace-api 를 가장 먼저 시작하고 이후 나머지 앱들을 시작한다.
  <strong>[marketplace-api]</strong>  
  ```
  $ cf start marketplace-api
  ```
  ```
  Starting app marketplace-api in org market-org / space dev as admin...

  Staging app and tracing logs...
     Downloading java_buildpack...
     Downloaded java_buildpack
     Cell 81d75576-549f-4b9e-8ddc-eb65410d877d creating container for instance cca4ceca-1ad2-4c00-b930-3af1ed28d2ed
     Cell 81d75576-549f-4b9e-8ddc-eb65410d877d successfully created container for instance cca4ceca-1ad2-4c00-b930-3af1ed28d2ed
     Downloading app package...
     Downloaded app package (53M)
     -----> Java Buildpack v4.19 | https://github.com/cloudfoundry/java-buildpack.git#3f4eee2
     -----> Downloading Jvmkill Agent 1.16.0_RELEASE from https://java-buildpack.cloudfoundry.org/jvmkill/bionic/x86_64/jvmkill-1.16.0-RELEASE.so (0.1s)
     -----> Downloading Open Jdk JRE 1.8.0_222 from https://java-buildpack.cloudfoundry.org/openjdk/bionic/x86_64/openjdk-jre-1.8.0_222-bionic.tar.gz (5.5s)
            Expanding Open Jdk JRE to .java-buildpack/open_jdk_jre (0.9s)
            JVM DNS caching disabled in lieu of BOSH DNS caching
     -----> Downloading Open JDK Like Memory Calculator 3.13.0_RELEASE from https://java-buildpack.cloudfoundry.org/memory-calculator/bionic/x86_64/memory-calculator-3.13.0-RELEASE.tar.gz (0.0s)
            Loaded Classes: 21392, Threads: 250
     -----> Downloading Client Certificate Mapper 1.11.0_RELEASE from https://java-buildpack.cloudfoundry.org/client-certificate-mapper/client-certificate-mapper-1.11.0-RELEASE.jar (0.0s)
     -----> Downloading Container Security Provider 1.16.0_RELEASE from https://java-buildpack.cloudfoundry.org/container-security-provider/container-security-provider-1.16.0-RELEASE.jar (0.0s)
     -----> Downloading Spring Auto Reconfiguration 2.9.0_RELEASE from https://java-buildpack.cloudfoundry.org/auto-reconfiguration/auto-reconfiguration-2.9.0-RELEASE.jar (5.1s)
     Exit status 0
     Uploading droplet, build artifacts cache...
     Uploading droplet...
     Uploading build artifacts cache...
     Uploaded build artifacts cache (43.4M)
     Uploaded droplet (96.5M)
     Uploading complete
     Cell 81d75576-549f-4b9e-8ddc-eb65410d877d stopping instance cca4ceca-1ad2-4c00-b930-3af1ed28d2ed
     Cell 81d75576-549f-4b9e-8ddc-eb65410d877d destroying container for instance cca4ceca-1ad2-4c00-b930-3af1ed28d2ed
     Cell 81d75576-549f-4b9e-8ddc-eb65410d877d successfully destroyed container for instance cca4ceca-1ad2-4c00-b930-3af1ed28d2ed

  Waiting for app to start...

  name:              marketplace-api
  requested state:   started
  routes:            marketplace-api.<DOMAIN>.xip.io
  last uploaded:     Wed 25 Sep 10:43:50 KST 2019
  stack:             cflinuxfs3
  buildpacks:        java_buildpack

  type:            web
  instances:       1/1
  memory usage:    1024M
  start command:   JAVA_OPTS="-agentpath:$PWD/.java-buildpack/open_jdk_jre/bin/jvmkill-1.16.0_RELEASE=printHeapHistogram=1 -Djava.io.tmpdir=$TMPDIR -XX:ActiveProcessorCount=$(nproc)
                   -Djava.ext.dirs=$PWD/.java-buildpack/container_security_provider:$PWD/.java-buildpack/open_jdk_jre/lib/ext -Djava.security.properties=$PWD/.java-buildpack/java_security/java.security $JAVA_OPTS" &&
                   CALCULATED_MEMORY=$($PWD/.java-buildpack/open_jdk_jre/bin/java-buildpack-memory-calculator-3.13.0_RELEASE -totMemory=$MEMORY_LIMIT -loadedClasses=22692 -poolType=metaspace -stackThreads=250
                   -vmOptions="$JAVA_OPTS") && echo JVM Memory Configuration: $CALCULATED_MEMORY && JAVA_OPTS="$JAVA_OPTS $CALCULATED_MEMORY" && MALLOC_ARENA_MAX=2 SERVER_PORT=$PORT eval exec
                   $PWD/.java-buildpack/open_jdk_jre/bin/java $JAVA_OPTS -cp $PWD/. org.springframework.boot.loader.JarLauncher
       state     since                  cpu    memory         disk           details
  #0   running   2019-09-25T01:44:15Z   0.0%   115.6M of 1G   170.7M of 1G   

  ```

  <strong>[marketplace-webadmin]</strong>
  ```
  $ cf start marketplace-webadmin
  ```
  ```
  Starting app marketplace-webadmin in org market-org / space dev as admin...

  Staging app and tracing logs...
     Downloading java_buildpack...
     Downloaded java_buildpack
     Cell 81d75576-549f-4b9e-8ddc-eb65410d877d creating container for instance cfd9a5b6-d011-4d99-bcaf-cca33beca89a
     Cell 81d75576-549f-4b9e-8ddc-eb65410d877d successfully created container for instance cfd9a5b6-d011-4d99-bcaf-cca33beca89a
     Downloading app package...
     Downloaded app package (72.2M)
     -----> Java Buildpack v4.19 | https://github.com/cloudfoundry/java-buildpack.git#3f4eee2
     -----> Downloading Jvmkill Agent 1.16.0_RELEASE from https://java-buildpack.cloudfoundry.org/jvmkill/bionic/x86_64/jvmkill-1.16.0-RELEASE.so (5.1s)
     -----> Downloading Open Jdk JRE 1.8.0_222 from https://java-buildpack.cloudfoundry.org/openjdk/bionic/x86_64/openjdk-jre-1.8.0_222-bionic.tar.gz (0.5s)
            Expanding Open Jdk JRE to .java-buildpack/open_jdk_jre (0.9s)
            JVM DNS caching disabled in lieu of BOSH DNS caching
     -----> Downloading Open JDK Like Memory Calculator 3.13.0_RELEASE from https://java-buildpack.cloudfoundry.org/memory-calculator/bionic/x86_64/memory-calculator-3.13.0-RELEASE.tar.gz (0.0s)
            Loaded Classes: 20682, Threads: 250
     -----> Downloading Client Certificate Mapper 1.11.0_RELEASE from https://java-buildpack.cloudfoundry.org/client-certificate-mapper/client-certificate-mapper-1.11.0-RELEASE.jar (0.0s)
     -----> Downloading Container Customizer 2.6.0_RELEASE from https://java-buildpack.cloudfoundry.org/container-customizer/container-customizer-2.6.0-RELEASE.jar (0.0s)
     -----> Downloading Container Security Provider 1.16.0_RELEASE from https://java-buildpack.cloudfoundry.org/container-security-provider/container-security-provider-1.16.0-RELEASE.jar (5.0s)
     -----> Downloading Spring Auto Reconfiguration 2.9.0_RELEASE from https://java-buildpack.cloudfoundry.org/auto-reconfiguration/auto-reconfiguration-2.9.0-RELEASE.jar (0.1s)
     Exit status 0
     Uploading droplet, build artifacts cache...
     Uploading build artifacts cache...
     Uploading droplet...
     Uploaded build artifacts cache (43.4M)
     Uploaded droplet (115.6M)
     Uploading complete
     Cell 81d75576-549f-4b9e-8ddc-eb65410d877d stopping instance cfd9a5b6-d011-4d99-bcaf-cca33beca89a
     Cell 81d75576-549f-4b9e-8ddc-eb65410d877d destroying container for instance cfd9a5b6-d011-4d99-bcaf-cca33beca89a
     Cell 81d75576-549f-4b9e-8ddc-eb65410d877d successfully destroyed container for instance cfd9a5b6-d011-4d99-bcaf-cca33beca89a

  Waiting for app to start...

  name:              marketplace-webadmin
  requested state:   started
  routes:            marketplace-webadmin.<DOMAIN>.xip.io
  last uploaded:     Wed 25 Sep 15:50:02 KST 2019
  stack:             cflinuxfs3
  buildpacks:        java_buildpack

  type:            web
  instances:       1/1
  memory usage:    1024M
  start command:   JAVA_OPTS="-agentpath:$PWD/.java-buildpack/open_jdk_jre/bin/jvmkill-1.16.0_RELEASE=printHeapHistogram=1 -Djava.io.tmpdir=$TMPDIR -XX:ActiveProcessorCount=$(nproc)
                   -Djava.ext.dirs=$PWD/.java-buildpack/container_security_provider:$PWD/.java-buildpack/open_jdk_jre/lib/ext -Djava.security.properties=$PWD/.java-buildpack/java_security/java.security $JAVA_OPTS" &&
                   CALCULATED_MEMORY=$($PWD/.java-buildpack/open_jdk_jre/bin/java-buildpack-memory-calculator-3.13.0_RELEASE -totMemory=$MEMORY_LIMIT -loadedClasses=21985 -poolType=metaspace -stackThreads=250
                   -vmOptions="$JAVA_OPTS") && echo JVM Memory Configuration: $CALCULATED_MEMORY && JAVA_OPTS="$JAVA_OPTS $CALCULATED_MEMORY" && MALLOC_ARENA_MAX=2 SERVER_PORT=$PORT eval exec
                   $PWD/.java-buildpack/open_jdk_jre/bin/java $JAVA_OPTS -cp $PWD/. org.springframework.boot.loader.WarLauncher
       state     since                  cpu    memory         disk           details
  #0   running   2019-09-25T06:50:20Z   0.0%   153.7M of 1G   222.5M of 1G   
  ```

  - webseller 와 webuser 도 같은 방식으로 배포한다.
  ```
  $ cf start marketplace-webseller
  ```
  ```
  $ cf start marketplace-webuser
  ```
<br>

- 배포된 마켓플레이스 관련 App 들을 확인한다.


  ```
  $ cf apps
  Getting apps in org market-org / space dev as admin...
  OK

  name                    requested state   instances   memory   disk   urls
  marketplace-webseller   started           1/1         2G       2G     marketplace-webseller.<DOMAIN>.xip.io
  marketplace-webadmin    started           1/1         1G       1G     marketplace-webadmin.<DOMAIN>.xip.io
  marketplace-webuser     started           1/1         2G       1G     marketplace-webuser.<DOMAIN>.xip.io
  marketplace-api         started           1/1         1G       1G     marketplace-api.<DOMAIN>.xip.io

  ```

### <div id='23'/> 2.3. 마켓플레이스 UAA Client Id 등록
UAA 계정 등록 절차에 대한 순서를 확인한다.

- uaac server의 endpoint를 설정한다.

  ```
  $ uaac target

  Target: https://uaa.<DOMAIN>.xip.io
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
  $ uaac client add marketclient -s clientsecret --redirect_uri "http://marketplace-webseller.<DOMAIN>.xip.io http://marketplace-webseller.<DOMAIN>.xip.io/main http://marketplace-webuser.<DOMAIN>.xip.io http://marketplace-webuser.<DOMAIN>.xip.io/main http://marketplace-webadmin.<DOMAIN>.xip.io http://marketplace-webadmin.<DOMAIN>.xip.io/main" --scope "cloud_controller_service_permissions.read , openid , cloud_controller.read , cloud_controller.write , cloud_controller.admin" --authorized_grant_types "authorization_code , client_credentials , refresh_token" --authorities="uaa.resource" --autoapprove="openid , cloud_controller_service_permissions.read"
  ```


- Marketplace 서비스 계정 정보를 수정한다. (이미 uaac client가 등록되어 있는 경우)

> $ uaac client update marketclient --redirect_uri={마켓플레이스 서비스 대시보드 URI}
>
> - 마켓플레이스 서비스 대시보드 URI : 성공적으로 리다이렉션 할 마켓플레이스 서비스 대시보드 URI를 입력한다.

  ```
  $ uaac client update marketclient --redirect_uri="http://marketplace-webseller.<DOMAIN>.xip.io http://marketplace-webseller.<DOMAIN>.xip.io/main http://marketplace-webuser.<DOMAIN>.xip.io http://marketplace-webuser.<DOMAIN>.xip.io/main http://marketplace-webadmin.<DOMAIN>.xip.io http://marketplace-webadmin.<DOMAIN>.xip.io/main"
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
