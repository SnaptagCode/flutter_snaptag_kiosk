---
marp: true
theme: default
paginate: true
author: 양 서린
style: |
    img[alt~="center"] {
        max-width: 85%;
        display: block;
        margin: 0 auto;
    }
    table {
        font-size: 0.7em;
        max-width: 100%;
    }
---

## 📌 **프로젝트 세팅 방법**
### 1️⃣ 레포지토리 클론 및 초기 세팅
- 레포지토리 Clone
- `assets/.env` 생성 및 환경 변수 설정

### 2️⃣ 필수 스크립트 실행
- **Flutter 프로젝트 설정**
  - `flutter create .` → 플랫폼 관련 설정 적용
  - `flutter pub get` → 의존성 설치
  - `dart run` → 실행

---

## 🛠️ **주요 기술 스택 및 외부 연동**
### 🔹 **Van사 연동 (결제 시스템)**
- **KSNET** 사용

### 🔹 **DLL 의존성**
- `labguard` → 비가시성 QR 
- `Luca` → 프린터

---

## 🔄 **전체 기능 Flow**
1️⃣ **앱 실행 → 머신 ID 입력**
   - 현재 활성화된 이벤트 불러오기
     - [/v1/machine/info](https://kiosk-dev-server.snaptag.co.kr/swagger#/Kiosk%20Machine/MachineController_getKioskMachineInfo)
     - [kioskInfoServiceProvider](https://github.com/SnaptagCode/flutter_snaptag_kiosk/blob/169e150987ecb3a94fe23f92718d94b238d633af/lib/data/datasources/cache/kiosk_info_service.dart)에서 [frontPhotoListProvider](https://github.com/SnaptagCode/flutter_snaptag_kiosk/blob/a9afee28ad199afcd6b70ad9988752ca12b51135/lib/features/move_me/providers/front_photo_list.dart)를 호출하여 이벤트에 종속된 **front 이미지**들을 로컬 저장하여 File타입으로 cache
     - [/v1/kiosk-event/front-photo-list](https://kiosk-dev-server.snaptag.co.kr/swagger#/Kiosk%20Event/KioskEventController_getFrontPhotoListByKioskEventId)

위 두 데이터가 정상적으로 저장되면 사용자 플로우 가능

---
2️⃣ **사용자 Flow** (Kiosk Windows App & QR Web 협업 형태)

| Windows App                                                         | QR Web                                                |
|---------------------------------------------------------------------|-------------------------------------------------------|
| **QR 화면 표시** <br>- 웹으로 이동할 수 있는 QR 코드 노출                            |                                                       |
|                                                                     | **백포토 선택 및 업로드** <br> - 커스텀 백포토 업로드 또는 기본 백포토 선택      |
|                                                                     | **4자리 인증번호 발급** <br> - 업로드 완료 후 4자리 인증번호 생성하여 리스폰스 반환 |
| **4자리 인증번호 입력 화면** <br> -유저가 QR 웹에서 받은 인증번호 입력                      |                                                       |
| **백포토 미리보기 & 결제 화면** <br> - 금액 확인 및 결제 진행<br>- QR 웹에서 업로드한 백포토 미리보기 |                                                       |
| **프린트 진행 화면**<br>- 인쇄 진행                                            |                                                       |

---

3️⃣ **결제 후 프린트까지 처리**
   - **백이미지에 Labguard 적용** (비가시성 QR)
   - **프린터 핸들링**
     - 랜덤한 front 이미지 + 백포토 인쇄
     - 인쇄 완료 후 최종 처리

---
``` mermaid
graph TD;
    SEVER -->|API 호출| WindowsApp;
    WindowsApp -->|결제 요청| VAN;
    VAN -->|승인 결과| WindowsApp;
    WindowsApp -->|프린트 요청| printer;
    WindowsApp -->|QR 표시| QRWeb;
    QRWeb -->|백포토 업로드| SEVER;
    QRWeb -->|4자리 인증번호 반환| WindowsApp;
```
---