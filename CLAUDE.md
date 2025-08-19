# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with the EzVoca Flutter project.

## 🎯 프로젝트 개요

**EzVoca TOEFL 단어 학습 앱** - Flutter 기반 단어 암기 집중 앱

### 핵심 가치
- **단어 암기에 초집중**: 미세 UX로 학습 몰입도 극대화
- **정직한 학습**: Leech/애매 제외한 실제 암기 단어 수 표시
- **한 손 완결**: 스와이프만으로 모든 학습 완료

---

## 📅 개발 진행 상황 (2025-08-19 업데이트)

### ✅ 완료된 뼈대 작업

#### 1. **프로젝트 초기 설정**
- `pubspec.yaml`: flutter_riverpod, go_router, sqflite, json_annotation 추가
- `build_runner`로 JSON 직렬화 코드 생성
- GitHub 저장소 설정 및 초기 커밋 완료

#### 2. **데이터 모델링 (`lib/models/`)**
- `word.dart`: Word, ConfusablePair 모델 + JSON 직렬화
- `card.dart`: Card 모델 + CardState, ReviewResult enum + JSON 직렬화
- `study_session.dart`: StudySession, StudySessionCard + RevealState, StudyMode enum

#### 3. **로컬 데이터베이스 (`lib/database/`)**
- `database_helper.dart`: SQLite 스키마 설계 및 데이터베이스 초기화
- `words_dao.dart`: 단어 CRUD 연산, 검색 기능, 임의 단어 선택
- `cards_dao.dart`: 카드 CRUD 연산, SRS 알고리즘, 일일 학습 카드 선택
- `sample_data.dart`: 15개 TOEFL 단어 샘플 데이터 (confusable pairs 포함)
- `database_seeder.dart`: 데이터베이스 초기화 및 샘플 데이터 시딩

#### 4. **상태 관리 (`lib/providers/`)**
- `study_session_provider.dart`: 학습 세션 로직 (탭-투-리빌, 포커스 모드, 데이터베이스 연동)
- `app_state_provider.dart`: 앱 테마, 오프라인 상태, 학습 통계 관리
- `database_provider.dart`: 데이터베이스 DAO 및 초기화 상태 관리

#### 5. **라우팅 (`lib/routes/`)**
- `app_router.dart`: go_router 기반 선언적 라우팅
- 경로: `/` (홈) → `/study` (학습) → `/study/card/:id` (카드 상세)

#### 6. **화면 구조**
- `main.dart`: 홈 화면 (학습 통계, 포커스 모드 토글, 실제 데이터베이스 연동)
- 학습 통계: 총 단어 수, 학습한 단어 수 실시간 표시

#### 7. **테스트 및 검증**
- `test/widget_test.dart`: 기본 위젯 테스트 및 라우팅 테스트 통과
- 데이터베이스 연동 테스트 완료
- 웹 브라우저에서 앱 실행 가능 확인

### 🔄 현재 상태
- **뼈대 구축**: 100% 완료 ✅
- **데이터베이스 레이어**: 100% 완료 ✅ 
- **핵심 UX 기능**: 0% (다음 단계)
- **테스트**: 모든 기본 테스트 통과 ✅

---

## 🚀 다음 우선순위 작업

### Phase 1: 뼈대 완성 ✅ (완료)
1. **로컬 데이터베이스 설정** ✅
   - SQLite 스키마 정의 및 초기화 완료
   - 단어/카드 데이터 CRUD 구현 완료
   - SRS (Spaced Repetition System) 알고리즘 적용
   
2. **기본 학습 세션 플로우** ✅
   - 실제 데이터베이스 데이터로 학습 플로우 구현
   - 세션 생성 → 카드 표시 → 결과 저장 완료
   - Riverpod 프로바이더로 데이터베이스 연동

### Phase 2: 핵심 UX 기능 (1주)
3. **탭-투-리빌 (두 단계)**
   - 첫 탭: 첫 글자+품사만 블러 처리
   - 두 번째 탭: 전체 의미 표시
   - `StudySessionProvider.revealCard()` 완성

4. **한 손 스와이프 제스처**
   - 우=알았음, 좌=몰랐음, 하=애매
   - `GestureDetector` + 속도 임계값 처리

5. **고정 '정답 보기' 버튼**
   - 화면 하단 중앙 고정 위치
   - iOS/Android SafeArea 대응

6. **진행률 표시 (남은 개수)**
   - AppBar 우측 Pill에 "남은 N개" 표시
   - 퍼센트 대신 절대 개수

### Phase 3: 고급 기능 (1주)
7. **세션 스냅샷 (중단 보존)**
8. **Leech 퀵 액션**
9. **자동 저자극 모드**
10. **정직 카운터 API 연동**

---

## 💻 개발 가이드

### 프로젝트 구조
```
lib/
├── models/          # 데이터 모델 (완료)
├── providers/       # 상태 관리 (완료)
├── routes/          # 라우팅 (완료)
├── database/        # 로컬 DB (완료)
├── widgets/         # 재사용 위젯 (TODO)
└── main.dart        # 앱 엔트리 (완료)
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

### Frontend (Flutter)
- **상태관리**: flutter_riverpod ^2.4.9
- **라우팅**: go_router ^13.2.0
- **로컬DB**: sqflite ^2.3.0
- **JSON**: json_annotation + json_serializable

### Backend API (향후 연동)
- Spring Boot 3 + JPA + PostgreSQL
- 주요 엔드포인트:
  - `GET /daily-sets` - 오늘의 학습 세트
  - `POST /reviews` - 학습 결과 제출  
  - `GET /me/counters?exclude=leech,ambiguous` - 정직 카운터

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