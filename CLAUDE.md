# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with the EzVoca Flutter project.

## 🎯 프로젝트 개요

**EzVoca TOEFL 단어 학습 앱** - Flutter 기반 단어 암기 집중 앱

### 핵심 가치
- **단어 암기에 초집중**: 미세 UX로 학습 몰입도 극대화
- **정직한 학습**: Leech/애매 제외한 실제 암기 단어 수 표시
- **한 손 완결**: 스와이프만으로 모든 학습 완료

---

## 📅 개발 진행 상황 및 아키텍처 전환 (2025-08-20 업데이트)

### 🔄 **중요한 아키텍처 변경사항 - 완료됨** ✅
**SQLite 로컬 DB 제거** → **백엔드 API 중심 아키텍처 전환 완료**
- 모든 데이터는 백엔드 REST API를 통해 접근하도록 구조 변경 완료
- 로컬 데이터베이스 완전 제거 완료 (`lib/database/` 폴더 삭제)
- HTTP 클라이언트 인프라 구축 완료 (Dio, Flutter Secure Storage)
- 오프라인 기능은 최소한의 캐싱으로만 지원 예정

### ✅ **API 아키텍처 전환 작업 완료** (2025-08-20)

#### 1. **의존성 관리 및 정리**
- `pubspec.yaml`: ~~sqflite, path~~ 제거 완료 ✅
- `pubspec.yaml`: dio ^5.3.2, http ^1.1.0, flutter_secure_storage ^9.0.0 추가 완료 ✅
- SQLite 관련 모든 import 정리 완료 ✅

#### 2. **데이터베이스 레이어 완전 제거** 🗑️ 
- ~~`lib/database/` 폴더 전체 삭제~~ 완료 ✅
  - ~~`database_helper.dart`~~ 삭제
  - ~~`words_dao.dart`~~ 삭제
  - ~~`cards_dao.dart`~~ 삭제  
  - ~~`sample_data.dart`~~ 삭제
  - ~~`database_seeder.dart`~~ 삭제
- ~~`database_provider.dart`~~ 삭제 완료 ✅

#### 3. **API 서비스 레이어 구축** 🆕
- `lib/config/api_config.dart`: API 설정 및 엔드포인트 정의 ✅
- `lib/services/api_client.dart`: Dio 기반 HTTP 클라이언트, JWT 토큰 관리, 인터셉터 ✅
- `lib/services/word_service.dart`: 단어 관련 API 호출 서비스 ✅
- `lib/services/study_service.dart`: 학습 세션, 리뷰 제출 API 서비스 ✅

#### 4. **상태 관리 API 기반으로 전환** 🔄
- `lib/providers/api_provider.dart`: API 기반 Riverpod 프로바이더 구축 ✅
  - `apiClientProvider`: API 클라이언트 싱글톤 관리
  - `wordServiceProvider`, `studyServiceProvider`: 서비스 레이어 프로바이더
  - `authStateProvider`: 인증 상태 관리 (현재 false로 설정)
  - `learningCountersProvider`, `dailyStudyCardsProvider`: API 데이터 프로바이더
  - `ApiMutations` 클래스: 리뷰 제출, Leech 마킹 등 변경 작업 관리

#### 5. **UI 레이어 API 연동 준비**
- `main.dart`: API 대기 화면 표시, 인증되지 않은 상태에서 "백엔드 API 연동 대기 중" 메시지 ✅
- `HomePage`: API 기반 학습 통계 표시, 네트워크 상태 표시기 추가 ✅
- 인증 상태에 따른 조건부 UI 렌더링 구현 ✅

#### 6. **테스트 코드 API 기반으로 업데이트**
- `test/widget_test.dart`: API 프로바이더 모킹 테스트로 전환 완료 ✅
- 인증 상태별 UI 테스트 (API 대기 화면, 학습 통계 화면) 구현 완료 ✅
- 모든 테스트 통과 확인 완료 ✅

#### 7. **Git 저장소 업데이트**
- 모든 변경사항 커밋 및 `origin/main`에 푸시 완료 ✅
- 커밋 메시지: "Complete API architecture migration from SQLite to HTTP client infrastructure"

### 🔄 **현재 상태 (2025-08-20 기준)**
- **SQLite 기반 구조**: ~~100% 완료~~ → **완전 제거됨** ✅
- **API 기반 아키텍처**: **100% 완료** ✅ (백엔드 API 연동 대기 상태)
- **HTTP 클라이언트 인프라**: **100% 완료** ✅
- **JWT 토큰 관리**: **100% 완료** ✅
- **프로바이더 리팩토링**: **100% 완료** ✅
- **테스트 코드**: **100% 완료** ✅
- **핵심 UX 기능**: **0%** (백엔드 API 서버 연동 후 진행 예정)

### 🎯 **다음 작업 대기 중** (백엔드 API 서버 완성 후)
- JWT 인증 플로우 활성화 (`authStateProvider` → true)
- 실제 API 엔드포인트 연결 테스트
- 오프라인 캐싱 전략 구현
- 핵심 UX 기능 구현 (탭-투-리빌, 스와이프 제스처 등)

---

## 🤝 백엔드 팀 진행 상황 공유 (2025-08-20 업데이트)

### **📊 백엔드 현재 상태**
**Spring Boot 기본 뼈대 완성** - 핵심 엔티티 및 API 구현 필요

#### **✅ 백엔드 완료된 작업들**
1. **프로젝트 초기 설정** ✅
   - Spring Boot 3.5.4 + Gradle 설정 완료
   - PostgreSQL, Redis, Meilisearch, AWS S3 의존성 추가 완료
   - Flyway 마이그레이션 설정 완료

2. **데이터베이스 스키마 설계** ✅
   ```sql
   # /src/main/resources/db/migration/V1__Create_initial_tables.sql
   ✅ users 테이블 (OAuth 로그인, 프로필 관리)
   ✅ words 테이블 (단어, 발음, 정의, 난이도)
   ✅ examples 테이블 (예문, 번역)
   ✅ synonyms 테이블 (동의어)
   ✅ cards 테이블 (SRS 학습 카드, SM-2 알고리즘)
   ✅ reviews 테이블 (학습 기록, 리뷰 히스토리)
   ✅ daily_sets 테이블 (일일 학습 세트)
   ✅ daily_set_words 테이블 (세트-단어 연결)
   ✅ 성능 최적화 인덱스 설정
   ```

3. **환경 설정 및 배포 준비** ✅
   - `application.properties`: PostgreSQL, Redis, AWS S3 설정
   - JWT 시크릿 키 설정
   - AWS ECS Fargate 배포 아키텍처 설계 완료
   - Docker 컨테이너화 가이드 완료

#### **⏳ 백엔드 구현 필요 작업들**
1. **핵심 엔티티 구현** (최우선 - P1)
   ```java
   📋 구현 필요:
   src/main/java/com/ezvoca/server/entity/
   ├── User.java          # ✅ 완료
   ├── Word.java          # ❌ 구현 필요
   ├── Card.java          # ❌ 구현 필요
   ├── Review.java        # ❌ 구현 필요
   ├── DailySet.java      # ❌ 구현 필요
   ├── Example.java       # ❌ 구현 필요
   └── Synonym.java       # ❌ 구현 필요
   ```

2. **레포지토리 레이어 구현** (P1)
   ```java
   📋 구현 필요:
   src/main/java/com/ezvoca/server/repository/
   ├── WordRepository.java
   ├── CardRepository.java
   ├── ReviewRepository.java
   └── DailySetRepository.java
   ```

3. **JWT 인증 체계 구축** (P1)
   ```java
   📋 구현 필요:
   src/main/java/com/ezvoca/server/security/
   ├── SecurityConfig.java      # ❌ 구현 필요
   ├── JwtTokenProvider.java    # ❌ 구현 필요
   └── OAuth2LoginController.java # ❌ 구현 필요
   ```

4. **핵심 API 컨트롤러 구현** (P1)
   ```java
   📋 프론트엔드 대기 중인 API들:
   src/main/java/com/ezvoca/server/controller/
   ├── AuthController.java      # POST /api/auth/oauth/{provider}
   ├── WordController.java      # GET /api/words
   ├── StudyController.java     # GET /api/daily-sets, POST /api/reviews
   └── UserController.java      # GET /api/me/counters, POST /api/leech/{wordId}
   ```

### **🚨 백엔드 긴급 요청사항**
**프론트엔드가 API 연동 대기 중** - 백엔드 우선 구현 필요

#### **1단계: 최소 기능 구현 (1주 목표)**
- User, Word, Card, Review 엔티티 완성
- 기본 CRUD 레포지토리 구현
- 6개 핵심 API 엔드포인트 구현 (인증 제외)

#### **2단계: 인증 시스템 (1주 목표)**  
- JWT 인증 체계 완성
- OAuth (Google/Apple) 로그인 구현
- 보안 설정 완료

#### **3단계: 연동 테스트**
- 프론트엔드와 로컬 연동 테스트
- API 문서화 (Swagger)
- CORS 설정

### **📋 프론트엔드 → 백엔드 API 스펙 요청**
```json
# 프론트엔드에서 기대하는 API 응답 형식

GET /api/me/counters
{
  "totalWords": 1500,
  "learnedWords": 450,
  "leechWords": 23,
  "todayReviews": 15
}

GET /api/daily-sets  
{
  "id": 1,
  "name": "TOEFL Essential Day 1",
  "words": [
    {
      "id": 1,
      "word": "abundant",
      "pronunciation": "/əˈbʌndənt/",
      "partOfSpeech": "adjective", 
      "meaning": "existing in large quantities; plentiful"
    }
  ]
}

POST /api/reviews
Request: {
  "cardId": 123,
  "rating": 3,
  "responseTimeMs": 4500
}
Response: {
  "success": true,
  "nextReviewAt": "2025-08-21T10:30:00Z"
}
```

---

## 🚀 API 기반 아키텍처 전환 로드맵

### Phase 1: API 연동 기반 구축 (2-3주)
1. **백엔드 API 대기** ⏳
   - 백엔드에서 핵심 엔티티(Word, Card, Review) 구현 완료 대기
   - JWT 인증 체계 및 기본 API 엔드포인트 완성 대기

2. **프론트엔드 API 클라이언트 설정**
   ```yaml
   # pubspec.yaml 의존성 추가
   dependencies:
     http: ^1.1.0
     dio: ^5.3.2                    # 추천 (인터셉터, 캐싱 지원)
     flutter_secure_storage: ^9.0.0  # JWT 토큰 저장
   ```

3. **SQLite 관련 코드 제거**
   - `lib/database/` 폴더 전체 삭제
   - `pubspec.yaml`에서 `sqflite`, `path` 의존성 제거
   - 관련 import 구문 정리

4. **API 서비스 레이어 구현** (`lib/services/`)
   - `api_client.dart`: HTTP 클라이언트 설정, 인터셉터, 에러 핸들링
   - `auth_service.dart`: 로그인, JWT 토큰 관리
   - `word_service.dart`: 단어 관련 API 호출
   - `study_service.dart`: 학습 세션, 리뷰 제출 API

5. **상태 관리 API 기반으로 전환**
   - `database_provider.dart` → `api_provider.dart`
   - `study_session_provider.dart`: API 호출 기반으로 변경
   - 네트워크 상태 관리 및 로딩 상태 처리

6. **데이터 모델 API 스펙 맞춤**
   - 백엔드 API 응답 구조에 맞게 모델 수정
   - JSON 직렬화 코드 재생성

### Phase 2: 핵심 UX 기능 구현 (백엔드 API 완성 후)
7. **탭-투-리빌 (두 단계)**
8. **한 손 스와이프 제스처**
9. **고정 '정답 보기' 버튼**
10. **진행률 표시 (남은 개수)**

### Phase 3: 고급 기능 (API 연동 완료 후)
11. **오프라인 캐싱 전략** (SharedPreferences 기반 최소 캐싱)
12. **세션 스냅샷 (서버 동기화)**
13. **Leech API 연동** (`POST /api/leech/{wordId}`)
14. **정직 카운터 API 연동** (`GET /api/me/counters`)

### 🚨 **즉시 할 수 없는 작업**
- 백엔드 API가 완성될 때까지 대기해야 하는 작업들
- 현재 SQLite 기반 코드는 참고용으로만 활용

---

## 💻 개발 가이드

### 프로젝트 구조 (API 기반으로 재설계)
```
lib/
├── models/          # API 응답 모델 (수정 필요)
├── services/        # API 서비스 레이어 (신규)
├── providers/       # API 기반 상태 관리 (수정 필요)
├── routes/          # 라우팅 (유지)
├── config/          # API 설정, 환경변수 (신규)
├── widgets/         # 재사용 위젯 (TODO)
├── database/        # 🗑️ 제거 예정
└── main.dart        # 앱 엔트리 (API 연동으로 수정)
```

### 핵심 명령어
```bash
cd ezword_front
flutter pub get          # 의존성 설치
flutter analyze         # 정적 분석
flutter test            # 테스트 실행
flutter run -d chrome   # 웹에서 앱 실행
flutter run -d macos    # macOS에서 앱 실행
dart run build_runner build # JSON 코드 생성
```

### 상태 관리 패턴
- **Riverpod** 사용
- `StudySessionProvider`: 학습 로직
- `AppStateProvider`: 앱 전역 상태
- Computed providers로 UI 상태 분리

### UI/UX 가이드라인
- **포커스 모드**: 저자극 테마 자동 적용
- **고정 요소**: '정답 보기' 버튼 위치 절대 고정
- **진행률**: 퍼센트 대신 "남은 N개" 표시
- **제스처**: 스와이프 임계값 400px/s

---

## 🧪 테스트 전략
- 위젯 테스트: UI 동작 확인
- 단위 테스트: 비즈니스 로직 검증
- Provider 테스트: 상태 변화 검증
- 통합 테스트: 학습 플로우 E2E

---

## 🔧 기술 스택

### Frontend (Flutter) - API 기반
- **상태관리**: flutter_riverpod ^2.4.9
- **라우팅**: go_router ^13.2.0
- **HTTP 클라이언트**: dio ^5.3.2 (권장) 또는 http ^1.1.0
- **보안 저장소**: flutter_secure_storage ^9.0.0 (JWT 토큰)
- **JSON**: json_annotation + json_serializable
- ~~**로컬DB**: sqflite ^2.3.0~~ (제거)

### Backend API (연동 진행 중)
- Spring Boot 3 + JPA + PostgreSQL
- **인증**: JWT 기반 OAuth (Google/Apple)
- **주요 엔드포인트**:
  - `POST /api/auth/oauth/{provider}` - 로그인
  - `GET /api/words` - 단어 목록
  - `GET /api/daily-sets` - 오늘의 학습 세트
  - `POST /api/reviews` - 학습 결과 제출 (SRS 알고리즘)
  - `POST /api/leech/{wordId}` - 어려운 단어 처리
  - `GET /api/me/counters` - 학습 통계 (정직 카운터)

---

## 📋 핵심 기능 요구사항 (향후 구현)

### 카드/인터랙션 미세 UX
1. **탭-투-리빌(두 단계)** — 첫 탭: 첫 글자+품사만 블러, 두 번째 탭: 전체 의미 표시
2. **한 손 완결 스와이프** — 오른쪽=알았음, 왼쪽=몰랐음, 아래=애매
3. **자동 다크·저자극 모드** — 집중 세션 시 저자극 테마 자동 전환

### 못외운 단어 다루기
4. **Leech 스택 퀵 액션** — 왼쪽 길게 스와이프로 `POST /leech/{wordId}`
5. **정직 카운터** — Leech/애매 제외하고 지금까지 **정말** 외운 수 집계

### 세션 설계(몰입)
6. **진행률은 '남은 카드'만 크게** 표시
7. **중단 보존(세션 스냅샷)** — 앱 이탈 시 즉시 복원
8. **'정답 보기' 버튼 위치 고정** — 손이 기억하는 위치 절대 고정

---

## 🔒 보안 가이드라인

### 민감 정보 관리
- **API 키, 토큰**: `lib/config/secrets.dart`에 저장 (gitignore 처리됨)
- **환경 변수**: `.env` 파일 사용, 절대 커밋하지 않음
- **데이터베이스**: 개발용 더미 데이터만 커밋, 실제 사용자 데이터 제외
- **인증서**: `.p12`, `.pem` 등 모든 인증서 파일은 gitignore

### 절대 커밋하면 안 되는 것들
```
❌ API 키, 시크릿 토큰
❌ 실제 사용자 데이터 (단어, 학습 기록)  
❌ Firebase 설정 파일 (나중에 추가 시)
❌ 백엔드 연동 정보 (서버 URL, DB 접속 정보)
❌ 앱스토어/플레이스토어 인증서
```

### 안전한 개발 패턴
- 환경별 설정 파일 분리 (dev/prod)
- 더미 데이터는 `assets/sample_data/` 에서 관리
- API 엔드포인트는 환경변수로 주입
- 테스트용 토큰은 `.env.example`에 샘플만 제공

---

## 🚀 앱스토어 배포 전략 (2025-08-19)

### **앱 배포 아키텍처**

#### **모바일 앱 배포 (초기 저비용 전략)**
```yaml
초기 단계 (사용자 적음):
  - TestFlight (iOS) / Play Console 내부 테스트만 활용
  - Apple Developer: $99/년 (필수)
  - Google Play: $25 (일회성, 필수)
  
대안 배포 (더 저렴):
  - 웹 앱 우선: Flutter Web → GitHub Pages (무료)
  - Firebase Hosting: 무료 계층 (10GB 스토리지)
  - Netlify/Vercel: 무료 정적 호스팅
  
스토어 등록 연기:
  - 초기에는 웹 앱으로 MVP 검증
  - 사용자 확보 후 스토어 등록 고려
```

### **환경별 설정 관리**

#### **1. API 엔드포인트 환경 구분**
```dart
// lib/config/api_config.dart
class ApiConfig {
  static String get baseUrl {
    switch (Environment.current) {
      case Environment.local:
        return 'http://localhost:8080/api';
      case Environment.development:
        return 'https://dev-api.ezvoca.com/api';  
      case Environment.production:
        return 'https://api.ezvoca.com/api';
    }
  }
}

enum Environment {
  local,
  development, 
  production,
}
```

#### **2. 빌드 Flavor 설정**
```yaml
# android/app/build.gradle
flavorDimensions "environment"
productFlavors {
    local {
        applicationId "com.ezvoca.app.local"
        versionNameSuffix "-local"
    }
    production {
        applicationId "com.ezvoca.app"
    }
}
```

```dart
// lib/config/environment.dart
class Environment {
  static Environment get current {
    const flavor = String.fromEnvironment('FLUTTER_FLAVOR', defaultValue: 'local');
    switch (flavor) {
      case 'production':
        return Environment.production;
      case 'development':
        return Environment.development;
      default:
        return Environment.local;
    }
  }
}
```

#### **3. 보안 설정 (프로덕션)**
```dart
// lib/config/secrets.dart (gitignore 처리)
class Secrets {
  // ❌ 절대 커밋하지 않음
  static const String jwtSecret = 'PRODUCTION_JWT_SECRET';
  static const String apiKey = 'PRODUCTION_API_KEY';
}

// lib/config/secrets_example.dart (샘플 파일)
class Secrets {
  // 예시용 - 실제 값은 secrets.dart에 작성
  static const String jwtSecret = 'your-jwt-secret-here';
  static const String apiKey = 'your-api-key-here';
}
```

### **배포 파이프라인**

#### **자동 배포 (GitHub Actions)**
```yaml
# .github/workflows/deploy.yml
name: Deploy to App Stores

on:
  push:
    tags: ['v*']

jobs:
  ios-deploy:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - name: Build iOS
        run: |
          flutter build ios --release --flavor production
          # TestFlight 업로드 자동화
          
  android-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - name: Build Android
        run: |
          flutter build appbundle --release --flavor production
          # Play Console 업로드 자동화
```

#### **저비용 배포 명령어**
```bash
# 로컬 개발 빌드
flutter run --flavor local -d chrome  # 웹으로 테스트

# 웹 배포 (무료 호스팅)
flutter build web --release
# GitHub Pages
git subtree push --prefix build/web origin gh-pages
# 또는 Firebase Hosting
firebase deploy --only hosting

# 모바일 빌드 (스토어 등록시에만)
flutter build ios --release --flavor production
flutter build appbundle --release --flavor production
```

### **배포 체크리스트**

#### **🍎 iOS App Store**
- [ ] Apple Developer Program 가입 ($99/년)
- [ ] 인증서 및 프로비저닝 프로파일 설정
- [ ] App Store Connect에서 앱 정보 등록
- [ ] TestFlight β 테스트 → 스토어 심사

#### **🤖 Google Play Store** 
- [ ] Google Play Console 계정 생성 ($25)
- [ ] 키스토어 파일 생성 및 보안 관리
- [ ] Play Console에서 앱 정보 등록
- [ ] 내부 테스트 → 공개 릴리스

#### **📊 성능 모니터링 (무료/저비용)**
- **Flutter**: Google Analytics (무료) + 기본 에러 로깅
- **백엔드**: CloudWatch 기본 모니터링만 (상세 모니터링 비활성화)
- **사용자 피드백**: Google Forms 또는 이메일 (무료)

### **초기 저비용 전략**

#### **초기 단계 배포 비용 (연간)**
```yaml
필수 비용:
  - 도메인: $12-15/년 (Namecheap, GoDaddy)
  - SSL 인증서: 무료 (Let's Encrypt)
  
선택적 비용:
  - Apple Developer: $99/년 (iOS 앱 배포시에만)
  - Google Play: $25 (일회성, Android 앱 배포시에만)
  
AWS 인프라 (월 비용):
  - EC2 t3.micro: $10-15/월 (프리티어 종료 후)
  - RDS t3.micro: $15-20/월 (프리티어 종료 후)  
  - S3 + 데이터 전송: $5-10/월
  - 총합: $30-45/월 ($360-540/년)
```

#### **무료 대안 활용 전략**
```yaml
완전 무료 시작:
  - 웹 앱: GitHub Pages 호스팅 (무료)
  - 백엔드: Heroku 무료 계층 (제한적)
  - 데이터베이스: PostgreSQL Heroku Add-on (무료 계층)
  - 도메인: GitHub Pages 서브도메인 (무료)
  
저비용 업그레이드:
  - 사용자 50명 이하: 완전 무료
  - 사용자 100-500명: $20-30/월
  - 사용자 1000명+: AWS 프리티어 + $50/월
```

#### **마케팅 예산 (초기 제로 비용)**
- **SEO 최적화**: 무료 (직접 작업)
- **소셜 미디어**: 유기적 마케팅 (무료)
- **커뮤니티 마케팅**: Reddit, Discord (무료)
- **블로그**: Medium, 개인 블로그 (무료)
- **유튜브**: 영어 학습 채널 협업 (무료)