# PulseBoard
<p>A category-based micro SNS focused on limited and meaningful opinions</p>
PulseBoard는 트위터처럼 짧은 글로 의견을 나누는 미니 SNS입니다.
사용자가 직접 카테고리를 생성하고, 그 안에서 **제한된 수의 의견(Pulse)**을 공유합니다.

이 프로젝트는 상용 서비스가 아니라,
RxSwift · Combine · Firebase를 실제 앱 구조 안에서 학습하기 위한 포트폴리오 프로젝트입니다.



# Project Goal
PulseBoard는 다음을 목표로 합니다.
- RxSwift 기반 Reactive Programming 이해
- (확장) Combine과의 개념·사고방식 비교
- Firebase(Firestore, Auth)를 활용한 실제 데이터 흐름 설계
- MVVM 아키텍처에서 상태와 이벤트를 다루는 방식 학습

기능의 완성도보다, 왜 이런 구조를 선택했는지 설명할 수 있는 설계에 집중합니다.



# 🫀 Why “PulseBoard”?
- Pulse
  - 순간적인 생각, 반응, 의견
  - 길게 정제된 글이 아닌 지금의 생각
- Board
  - 무작위 타임라인이 아닌
  - 구조화된 의견 공간

PulseBoard = 순간적인 의견(Pulse)을
제한된 규칙 안에서 모으는 구조화된 공간(Board)

PulseBoard는
“많이 말하는 SNS”가 아니라 $\bf{\large{\color{#DD6565}“필요한\ 만큼만\ 말하는\ SNS”}}$
를 지향합니다.



# 🧠 Core Design Philosophy
## 1️⃣ 게시글(Pulse) 중심 설계
PulseBoard에서 가장 중요한 엔티티는 게시글(Pulse) 입니다.
- 게시글은 하나의 의견 이벤트
- 모든 사용자 액션은 이벤트 스트림으로 취급
- UI는 이 스트림의 결과를 반영

카테고리는 게시글을 담는 컨텍스트이며,
전역적인 분류 체계가 아닙니다.

## 2️⃣ 카테고리는 “주제 분류”가 아니다
PulseBoard의 카테고리는:
- ❌ 정규화된 전역 주제
- ❌ 완전한 중복 방지 대상

이 아니라,

✅ 의견이 모이는 하나의 판(thread)
<p>✅ 게시글 흐름을 묶는 최소 단위</p>

입니다.

PulseBoard는
“같은 주제의 모든 의견을 하나로 모으는 것”보다
<p>$\bf{\large{\color{#DD6565}“이\ 카테고리\ 안에서\ 어떤\ 의견\ 흐름이\ 있었는지”}}$에 집중합니다.</p>


# 🔒 Restriction Policy (Key Point)
PulseBoard의 모든 설계는 제한 정책을 중심으로 결정됩니다.


# 🔐 Authentication
- SNS 로그인 기반 인증 (Apple / Google 등)
- Email/Password 방식은 사용하지 않음
- 목적: 계정 무한 생성으로 인한 제한 정책 무력화 방지


# 🗂 Category Restrictions
- 유저당 생성 가능한 카테고리: 1개
- 카테고리 생성 제한은 1개월 기준으로 갱신
- 카테고리는 게시글을 담는 컨텍스트 역할만 수행


# ✍️ Post (Pulse) Restrictions
- 하루 작성 가능 게시글 수: 최대 3개
- 작성 제한은 매일 갱신
- 게시글(Pulse)은 PulseBoard의 핵심 콘텐츠


# 🛠 Tech Stack
- Platform: iOS (UIKit)
- Architecture: MVVM
- Reactive: RxSwift / RxCocoa
(일부 기능에서 Combine 비교 적용 예정)
- Backend: Firebase (Auth, Firestore)
- Dependency Management: Swift Package Manager


# 🧱 Firestore Data Model Design
PulseBoard의 데이터 모델은
게시글(Pulse) 중심 + 제한 정책 검증을 기준으로 설계됩니다.

## 👤 User (users)
```
{
  "uid": "string",
  "provider": "apple | google",
  "createdAt": "timestamp",

  "categoryCreatedAt": "timestamp",
  "dailyPostCount": 0,
  "dailyPostUpdatedAt": "timestamp"
}
```
설계 의도
- categoryCreatedAt → 1개월 기준 카테고리 생성 가능 여부 판단
- dailyPostCount, dailyPostUpdatedAt → 하루 3개 게시글 제한 검증

## 🗂 Category (categories)
```
{
  "id": "string",
  "ownerUid": "string",
  "title": "string",

  "createdAt": "timestamp",
  "postCount": 0
}
```
설계 의도
- 카테고리는 유저 소유
- 전역 유니크 강제 ❌
- 게시글 흐름을 묶는 컨텍스트 역할

## ✍️ Post / Pulse (posts)
```
{
  "id": "string",
  "categoryId": "string",
  "authorUid": "string",

  "content": "string",
  "createdAt": "timestamp"
}
```
설계 의도
- Pulse는 1급 엔티티
- 모든 피드는 게시글 기준으로 구성
- 카테고리는 참조 관계

## 🧱 Architecture Direction
PulseBoard는 단방향 데이터 흐름을 기반으로 설계됩니다.
```
User Action
 → ViewModel (Rx)
   → Restriction Validation
     → Firestore Write
       → Observable Stream
         → UI Update
```
- 제한 정책은 UI가 아닌 ViewModel / Repository 레벨에서 검증
- 데이터 변화는 스트림을 통해 UI에 반영


# 🚧 Project Status
- [x] 프로젝트 초기 세팅
- [x] Firebase 프로젝트 생성 및 iOS 앱 연동


# 📜 License
이 프로젝트는 MIT License 하에 배포됩니다.
<p>단, 앱 스토어 등록 후에는 No License로 변경될 수 있습니다.</p>


# 🤝 Contributing
기여는 환영합니다!
<p>PR(Pull Request) 전에는 이슈 등록 및 사전 토론을 먼저 진행해주세요.</p>

브랜치 전략
- main : 배포용
- develop : 개발 통합
- feature/* : 기능 단위 브랜치


# 📬 Contact
궁금한 점이나 제안이 있으시면 이슈를 열어주세요.
