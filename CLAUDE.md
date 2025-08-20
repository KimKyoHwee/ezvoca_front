# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with the EzVoca Flutter project.

## 🎯 프로젝트 개요

**EzVoca TOEFL 단어 학습 앱** - Flutter 기반 단어 암기 집중 앱

### 핵심 가치
- **단어 암기에 초집중**: 미세 UX로 학습 몰입도 극대화
- **정직한 학습**: Leech/애매 제외한 실제 암기 단어 수 표시
- **한 손 완결**: 스와이프만으로 모든 학습 완료

---

## 📅 개발 진행 상황 및 아키텍처 전환 (2025-08-19 업데이트)

### 🔄 **중요한 아키텍처 변경사항**
**SQLite 로컬 DB 제거** → **백엔드 API 중심 아키텍처**
- 모든 데이터는 백엔드 REST API를 통해 접근
- 로컬 데이터베이스 완전 제거 예정
- 오프라인 기능은 최소한의 캐싱으로만 지원

### ✅ 완료된 작업 (재구성 예정)

#### 1. **프로젝트 초기 설정**
- `pubspec.yaml`: flutter_riverpod, go_router, ~~sqflite~~, json_annotation 추가
- `build_runner`로 JSON 직렬화 코드 생성
- GitHub 저장소 설정 및 초기 커밋 완료

#### 2. **데이터 모델링 (`lib/models/`)**
- `word.dart`: Word, ConfusablePair 모델 + JSON 직렬화 → **API 응답 모델로 변경 예정**
- `card.dart`: Card 모델 + CardState, ReviewResult enum + JSON 직렬화 → **API 응답 모델로 변경 예정**
- `study_session.dart`: StudySession, StudySessionCard + RevealState, StudyMode enum → **유지**

#### 3. ~~로컬 데이터베이스 (`lib/database/`)~~ → **🗑️ 제거 예정**
- ~~`database_helper.dart`: SQLite 스키마 설계 및 데이터베이스 초기화~~
- ~~`words_dao.dart`: 단어 CRUD 연산, 검색 기능, 임의 단어 선택~~
- ~~`cards_dao.dart`: 카드 CRUD 연산, SRS 알고리즘, 일일 학습 카드 선택~~
- ~~`sample_data.dart`: 15개 TOEFL 단어 샘플 데이터 (confusable pairs 포함)~~
- ~~`database_seeder.dart`: 데이터베이스 초기화 및 샘플 데이터 시딩~~

#### 4. **상태 관리 (`lib/providers/`)** → **API 기반으로 재구성**
- `study_session_provider.dart`: 학습 세션 로직 → **API 호출 기반으로 변경**
- `app_state_provider.dart`: 앱 테마, 오프라인 상태, 학습 통계 관리 → **유지**
- ~~`database_provider.dart`: 데이터베이스 DAO 및 초기화 상태 관리~~ → **API 프로바이더로 대체**

#### 5. **라우팅 (`lib/routes/`)**
- `app_router.dart`: go_router 기반 선언적 라우팅 → **유지**
- 경로: `/` (홈) → `/study` (학습) → `/study/card/:id` (카드 상세) → **유지**

#### 6. **화면 구조**
- `main.dart`: 홈 화면 → **API 연동으로 변경 필요**

#### 7. **테스트 및 검증**
- `test/widget_test.dart`: 기본 위젯 테스트 → **API 모킹 테스트로 변경 필요**

### 🔄 현재 상태
- **기존 로컬 DB 기반 구조**: 100% 완료 ✅ → **폐기 예정** ❌
- **API 기반 아키텍처**: 0% (새로 시작)
- **핵심 UX 기능**: 0% (API 연동 후 진행)
- **테스트**: 전면 재작성 필요

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

#### **모바일 앱 배포**
```yaml
iOS App Store:
  - Xcode 빌드 → TestFlight β → App Store 릴리스
  - 인증서: Apple Developer Program ($99/년)
  
Google Play Store:
  - Android Studio/CLI 빌드 → Play Console → 스토어 배포
  - 비용: $25 (일회성 등록비)
  
대안 배포:
  - 웹 앱: Flutter Web → AWS S3 + CloudFront 정적 호스팅
  - 데스크톱: Flutter Desktop (Windows/macOS/Linux)
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

#### **수동 배포 명령어**
```bash
# 로컬 개발 빌드
flutter run --flavor local

# 프로덕션 빌드
flutter build ios --release --flavor production
flutter build appbundle --release --flavor production

# 웹 배포 (선택사항)
flutter build web --release
aws s3 sync build/web s3://ezvoca-web-app
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

#### **📊 성능 모니터링**
- **Flutter**: Firebase Analytics + Crashlytics
- **백엔드**: AWS CloudWatch (ECS Fargate 연동)
- **사용자 피드백**: 인앱 피드백 시스템

### **비용 예상**

#### **앱 배포 비용**
- **Apple Developer**: $99/년
- **Google Play**: $25 (일회성)
- **AWS 인프라**: $50-500/월 (사용량 기반)
- **도메인**: $10-20/년
- **SSL 인증서**: AWS Certificate Manager (무료)

#### **마케팅 예산 (선택사항)**
- **App Store 최적화**: $0-1000
- **광고**: Google Ads, Apple Search Ads
- **소셜 미디어**: 유기적 마케팅