## Table of Contents

1. [개요](#1)
  * 1.1 [목적](#2)
  * 1.2 [범위](#3)
2. [이종 PaaS-TA 사용 가이드](#4)
	* 2.1 [플랫폼 관리자 관리](#5)
	* 2.2 [로그인 계정 관리](#6)
	* 2.3 [인프라 관리](#7)
	* 2.4 [스템셀과 릴리즈](#8)
	* 2.5 [이종 BOOTSTRAP 설치하기](#9)
	  * 2.5.1 [인프라 환경 설정 관리](#10)
	  * 2.5.2 [스템셀 다운로드](#11)
	  * 2.5.3 [릴리즈 다운로드](#12)
	  * 2.5.4 [이종 BOOTSTRAP 설치](#13)
	* 2.6 [이종 CF-DEPLOYMENT 설치하기](#14)
	  * 2.6.1 [스템셀 업로드](#15)
	  * 2.6.2 [PaaS-TA 릴리즈 사용](#16)
	  * 2.6.3 [이종 CF-DEPLOYMENT 설치](#17)

## Executive Summary

본 문서는 이종 PaaS-TA 설치 자동화의 사용 절차에 대해 기술하였다.

# <div id='1'/>1.  문서 개요

## <div id='2'/>1.1.  목적
본 문서는 이종 PaaS-TA 설치 자동화를 사용하여 이종 PaaS-TA를 설치하는 절차에 대해 기술하였다.

## <div id='3'/>1.2.  범위
본 문서는 Linux 환경(Ubuntu 16.04) 및 Azure/Openstack 인프라 환경을 기준으로 이종 PaaS-TA 설치 자동화를 사용하여 이종PaaS-TA를 설치하는 방법에 대해 작성되었다.

# <div id='4'/>2. 이종 PaaS-TA 설치 자동화 사용 가이드

BOSH는 클라우드 환경에 서비스를 배포하고 소프트웨어 릴리즈를 관리해주는 오픈 소스로 Bootstrap은 하나의 VM에 디렉터의 모든 컴포넌트를 설치한 것으로 PaaS-TA 설치를 위한 관리자 기능을 담당한다.

이종 PaaS-TA 설치 자동화를 이용해서 클라우드 환경에 PaaS-TA를 설치하기 위해서는 **인프라 설정, 스템셀, 소프트웨어 릴리즈, Manifest 파일, 인증서 파일**의 5가지 요소가 필요하다. 스템셀은 클라우드 환경에 VM을 생성하기 위해 사용할 기본 이미지이고, 소프트웨어 릴리즈는 VM에 설치할 소프트웨어 패키지들을 묶어 놓은 파일이며, Manifest파일은 스템셀과 소프트웨어 릴리즈를 이용해서 서비스를 어떤 식으로 구성할지를 정의해 놓은 명세서이다. 다음 그림은 BOOTSTRAP을 이용하여 PaaS-TA를 설치하는 절차이다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image01]

## <div id='5'/>2.1. 플랫폼 관리자 관리

플랫폼 설치 자동화 -> 플랫폼 관리자 관리의 코드/권한/사용자 관리를 통해 전체 사용자의 생성 및 사용 권한과 공통 Manifest 버전/신규 스템셀 확장 등의 공통 코드를 사용할 수 있다.

## <div id='6'/>2.2. 로그인 계정 관리

플랫폼 설치 자동화 웹 화면에서 “플랫폼 관리자 관리” -> “로그인 계정 관리” 메뉴로 이동한다. 플랫폼 설치 자동화는 “로그인 계정 관리” 메뉴에서 기본적으로 플랫폼 설치 자동화 관리자 정보(admin/admin)를 제공한다.

### 1. 로그인 계정 등록

1. 사용자 “등록” 버튼을 클릭 후 사용자 정보 입력 및 해당 사용자의 권한을 선택하여 “확인” 버튼을 클릭한다.
2. 사용자 등록 후 초기 비밀번호는 “1234” 이며, 최초 로그인 후 비밀번호를 변경할 수 있다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image02]

### 2. 로그인 계정 수정

1. 사용자 “수정” 버튼을 클릭 후 사용자 정보 및 해당 권한을 수정하여 “확인” 버튼을 클릭한다.
2. 관리자는 선택한 사용자의 아이디는 수정할 수 없지만 비밀번호를 변경할 수 있다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image03]

## <div id='7'/>2.3. 인프라 관리

이종 BOOTSTRAP & PaaS-TA를 설치하기 위해서는 사전에 인프라 환경 구축이 필요하다. 인프라 관리 메뉴는 실제 인프라의 대시보드 화면에서도 환경 구축을 할 수 있다.

플랫폼 설치 자동화 웹 화면에서 “인프라 환경 관리” 의 “인프라 계정 관리” 메뉴에서 Azure 인프라 계정을 등록하고 “Azure 관리” 메뉴로 이동하여 등록 한 Azure 계정을 설정 후 해당 Azure 계정에 대한 실제 Azure 인프라 리소스를 제어할 수 있다.

또한, “인프라 계정 관리” 메뉴에서 Openstack 인프라 계정을 등록하고 “Openstack 관리” 메뉴로 이동하여 등록한 Openstack 계정을 설정 후 해당 Openstack 계정에 대한 실제 Openstack 인프라 리소스를 제어할 수 있다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image04]

### 1. Azure 계정 설정

1. “인프라 환경 관리” -> “인프라 계정 관리 화면으로 이동한다”
2. 전체 인프라 계정 관리 화면에서 Azure 계정 관리 화면으로 이동한다.
3. Azure 계정 관리 화면에서는 “등록” 버튼을 클릭한다
4. Azure 계정 등록 팝업 화면에서 플랫폼 설치에 필요한 인프라 계정 정보를 입력하고 “확인” 버튼을 클릭한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image05]

※ ※	Azure 계정 등록 입력 정보

- 계정 별칭: 인프라 관리에서 사용할 계정의 별칭
- Subscription ID: 실제 Azure Portal 청구 아이디
- Tenant ID: 실제 Azure Portal Active Directory Properties의 디렉토리 아이디
- Application ID: 실제 Azure Portal Active Directory App의 아이디
- Application Secret: 실제 Azure Portal Active Directory App의 Password

### 2. *Azure 리소스 관리*

1.	Azure 관리 화면에서 등록 한 Azure를 기본 계정으로 설정하여 실제 Azure 리소스를 제어할 수 있다.
2.	“인프라 환경 관리” -> Azure 관리 화면으로 이동한다.
3.	아래는 Azure 관리 화면에서 실제 PaaS-TA 설치에 필요한 Azure 리소스의 환경이다.

<table>
    <tr>
        <td>
            인프라 환경
        </td>
        <td>
            메뉴
        </td>
    </tr>
    <tr>
        <td rowspan="7">
            Azure 리소스 관리
        </td>
        <td>
            Resource Group
        </td>
    </tr>
    <tr>
        <td>
            Virtual Network & Subnet
        </td>
    </tr>
    <tr>
        <td>
            Storage Account
        </td>
    </tr>
    <tr>
        <td>
            Public IP
        </td>
    </tr>
    <tr>
        <td>
            Key Pair
        </td>
    </tr>
    <tr>
        <td>
            Security Group
        </td>
    </tr>
    <tr>
        <td>
            Route Table
        </td>
    </tr>
</table>

![Hybrid_PaaSTa_Deploy_Use_Guide_Image06]

### 3. *Azure 리소스 그룹 등록*

1.	“Azure 관리” 메뉴에서 “Resource Group 관리” 메뉴를 클릭한다.
2.	“생성” 버튼을 클릭한다.
3.	Resource Group 생서 팝업 화면에서 정보를 입력 후 “확인” 버튼을 클릭한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image07]

※	Azure Resource Group 생성 입력 정보
- Resource Group Name: 생성할 Resource Group 명
- RG Location: 생성할 Resource Group의 위치 선택 (각 Location 별 특이 사항이 존재할 수 있음, 본 가이드 테스트 환경은 Service Limit이 충분한 Koreasouth Location 사용)
- Subscription: Azure 기본 계정의 Subscription의 명칭(자동 입력)


### 4. *Azure 네트워크 생성 & 서브넷 생성*

1.	“Azure관리” 메뉴에서 “Virtual Network & Subnet 관리” 메뉴를 클릭한다.
2.	“생성” 버튼을 클릭한다.
3.	네트워크 생성 팝업화면에서 정보를 입력 후 “확인” 버튼을 클릭한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image08]

※	Azure 네트워크 생성 입력 정보
- Network Name: 생성할 네트워크 명
- Network 주소 공간: 생성할 네트워크의 주소 범위
- Resource Group: 어느 Resource Group에 네트워크를 생성할 것인지 선택
- Location: 선택 한 Resource Group의 Location(자동 입력)
- Subnet Name: 네트워크에 할당할 기본 서브넷 명
- Subnet 주소 범위: 네트워크의 주소 공간에 할당할 기본 서브넷의 주소 범위
- Subscription: Azure 기본 계정의 Subscription의 명칭(자동 입력)


4.	PaaS-TA 및 기타 서비스를 설치 하기위해 Subnet을 추가할 경우 아래의 절차를 반복한다.
5	생성 한 네트워크를 선택하고 “서브넷 추가” 버튼을 클릭한다.
6	서브넷 생성 팝업화면에서 정보를 입력 후 “확인” 버튼을 클릭한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image09]

※	Azure 서브넷 생성 입력 정보
- Subnet Type: 서브넷 유형 선택 (본 가이드에서는 일반 subnet으로 생성하였다.)
- Subnet Name: 네트워크에 할당할 기본 서브넷 명
- Subnet 주소 범위: 네트워크의 주소 공간에 할당할 기본 서브넷의 주소 범위


### 5. *Azure Storage Account생성*

1.	Azure관리” 메뉴에서 “Storage Account 관리” 메뉴를 클릭한다.
2.	정보를 입력 후 “생성” 버튼을 클릭한다.
![Hybrid_PaaSTa_Deploy_Use_Guide_Image10]

※	Azure Storage Account 생성 입력 정보
- Storage Account Name: 생성할 Storage Account 명
- Resource Group: 어느 Resource Group에 Storage Account를 생성할 것인지 선택
- Location: 선택 한 Resource Group의 Location(자동 입력)
- Performance: Azure Storage Account의 Performance Type(자동 입력)
- Subscription: Azure 기본 계정의 Subscription의 명칭(자동 입력)

3.	PaaS-TA Instance 정보와 Stemcell 메타 데이터 정보를 저장하기 위해 Blob을 추가해야 한다.
4.	생성한 Storage Account를 선택하고 “Blob 생성” 버튼을 클릭한다.
5.	Blob 생성 팝업화면에서 정보 입력 후 “확인” 버튼을 클릭한다.
6.	아래 화면에서 Private/Blob Access Level의 blob 2개를 생성한다.
![Hybrid_PaaSTa_Deploy_Use_Guide_Image11]

※	Azure Storage Blob 생성 입력 정보
- Public Access Level: Blob Access Level, Private는 Bosh 인스턴스 정보 저장 관련 Blob이고 Blob은 스템셀 메타데이터 정보 관련 Blob
- Blob Name: Blob Level에 따른 Blob Name (자동 입력)

7. PaaS-TA Stemcell 정보를 저장하기 위해 Table을 추가해야 한다.
8. 생성한 Storage Account를 선택하고 “Table 생성” 버튼을 클릭한다.
9. Table 생성 팝업 화면에서 정보 입력 후 “확인” 버튼을 클릭한다.


![Hybrid_PaaSTa_Deploy_Use_Guide_Image13]

※	Azure Storage Table 생성 입력 정보
- Storage Table Name: 생성할 Storage Table Name (자동 입력)

### 6. *Azure Public IP 할당*

1.	“Azure 관리” 메뉴에서 “Public IPs 관리” 메뉴를 클릭한다.
2.	“IP 할당” 버튼을 클릭한다.
3.	Azure Public IP 할당 팝업 화면에서 정보를 입력 후 “할당” 버튼을 클릭한다.
4.	PaaS-TA 설치를 위해 총 2개의 Public IP가 필요하다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image12]


※	Azure Public IP 할당 입력 정보
- Public IP Name: 할당할 Public IP 명
- Resource Group: 어느 Resource Group에 Public를 생성할 것인지 선택
- Location: 선택 한 Resource Group의 Location(자동 입력)
- Subscription: Azure 기본 계정의 Subscription의 명칭(자동 입력)


### 7. *Azure Key Pair 생성*

1.	“Azure 관리” 메뉴에서 “Key Pair 관리” 메뉴를 클릭한다.
2.	“생성” 버튼을 클릭한다.
3.	Key Pair 생성 팝업 화면에서 정보를 입력한다.
4.	Azure Key Pair 생성 후 읽기 권한으로 변경이 필요 할 수 있다. 생성한 Key Pair는 \${user_home}/.ssh/ 디렉토리에 생성되며 private key파일에 대하여 $ chmod 400 \${Private Key Name} 절차가 필요할 수 있다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image14]


※ 	Security Group 등록 정보

-	Security Group Tag: Security Group의 별칭
-	Group Name: Security Group의 이름
-	Description: Security Group에 대한 추가 정보
-	VPC: Security Group이 적용될 VPC 정보(여기서는 2 항목에서 생성한 VPC)
-	Ingress Rule: Security Group의 적용되는 진입 규칙

### 8. *Azure 보안 그룹 생성*
1.	“Azure 관리” 메뉴에서 “Security Group 관리” 메뉴를 클릭한다.
2.	“생성” 버튼을 클릭한다.
3.	Security Group 생성 팝업 화면에서 정보를 입력한다.
4.	초기 생성 Security Group는 모든 Inbound 포트에 대하여 열려 있는 상태이다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image15]

※	Azure Security Group 생성 입력 정보
- Security Group Name: 생성할 Security Group 명
- Resource Group: 어느 Resource Group에 Security Group를 생성할 것인지 선택
- Location: 선택 한 Resource Group의 Location(자동 입력)
- Performance: Azure Security Group의 Performance Type(자동 입력)
- Subscription: Azure 기본 계정의 Subscription의 명칭(자동 입력)


### 9. *Azure Router Table 생성 & 서브넷 연결*

1.	“Azure 관리” 메뉴에서 “Router Table 관리” 메뉴를 클릭한다.
2.	“생성” 버튼을 클릭한다.
3.	Router Table 생성 팝업 화면에서 정보를 입력한다.


![Hybrid_PaaSTa_Deploy_Use_Guide_Image16]


※	Azure Router Table 생성 입력 정보
- Router Table Name: 생성할 Router Table 명
- Resource Group: 어느 Resource Group에 Router Table을 생성할 것인지 선택
- Location: 선택 한 Resource Group의 Location(자동 입력)
- Subscription: Azure 기본 계정의 Subscription의 명칭(자동 입력)

4. Router Table에 서브넷을 연결하기 위해 생성한 Router Table을 선택하고 “Subnet 연결” 버튼을 클릭한다.
5. Subnet 연결 팝업화면에서 네트워크와 서브넷을 선택하고 ”확인” 버튼을 클릭한다.
6. 생성한 Router Table에 Network의 Subnet을 모두 연결한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image17]

※	Azure 서브넷 연결 입력 정보
- Network: Router Table에 연결한 생성한 Network 명칭 선택
- Subnet: Router Table에 연결할 Network의 Subnet 명칭 선택

### 10. *Openstack 계정 등록*
1.	“인프라 환경 관리” -> “인프라 계정 관리 화면으로 이동한다”
2.	전체 인프라 계정 관리 화면에서 Openstack 계정 관리 화면으로 이동한다.
3.	Openstack 계정 관리 화면에서는 “등록” 버튼을 클릭한다
4.	Openstack 계정 등록 팝업 화면에서 플랫폼 설치에 필요한 인프라 계정 정보를 입력하고 “확인” 버튼을 클릭한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image19]


※ 계정 등록 정보

-	계정 별칭: 인프라 관리에서 사용할 계정의 별칭
-	Keystone Version: Identity 서비스에 대한 코드이름(v2, v3 로 구분)
-	Identify API Tokens URL: Identify 서비스에 접근하기 위한 API URL
-	User Name: Openstack 계정 명
-	User Password: Openstack 계정 비밀번호
-	Project: Identity 서비스에 의해 개별 프로젝트에 할당되는 고유한 ID
-	Domain: OpenStack Identity 엔티티 관리에 대한 관리 영역을 정의하는 프로젝트, 그룹 및 사용자 집합
-	Tenant: 사용자의 그룹으로, Compute 자원에 대한 액세스를 격리하기 위해 사용, 프로젝트에 대한 다른 용어

**계정 등록 후 Openstack API URL이 숫자가 아닌 문자열이라면 Inception서버에서 Openstack의 API IP의 host를 등록해준다.**

### 11. *Openstack 리소스 관리*

1.	Openstack 관리 화면에서 등록 한 Openstack를 기본 계정으로 설정하여 실제 Openstack 리소스를 제어할 수 있다.
2.	“인프라 환경 관리” -> Openstack 관리 화면으로 이동한다.
3.	아래는 Opensack 관리 화면에서 실제 PaaS-TA 설치에 필요한 Openstack 리소스의 환경이다.

<table>
    <tr>
        <td>
            인프라 환경
        </td>
        <td>
            메뉴
        </td>
    </tr>
    <tr>
        <td rowspan="5">
            Openstack 리소스 관리
        </td>
        <td>
            Network 관리
        </td>
    </tr>
    <tr>
        <td>
            Router 관리
        </td>
    </tr>
    <tr>
        <td>
            Key Pair 관리
        </td>
    </tr>
    <tr>
        <td>
            Floating IP 관리
        </td>
    </tr>
    <tr>
        <td>
            Security Group 관리
        </td>
    </tr>
</table>

![Hybrid_PaaSTa_Deploy_Use_Guide_Image20]

### 12. *Openstack Network 설정*

1.	“OPENSTACK 관리” 메뉴에서 “Network” 메뉴를 클릭한다.
2.	“생성” 버튼을 클릭한다.
3.	네트워크 생성 팝업 화면에서 정보를 입력 후 “확인” 버튼을 클릭한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image21]

※ Openstack Network 설정 정보

-	네트워크 명: 등록할 네트워크의 별칭
-	Admin State: 네트워크의 동작 상태 체크
-	Subnet Name: 네트워크에 할당되는 서브넷의 별칭
-	Network Address: 네트워크의 주소 범위
-	IP Version: IP Version 선택(Ipv4, Ipv6)
-	Gateway IP: 게이트웨이 IP
-	Enable DHCP: DHCP 사용 유무 체크
-	DNS: 인터넷 도메인에 대한 이름-주소 및 주소-이름 입력


### 13. *Openstack Subnet 설정*

1.	“OPENSTACK 관리” 메뉴에서 “Router” 메뉴를 클릭한다.
2.	“생성” 버튼을 클릭한다.
3.	Router 생성 팝업 화면에서 라우터 명을 입력한 후 “확인” 버튼을 클릭한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image22]

※ Subnet 설정 정보

-	Subnet Name: 서브넷의 별칭
-	Network Address: 서브넷의 주소 범위
-	Gateway IP: 네트워크에 할당되는 서브넷의 별칭
-	IP Version: IP Version 선택(Ipv4, Ipv6)
-	Enable DHCP: DHCP 사용 유무 체크
-	DNS: 인터넷 도메인에 대한 이름-주소 및 주소-이름 입력

### 14. *Openstack Router 설정*

1.	“OPENSTACK 관리” 메뉴에서 “Router” 메뉴를 클릭한다.
2.	“생성” 버튼을 클릭한다.
3.	Router 생성 팝업 화면에서 라우터 명을 입력한 후 “확인” 버튼을 클릭한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image23]

※ Router 설정 정보

-	Router Name: 등록할 Openstack Router의 별칭

### 15. *Openstack 인터페이스 설정*

1.	“OPENSTACK 관리” 메뉴에서 “Router” 메뉴를 클릭한다.
2.	Router 목록에서 Router를 선택한다(Router가 없다면 5항목의 Openstack 라우터 생성 참조).
3.	“인터페이스” 버튼을 클릭한다.
4.	라우터 인터페이스 설정 팝업 화면에서 정보를 입력 후 “연결” 버튼을 클릭한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image24]

※ 인터페이스 설정 정보

-	Subnet Name: 서브넷 설정에서 등록한 서브넷의 별칭
-	IP Address: 특정한 IP 주소로 인터페이스 연결(optional)
-	Router Name: 라우터 생성에서 설정한 라우터 별칭(자동입력)
-	Router ID: 라우터 생성에서 생성된 라우터 ID(자동입력)

### 16. *Openstack 게이트웨이 설정*

1.	“OPENSTACK 관리” 메뉴에서 “Router” 메뉴를 클릭한다.
2.	Router 목록에서 Router를 선택한다(Router가 없다면 5항목의 Openstack 라우터 생성 참조).
3.	“게이트웨이” 버튼을 클릭한다.
4.	게이트웨이 설정 팝업 화면에서 정보를 입력 후 “연결” 버튼을 클릭한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image25]

※ 	게이트웨이 연결 설정 정보

-	External Network: 게이트웨이 연결 설정이 가능한 외부 네트워크 정보
-	Router Name: 라우터 생성에서 설정한 라우터 별칭(자동입력)
-	Router ID: 라우터 생성에서 생성된 라우터 ID(자동입력)

### 17. *Openstack Key Pair 설정*

1.	“OPENSTACK 관리” 메뉴에서 “Key Pair 관리” 메뉴를 클릭한다.
2.	정보를 입력 후 “생성” 버튼을 클릭한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image26]

### 18. *Openstack Floating IP 설정*

1.	“OPENSTACK 관리” 메뉴에서 “Floating IPs 관리” 메뉴를 클릭한다.
2.	정보를 입력 후 “할당” 버튼을 클릭한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image27]

※ 	Floating IP 설정 정보

-	Pool: Floating IP가 생성되는 네트워크 풀 정보

### 19. *OPENSTACK Security Group 설정*

1.	“OPENSTACK 관리” 메뉴에서 “Security Group 관리” 메뉴를 클릭한다.
2.	생성 팝업 화면에서 정보를 입력한다.
   -	BOOTSTRAP 설치 시 Ingress Rule 항목에 “bosh-security” 버튼을 클릭한다.
   -	CF 설치 시 Ingress Rule 항목에 “cf-security” 버튼을 클릭한다.
   -	Security Group 생성 시 모든 Inbound 포트가 열려 있다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image28]

※	Security Group 등록 정보

-	Security Group Name: Security Group의 이름
-	Description: Security Group에 대한 추가 정보
-	Ingress Rule: Security Group에 적용되는 진입 규칙


## <div id='8'/>2.4  스템셀과 릴리즈

플랫폼 설치 자동화를 통해 배포 가능한 BOOTSTRAP 버전은 아래와 같으며, 아래의 지원 가능한 버전을 이용하지 않을 경우 에러가 발생할 수 있다. 따라서 아래의 릴리즈 버전으로 다운로드 및 설치한다.

<table>
    <tr>
        <td>BOSH 릴리즈</td>
        <td>CPI 릴리즈</td>
        <td>BPM</td>
        <td>스템셀</td>
    </tr>
    <tr>
        <td>bosh/267.8.0</td>
        <td>
            bosh-Azure-cpi/72 <br>
            bosh-openstack-cpi/39
        </td>
        <td>bpm/0.9.0</td>
        <td>
            bosh-Azure-xen-hvm-ubuntu-trusty-go_agent/3586.24 <br>
            bosh-openstack-kvm-ubuntu-trusty-go_agent/3586.24
        </td>
    </tr>
    <tr>
        <td>bosh/268.2.0</td>
        <td>
            bosh-Azure-cpi/72 <br>
            bosh-openstack/39
        </td>
        <td>
            bpm/0.12.3
        </td>
        <td>
            bosh-Azure-xen-hvm-ubuntu-xenial-go_agent/97.28 <br>
            bosh-openstack-kvm-ubuntu-xenial-go_agent/97.28
        </td>
    </tr>
    <tr>
        <td>bosh/270.2.0</td>
        <td>
            bosh-Azure-cpi/75 <br>
            bosh-openstack-cpi/43
        </td>
        <td>bpm/1.1.0</td>
        <td>
            bosh-Azure-xen-hvm-ubuntu-xenial-go_agent/315.64 <br>
            bosh-openstack-kvm-ubuntu-xenial-go_agent/315.64
        </td>
    </tr>
</table>

플랫폼 설치 자동화를 통해 배포 가능한 CF-Deployment 버전은 아래와 같으며, 아래의 릴리즈 버전으로 다운로드&업로드 및 설치한다.

<table>
    <tr>
        <td>릴리즈 버전</td>
        <td>스템셀</td>
    </tr>
    <tr>
        <td>cf-deployment/2.7.0</td>
        <td>
            bosh-Azure-xen-hvm-ubuntu-trusty-go_agent/3586.25<br>
            bosh-openstack-kvm-ubuntu-trusty-go_agent/3586.25
        </td>
    </tr>
    <tr>
        <td>cf-deployment/3.2.0</td>
        <td>bosh-Azure-xen-hvm-ubuntu-trusty-go_agent/3586.27<br>
            bosh-openstack-kvm-ubuntu-trusty-go_agent/3586.27
        </td>
    </tr>
    <tr>
        <td>cf-deployment/4.0.0</td>
        <td>bosh-Azure-xen-hvm-ubuntu-trusty-go_agent/3586.40<br>
            bosh-openstack-kvm-ubuntu-trusty-go_agent/3586.40
        </td>
    </tr>
    <tr>
        <td>cf-deployment/5.0.0</td>
        <td>bosh-Azure-xen-hvm-ubuntu-xenial-go_agent/97.18<br>
            bosh-openstack-kvm-ubuntu-xenial-go_agent/97.18
        </td>
    </tr>
    <tr>
        <td>cf-deployment/5.5.0</td>
        <td>bosh-Azure-xen-hvm-ubuntu-xenial-go_agent/97.28<br>
            bosh-openstack-kvm-ubuntu-xenial-go_agent/97.28
        </td>
    </tr>
    <tr>
        <td>cf-deployment/9.3.0</td>
        <td>bosh-Azure-xen-hvm-ubuntu-xenial-go_agent/315.36<br>
            bosh-openstack-kvm-ubuntu-xenial-go_agent/315.36
        </td>
    </tr>
    <tr>
        <td>cf-deployment/9.5.0</td>
        <td>bosh-Azure-xen-hvm-ubuntu-xenial-go_agent/315.64<br>
            bosh-openstack-kvm-ubuntu-xenial-go_agent/315.64
        </td>
    </tr>
    <tr>
        <td>paasta/4.0</td>
        <td>bosh-Azure-xen-hvm-ubuntu-xenial-go_agent/97.28<br>
            bosh-openstack-kvm-ubuntu-xenial-go_agent/97.28
        </td>
    </tr>
    <tr>
        <td>paasta/4.6</td>
        <td>bosh-Azure-xen-hvm-ubuntu-xenial-go_agent/315.36<br>
            bosh-openstack-kvm-ubuntu-xenial-go_agent/315.36
        </td>
    </tr>
    <tr>
        <td>paasta/5.0</td>
        <td>bosh-Azure-xen-hvm-ubuntu-xenial-go_agent/315.64<br>
            bosh-openstack-kvm-ubuntu-xenial-go_agent/315.64
        </td>
    </tr>
</table>

## <div id='9'/>2.5. 이종 BOOTSTRAP 설치하기

이종 PaaS-TA 설치 자동화를 이용하여 인프라 환경 설정 및 BOOTSTRAP을 설치하고, 디렉터로 등록하는 절차는 다음과 같다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image29]

### <div id='10'/>2.5.1 인프라 환경 설정 관리

이종 BOOTSTRAP을 설치하기 위해서는 설치할 인프라의 환경 설정 정보를 등록해야 하며, 이를 위해  “이종 PaaS-TA 설치 자동화” 메뉴를 클릭하여 이종 PaaS-TA설치 자동화 대시보드화면으로 이동한다.

이종 PaaS-TA 설치 자동화 웹 화면에서 “환경 설정 및 관리” -> “인프라 환경 설정 관리” 메뉴로 이동한다. “인프라 환경 설정 관리” 메뉴에서는 Azure/OPENSTACK 의 2개 인프라의 전체 환경 설정 목록 조회 기능과 관리 화면으로 이동하는 기능을 제공한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image30]

환경 설정 관리 화면 이동 컨테이너를 클릭하여 플랫폼 설치에 필요한 각 계정 정보를 등록한다.

#### 1.	Azure 환경 설정 등록

1.   Azure 환경 설정 관리 화면에서는 “등록” 버튼을 클릭한다.
2.   Azure 환경 설정 등록 팝업 화면에서 플랫폼 설치에 필요한 인프라 환경 설정 정보를 입력하고 “확인” 버튼을 클릭한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image31]

※	Azure 환경 설정 등록 정보

※	Azure 환경 설정 입력 정보
- Azure 환경 설정 별칭: 생성할 환경 설정 Azure 별칭
- Azure 계정 별칭: 인프라 관리에서 등록한 Azure 계정 정보 선택
- Security Group: 인프라 관리에서 등록한 Azure Security Group 명칭
- Azure 리소스 그룹: 인프라 관리에서 등록한 Azure 리소스 그룹 명칭
- Azure 스토리지 계정: 인프라 관리에서 등록한 Azure 스토리지 계정 명칭
- Azure SSH Public Key: 인프라 관리에서 등록한 Azure Key - Pair 중 Public Key 입력
- Azure SSH Private Key: 인프라 관리에서 등록한 Azure Key Pair 중 Private Key 선택


#### 2.	Openstack 환경 설정 등록

1.	Openstack 환경 설정 관리 화면에서는 “등록” 버튼을 클릭한다.
2.	Openstack 환경 설정 등록 팝업 화면에서 플랫폼 설치에 필요한 인프라 환경 설정 정보를 입력하고 “확인” 버튼을 클릭한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image32]

※	Openstack 환경 설정 등록 정보

-	Openstack 환경 설정 별칭: 등록할 환경 설정 정보의 별칭
-	Openstack 계정 별칭: 등록된 계정 정보의 별칭
-	Keystone Version: 등록된 Keystone Version 정보
-	Region: Identity (keystone)만을 공유하는 전용 API endpoint를 가진 별개의 OpenStack 환경 정보.
-	Security Group: 보안 그룹 정보
-	Keypair Name: Keypair 명
-	Private Key File: 개인 키 파일 업로드 정보(Keypair의 Private Key)

### <div id='11'/>2.5.2. 스템셀 다운로드

이종 PaaS-TA 설치 자동화 웹 화면에서 “환경설정 및 관리” -> “스템셀 관리” 메뉴로 이동한다. “스템셀 관리” 메뉴에서는 Cloud Foundry에서 제공하는 공개 스템셀을 다운로드할 수 있는 기능을 제공한다.
스템셀 다운로드 유형은 총 3가지이며 Version유형으로 다운로드가 안될 경우 로컬에서 다운로드 후 로컬에서 선택 유형, 또는 스템셀 다운로드 URL을 직접 입력하는 스템셀 URL 유형을 통해 다운로드 받는 유형을 선택할 수 있다.
이후, 상단에 위치한 “등록” 버튼을 클릭 후 스템셀 정보를 입력하고 “확인” 버튼을 클릭한다.

<table>
  <tr>
    <td>인프라 환경</td>
    <td>참조 사이트</td>
  </tr>
  <tr>
    <td>Azure</td>
    <td>https://bosh.io/stemcells/bosh-Azure-xen-hvm-ubuntu-xenial-go_agent</td>
  </tr>
  <tr>
    <td>Openstack</td>
    <td>https://bosh.io/stemcells/bosh-openstack-kvm-ubuntu-xenial-go_agent</td>
  </tr>
</table>

**본 가이드에서는 버전 Xenial 315.64를 다운로드 하였다.**

![Hybrid_PaaSTa_Deploy_Use_Guide_Image33]

### <div id='12'/>2.5.3. 릴리즈 다운로드

BOOTSTRAP을 설치하기 위해서는 BOSH 릴리즈, BOSH CPI릴리즈, OS-CONF 3개의 릴리즈가 필요하며, BOSH 릴리즈 버전 266 이상일 경우 BPM 릴리즈가 더 추가되어 총 4개의 릴리즈가 필요하다.

릴리즈 다운로드 유형은 상기 스템셀 다운로드와 동일하게 총 3가지이며, Version유형으로 다운로드가 안될 경우 마찬가지로 로컬에서 다운로드 후 로컬에서 선택 유형 또는, 릴리즈 다운로드 URL을 통해 다운로드 받는 유형을 선택할 수 있다.

릴리즈를 다운로드하기 위해 플랫폼 설치 자동화 웹 화면에서 “환경설정 및 관리” -> “릴리즈 관리” 메뉴로 이동 후 상단에 위치한 “등록” 버튼을 클릭하고, 릴리즈 등록 팝업 화면에서 릴리즈 정보 입력 후 “등록” 버튼을 클릭한다.

#### 1. BOSH 릴리즈

1.	릴리즈 등록 팝업 화면에서BOSH 릴리즈 정보를 입력하고, “등록” 버튼 클릭한다.
2.	BOSH 릴리즈 참조 사이트

    [http://bosh.io/releases/github.com/cloudfoundry/bosh?all=1](http://bosh.io/releases/github.com/cloudfoundry/bosh?all=1)

![Hybrid_PaaSTa_Deploy_Use_Guide_Image34]

**본 가이드에서는 v270.2.0을 다운로드 하였다.**

#### 2. BOSH CPI 릴리즈

1.	릴리즈 등록 팝업화면에서 BOSH CPI릴리즈 정보를 입력하고, “등록” 버튼 클릭한다.
2.	BOSH-CPI 릴리즈 참조 사이트

<table>
  <tr>
    <td>인프라 환경</td>
    <td>참조 사이트</td>
  </tr>
  <tr>
    <td>Azure</td>
    <td>https://bosh.io/releases/github.com/cloudfoundry/bosh-Azure-cpi-release?all=1</td>
  </tr>
  <tr>
    <td>Openstack</td>
    <td>https://bosh.io/releases/github.com/cloudfoundry/bosh-openstack-cpi-release?all=1</td>
  </tr>
</table>

![Hybrid_PaaSTa_Deploy_Use_Guide_Image35]

**본 가이드에서는 Azure CPI v75/Openstack CPI v43을 다운로드 하였다.**

#### 3. BPM 릴리즈

1.	릴리즈 등록 팝업화면에서 BPM릴리즈 정보를 입력하고, “등록” 버튼 클릭한다.
2.	BPM 릴리즈 참조 사이트

    [https://bosh.io/releases/github.com/cloudfoundry-incubator/bpm-release?all=1](https://bosh.io/releases/github.com/cloudfoundry-incubator/bpm-release?all=1)

![Hybrid_PaaSTa_Deploy_Use_Guide_Image36]

**본 가이드에서는 v1.1.0을 다운로드 하였다.**

#### 4. OS-CONF 릴리즈

1.	릴리즈 등록 팝업화면에서 OS-CONF릴리즈 정보를 입력하고, “등록” 버튼 클릭한다.
2.	OS-CONF 릴리즈 참조 사이트

    [https://bosh.io/releases/github.com/cloudfoundry/os-conf-release?all=1](https://bosh.io/releases/github.com/cloudfoundry/os-conf-release?all=1)

![Hybrid_PaaSTa_Deploy_Use_Guide_Image37]

**본 가이드에서는 v21.0.0을 다운로드 하였다.**

### <div id='13'/>2.5.4. 이종 BOOTSTRAP 설치

BOOTSTRAP 설치하기 위해 이종 PaaS-TA 설치 자동화 웹 화면에서 “이종 BOOTSTRAP” 메뉴로 이동 후 하위 항목의 메뉴버튼을 클릭하여 필요한 재원을 입력한다.

#### 1. 이종 BOOTSTRAP - CPI 정보 관리

1.	이종 PaaS-TA 설치 자동화 웹 화면에서 “이종 BOOTSTRAP”의 “CPI 정보 관리” 메뉴를 클릭한다.
2.	CPI 정보 입력 란에서 Azure 클라우드 환경을 선택한 경우 인프라 환경 설정 관리에서 설정한 Azure 인프라 환경 별칭을 선택한다.
3.	“등록” 버튼을 클릭한다.
4.	CPI 정보 목록에서 값이 정상적으로 입력된 것을 확인한다.
5.	상기 2 ~ 4 항목을 반복 수행하여 Openstack CPI 정보를 등록한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image38]

※	이종 BOOTSTRAP CPI 등록 정보

-	CPI 정보 별칭: CPI 정보를 구분하기 위한 별칭
-	클라우드 인프라 환경: 클라우드 인프라 설정 정보
-	BOOTSTRAP CPI 등록 정보의 경우 인프라 환경 설정 관리에서 설정한 정보와 동일한 정보가 들어간다.

#### 2. 이종 BOOTSTRAP - NETWORK 정보 관리

1.	이종 PaaS-TA 설치 자동화 웹 화면에서 “이종 BOOTSTRAP”의 “Network 정보 관리” 메뉴를 클릭한다.
2.	네트워크 정보 입력 란에서 Azure 클라우드 환경을 선택한 경우 인프라 환경 설정 관리에서 설정한 Azure 인프라 환경 별칭을 선택한 후, 각각의 입력란에 값을 입력한다.
3.	“등록” 버튼을 클릭한다.
4.	“네트워크 정보 목록”에서 값이 정상적으로 입력된 것을 확인한다.
5.	상기 2 ~ 4 항목을 반복 수행하여 Openstack Network 정보를 등록한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image39]

※	이종 BOOTSTRAP Network 등록 정보

-	네트워크 정보 별칭: 네트워크 정보를 구분하기 위한 별칭
-	클라우드 인프라 환경: 클라우드 인프라 설정 정보
-	디렉터 Public IP: BOOTSTRAP이 설치될 VM의 공인 IP 정보, 공인 IP를 사용하지 않을 경우 값을 입력하지 않는다(단, 공인 아이피가 없을 경우 Inception 서버와 설치할 Azure/Openstack의 BOSH 서브넷과 통신이 가능 해야 한다. 통신이 불가능할 경우 Public IP를 반드시 사용한다).
-	디렉터 Private IPs: BOOTSTRAP이 설치될 VM의 내부IP 정보
-	서브넷 아이디: 인프라 관리에서 생성한 인프라 환경의 서브넷 ID
-	서브넷 범위: 인프라 관리에서 생성한 인프라 환경의 서브넷 네트워크 범위
-	게이트웨이: 인프라 관리에서 생성한 인프라 환경의 서브넷 게이트웨이 주소
-	DNS: 인터넷 도메인에 대한 이름-주소 및 주소-이름 입력

#### 3. 이종 BOOTSTRAP - 디렉터 인증서 관리

1.	이종 PaaS-TA 설치 자동화 웹 화면에서 “이종 BOOTSTRAP”의 “디렉터 인증서 관리” 메뉴를 클릭한다.
2.	디렉터 인증서 정보 입력 란에서 Azure 클라우드 환경을 선택한 경우 인프라 환경 설정 관리에서 설정한 Azure 인프라 환경 별칭을 선택한 후, 각각의 입력란에 값을 입력한다.
3.	“등록” 버튼을 클릭한다.
4.	“디렉터 인증서 목록”에서 값이 정상적으로 입력된 것을 확인한다.
5.	상기 2 ~ 4 항목을 반복 수행하여 Openstack 디렉터 인증서 정보를 등록한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image40]

※	이종 BOOTSTRAP 디렉터 인증서 등록 정보

-	디렉터 인증서 별칭: 네트워크 정보를 구분하기 위한 별칭
-	클라우드 인프라 환경: 클라우드 인프라 설정 정보
-	네트워크 별칭: Network 정보 관리에서 등록한 네트워크 정보 별칭
-	디렉터 Public IP: BOOTSTRAP이 설치될 VM의 공인 IP 정보, 공인 IP를 사용하지 않을 경우 값을 입력하지 않는다(네트워크 별칭 선택 시 자동 입력)
-	디렉터 Private IP: BOOTSTRAP이 설치될 VM의 내부IP 정보(네트워크 별칭 선택 시 자동 입력)

**BOOTSTRAP Public IP 입력항목은 사용자의 설정에 따라 사용시 값을 입력할 수 있고, 사용하지 않을 경우 이를 제외한 항목만 채워 넣어도 디렉터 인증서 생성/등록이 가능하다**

#### 4. 이종 BOOTSTRAP - 기본 정보 관리

1.	이종 PaaS-TA 설치 자동화 웹 화면에서 “이종 BOOTSTRAP”의 “기본 정보 관리” 메뉴를 클릭한다.
2.	기본 정보 입력 란에서 Azure 클라우드 환경을 선택한 경우 인프라 환경 설정 관리에서 설정한 Azure 인프라 환경 별칭을 선택한 후, 각각의 입력란에 값을 입력한다.
3.	“등록” 버튼을 클릭한다.
4.	“기본 정보 목록”에서 값이 정상적으로 입력된 것을 확인한다.
5.	상기 2 ~ 4 항목을 반복 수행하여 Openstack 기본 정보를 등록한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image41]

※	이종 BOOTSTRAP 기본 정보 등록 정보

-	기본 정보 별칭: 기본 정보를 구분하기 위한 별칭
-	클라우드 인프라 환경: 클라우드 인프라 설정 정보
-	배포 명: BOOTSTRAP 배포 시 사용하는 명칭
-	디렉터 명: 디렉터 명칭
-	디렉터 접속 인증서: 디렉터 설정에서 등록한 디렉터 인증서 정보
-	NTP: 신뢰하고 정확한 시간 원본과의 통신을 통하여 호스트 또는 노드를 위해 시계를 유지하는 방식으로 공인된 주소를 사용
-	BOSH 릴리즈: 릴리즈 관리에서 등록한 BOSH 릴리즈 정보
-	BOSH CPI 릴리즈: 릴리즈 관리에서 등록한 BOSH CPI 릴리즈 정보
-	OS-CONF 릴리즈: 설치할 OS-CONF 릴리즈를 선택
-	BOSH-BPM 릴리즈: 설치할 BPM 릴리즈 선택, 특정 BOSH 버전 이상일 경우 사용
-	스냅샷기능 사용여부: 스토리지 볼륨 또는 이미지에 대한 특정 시점에서의 사본. 볼륨을 백업하기 위해 스냅샷 기능 사용유무 체크
-	PaaS-TA 모니터링 정보: PaaS-TA 모니터링을 이용하려면 BOSH Release v270.2.0를 선택하고 PaaS-TA 모니터링 사용을 선택한다.

#### 5. 이종 BOOTSTRAP - 리소스 정보 관리

1.	이종 PaaS-TA 설치 자동화 웹 화면에서 “이종 BOOTSTRAP”의 “리소스 정보 관리” 메뉴를 클릭한다.
2.	리소스 정보 입력 란에서 Azure 클라우드 환경을 선택한 경우 인프라 환경 설정 관리에서 설정한 Azure 인프라 환경 별칭을 선택한다.
3.	“등록” 버튼을 클릭한다.
4.	“리소스 정보 목록”에서 값이 정상적으로 입력된 것을 확인한다.
5.	상기 2 ~ 4 항목을 반복 수행하여 Openstack 리소스 정보를 등록한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image42]

※	이종 BOOTSTRAP 리소스 등록 정보

-	리소스 정보 별칭: 리소스 정보를 구분하기 위한 별칭
-	클라우드 인프라 환경: 클라우드 인프라 설정 정보
-	스템셀 명: BOOTSTRAP이 설치될 VM의 스템셀 정보
-	인스턴스 유형: BOOTSTRAP이 설치될 VM의 인스턴스 유형 정보

#### 6. 이종 BOOTSTRAP - 설치

1.	이종 PaaS-TA 설치 자동화 웹 화면에서 “이종 BOOTSTRAP”의 “이종 BOOTSTRAP” 메뉴를 클릭한다.
2.	정보 등록 버튼을 클릭한다.
3.	“이종 BOOTSTRAP 설치 정보 등록” 란에서 BOOTSTRAP 정보 별칭을 입력하고, Azure 클라우드 환경을 선택한 다음, 1,2,4,5 항목에서 입력한 CPI,NETWORK,기본,리소스 정보들을 선택한다.
4.	“등록” 버튼을 클릭한다.
5.	“배포 가능 한 Private/Public BOOTSTRAP 목록”에서 값이 정상적으로 입력된 것을 확인한다.
6.	상기 2 ~ 5 항목을 반복 수행하여 Openstack 설치 정보를 등록한다.

    ![Hybrid_PaaSTa_Deploy_Use_Guide_Image43]

7.	“배포 가능 한 Private/Public BOOTSTRAP 목록”에서 Azure/Openstack 정보를 선택 후 더블클릭하여 “배포 할 Private/Public BOOTSTRAP 목록”에 정보가 삽입된 것을 확인한다.
8.	VM 설치 버튼을 클릭한다.
9.	이종 BOOTSTRAP 설치 팝업 창이 출력되고 설치가 진행된다
10.	설치가 완료된 후 “배포 한 Private/Public BOOTSTRAP 목록”에 정보가 삽입된 것을 확인한다.

#### 7. 이종 BOOTSTRAP - 디렉터 설정

이종 BOOTSTRAP설치가 완료되면 BOOTSTRAP 디렉터 정보를 이용해서 이종 PaaS-TA 설치 자동화의 디렉터로 설정한다.

1.	이종 PaaS-TA 설치 자동화 웹 화면에서 “이종 BOOTSTRAP”의 “디렉터 설정” 메뉴를 클릭한다.
2.	“Azure Cloud 디렉터 목록”의 설정 추가 버튼을 클릭한다.
3.	“디렉터 정보” 입력란에서 디렉터 정보를 입력한다.
4.	확인 버튼을 클릭한다.
5.	“Azure Cloud 디렉터 목록”에서 값이 정상적으로 입력된 것을 확인한다.
6.	“Openstack Cloud 디렉터 목록”의 설정 추가 버튼을 클릭한다.
7.	“디렉터 정보” 입력란에서 디렉터 정보를 입력한다.
8.	확인 버튼을 클릭한다.
9.	“Openstack Cloud 디렉터 목록”에서 값이 정상적으로 입력된 것을 확인한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image44]

※	이종 BOOTSTRAP 디렉터 설정 등록 정보

-	디렉터 IP: BOOTSTRAP 설치 IP 정보를 입력
-	포트번호: BOOTSTRAP 설치 Manifest의 Director Port 번호 입력(default 25555)
-	계정: BOOTSTRAP 설치 Manifest의 user_management 아래 Director User 입력
-	비밀번호: BOOTSTRAP 설치 Manifest의 user_management아래 Director Password 입력

## <div id='14'/>2.6. 이종 CF-Deployment 설치하기

BOOTSTRAP을 설치하고 이종 PaaS-TA 설치 자동화의 Azure/Openstack의 디렉터로 설정이 완료되면 CF-Deployment를 설치할 준비가 된 상태로 PaaS-TA를 설치하는 절차는 다음과 같다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image45]

### <div id='15'/>2.6.1. 스템셀 업로드

“배포 정보 조회 및 관리”의 “스템셀 업로드” 메뉴에서 스템셀을 업로드할 디렉터를 선택하고, 이종 PaaS-TA 설치 자동화에서 다운받은 스템셀을 “스템셀 업로드” 화면을 통해 디렉터에 315.64 버전의 스템셀을 업로드 한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image46]

### <div id='16'/>2.6.2. PaaS-TA 릴리즈 사용

**해당 절차는 PaaS-TA를 설치하기 위해 반드시 필요한 Compiled Local 릴리즈를 다운로드하는 절차이다. PaaS-TA를 설치하기 위해 필요한 절차이다.**

**플랫폼 설치 자동화를 통해 배포 가능한 PaaS-TA 버전에 맞는 릴리즈와 스템셀을 PaaS-TA 공식 홈페이지 [https://paas-ta.kr/download/package](https://paas-ta.kr/download/package)에서 다운로드 받는다.**

1.	PaaS-TA 릴리즈 사용

-	다운로드 한 paasta 릴리즈 압축 파일을 scp 명령어를 통해 플랫폼 설치 자동화가 동작하고 있는 Inception 서버로 이동시킨다.

    ex) $ scp -i {inception.key} ubuntu@172.xxx.xxx.xx {릴리즈 압축 일 명} # Key Pair를 사용할 경우

    ex) $ scp ubuntu@172.xxx.xxx.xx {릴리즈 압축 일 명} # Password를 사용할 경우

2.	릴리즈 디렉토리를 생성하고 릴리즈 디렉토리에서 해당 릴리즈 파일의 압축을 해제한다.
릴리즈 디렉토리의 위치는 반드시 {home}/workspace/paasta-5.0/release/paasta여야 한다.
-	디렉토리 생성

    ex) $ mkdir -p workspace/paasta-5.0/release/paasta

-	릴리즈 압축 파일 이동

    ex) $ mv {릴리즈 압축 파일 명} workspace/paasta-5.0/release/paasta/

-	릴리즈 파일 압축 해제

    ex) $ tar xvf {릴리즈 압축 파일 명} # 릴리즈 파일 확장자가 tar인 경우

    ex) $ unzip {릴리즈 압축 파일 명} # 릴리즈 파일 확장자가 zip인 경우

3.	아래는 릴리즈 디렉토리의 PaaS-TA 릴리즈 형상 예시 그림이다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image54]

### <div id='17'/>2.6.3. 이종 CF-Deployment 설치

이종 CF-Deployment를 설치하기 위해 이종 PaaS-TA 설치 자동화 웹 화면에서 “이종 CF-DEPLOYMENT” 메뉴로 이동 후 하위 항목의 메뉴버튼을 클릭하여 필요한 재원을 입력한다.

#### 1. 이종 CF-Deployment 설치 - 기본 정보 관리

1.	이종 PaaS-TA 설치 자동화 웹 화면에서 “이종 CF-DEPLOYMENT”의 “기본 정보 관리” 메뉴를 클릭한다.
2.	기본 정보 입력 란에서 Azure 클라우드 환경을 선택하고, 입력란에 정보를 기입한다.
3.	“등록” 버튼을 클릭한다.
4.	“기본 정보 목록”에서 값이 정상적으로 입력된 것을 확인한다.
5.	상기 2 ~ 4 항목을 반복 수행하여 Openstack 기본 정보를 등록한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image48]

**본 가이드에서는 CF-Deployment 버전으로 paasta/5.0을 사용하였다.**

※	이종 CF-Deployment 기본 등록 정보

-	기본 정보 별칭 & 배포 명: CF-Deployment 기본 정보를 구분하기 위한 별칭(배포 명으로 사용)
-	클라우드 인프라 환경: 클라우드 인프라 설정 정보
-	CF-Deployment 버전 명: 플랫폼 설치 자동화에서 지원하는 CF Deployment 버전 선택
-	CF 도메인: CF 설치에 사용 할 도메인 입력 ex) {public IP}.xip.io
-	CF 기본 조직명: CF를 구성하는데 있어 필요한 기본 조직의 별칭 정보
-	CF Database 유형: CF Database 컴포넌트의 유형(Mysql로 설치 시 컴파일 시간이 오래 걸릴 수 있음)
-	Inception User Name: Inception 서버의 계정 명(PaaS-TA 선택 시 제공) ex) vcap
-	CF Admin Password: CF Login 패스워드 입력
-	Portal 도메인: Portal을 설치 및 접속할 도메인 주소를 입력한다. Portal을 설치하지 않고 CF-Deployment를 실행할 경우 해당 값을 입력하지 않는다.
-	PaaS-TA 모니터링 정보: PaaS-TA 모니터링을 이용하려면 paasta/5.0을 선택하고 PaaS-TA 모니터링 사용을 선택한다.

#### 2. 이종 CF-Deployment 설치 - 네트워크 정보 관리

1.	이종 PaaS-TA 설치 자동화 웹 화면에서 “이종 CF-DEPLOYMENT”의 “NETWORK 정보 관리” 메뉴를 클릭한다.
2.	네트워크 정보 입력 란의 클라우드 인프라 환경에서 Azure 클라우드 환경을 선택하고, 입력란에 정보를 기입한다(AZ를 분리 배치하기 위해 “추가” 버튼을 클릭하여 네트워크를 추가로 설정할 수 있다.)
3.	“등록” 버튼을 클릭한다.
4.	“네트워크 정보 목록”에서 값이 정상적으로 입력된 것을 확인한다.
5.	상기 2 ~ 4 항목을 반복 수행하여 Openstack 네트워크 정보를 등록한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image49]

※	이종 CF-Deployment 네트워크 등록 정보

-	클라우드 인프라 환경: 클라우드 인프라 설정 정보
-	Network 별칭: CF-Deployment 네트워크 정보를 구분하기 위한 별칭
-	CF API TARGET IP: CF Deployment 설치 시 사용되는 Azure Public IP
-	서브넷 아이디: 인프라 관리에서 생성한 Azure VPC의 서브넷 명
-	보안 그룹: 인프라 관리에서 생성한 Azure 서브넷의 보안 그룹 명
-	가용 영역: 인프라 관리에서 설정한 Azure Region 내의 개별적인 지점
-	서브넷 범위: 인프라 관리에서 생성한 Azure 서브넷의 네트워크 범위
-	게이트웨이: 인프라 관리에서 생성한 Azure 서브넷의 게이트웨이 주소
-	DNS: DNS 서버 주소
-	IP 할당 제외 대역: CF Deployment VM을 배치하지 않을 IP 주소 시작/끝 입력
-	IP 할당 대역(최소 20개): CF Deployment VM을 배치할 IP 주소 시작/끝 입력

**Azure의 경우 복수개의 Internal(서브넷) 네트워크를 사용해야만 한다. 이는 Azure에는 Public/Private 용도의 서브넷이 존재하고 diego-cell(컨테이너)을 Private 서브넷으로 구분하기 위함이다.**

#### 3. 이종 CF-Deployment 설치 - 인증서 정보 관리

1.	이종 PaaS-TA 설치 자동화 웹 화면에서 “이종 CF-DEPLOYMENT”의 “인증서 정보 관리” 메뉴를 클릭한다.
2.	인증서 정보 입력 란의 클라우드 인프라 환경에서 Azure 클라우드 환경을 선택하고, 입력란에 정보를 기입한다.
3.	“등록” 버튼을 클릭한다.
4.	“인증서 정보 목록”에서 값이 정상적으로 입력된 것을 확인한다.
5.	상기 2 ~ 4 항목을 반복 수행하여 Openstack 인증서 정보를 등록한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image50]

※	이종 CF-Deployment 인증서 등록 정보

-	인증서 별칭: CF-Deployment 인증서 정보를 구분하기 위한 별칭
-	클라우드 인프라 환경: 클라우드 인프라 설정 정보
-	CF-Deployment 버전 명: 이종 PaaS-TA 설치 자동화에서 지원하는 CF Deployment 버전 정보
-	CF 도메인: 기본 정보에서 등록한 CF Deployment 도메인 주소
-	국가 코드: 국가 코드 선택
-	시/도: 시/도 입력
-	시/구/군: 시/구/군 입력
-	회사명: 회사명 입력
-	부서명: 부서 명 입력
-	Email: 이메일 주소 입력

#### 4. 이종 CF-Deployment 설치 - 리소스 정보 관리

1.	이종 PaaS-TA 설치 자동화 웹 화면에서 “이종 CF-DEPLOYMENT”의 “리소스 정보 관리” 메뉴를 클릭한다.
2.	리소스 정보 입력 란의 클라우드 인프라 환경에서 Azure 클라우드 환경을 선택하고, 입력란에 정보를 기입한다.
3.	“등록” 버튼을 클릭한다.
4.	“리소스 정보 목록”에서 값이 정상적으로 입력된 것을 확인한다.
5.	상기 2 ~ 4 항목을 반복 수행하여 Openstack 리소스 정보를 등록한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image51]

※	이종 CF-Deployment 리소스 등록 정보

-	리소스 정보 별칭: CF-Deployment 리소스 정보를 구분하기 위한 별칭
-	클라우드 인프라 환경: 클라우드 인프라 설정 정보
-	디렉터 정보: 이종 PaaS-TA 설치 자동화에 등록된 디렉터 정보
-	스템셀 명: 선택된 디렉터에 업로드 한 스템셀 선택
-	인스턴스 유형 Small: 클라우드 인프라 환경의 Small Instance Type
-	인스턴스 유형 Medium: 클라우드 인프라 환경의 Medium Instance Type
-	인스턴스 유형 Large: 클라우드 인프라 환경의 Large Instance Type

#### 5. 이종 CF-Deployment 설치 - 인스턴스 정보 관리

1.	이종 PaaS-TA 설치 자동화 웹 화면에서 “이종 CF-DEPLOYMENT”의 “인스턴스 정보 관리” 메뉴를 클릭한다.
2.	인스턴스 정보 입력 란의 클라우드 인프라 환경에서 Azure 클라우드 환경을 선택하고, 입력란에 정보를 기입한다.
3.	“등록” 버튼을 클릭한다.
4.	“인스턴스 정보 목록”에서 값이 정상적으로 입력된 것을 확인한다.
5.	상기 2 ~ 4 항목을 반복 수행하여 Openstack 인스턴스 정보를 등록한다.

![Hybrid_PaaSTa_Deploy_Use_Guide_Image52]

※	이종 CF-Deployment 인스턴스 등록 정보

-	인스턴스 정보 별칭: CF-Deployment 인스턴스 정보를 구분하기 위한 별칭
-	클라우드 인프라 환경: 클라우드 인프라 설정 정보
-	CF Deployment 버전 명: 이종 PaaS-TA 설치 자동화에서 지원하는 CF Deployment 버전 정보
-	인스턴스 수: VM에 할당할 인스턴스 수

**인스턴스 수가 늘어나게 되면 해당 수만큼 네트워크 대역이 필요해 NETWORK 정보 관리에서 네트워크 할당 대역을 늘려줄 필요 가 있다.**

#### 6. 이종 CF-Deployment - 설치

1.	이종 PaaS-TA 설치 자동화 웹 화면에서 “이종 CF-DEPLOYMENT”의 “이종 CF-DEPLOYMENT 설치” 메뉴를 클릭한다.
2.	정보 등록 버튼을 클릭한다.
3.	“이종 CF-DEPLOYMENT 설치 정보 등록” 란에서 CF-DEPLOYMENT 정보 별칭을 입력하고, Azure 클라우드 환경을 선택한 다음, 1,2,3,4,5 항목에서 입력한 기본,네트워크,인증서,리소스,인스턴스 정보들을 선택한다.
4.	“등록” 버튼을 클릭한다.
5.	“배포 가능 한 Private/Public CF-DEPLOYMENT 목록”에서 값이 정상적으로 입력된 것을 확인한다.
6.	상기 2 ~ 5 항목을 반복 수행하여 Openstack CF-DEPLOYMENT 설치 정보를 등록한다.

    ![Hybrid_PaaSTa_Deploy_Use_Guide_Image53]

7.	“배포 가능 한 Private/Public CF-DEPLOYMENT 목록”에서 Azure/Openstack 정보를 선택 후 더블클릭하여 “배포 할 Private/Public CF-DEPLOYMENT 목록”에 정보가 삽입된 것을 확인한다.
8.	VM 설치 버튼을 클릭한다.
※	이종 CF-Deployment 설치 시 인프라 환경 타입은 [Openstack – AWS] 또는 [Openstack – Azure] 로 구성이 되어야 VM 설치 진행이 가능하다. 만약 다른 인프라 환경 타입으로의 구성 후 VM설치 버튼을 클릭하게 되면 다음과 같은 에러 메시지가 출력 된다.
![Hybrid_PaaSTa_Deploy_Use_Guide_Image55]
9.	이종 CF-DEPLOYMENT 설치 팝업 창이 출력되고 설치가 진행된다
10.	설치가 완료된 후 “배포 한 Private/Public CF-DEPLOYMENT 목록”에 정보가 삽입된 것을 확인한다.



[Hybrid_PaaSTa_Deploy_Use_Guide_Image01]:./images/use-guide/hbpaastause/useflow_azure_openstack.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image02]:./images/use-guide/hbpaastause/platform/login_account_add.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image03]:./images/use-guide/hbpaastause/platform/login_account_modify.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image04]:./images/use-guide/hbpaastause/infradashboard/azure/azure_account_info.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image05]:./images/use-guide/hbpaastause/infradashboard/azure/azure_account_add.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image06]:./images/use-guide/hbpaastause/infradashboard/azure/azure_infra_dashboard.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image07]:./images/use-guide/hbpaastause/infradashboard/azure/azure_resource_group_add.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image08]:./images/use-guide/hbpaastause/infradashboard/azure/azure_subnet_add.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image09]:./images/use-guide/hbpaastause/infradashboard/azure/azure_internetgw_add.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image10]:./images/use-guide/hbpaastause/infradashboard/azure/azure_storage_account_create.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image11]:./images/use-guide/hbpaastause/infradashboard/azure/azure_private_bloc_access_level_blob_2create.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image12]:./images/use-guide/hbpaastause/infradashboard/azure/azure_public_ip_assign.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image13]:./images/use-guide/hbpaastause/infradashboard/azure/azure_storage_blob_cretate_table.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image14]:./images/use-guide/hbpaastause/infradashboard/azure/azure_keypair_create.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image15]:./images/use-guide/hbpaastause/infradashboard/azure/azure_security_group_create.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image16]:./images/use-guide/hbpaastause/infradashboard/azure/azure_routetable_add.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image17]:./images/use-guide/hbpaastause/infradashboard/azure/azure_routetable_associate.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image18]:./images/use-guide/hbpaastause/infradashboard/openstack/openstack_account_info.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image19]:./images/use-guide/hbpaastause/infradashboard/openstack/openstack_account_add.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image20]:./images/use-guide/hbpaastause/infradashboard/openstack/openstack_infra_dashboard.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image21]:./images/use-guide/hbpaastause/infradashboard/openstack/openstack_network_add.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image22]:./images/use-guide/hbpaastause/infradashboard/openstack/openstack_subnet_add.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image23]:./images/use-guide/hbpaastause/infradashboard/openstack/openstack_router_add.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image24]:./images/use-guide/hbpaastause/infradashboard/openstack/openstack_interface_attach.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image25]:./images/use-guide/hbpaastause/infradashboard/openstack/openstack_gateway_add.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image26]:./images/use-guide/hbpaastause/infradashboard/openstack/openstack_keypair_add.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image27]:./images/use-guide/hbpaastause/infradashboard/openstack/openstack_floatingip_add.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image28]:./images/use-guide/hbpaastause/infradashboard/openstack/openstack_securitygroup_add.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image29]:./images/use-guide/hbpaastause/bootstrap/hb_bootstrap_deployflow_azure_openstack.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image30]:./images/use-guide/hbpaastause/envmgnt/infra_env_info_azure.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image31]:./images/use-guide/hbpaastause/envmgnt/azure_infra_env_add.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image32]:./images/use-guide/hbpaastause/envmgnt/openstack_infra_env_add.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image33]:./images/use-guide/hbpaastause/envmgnt/stemcell_add.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image34]:./images/use-guide/hbpaastause/envmgnt/bosh_release_add.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image35]:./images/use-guide/hbpaastause/envmgnt/boshcpi_release_add.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image36]:./images/use-guide/hbpaastause/envmgnt/bpm_release_add.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image37]:./images/use-guide/hbpaastause/envmgnt/osconf_release_add.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image38]:./images/use-guide/hbpaastause/bootstrap/hb_bootstrap_cpiinfo.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image39]:./images/use-guide/hbpaastause/bootstrap/hb_bootstrap_networkinfo.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image40]:./images/use-guide/hbpaastause/bootstrap/hb_bootstrap_authinfo.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image41]:./images/use-guide/hbpaastause/bootstrap/hb_bootstrap_defaultinfo.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image42]:./images/use-guide/hbpaastause/bootstrap/hb_bootstrap_resourceinfo.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image43]:./images/use-guide/hbpaastause/bootstrap/hb_bootstrap_install.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image44]:./images/use-guide/hbpaastause/bootstrap/hb_bootstrap_director_add.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image45]:./images/use-guide/hbpaastause/cfdeployment/hb_cfdeployment_deployflow_azure_openstack.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image46]:./images/use-guide/hbpaastause/cfdeployment/hb_cfdeployment_stemcell_upload.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image47]:./images/use-guide/hbpaastause/cfdeployment/hb_cfdeployment_paasta_release.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image48]:./images/use-guide/hbpaastause/cfdeployment/hb_cfdeployment_defaultinfo.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image49]:./images/use-guide/hbpaastause/cfdeployment/hb_cfdeployment_networkinfo.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image50]:./images/use-guide/hbpaastause/cfdeployment/hb_cfdeployment_authinfo.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image51]:./images/use-guide/hbpaastause/cfdeployment/hb_cfdeployment_resourceinfo.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image52]:./images/use-guide/hbpaastause/cfdeployment/hb_cfdeployment_instanceinfo.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image53]:./images/use-guide/hbpaastause/cfdeployment/hb_cfdeployment_install.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image54]:./images/use-guide/hbpaastause/cfdeployment/hb_cfdeployment_paasta_release_5.0.png
[Hybrid_PaaSTa_Deploy_Use_Guide_Image55]:./images/use-guide/hbpaastause/cfdeployment/hb_cfdeployment_install_not_pair.png
