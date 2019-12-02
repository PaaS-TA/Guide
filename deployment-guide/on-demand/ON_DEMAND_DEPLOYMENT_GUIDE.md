## Table of Contents
1. [문서 개요](#1)
    * [1.1. 목적](#11)
    * [1.2. 범위](#12)
    * [1.3. 참고자료](#13)
2. [온디멘드 서비스 개요](#2)
    * [2.1. 온디멘드 서비스 아키텍쳐 및 프로세스](#21)
    * [2.2. 용어 정의](#22)
3. [온디멘드 서비스 브로커 API](#3)
    * [3.1. Service Architecture](#31)
    * [3.2. Service Broker API Architecture](#32)
    * [3.3. Pivotal(Cloud Foundry) Marketplace Model](#33)
4. [온디멘드 서비스 브로커 API 개발 가이드](#4)
    * [4.1. 개발 가이드](#41)
    * [4.2. 서비스 및 VM Instance 생성 API 가이드](#42)
    * [4.3. On-Demand Service-Broker 구현 소스 개발가이드](#43)
    * [4.4. On-Demand 릴리즈 개발가이드](#44)
    * [4.5. On-Demand Deployment 개발가이드](#45)

# <a name="1"/>1. 문서 개요

### <a name="11"/>1.1. 목적

본 문서(개발가이드\_온디멘드)는 개방형 클라우드 플랫폼 프로젝트의 온디멘드
서비스 개발 표준을 가이드하는 문서로써, 온디멘드 서비스 아키텍처부터 테스트
까지의 내용을 포함하고 있다.

본 가이드 문서를 통해 온디멘드 서비스에 대한 이해도를 높여, 온디멘드 서비스
개발의 효율성과 유지보수성을 향상시키고자 한다. 또한 제시된 표준에 따라 개발된
온디멘드 서비스는 개방형 클라우드 플랫폼에서의 기능성(Functionality)과
통합성(Integrability)를 보장한다.

### <a name="12"/>1.2. 범위
본 문서의 범위는 개방형 클라우드 플랫폼 프로젝트와 관련된 온디멘드 서비스 개발에
대한 내용으로 한정하며, 기타 오픈소스 도입의 경우 예외를 둔다.

### <a name="13"/>1.3. 참고자료

# <a name="2"/>2. 온디멘드 서비스 개요
온디멘드 서비스 브로커는 자바 스프링 프레임워크를 사용하여 개발한다.
온디멘드는 사용자가 서비스 요청시 공급자가 서비스를 생산해 제공하기
때문에 무분별한 자원 낭비를 방지한다.
현재 온디멘드 서비스는 데이케이트 형식으로만 제공한다.
본 장에서는 사용되는 용어들을 정의하고, 온디멘드 아키텍처를 설명한다.

### <a name="21"/>2.1. 온디멘드 서비스 아키텍쳐 및 프로세스

>![On-Demand_Image_01]

**그림 2-1 개방형 클라우드 플랫폼에서의 온디멘드 서비스 아키텍쳐**

>![On-Demand_Image_02]

**그림 2-2 개방형 클라우드 플랫폼에서의 온디멘드 서비스 프로세스**

개방형 클라우드 플랫폼에 배포되는 온디멘드 서비스는 크게
서비스 신청(Create_Service), 서비스 바인딩(Service_binding),
서비스 준비(Service_inprogress), 서비스 삭제(Service_delete)
4가지의 프로세스를 제공한다.

사용자가 개방형 클라우드 플랫폼에 어플리케이션 배포를 요청하면, 배포
프로세스가 시작된다. 각 단계는 다음과 같은 동작을 한다.

-   **서비스 신청(Create_Service):** 서비스 생성 요청시 서비스를 생성한다.

-   **서비스 준비(Service_inprogress):** 서비스 구동시 필요한 VM을 생성한다.

-   **서비스 바인딩(Service_binding):** 서비스의 환경설정을 어플리케이션 환경설정에 적용한다.

-   **서비스 삭제(Service_delete):** 사용자 요청시 서비스 삭제 및 VM 가동을 삭제(중지)한다.

사용자가 서비스 신청을 하면 서비스를 구동하기위한 VM생성을 진행한다. 진행중 서비스는
준비상태로 전환되며 VM이 생성완료되고 난 후 해당 서비스는 완료상태로 전환되며 사용자에게
서비스를 제공한다.

### <a name="22"/>2.2. 용어 정의

아키텍처 설명에 앞서, 본 문서에서 사용하는 몇가지 용어들을 정리하면
다음과 같다.

-   **온디멘드(On-Demand)**: '요구만 있으면 (언제든지)'~ 즉,
    공급 중심이 아니라 수요가 모든 것을 결정하는 시스템이나
    전략 등을 총칭한다.


-   **어플리케이션(application)**: 개방형 클라우드 플랫폼에서
    어플리케이션은 배포의 단위이다. 즉, 소스코드 또는 패키징된 형태(예를
    들면, .war)의 파일과 배포 시 사용할 부가정보(meta)들을 정의한 파일의
    조합을 의미한다.

-   **서비스(Service)**: 서비스는 Service Broker API 라고 불리우는
    cloud controller 클라이언트 API를 구현하여 개방형 클라우드 플랫폼에서 사용된다.
    Services API는 독립적인 cloud controller API의 버전이다.
    이는 플랫폼에서 외부 application을 이용 가능하게 한다.

# <a name="3"/>3. 온디멘드 서비스 브로커 API
개방형 클라우드 플랫폼 Service API는 Cloud Controller와 Service Broker 사이의 규약을 정의한다. Broker는 HTTP (or HTTPS) endpoints URI 형식으로 구현된다. 하나 이상의 Service가 하나의 Broker 에 의해 제공 될 수 있고, 로드 밸런싱과 수평 확장성이 가능하게 제공 될 수 있다.

#### <a name="31"/>3.1. Service Architecture
>![On-Demand_Image_03]
[그림출처]: http://docs.cloudfoundry.org/services/overview.html

Services 는 Service Broker API 라고 불리우는 cloud controller 클라이언트 API를 구현하여 개방형 클라우드 플랫폼에서 사용된다. Services API는 독립적인 cloud controller API의 버전이다.
이는 플랫폼에서 외부 application을 이용 가능하게 한다. (database, message queue, rest endpoint , etc)

#### <a name="32"/>3.2. Service Broker API Architecture
>![On-Demand_Image_04]
[그림출처]: http://docs.cloudfoundry.org/services/api.html

개방형 클라우드 플랫폼 Service API는 Cloud Controller 와 Service Broker 사이의 규약 (catalog, provision, deprovision, update provision plan, bind, unbind)이고 Service Broker 는 RESTful API 로 구현하고 Cloud Controller 에 등록한다.

#### <a name="33"/>3.3. Pivotal(Cloud Foundry) Marketplace Model
>![On-Demand_Image_05]
[그림출처]: http://www.slideshare.net/platformcf/cloud-foundry-marketplacepowered-by-appdirect

AppDirect: 클라우드 서비스 marketplace 및 관리 솔루션의 선두 업체이고 많은 글로벌 회사의 marketplace를 구축하였다. (삼성, Cloud Foundry, ETC)
AppDirect는 Cloud Foundry 서비스 중개(brokerage) 기능과 부가 서비스를 제공한다.

Service Provider 및 Cloud Foundry 통합에 관련 설명
>![On-Demand_Image_06]
[그림출처]: http://www.slideshare.net/platformcf/cloud-foundry-marketplacepowered-by-appdirect

# <a name="4"/>4. 온디멘드 서비스 브로커 API 개발 가이드

#### <a name="41"/>4.1. 개발 가이드
서비스의 구현 방법은 서비스 제공자(Provider) 와 개발자(developer)의 몫이다. 개방형 클라우드 플랫폼은 서비스 제공자가 6가지의 Service Broker API를 구현해야 한다. 이때 2.4 Pivotal Marketplace Model를 이용해서 AppDirect 에서 제공중인 서비스 제공자와 협의 하여 AppDirect 의 중개 기능을 이용해서 제공할수도 있다. 또한 Broker 는 별도의 애플리케이션으로 구현하든지 기존 서비스에 필요한 HTTP endpoint를 추가함으로써 구현 될 수 있다.

기본적인 서비스브로커 API가이드는 (문서 URL) 참고해서 개발을 진행한다.
현재 On-Demand 서비스 브로커 개발은 JAVA만 지원한다.


On-Demand 서비스 브로커의 환경파일 (application.yml)은 다음과 같다 {}의 값은 조건에 맞춰 넣어주면 된다. (deploy시 수정가능)
```
server:
  port: 8080

bosh:
  client_id: {bosh_client_admin_id}                               
  client_secret: {bosh_client_secret}
  url: {bosh_diretor_url}
  oauth_url: {bosh_diretor_url:8443}
  deployment_name: {on-demand-service-broker}
  instance_name: {on-demand-service-instance name}

spring:
  application:
    name: paas-ta-on-demand-broker
  datasource:
    driver-class-name: com.mysql.jdbc.Driver
    url: "jdbc:mysql://{on_demand_service_broker_database_url}/on-demand?autoReconnect=true&useUnicode=true&characterEncoding=utf8"
    username: root
    password: {Broker_Database_password}
  jpa:
    hibernate:
      ddl-auto: none
      database: mysql
      show-sql: true

serviceDefinition:
  id: 54e2de61-de84-4b9c-afc3-88d08aadfcb6
  name: redis
  desc: "A paasta source control service for application development.provision parameters : parameters {owner : owner}"
  bindable: true
  planupdatable: false
  bullet:
    name: 100
    desc: 100
  plan1:
    id: 2a26b717-b8b5-489c-8ef1-02bcdc445720
    name: dedicated-vm
    desc: Redis service to provide a key-value store
    type: A
  org_limitation: 1
  space_limitation: 1

cloudfoundry:
  cc:
    api:
      url: https://api.{cloudfoundry_url}
      uaaUrl: https://uaa.{cloudfoundry_url}  # YOUR UAA API URL
      sslSkipValidation: true
  user:
    admin:
      username: {cloudfoundry_admin_id} # YOUR CF ADMIN ACCOUT
      password: {cloudfoundry_admin_password}# YOUR CF ADMIN PASSWORD

instance:
  password: admin_test
  port: 6379

```

##### <a name="42"/>4.2. 서비스 및 VM Instance 생성 API 가이드
참고: On-Demand 서비스 브로커는 Bosh API를 사용한다.
On-Demand 형식을 구현하기 위한 Bosh API는 다음과 같다.


1. Bosh Api Setting
1.1.   BoshDirector
Bosh Director에 로그인 및 토큰을 받아 저장 및 Bosh API 접근가능한 오브젝트를 생성한다.

##### parameter

    client_id :: string
    client_secret :: string
    bosh_url :: string
    oauth_url :: string

##### Request

    POST oauth_url + "/oauth/token?client_id=" + client_id + "&client_secret=" + client_secret + "&grant_type=client_credentials

##### Response
    OAuth2AccessToken

2. ServiceInstace
2.1 VMInstance
    Bosh에 배포된 VMInstance 정보를 가져온다.

##### parameter

    deployment_name :: string
    instance_name :: string

##### Request

    Get bosh_url + "/deployments/" + deployment_name + "/instances?format=full"

    format=full로 조회하는 방식은 Bosh 자체적으로 task를 발생시켜 redirect로 테스크를 찾아 값을 반환하는 방식으로 되어있다.

    기본 Resttemplate으로 api요청시 redirect 부분에서 오류가 발생하기 때문에 따로 redirect 기능을 하지 않게 Resttemplate을 생성해서 요청해야한다.

##### Response
     task :: string


2.2. TaskResult
Bosh task를 조회한다. (option :: output=result) 해당 deployment의 상세값을 확인할수 있다.

##### parameter

    task :: string

##### Request

    Get bosh_url + "/deployments/" + deployment_name + "/instances?format=full"

    format=full로 조회하는 방식은 Bosh 자체적으로 task를 발생시켜 redirect로 테스크를 찾아 값을 반환하는 방식으로 되어있다.

    기본 Resttemplate으로 api요청시 redirect 부분에서 오류가 발생하기 때문에 따로 redirect 기능을 하지 않게 Resttemplate을 생성해서 요청해야한다.

##### Response
    result :: string
    Bosh API에서 List<Map>형식으로 커스텀해 반환해준다.


2.3. GetLock
Deployment Update 하기전 해당 Deployment가 작업(Lock)여부 조회하는 기능이다.

##### parameter

    null

##### Request

    Get bosh_url + "/locks"

##### Response
    result :: string
    Bosh API에서 Json형식으로 반환해준다.

2.4. UpdateInstance
해당 Instance상태를 업데이트한다 (stop --> start)

##### parameter

    deployment_name :: string
    instance_name :: string
    instance_id :: string
    type :: string

    type은 "started" 또는 "detached"로 정한다.

##### Request

    Get bosh_url + "/deployments/" + deployment_name + "/jobs/" + job_name + "/" + job_id + "?state=" + state

##### Response
    null

2.5. GetTaskID
현재 작업중인(state = queued, processing,cancelling) Task중 해당 deployment_name과 같은 ID를 조회한다.

##### parameter

    deployment_name :: string

##### Request

    Get bosh_url + "/tasks?state=queued,processing,cancelling"

##### Response
    List<map>

##### StartInstance
해당 Instance VM을 실행시킨다.(stop -> start)

##### parameter

    task_id :: string
    instance_name :: string
    instance_id :: string

##### Request

    Get bosh_url + "/tasks/" + task_id + "/output?type=debug"

##### Response
    String

##### CreateInstance
서비스 신청이 들어올 때 할당해줄 VM이 없을시  Instace 개수를 늘려 VM 하나를 생성하는 기능이다.

##### parameter

    deployment_name :: string
    instance_name :: string

##### Request

    Post bosh_url + "/deployments"

##### body
bosh deploy할때 필요한 manifest.yml구성된 내용을 String으로 변환해서 담아야한다.

예시)
```
instance_groups:
- azs:
  - z7
  instances: 1
  jobs:
  - name: binary_storage
    release: paasta-portal-api-release
  name: binary_storage
  networks:
  - default:
    - dns
    - gateway
    name: service_private
  - name: service_public
  persistent_disk: 102400
  stemcell: default
  vm_type: medium
- azs:
  - z2
  instances: 1
  jobs:
  - name: mariadb
    release: common-infra
  name: mariadb
  networks:
  - name: service_private
  persistent_disk: 4096
  stemcell: default
  vm_type: small
name: common-infra-service
properties:
  binary_storage:
    auth_port: 5000
    binary_desc:
    - marketplace-container
    container:
    - marketplace-container
    email:
    - email@email.com
    - email@email.com
    password:
    - paasta
    proxy_ip:
    proxy_port: 10008
    tenantname:
    - paasta-marketplace
    username:
    - paasta-marketplace
  haproxy:
    http_port: 8080
  mariadb:
    admin_user:
      password: '!paas_ta202'
    port: 3306
  postgres:
    datasource:
      database: sonar
      password: sonar
      username: sonar
    port: 5432
    vcap_password: c1oudc0w
releases:
- name: paasta-portal-api-release
  version: latest
- name: common-infra
  version: latest
stemcells:
- alias: default
  os: ubuntu-xenial
  version: 315.36
update:
  canaries: 1
  canary_watch_time: 5000-120000
  max_in_flight: 1
  serial: false
  update_watch_time: 5000-120000
```

##### Response
    null


##### <a name="43"/>4.3. On-Demand Service-Broker 구현 소스 개발가이드
On-Demand 구현에 관련한 서비스 브로커 개발 가이드를 진행한다.
현재 JAVA 버전만 사용이 가능하다. 예시로 나와있는 소스는 PaaS-TA GitHub의
On-Demand-broker에서 찾아볼수 있다.

1. On-Demand ServiceInstace
할당된 VM의 대한 정보를 broker DB에 ServiceIntance객제와 함께 저장한다.

예시)JpaServiceInstance Class
```
@Entity
@Table(name = "on_demand_info")
public class JpaServiceInstance extends ServiceInstance {

    @JsonSerialize
    @JsonProperty("service_instance_id")
    @Id
    @Column(name = "service_instance_id")
    private String serviceInstanceId;

    @JsonSerialize
    @Column(name = "service_id")
    @JsonProperty("service_id")
    private String serviceDefinitionId;

    @JsonSerialize
    @Column(name = "plan_id")
    @JsonProperty("plan_id")
    private String planId;

    @JsonSerialize
    @Column(name = "organization_guid")
    @JsonProperty("organization_guid")
    private String organizationGuid;

    @JsonSerialize
    @Column(name = "space_guid")
    @JsonProperty("space_guid")
    private String spaceGuid;

    @JsonSerialize
    @Column(name = "dashboard_url")
    @JsonProperty("dashboard_url")
    private String dashboardUrl;

    @Transient
    @JsonIgnore
    private boolean async;

    @JsonSerialize
    @JsonProperty("vm_instance_id")
    @Column(name = "vm_instance_id")
    private String vmInstanceId;

    @JsonSerialize
    @JsonProperty("app_guid")
    @Column(name = "app_guid")
    private String appGuid;

    @JsonSerialize
    @JsonProperty("task_id")
    @Column(name = "task_id")
    private String taskId;

    @JsonSerialize
    @JsonProperty("app_parameter")
    @Column(name = "app_parameter")
    private String app_parameter;


    public JpaServiceInstance() {
        super();
    }

    public JpaServiceInstance(CreateServiceInstanceRequest request) {
        super(request);
        setServiceDefinitionId(request.getServiceDefinitionId());
        setPlanId(request.getPlanId());
        setOrganizationGuid(request.getOrganizationGuid());
        setSpaceGuid(request.getSpaceGuid());
        setServiceInstanceId(request.getServiceInstanceId());
        AtomicReference<String> param = new AtomicReference<>("{");
        AtomicInteger i = new AtomicInteger(1);
        try {
            if (request.getParameters() != null) {
                request.getParameters().forEach((key, value) -> {
                    if (key.equals("app_guid")) {
                        setAppGuid(value.toString());
                    }
                    param.set(param.get() + "\"" + key + "\":\"" + value.toString() + "\"");
                    if (i.get() < request.getParameters().size()) {
                        param.set(param.get() + ",");
                    }
                    i.set(i.get() + 1);
                });
            }
        }catch (Exception e){
        }
        param.set(param.get() + "}");
        setApp_parameter(param.get());
    }

    @Override
    public String getDashboardUrl() {
        return dashboardUrl;
    }

    public void setDashboardUrl(String dashboardUrl) {
        this.dashboardUrl = dashboardUrl;
    }

    public String getAppGuid() {
        return appGuid;
    }

    public void setAppGuid(String appGuid) {
        this.appGuid = appGuid;
    }

    public String getTaskId() {
        return taskId;
    }

    public void setTaskId(String taskId) {
        this.taskId = taskId;
    }

    @Override
    public String getPlanId() {
        return planId;
    }

    public void setPlanId(String planId) {
        this.planId = planId;
    }

    @Override
    public String getServiceDefinitionId() {
        return serviceDefinitionId;
    }

    public void setServiceDefinitionId(String serviceDefinitionId) {
        this.serviceDefinitionId = serviceDefinitionId;
    }

    @Override
    public String getServiceInstanceId() {
        return serviceInstanceId;
    }

    public void setServiceInstanceId(String serviceInstanceId) {
        this.serviceInstanceId = serviceInstanceId;
    }

    @Override
    public String getSpaceGuid() {
        return spaceGuid;
    }

    public void setSpaceGuid(String spaceGuid) {
        this.spaceGuid = spaceGuid;
    }

    @Override
    public String getOrganizationGuid() {
        return organizationGuid;
    }

    public void setOrganizationGuid(String organizationGuid) {
        this.organizationGuid = organizationGuid;
    }

    public String getVmInstanceId() {
        return vmInstanceId;
    }

    public void setVmInstanceId(String vmInstanceId) {
        this.vmInstanceId = vmInstanceId;
    }

    @Override
    public boolean isAsync() {
        return async;
    }

    @Override
    public ServiceInstance and() {
        return this;
    }

    @Override
    public JpaServiceInstance withDashboardUrl(String dashboardUrl) {
        this.dashboardUrl = dashboardUrl;
        return this;
    }

    @Override
    public ServiceInstance withAsync(boolean async) {
        this.async = async;
        return this;
    }


    public String getApp_parameter() {
        return app_parameter;
    }

    public void setApp_parameter(String app_parameter) {
        this.app_parameter = app_parameter;
    }

    public void setAsync(boolean async) {
        this.async = async;
    }

    @Override
    public String toString() {
        return "JpaServiceInstance{" +
                "serviceInstanceId='" + serviceInstanceId + '\'' +
                ", serviceDefinitionId='" + serviceDefinitionId + '\'' +
                ", planId='" + planId + '\'' +
                ", organizationGuid='" + organizationGuid + '\'' +
                ", spaceGuid='" + spaceGuid + '\'' +
                ", dashboardUrl='" + dashboardUrl + '\'' +
                ", async=" + async +
                ", vmInstanceId='" + vmInstanceId + '\'' +
                ", appGuid='" + appGuid + '\'' +
                ", taskId='" + taskId + '\'' +
                '}';
    }
}
```
◎ 1.1. On-Demand-broker에서 커스텀한 변수의 대한 설명

##### vm_instance_id : 서비스 인스턴스에 할당할 VM의 Instance Id
##### appGuid : 서비스 바인딩을 진행할 application의 Guid
##### taskId : 서비스에 할당할 VM작업을 진행하는 BOSH의 task Id

◎ 1.2. JPAInstance(CreateServiceInstanceRequest request) 생성자
##### PaaS-TA Portal을 이용한 앱 템플릿을 사용하기 위해 임의로 지정한 키에 할당된 서비스 파라미터 값을 받아 appGuid에 할당한다.
       ```
       예시)
       public JpaServiceInstance(CreateServiceInstanceRequest request) {
        super(request);
        setServiceDefinitionId(request.getServiceDefinitionId());
        setPlanId(request.getPlanId());
        setOrganizationGuid(request.getOrganizationGuid());
        setSpaceGuid(request.getSpaceGuid());
        setServiceInstanceId(request.getServiceInstanceId());
        AtomicReference<String> param = new AtomicReference<>("{");
        AtomicInteger i = new AtomicInteger(1);
        try {
            if (request.getParameters() != null) {
                request.getParameters().forEach((key, value) -> {
                    if (key.equals("app_guid")) {
                        setAppGuid(value.toString());
                    }
                    param.set(param.get() + "\"" + key + "\":\"" + value.toString() + "\"");
                    if (i.get() < request.getParameters().size()) {
                        param.set(param.get() + ",");
                    }
                    i.set(i.get() + 1);
                });
            }
        }catch (Exception e){
        }
        param.set(param.get() + "}");
        setApp_parameter(param.get());
      }
      ```

2. On-Demand createServiceInstance
사용자가 서비스를 신청할 경우 과정에서 VM 재기동 또는 생성을 진행한다.

1.1. Deployment가 현재 구성이 제대로 되어있는지 확인 및 Instance List를 가져온다.
     ```

     ```
##### 1.1. 에서 에러가 날 경우 서비스 생성을 중지한다.

     ```
     예시)
     List<DeploymentInstance> deploymentInstances = onDemandDeploymentService.getVmInstance(deployment_name, instance_name);
            if (deploymentInstances == null) {
                throw new ServiceBrokerException(deployment_name + " is Working");
            }
     ```

1.2. Instance List중 유휴 VM이 있을경우 해당 VM정보가 저장된 Service Instance를 생성해 제공한다.

     ```
     예시)
     List<DeploymentInstance> startedDeploymentInstances = deploymentInstances.stream().filter((x) -> x.getState().equals(BoshDirector.INSTANCE_STATE_START) && x.getJobState().equals("running")).collect(Collectors.toList());
            for(DeploymentInstance dep : startedDeploymentInstances){
                if(jpaServiceInstanceRepository.findByVmInstanceId(dep.getId()) == null){
                    jpaServiceInstance.setVmInstanceId(dep.getId());
                    jpaServiceInstance.setDashboardUrl(dep.getIps().substring(1,dep.getIps().length()-1));
                    jpaServiceInstanceRepository.save(jpaServiceInstance);
                    jpaServiceInstance.withAsync(true);
                    SecurityGroups securityGroups = common.cloudFoundryClient().securityGroups();
                    cloudFoundryService.SecurityGurop(request.getSpaceGuid(), jpaServiceInstance.getDashboardUrl(), securityGroups);
                    logger.info("서비스 인스턴스 생성");
                    return jpaServiceInstance;
                }
            }
     ```

1.3. 유휴 VM이 없을경우 Instance를 업데이트 하기 전 현재 Deployment가 Lock인 상태인지 체크한다. Lock인 상태인 경우엔 "생성할 수 없습니다." 에러를 발생시킨다.

     ```
     예시)
     if (onDemandDeploymentService.getLock(deployment_name)) {
                throw new ServiceBrokerException(deployment_name + " is Working");
     }
     ```

1.4. 정지상태인 VM을 찾아 있을경우 해당 VM을 실행시키며 해당 VM정보를 가진 Service Instance를 생성해 제공한다.

     ```
     예시)
     List<DeploymentInstance> detachedDeploymentInstances = deploymentInstances.stream().filter(x -> x.getState().equals(BoshDirector.INSTANCE_STATE_DETACHED)).collect(Collectors.toList());
     String taskID = "";
     for (DeploymentInstance dep : detachedDeploymentInstances) {
         onDemandDeploymentService.updateInstanceState(deployment_name, instance_name, dep.getId(), BoshDirector.INSTANCE_STATE_START);
         while (true) {
             Thread.sleep(1000);
             taskID = onDemandDeploymentService.getTaskID(deployment_name);
             if (taskID != null) {
                 logger.info("taskID : " + taskID);
                 break;
             }
         }
         String ips = "";
         while (true) {
             Thread.sleep(1000);
             ips = onDemandDeploymentService.getStartInstanceIPS(taskID, instance_name, dep.getId());
             if (ips != null) {
                 break;
             }
         }
         jpaServiceInstance.setVmInstanceId(dep.getId());
         jpaServiceInstance.setDashboardUrl(ips);
         jpaServiceInstanceRepository.save(jpaServiceInstance);
         jpaServiceInstance.withAsync(true);
         SecurityGroups securityGroups = common.cloudFoundryClient().securityGroups();
         cloudFoundryService.SecurityGurop(request.getSpaceGuid(), jpaServiceInstance.getDashboardUrl(), securityGroups);
         return jpaServiceInstance;
     }
     ```

1.5. 1.4.에서 정지된 VM이 없을경우 해당 Deployment의 manifest를 수정해 Service Instance에 필요한 VM을 늘린 후 해당 정보를 가진 Instance를 생성해 제공한다.

     ```
     예시)
     onDemandDeploymentService.createInstance(deployment_name, instance_name);
     while (true) {
       Thread.sleep(1000);
       taskID = onDemandDeploymentService.getTaskID(deployment_name);
       if (taskID != null) {
         logger.info("Create Instance taskID : " + taskID);
         break;
       }
     }
     String ips = "";
     while (true) {
       Thread.sleep(1000);
       ips = onDemandDeploymentService.getUpdateInstanceIPS(taskID);
       if (ips != null) {
           break;
       }
     }
     String instanceId = "";
     while (true) {
         Thread.sleep(1000);
         instanceId = onDemandDeploymentService.getUpdateVMInstanceID(taskID, instance_name);
         if (instanceId != null) {
             break;
         }
     }
     jpaServiceInstance.setDashboardUrl(ips);
     jpaServiceInstance.setVmInstanceId(instanceId);
     jpaServiceInstanceRepository.save(jpaServiceInstance);
     jpaServiceInstance.withAsync(true);
     SecurityGroups securityGroups = common.cloudFoundryClient().securityGroups();
     cloudFoundryService.SecurityGurop(request.getSpaceGuid(), jpaServiceInstance.getDashboardUrl(), securityGroups);
     return jpaServiceInstance;
     ```

3. On-Demand getOperationServiceInstance

1.1. 현재 Bosh의 Task를 조회해 running task중 Deployment가 포함되어있으면
     inprogress 상태를 반환 없을경우 succeed 상태를 반환한다.

     ```
     CloudController에서 null을 반환받을경우 inprogress를 최종적으로 반환한다.
     반대로 instance값을 전달받을경우 succeed를 반환한다.
     예시)
     public JpaServiceInstance getOperationServiceInstance(String Instanceid) {
        JpaServiceInstance instance = jpaServiceInstanceRepository.findByServiceInstanceId(Instanceid);
        if (onDemandDeploymentService.runningTask(deployment_name, instance)) {
            logger.info("인스턴스 생성완료");
            ExecutorService executor = Executors.newSingleThreadExecutor();
            CompletableFuture.runAsync(() -> {
                try {
                    if (instance.getAppGuid() != null) {
                        ServiceBindingsV2 serviceBindingsV2 = common.cloudFoundryClient().serviceBindingsV2();
                        ApplicationsV2 applicationsV2 = common.cloudFoundryClient().applicationsV2();
                        cloudFoundryService.ServiceInstanceAppBinding(instance.getAppGuid(), instance.getServiceInstanceId(), (Map) this.objectMapper.readValue(instance.getApp_parameter(), Map.class), serviceBindingsV2, applicationsV2);
                    }
                } catch (Exception e) {
                    logger.error(e.getMessage());
                }
            }, executor);
            return instance;
        }
        logger.info("인스턴스 생성중");
        return null;
     }
    ```

4. On-Demand deleteServiceInstance

1.1. Service Instance를 제거해 반환한다.
1.2. 비동기방식으로 삭제한 Instance에 할당된 VM을 중지시키기 위한 준비를 한다.
##### 해당 Deployment가 Lock상태인지 조회한다. Lock인경우 15초 뒤에 다시 조회후 Lock이 아닌 경우 해당 VM을 중지시킨다.

      ```
      예시)
      ExecutorService executor = Executors.newSingleThreadExecutor();
            CompletableFuture.runAsync(() -> {
                lock.lock();
                try {
                while (true) {
                    if (onDemandDeploymentService.getLock(deployment_name)) {
                        Thread.sleep(15000);
                        continue;
                    }
                    onDemandDeploymentService.updateInstanceState(deployment_name, instance_name, instance.getVmInstanceId(), BoshDirector.INSTANCE_STATE_DETACHED);
                    cloudFoundryService.DelSecurityGurop(common.cloudFoundryClient().securityGroups(), instance.getSpaceGuid(), instance.getDashboardUrl());
                    logger.info("VM DETACHED SUCCEED : VM_ID : " + instance.getVmInstanceId());
                    break;
                }
                } catch (InterruptedException e) {
                    logger.error(e.getMessage());
                }
                lock.unlock();
            }, executor);
      ```

##### <a name="44"/>4.4. On-Demand 릴리즈 개발가이드
service를 Bosh release를 통해 배포 해야 하기 때문에 Bosh release 개발 방식에 따라 작성되어야한다.Bosh release 는 packages 와 jobs 관련 스크립트로 구성되어 있다.

1. On-Demand Release 기본구성

    ```
    예시)
    .
    ├── README.md
    ├── blobs
    ├── config
    │   ├── blobs.yml
    │   └── final.yml
    ├── create.sh
    ├── delete.sh
    ├── deployments
    │   ├── deploy-vsphere.sh
    │   ├── necessary_on_demand_vars.yml
    │   ├── paasta_on_demand_service_broker.yml
    │   └── unnecessary_on_demand_vars.yml
    ├── jobs
    │   ├── mariadb
    │   │   ├── monit
    │   │   ├── spec
    │   │   └── templates
    │   │       ├── bin
    │   │       │   ├── mariadb_ctl.erb
    │   │       │   ├── post-start
    │   │       │   └── pre-start
    │   │       └── conf
    │   │           ├── init.sql
    │   │           └── mariadb.cnf
    │   ├── paas-ta-on-demand-broker
    │   │   ├── monit
    │   │   ├── spec
    │   │   └── templates
    │   │       ├── bin
    │   │       │   ├── monit_debugger
    │   │       │   └── service_ctl.erb
    │   │       ├── data
    │   │       │   ├── application.yml.erb
    │   │       │   └── properties.sh
    │   │       └── helpers
    │   │           ├── ctl_setup.sh
    │   │           └── ctl_utils.sh
    ├── packages
    │   ├── java
    │   │   ├── packaging
    │   │   └── spec
    │   ├── mariadb
    │   │   ├── packaging
    │   │   └── spec
    │   ├── paas-ta-on-demand-broker
    │   │   ├── packaging
    │   │   └── spec
    └── src
        ├── java
        │   └── server-jre-8u121-linux-x64.tar.gz
        ├── mariadb
        │   └── mariadb-10.1.22-linux-x86_64.tar.gz
        └── paas-ta-on-demand-broker
            └── paas-ta-on-demand-broker.jar

    ```

2. 해당서비스를 On-Demand로 적용시켜 Release를 개발할 경우 jobs, packages, src에 추가
   해서 Release 파일을 생성하면 된다.

    ```
    예시) On-Demand Redis Relases Tree
    .
    ├── README.md
    ├── blobs
    │   ├── aws-cli
    │   ├── ginkgo
    │   ├── go
    │   ├── nginx
    │   └── redis
    │       └── redis-4.0.11.tar.gz
    ├── config
    │   ├── blobs.yml
    │   └── final.yml
    ├── create.sh
    ├── delete.sh
    ├── deployments
    │   ├── deploy-vsphere.sh
    │   ├── necessary_on_demand_vars.yml
    │   ├── paasta_on_demand_service_broker.yml
    │   └── unnecessary_on_demand_vars.yml
    ├── jobs
    │   ├── mariadb
    │   │   ├── monit
    │   │   ├── spec
    │   │   └── templates
    │   │       ├── bin
    │   │       │   ├── mariadb_ctl.erb
    │   │       │   ├── post-start
    │   │       │   └── pre-start
    │   │       └── conf
    │   │           ├── init.sql
    │   │           └── mariadb.cnf
    │   ├── paas-ta-on-demand-broker
    │   │   ├── monit
    │   │   ├── spec
    │   │   └── templates
    │   │       ├── bin
    │   │       │   ├── monit_debugger
    │   │       │   └── service_ctl.erb
    │   │       ├── data
    │   │       │   ├── application.yml.erb
    │   │       │   └── properties.sh
    │   │       └── helpers
    │   │           ├── ctl_setup.sh
    │   │           └── ctl_utils.sh
    │   ├── redis
    │   │   ├── monit
    │   │   ├── spec
    │   │   └── templates
    │   │       ├── bin
    │   │       │   ├── health_check
    │   │       │   └── pre_start.sh
    │   │       └── config
    │   │           ├── bpm.yml.erb
    │   │           └── redis.conf.erb
    │   └── sanity-tests
    │       ├── monit
    │       ├── spec
    │       └── templates
    │           └── bin
    │               └── run
    ├── packages
    │   ├── java
    │   │   ├── packaging
    │   │   └── spec
    │   ├── mariadb
    │   │   ├── packaging
    │   │   └── spec
    │   ├── paas-ta-on-demand-broker
    │   │   ├── packaging
    │   │   └── spec
    │   └── redis-4
    │       ├── packaging
    │       └── spec
    └── src
        ├── java
        │   └── server-jre-8u121-linux-x64.tar.gz
        ├── mariadb
        │   └── mariadb-10.1.22-linux-x86_64.tar.gz
        └── paas-ta-on-demand-broker
            └── paas-ta-on-demand-broker.jar
    ```

3. Release 구성을 완료한 후에 bosh cli 명령어를 통해 tgz파일을 만든후 업로드를 한다.

    ```
    예시)
    $ bosh create-release --force --tarball on-demand-release.tgz --name on-demand-release --version 1.0
    $ bosh upload-release on-demand-release.tgz(bosh ur on-demand-release.tgz)

    또는 create.sh파일을 커스텀한후 실행시키면 된다.
    ```

##### <a name="45"/>4.5. On-Demand Deployment 개발가이드
BOSH Deploymentmanifest 는 components 요소 및 배포의 속성을 정의한YAML  파일이다.
Deployment manifest 에는 sotfware를 설치 하기 위해서 어떤 Stemcell (OS, BOSH agent) 을 사용할것이며 Release (Software packages, Config templates, Scripts) 이름과 버전, VMs 용량, Jobs params 등을 정의하여 Bosh deploy CLI 을 이용하여 software(여기서는 서비스팩)를 설치 한다.

1. On-Demand Deployment 기본 구성

    ```
    .
    ├── deploy-vsphere.sh                     bosh deploy 실행파일
    ├── necessary_on_demand_vars.yml          manifest.yml에 들어갈 필수 변경 property파일
    ├── paasta_on_demand_service_broker.yml   deploy manifest.yml 파일
    └── unnecessary_on_demand_vars.yml        manifest.yml에 들어갈 property파일
    ```
    deploy-vsphere.sh

    ```
    bosh -d on-demand-service-broker deploy paasta_on_demand_service_broker.yml \
   -l necessary_on_demand_vars.yml\
   -l unnecessary_on_demand_vars.yml
    ```

    necessary_on_demand_vars.yml : 변경해야 하는 필수 property파일(정확히 기입안할시 deploy에서 error 발생)

    ```
    #!/bin/bash

    ---
    ### On-Demand Bosh Deployment Name Setting ###
    deployment_name: on-demand-service-broker                       #On-Demand Deployment Name

    ### Main Stemcells Setting ###
    stemcell_os: ubuntu-xenial                                      # Deployment Main Stemcell OS
    stemcell_version: latest                                       # Main Stemcell Version
    stemcell_alias: default                                         # Main Stemcell Alias

    ### On-Demand Release Deployment Setting ###
    releases_name : on-demand-redis-release                               # On-Demand Release Name
    internal_networks_name : default                        # Some Network From Your 'bosh cloud-config(cc)'
    mariadb_disk_type : 2GB                                        # MariaDB Disk Type 'bosh cloud-config(cc)'
    broker_port : 8080                                              # On-Demand Broker Server Port
    bosh_client_admin_id: admin                                     # Bosh Client Admin ID
    bosh_client_admin_secret: bosh_clinet_password                  # Bosh Client Admin Secret 'echo ${BOSH_CLIENT_SECRET}'
    bosh_url: https://xx.xx.xx.xxx                                  # Bosh URL 'bosh env'
    bosh_director_port: 25555                                       # Bosh API Port
    bosh_oauth_port: 8443                                           # Bosh Oauth Port

    cloudfoundry_url: xx.xxx.xx.xxx.xip.io                          # CloudFoundry URL
    cloudfoundry_sslSkipValidation: true                            # CloudFoundry Login SSL Validation
    cloudfoundry_admin_id: admin                                    # CloudFoundry Admin ID
    cloudfoundry_admin_password: admin                         # CloudFoundry Admin Password

    ### On-Demand Service Property(Changes are possible) ###
    mariadb_port: 3306                                              # MariaDB Server Port
    mariadb_user_password: DB_password                              # MariaDB Root Password
    ```

    unnecessary_on_demand_vars.yml : 변경하지 않아도 되는 property파일

    ```
    #!/bin/bash

    ---
    service_instance_guid: 54e2de61-de84-4b9c-afc3-88d08aadfcb6
    service_instance_name: redis
    service_instance_bullet_name: Redis Dedicated Server Use
    service_instance_bullet_desc: Redis Service Using a Dedicated Server
    service_instance_plan_guid: 2a26b717-b8b5-489c-8ef1-02bcdc445720
    service_instance_plan_name: dedicated-vm
    service_instance_plan_desc: Redis service to provide a key-value store
    service_instance_org_limitation: -1                                        # org당 서비스 개수 제한 -1일경우 limit 없음
    service_instance_space_limitation: -1                                      # space당 서비스 개수 제한 -1일경우 limit 없음

    ```

    paasta_on_demand_service_broker.yml : On-demand-Service의 manifest.yml 파일

    ```
    ---
    name: "((deployment_name))"        #서비스 배포이름(필수) bosh deployments 로 확인 가능한 이름

    stemcells:
    - alias: "((stemcell_alias))"
      os: "((stemcell_os))"
      version: "((stemcell_version))"

    variables:
    - name: redis-password
      type: password

    releases:
    - name: "((releases_name))"                  # 서비스 릴리즈 이름(필수) bosh releases로 확인 가능
      version: "1.0"                                             # 서비스 릴리즈 버전(필수):latest 시 업로드된 서비스 릴리즈 최신버전

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
      - z5
      instances: 1
      vm_type: medium
      stemcell: "((stemcell_alias))"
      persistent_disk_type: "((mariadb_disk_type))"
      networks:
      - name: "((internal_networks_name))"
      jobs:
      - name: mariadb
        release: "((releases_name))"
      syslog_aggregator: null

    ######## BROKER ########

    - name: paas-ta-on-demand-broker
      azs:
      - z5
      instances: 1
      vm_type: service_medium
      stemcell: "((stemcell_alias))"
      networks:
      - name: "((internal_networks_name))"
      jobs:
      - name: paas-ta-on-demand-broker
        release: "((releases_name))"
      syslog_aggregator: null

    ######### COMMON PROPERTIES ##########
    properties:
      broker:
        server:
          port: "((broker_port))"
        datasource:
          password: "((mariadb_user_password))"
        service_instance:
          guid: "((service_instance_guid))"
          name: "((service_instance_name))"
          bullet:
            name: "((service_instance_bullet_name))"
            desc: "((service_instance_bullet_desc))"
          plan:
            id: "((service_instance_plan_guid))"
            name: "((service_instance_plan_name))"
            desc: "((service_instance_plan_desc))"
          org_limitation: "((service_instance_org_limitation))"
          space_limitation: "((service_instance_space_limitation))"
        bosh:
          client_id: "((bosh_client_admin_id))"
          client_secret: "((bosh_client_admin_secret))"
          url: ((bosh_url)):((bosh_director_port))
          oauth_url: ((bosh_url)):((bosh_oauth_port))
          deployment_name: "((deployment_name))"
          instance_name: "((on_demand_service_instance_name))"
        cloudfoundry:
          url: "((cloudfoundry_url))"
          sslSkipValidation: "((cloudfoundry_sslSkipValidation))"
          admin:
            id: "((cloudfoundry_admin_id))"
            password: "((cloudfoundry_admin_password))"
      mariadb:                                                # MARIA DB SERVER 설정 정보
        port: "((mariadb_port))"                                            # MARIA DB PORT 번호
        admin_user:
          password: "((mariadb_user_password))"                             # MARIA DB ROOT 계정 비밀번호
        host_names:
        - mariadb0   

    ```

2. 서비스를 추가한 On-Demand-Service 배포하기(On-Demand-Service-Redis)
서비스를 추가한 On-Demand-Service를 배포하기 위해선 서비스에 필요한 프로퍼티 설정 및 manifest.yml에 추가해 deploy를 진행하면 된다.


    On-Demand-Redis property.yml(예시)
    ```
    #!/bin/bash

    ---
    ### On-Demand Bosh Deployment Name Setting ###
    deployment_name: on-demand-service-broker                       #On-Demand Deployment Name

    ### Main Stemcells Setting ###
    stemcell_os: ubuntu-xenial                                      # Deployment Main Stemcell OS
    stemcell_version: latest                                       # Main Stemcell Version
    stemcell_alias: default                                         # Main Stemcell Alias

    ### On-Demand Release Deployment Setting ###
    releases_name : on-demand-redis-release                               # On-Demand Release Name
    internal_networks_name : default                        # Some Network From Your 'bosh cloud-config(cc)'
    mariadb_disk_type : 2GB                                        # MariaDB Disk Type 'bosh cloud-config(cc)'
    broker_port : 8080                                              # On-Demand Broker Server Port
    bosh_client_admin_id: admin                                     # Bosh Client Admin ID
    bosh_client_admin_secret: bosh_clinet_password                  # Bosh Client Admin Secret 'echo ${BOSH_CLIENT_SECRET}'
    bosh_url: https://xx.xx.xx.xxx                                  # Bosh URL 'bosh env'
    bosh_director_port: 25555                                       # Bosh API Port
    bosh_oauth_port: 8443                                           # Bosh Oauth Port

    cloudfoundry_url: xx.xxx.xx.xxx.xip.io                          # CloudFoundry URL
    cloudfoundry_sslSkipValidation: true                            # CloudFoundry Login SSL Validation
    cloudfoundry_admin_id: admin                                    # CloudFoundry Admin ID
    cloudfoundry_admin_password: admin                         # CloudFoundry Admin Password

    ### On-Demand Service Property(Changes are possible) ###
    mariadb_port: 3306                                              # MariaDB Server Port
    mariadb_user_password: DB_password                              # MariaDB Root Password

    ### On-Demand Dedicated Service Instance Properties ###         #서비스에 적용시킬 프로퍼티 추가 기입

    on_demand_service_instance_name: redis                          # On-Demand Service Instance Name
    service_password: service_password
    service_port: 6379

    ```

    On-Demand-Redis paasta_on_demand_service_broker(예시)
    ```
    ---
    name: "((deployment_name))"        #서비스 배포이름(필수) bosh deployments 로 확인 가능한 이름

    stemcells:
    - alias: "((stemcell_alias))"
      os: "((stemcell_os))"
      version: "((stemcell_version))"

    addons:
    - name: bpm
      jobs:
      - name: bpm
        release: bpm

    variables:
    - name: redis-password
      type: password

    releases:
    - name: bpm
      sha1: f2bd126b17b3591160f501d88d79ccf0aba1ae54
      url: git+https://github.com/cloudfoundry-incubator/bpm-release
      version: 1.0.3
    - name: "((releases_name))"                  # 서비스 릴리즈 이름(필수) bosh releases로 확인 가능
      version: "1.0"                                             # 서비스 릴리즈 버전(필수):latest 시 업로드된 서비스 릴리즈 최신버전

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
      - z5
      instances: 1
      vm_type: medium
      stemcell: "((stemcell_alias))"
      persistent_disk_type: "((mariadb_disk_type))"
      networks:
      - name: "((internal_networks_name))"
      jobs:
      - name: mariadb
        release: "((releases_name))"
      syslog_aggregator: null

    ######## BROKER ########

    - name: paas-ta-on-demand-broker
      azs:
      - z5
      instances: 1
      vm_type: service_medium
      stemcell: "((stemcell_alias))"
      networks:
      - name: "((internal_networks_name))"
      jobs:
      - name: paas-ta-on-demand-broker
        release: "((releases_name))"
      syslog_aggregator: null
    - name: redis
      azs:
      - z5
      instances: 0
      vm_type: medium
      stemcell: "((stemcell_alias))"
      persistent_disk: 1024
      networks:
      - name: "((internal_networks_name))"
      jobs:
      - name: redis
        release: "((releases_name))"
    - name: sanity-tests
      azs:
      - z5
      instances: 1
      lifecycle: errand
      vm_type: medium
      stemcell: "((stemcell_alias))"
      networks:
      - name: "((internal_networks_name))"
      jobs:
      - name: sanity-tests
        release: "((releases_name))"

    ######### COMMON PROPERTIES ##########
    properties:
      broker:
        server:
          port: "((broker_port))"
        datasource:
          password: "((mariadb_user_password))"
        service_instance:
          guid: "((service_instance_guid))"
          name: "((service_instance_name))"
          bullet:
            name: "((service_instance_bullet_name))"
            desc: "((service_instance_bullet_desc))"
          plan:
            id: "((service_instance_plan_guid))"
            name: "((service_instance_plan_name))"
            desc: "((service_instance_plan_desc))"
          org_limitation: "((service_instance_org_limitation))"
          space_limitation: "((service_instance_space_limitation))"
        bosh:
          client_id: "((bosh_client_admin_id))"
          client_secret: "((bosh_client_admin_secret))"
          url: ((bosh_url)):((bosh_director_port))
          oauth_url: ((bosh_url)):((bosh_oauth_port))
          deployment_name: "((deployment_name))"
          instance_name: "((on_demand_service_instance_name))"
        cloudfoundry:
          url: "((cloudfoundry_url))"
          sslSkipValidation: "((cloudfoundry_sslSkipValidation))"
          admin:
            id: "((cloudfoundry_admin_id))"
            password: "((cloudfoundry_admin_password))"
      mariadb:                                                # MARIA DB SERVER 설정 정보
        port: "((mariadb_port))"                                            # MARIA DB PORT 번호
        admin_user:
          password: "((mariadb_user_password))"                             # MARIA DB ROOT 계정 비밀번호
        host_names:
        - mariadb0
    ######### SERVICE PROPERTIES #################
      service:
        password: "((service_password))"
        port: "((service_port))"

    ```
3. 서비스 배포 성공후 브로커 등록 및 서비스 신청시 해당 서비스 instance 생성 확인, 생성 완료시 On-Demand-Service 설치 완료



[On-Demand_Image_01]:/deployment-guide/images/on-demand/1.png
[On-Demand_Image_02]:/deployment-guide/images/on-demand/2.png
[On-Demand_Image_03]:/deployment-guide/images/on-demand/3.png
[On-Demand_Image_04]:/deployment-guide/images/on-demand/4.png
[On-Demand_Image_05]:/deployment-guide/images/on-demand/5.png
[On-Demand_Image_06]:/deployment-guide/images/on-demand/6.png
