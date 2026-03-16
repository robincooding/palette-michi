# 🗾 Palette Michi — 당신의 취향을 여행에 입히다

> **사용자 취향 기반 맞춤형 AI 여행 큐레이션 서비스**

<br>

## 📱 Overview

Palette Michi는 단순한 일정 생성을 넘어, 사용자의 고유한 취향(카테고리·스타일·동행자·밀도)을 심층 분석하여 여행의 전 과정을 설계하는 **End-to-End AI** 여행 플랫폼입니다.

단순히 장소를 나열하는 기존 서비스와 달리, 본 프로젝트는 다음과 같은 기술적 차별점을 가집니다:

* **Intelligent Itinerary Engine**: Firestore에 구축된 정밀 장소 데이터와 Google Places API의 실시간 데이터를 결합하고, Gemini 2.5 Flash 모델을 통해 사용자 최적화된 동선과 일정을 자동 생성합니다.

* **Context-Aware Information**: 일정 외에도 현지 날씨, 실시간 환율, 교통 패스 분석 및 쇼핑 정보 등 여행 준비에 필요한 모든 부가 정보를 컨텍스트에 맞게 통합 제공합니다.

* **User-Centric Architecture**: Flutter(Dart)를 기반으로 한 직관적인 UI/UX와 Riverpod 기반의 반응형 상태 관리를 통해 복잡한 여행 계획 과정을 매끄러운 사용자 경험으로 전환합니다.

---

## ✨ Core Features

| Category | Feature | Description |
|:---:|:---|:---|
| **AI Engine** | **Gemini 2.5 Flash Itinerary** | 사용자 취향 분석 데이터 기반의 100% 자동화된 맞춤형 이티너리 설계 |
| **Analysis** | **Multi-Dimensional Profiling** | TripCategory(9종) & TripStyle(35+종) 조합을 통한 정밀 성향 진단 및 타입 테스트 |
| **Optimization** | **Geospatial Clustering** | 지역별 장소 그룹화(Area Grouping)를 통한 이동 효율 극대화 및 동선 최적화 |
| **Utility**| **Transit Analyzer** | Sliding Window 알고리즘을 활용한 여정별 최적 교통 패스 추천 및 비용 절감액 계산 |
| **Real-time** | **Live Data Utility** | 오픈 API 연동을 통한 실시간 JPY 환율 계산기 및 일본 주요 도시별 5일 기상 예보 |
| **Data** | **Shopping & Specialty** | 편의점, 드럭스토어 등 카테고리별 필수 쇼핑 리스트 및 도시별 한정 특산품 정보 제공 |

---

## 🛠 Tech Stack

### Frontend & Language
* **Framework:** Flutter (SDK ^3.10.7) / Dart
* **State Management:** `flutter_riverpod` ^3.2.1 (StateNotifier + FutureProvider)
* **UI & Animation**: google_fonts, cached_network_image, CustomPainter (일본 지도 구현)

### AI & Data Intelligence
* **LLM:** `google_generative_ai` ^0.4.7 (Gemini 2.5 Flash)
* **Location Services:** Google Places API (New) — `nearbySearch` / `textSearch`
* **Maps:** `Maps_flutter` ^2.15.0

### Backend & Infrastructure
* **Database:** Cloud Firestore (NoSQL)
* **Authentication:** Firebase Authentication
* **Media:** Cloudinary (Image Optimization)

### Networking & Tools
* **HTTP Client:** `dio` ^5.9.2 / `http` ^1.6.0
* **Environment:** `flutter_dotenv` (Security-first API Key management)

---

## 🏗 Architecture & Logic

### 🔄 맞춤형 일정 추천 서비스 플로우 (`lib/features/plan/`)

사용자의 입력부터 최종 일정 생성까지의 파이프라인은 **Reactive State Management**를 기반으로 설계되었으며, 비즈니스 로직과 데이터 소스를 명확히 분리하여 유지보수성을 높였습니다.

* **User Input Layer:** `planProvider (StateNotifier)`를 통해 여행지, 기간, 동행자, 취향(Category/Style), 밀도 데이터를 캡처합니다.
* **Recommendation Layer:** `areaGroupProvider (FutureProvider)`가 Firestore에서 장소 데이터를 Fetch하고, 자체 알고리즘을 통해 지리적 권역(Area)별 점수를 산정하여 최적의 방문 지역을 선정합니다.
* **Generation Layer:** `planResultProvider` 내에서 `GooglePlacesService`가 실시간 데이터를 병렬(Parallel) Fetch하며, `PlanGeneratorService`가 Gemini 2.5 Flash를 호출하여 최종 JSON 이티너리를 빌드합니다.

---

### 🧪 맞춤형 추천 알고리즘 (Scoring Logic)

사용자의 성향과 장소의 특성을 정밀하게 매칭하기 위해 자체적인 가중치 산정 공식을 적용했습니다.

#### 1. 장소 적합도 점수 (Place Suitability Score)
Firestore의 `vibeScores` Map 데이터를 기반으로 사용자 선택 키워드와의 일치도를 계산합니다.
$$S_{place} = (Score_{category} \times 0.4) + (Score_{style} \times 0.6)$$

#### 2. 지역 우선순위 점수 (Area Priority Score)
개별 장소의 점수를 기반으로 해당 권역(Area)의 방문 가치를 판단하여 이동 동선을 최적화합니다.
$$S_{area} = (Score_{anchor} \times 0.6) + (\overline{Score}_{others} \times 0.4)$$
> **Note:** 핵심 랜드마크(Anchor)의 비중을 높게 두어 여행의 질을 보장하고 동선의 효율성을 극대화합니다.

---

### 🔄 실시간 정보 통합 파이프라인 (lib/features/info/)

단순 정보 나열이 아닌, 사용자의 현재 컨텍스트에 필요한 정보를 유기적으로 연결합니다.

* **Transit Analysis Logic**: `TransitCalculatorService`가 사용자의 전체 여정 비용과 Firestore의 패스 데이터를 대조합니다. 특히 **Sliding Window** 기법을 사용하여 패스 유효 기간 내 최대 효용 구간을 탐색하고 절약 금액을 산출합니다.

* **Exchange Rate Synchronization**: 한국수출입은행 API를 통해 비영업시간 예외 처리가 포함된 실시간 JPY 환율을 가져오며, `ExchangeCalculatorCard`를 통해 즉각적인 원화 환산 기능을 제공합니다.

* **Geospatial Weather Service**: `OpenWeather API`를 활용하여 위/경도 기반의 현재 날씨 및 향후 5일간의 예보 데이터를 `WeatherCard`에 시각화합니다.

---

### 🧪 교통비 최적화 알고리즘 (Transit Optimization)

사용자의 계획된 경로에서 발생하는 개별 요금 합계와 특정 교통 패스 사용 시의 기회비용을 비교합니다.

**1. 패스 절약액 계산 (Saving Calculation)**
$$Saving = TotalFare_{Individual} - (Price_{Pass} + Fare_{OutsideWindow})$$

**2. 최적 활성화 시점 탐색 (Sliding Window)**
패스 유효 기간($d$) 동안 개별 요금의 합이 최대가 되는 시작일($t$)을 결정합니다.

$$BestStartDay = \arg\max_{t} \sum_{i=t}^{t+d-1} Fare_{i}$$

---

## 📂 Directory Structure (Feature-First)

본 프로젝트는 확장성과 도메인 중심 설계를 위해 **Feature-First Layered Architecture**를 채택하였습니다.

```text
lib/
├── core/               # 앱 전역 설정 및 공유 프로바이더
│   ├── theme/          # AppColors, Design System
│   └── providers/      # Global State Providers
├── features/           # 도메인 중심 기능 단위 모듈
│   ├── plan/           # [Core] 일정 생성 전체 파이프라인
│   │   ├── models/     # PlanRequest, PlaceModel, ItineraryModel
│   │   ├── services/   # Scoring Logic, Gemini Prompt, Google Places API
│   │   ├── providers/  # plan, areaGroup, planResult Providers
│   │   ├── repositories/ # Firestore Data Access Layer
│   │   └── screens/    # 10-Step Planning UI (도시 선택 ~ 일정 결과)
│   ├── auth/           # Firebase Authentication
│   ├── type/           # 여행 성향 테스트 (Type System)
│   ├── region/         # 지역별 상세 정보 및 즐겨찾기
│   ├── info/           # 실시간 유틸리티 (날씨, 환율, 쇼핑 정보)
│   ├── mypage/         # 사용자 프로필 및 업적(뱃지) 관리
│   └── memo/           # 여행 기록 및 메모 기능
├── screens/            # 공통/독립 화면 (Splash, Main Menu, App Info)
└── widgets/            # 프로젝트 전역 재사용 UI 컴포넌트
```

---

## 🗺 Data Taxonomy

### TripCategory & TripStyle Matrix

사용자의 취향을 다각도로 분석하기 위해 **9개의 대분류(Category)**와 **35개 이상의 세부 스타일(Style)**을 계층적으로 구조화했습니다.

| TripCategory | 주요 TripStyle 예시 |
|---|---|
| 🍣 gourmet | fineDining, omakase, localEats, streetFood |
| ☕ cafe | aestheticCafe, traditional, dessertFocus, specialtyCoffee |
| 📸 photo | trending, hidden, nightscape, streetSnap |
| 🏯 culture | shrine, heritage, experience, machiya |
| 🎨 art | modernArt, architecture, museum, illustArt |
| 🌿 nature | onsen, scenic, countryside, hiking |
| 🛍 shopping | vintage, select, drugstore, department |
| 🎡 activity | anime, outdoor, workshop, themePark, sports |
| 🏘 local | residential, market, publicBath, neighborhood, izakayaBar |

---

## 🔌 Data Integration & Intelligence

### Google Places API (New) Enrichment

정적 데이터베이스(Firestore)의 한계를 극복하기 위해 실시간 장소 데이터를 동적으로 결합합니다.

* **Smart Mapping**: `TripCategory`를 Places API의 특정 `type`과 매핑하여 지역별 최적의 레스토랑(3개) 및 카페(2개)를 자동 Fetch합니다.

* **Localized Context Search**: 각 도시의 페르소나를 강화하기 위해 지역 특화 키워드(예: 도쿄-もんじゃ焼き, 오사카-たこ焼き)를 활용한 검색을 수행합니다.

* **Robust Error Handling & Graceful Fallback**: API 할당량 초과나 호출 실패 시에도 Firestore 내부 DB를 기반으로 끊김 없는 일정 생성을 보장합니다.

* **Data Injection**: 수집된 실시간 데이터는 Gemini 프롬프트의 `food_and_lifestyle_nearby` 필드로 주입되어 일정의 현지성(Locality)을 높입니다.

---

## 🚀 Getting Started

프로젝트를 로컬 환경에서 실행하기 위한 단계별 가이드입니다.

### 1. Prerequisites & Dependencies (의존성 설치)

```bash
flutter pub get
```

### 2. Environment Variables Setup (환경 변수 설정)

프로젝트 루트에 `.env` 파일을 생성하고 아래 API 키를 설정합니다.

```env
# AI & Location Services
GEMINI_API_KEY=your_gemini_api_key
GOOGLE_PLACES_API_KEY=your_google_places_api_key
GOOGLE_MAPS_API_KEY=your_google_maps_api_key

# External Data Utilities
WEATHER_API_KEY=your_weather_api_key
RATE_API_KEY=your_exchange_rate_api_key

# Media Management
CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
CLOUDINARY_UPLOAD_PRESET=your_upload_preset
```

### 3. Firebase Configuration (Firebase 설정)

Firebase 프로젝트 설정 후 설정 파일을 아래 경로에 배치합니다.

```
ios/Runner/GoogleService-Info.plist
android/app/google-services.json
```

Firebase 프로젝트에서 파일을 다운로드해 위 경로에 추가합니다.

### 4. Build & Run (실행)

```bash
flutter run
```

---

## 📦 Firestore Database Structure (Firestore 컬렉션 구조)

프로젝트의 데이터 모델은 확장성과 효율적인 쿼리를 위해 아래와 같이 설계되었습니다.

```
/places          # 장소 DB (vibeScores, isAnchor, areaName 등)
/itineraries     # 저장된 여행 일정 (uid, request, itinerary[], accommodations[])
/transit_passes  # 도시별 교통 패스 정보 DB (가격, 유효 기간, 이용 범위 등)
/users           # 사용자 프로필 및 개인 설정 정보
```

---

## 🔑 Required API Keys

| API | 용도 | 획득처 |
|-----|------|--------|
| Gemini API | AI 일정 생성 | [Google AI Studio](https://aistudio.google.com/) |
| Google Places API (New) | 맛집·카페 실시간 검색 | [Google Cloud Console](https://console.cloud.google.com/) |
| Google Maps API | 지도 표시 | [Google Cloud Console](https://console.cloud.google.com/) |
| OpenWeather API | 날씨 정보 | [OpenWeatherMap](https://openweathermap.org/api) |
| Korea Exim Bank API | 실시간 환율 (한국수출입은행) | [한국수출입은행 Open API](https://www.koreaexim.go.kr/ir/HPHKIR020M01?apino=2) |

---

## 📄 License

This project is for portfolio purposes as part of the "Palette Michi" development.
