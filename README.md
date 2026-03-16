# 🗾 Palette Michi — AI 일본 여행 플래너

> **Gemini AI + Google Places API로 나만의 일본 여행 일정을 자동 생성하는 Flutter 앱**

<br>

## 📱 Overview

Palette Michi는 사용자의 여행 취향(카테고리·스타일·동행자·밀도)을 분석해
Firestore 장소 데이터베이스 + Google Places API 실시간 맛집 정보를 결합하고
Gemini 2.5 Flash AI가 완성된 여행 일정을 자동으로 생성해주는 앱입니다.

---

## ✨ Features

| 기능 | 설명 |
|------|------|
| AI 일정 생성 | Gemini 2.5 Flash 기반 완전 자동 이티너리 생성 |
| 취향 분석 | TripCategory 9종 × TripStyle 35종+ 조합 |
| 실시간 맛집 보강 | Google Places API (New) 연동 — 지역별 레스토랑·카페 실시간 fetch |
| 지역 그룹화 | 장소를 지리적 권역(Area)으로 묶어 이동 효율 최적화 |
| 밀도 조절 | 슬라이더(0.0~1.0)로 여행 빡빡함 커스터마이징 |
| 근교 포함 | 하코네·닛코 등 근교 당일치기 자동 포함 옵션 |
| 숙소 추천 | 권역 중심지 기준 숙소 자동 추천 |
| 일정 저장 | Firebase Firestore에 저장 / 불러오기 |
| 여행 타입 테스트 | 나의 여행 성향 진단 (Type 기능) |
| 지역 정보 | 날씨 · 환율 · 교통 · 쇼핑 정보 탭 |

---

## 🛠 Tech Stack

```
Flutter / Dart (SDK ^3.10.7)
├── State Management  : flutter_riverpod ^3.2.1 (StateNotifier + FutureProvider)
├── Backend           : Firebase Auth + Cloud Firestore
├── AI                : google_generative_ai ^0.4.7  (Gemini 2.5 Flash)
├── Places            : Google Places API (New) — nearbySearch / textSearch
├── Maps              : google_maps_flutter ^2.15.0
├── HTTP              : http ^1.6.0 / dio ^5.9.2
├── Image             : cached_network_image + Cloudinary
├── Font              : google_fonts (Noto Sans KR)
└── Env               : flutter_dotenv ^6.0.0
```

---

## 🏗 Architecture

### 핵심 플로우 (`lib/features/plan/`)

```
User Input
 └─ planProvider (StateNotifier)
      └─ PlanRequest (city / days / companion / categories / styles / density)

Recommendation
 └─ areaGroupProvider (FutureProvider)
      ├─ PlanRepository  → Firestore /places fetch
      └─ PlanService     → score & groupByArea → selectAreasForDays

Plan Generation  (planResultProvider)
 ├─ GooglePlacesService  → nearbySearch + textSearch (병렬 실행)
 └─ PlanGeneratorService → Gemini 프롬프트 빌드 → JSON 반환
      └─ { accommodations[], itinerary[{ day, area, schedule[] }] }
```

### 장소 점수 알고리즘

```
장소 점수 = (카테고리 점수 × 0.4) + (스타일 점수 × 0.6)
지역 점수 = (앵커 장소 × 0.6) + (나머지 평균 × 0.4)
```

Firestore 장소 문서의 `vibeScores` Map을 사용자 선택 키로 조회해 산정합니다.

### 디렉토리 구조

```
lib/
├── core/
│   ├── theme/          # AppColors
│   └── providers/
├── features/
│   ├── plan/           # 핵심 — 일정 생성 전체 파이프라인
│   │   ├── models/     # PlanRequest, PlaceModel, ItineraryModel
│   │   ├── services/   # PlanService, GooglePlacesService, PlanGeneratorService
│   │   ├── providers/  # planProvider, areaGroupProvider, planResultProvider
│   │   ├── repositories/
│   │   └── screens/    # 10개 스크린 (도시 선택 → 일정 결과)
│   ├── auth/           # Firebase 인증
│   ├── type/           # 여행 성향 테스트
│   ├── region/         # 지역 정보 & 즐겨찾기
│   ├── info/           # 날씨 · 환율 · 쇼핑
│   ├── mypage/         # 프로필 & 뱃지
│   └── memo/           # 여행 메모
├── screens/            # splash, menu, app_info
└── widgets/            # 공통 컴포넌트
```

---

## 🗺 TripCategory & TripStyle

| TripCategory | 주요 TripStyle 예시 |
|---|---|
| 🍣 gourmet | fineDining, omakase, localEats, streetFood, izakaya |
| ☕ cafe | dessertCafe, traditionalCafe, aestheticCafe, bakery |
| 📸 photo | streetSnap, architectureShot, nightView |
| 🏯 culture | templeVisit, traditionalCraft, historyExplore |
| 🎨 art | contemporaryArt, popCulture, museum |
| 🌿 nature | hiking, seaside, hotspring |
| 🛍 shopping | fashionHaul, vintageHunt, drugstoreRun |
| 🎡 activity | themepark, escape, sportsTry |
| 🏘 local | sentoBath, yokocho, morningMarket |

---

## 🔌 Google Places API 연동

카테고리별 `TripCategory → Places API type` 매핑으로
지역별 레스토랑 3개 + 카페 2개를 자동 fetch합니다.

도시별 특화 키워드 검색(일본어):
- **도쿄** — もんじゃ焼き, 立ち飲み
- **오사카** — たこ焼き, お好み焼き
- **교토** — 湯豆腐, おばんざい
- **공통** — ドン・キホーテ, 銭湯, 横丁, アニメイト

결과는 Gemini 프롬프트의 `food_and_lifestyle_nearby` 필드로 전달됩니다.
API 키 없음 / 호출 실패 시에도 DB만으로 일정 생성이 가능합니다 (graceful fallback).

---

## 🚀 Getting Started

### 1. 의존성 설치

```bash
flutter pub get
```

### 2. 환경 변수 설정

프로젝트 루트에 `.env` 파일을 생성하고 아래 키를 입력합니다.

```env
GEMINI_API_KEY=your_gemini_api_key
GOOGLE_PLACES_API_KEY=your_google_places_api_key
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
WEATHER_API_KEY=your_weather_api_key
RATE_API_KEY=your_exchange_rate_api_key
CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
CLOUDINARY_UPLOAD_PRESET=your_upload_preset
```

### 3. Firebase 설정

```
ios/Runner/GoogleService-Info.plist
android/app/google-services.json
```

Firebase 프로젝트에서 파일을 다운로드해 위 경로에 추가합니다.

### 4. 실행

```bash
flutter run
```

---

## 📦 Firestore 컬렉션 구조

```
/places          # 장소 DB (vibeScores, isAnchor, areaName 등)
/itineraries     # 저장된 여행 일정 (uid, request, itinerary[], accommodations[])
/users           # 사용자 프로필
```

---

## 🔑 Required API Keys

| API | 용도 | 획득처 |
|-----|------|--------|
| Gemini API | AI 일정 생성 | [Google AI Studio](https://aistudio.google.com/) |
| Google Places API (New) | 맛집·카페 실시간 검색 | [Google Cloud Console](https://console.cloud.google.com/) |
| Google Maps API | 지도 표시 | [Google Cloud Console](https://console.cloud.google.com/) |
| OpenWeather API | 날씨 정보 | [OpenWeatherMap](https://openweathermap.org/api) |

---

## 📄 License

This project is for portfolio purposes.
