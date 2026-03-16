// lib/features/info/services/transit_calculator_service.dart
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── 근교 고정 요금 테이블 ─────────────────────────────────────
class _SuburbanRoute {
  final String city;
  final String name;
  final LatLng anchor;
  final int fare;
  final String note;

  const _SuburbanRoute({
    required this.city,
    required this.name,
    required this.anchor,
    required this.fare,
    this.note = '',
  });
}

const List<_SuburbanRoute> _suburbanRoutes = [
  // 도쿄 근교
  _SuburbanRoute(
    city: '도쿄',
    name: '나리타공항(NEX)',
    anchor: LatLng(35.768, 140.386),
    fare: 3070,
    note: 'N\'EX 도쿄역 기준',
  ),
  _SuburbanRoute(
    city: '도쿄',
    name: '하네다공항(모노레일)',
    anchor: LatLng(35.553, 139.747),
    fare: 500,
    note: '하마마츠초 기준',
  ),
  _SuburbanRoute(
    city: '도쿄',
    name: '닛코역',
    anchor: LatLng(36.391, 139.712),
    fare: 3530,
    note: '신주쿠 기준 JR 특급',
  ),
  _SuburbanRoute(
    city: '도쿄',
    name: '가와구치코역',
    anchor: LatLng(35.503, 138.769),
    fare: 2600,
    note: '신주쿠 기준 특급',
  ),
  _SuburbanRoute(
    city: '도쿄',
    name: '가마쿠라역',
    anchor: LatLng(35.318, 139.548),
    fare: 950,
    note: 'JR 요코스카선',
  ),
  _SuburbanRoute(
    city: '도쿄',
    name: '에노시마역',
    anchor: LatLng(35.297, 139.488),
    fare: 1100,
    note: 'JR + 에노덴',
  ),
  _SuburbanRoute(
    city: '도쿄',
    name: '요코하마역',
    anchor: LatLng(35.444, 139.638),
    fare: 480,
    note: 'JR 도카이도선',
  ),

  // 나고야 근교
  _SuburbanRoute(
    city: '나고야',
    name: '중부국제공항(뮤스카이)',
    anchor: LatLng(34.858, 136.804),
    fare: 1430,
    note: '나고야역 기준',
  ),
  _SuburbanRoute(
    city: '나고야',
    name: '이누야마역',
    anchor: LatLng(35.380, 136.949),
    fare: 630,
    note: 'JR 쾌속',
  ),
  _SuburbanRoute(
    city: '나고야',
    name: '기후역',
    anchor: LatLng(35.423, 136.762),
    fare: 1500,
    note: 'JR 특급',
  ),
  _SuburbanRoute(
    city: '나고야',
    name: '타카야마역',
    anchor: LatLng(36.017, 137.256),
    fare: 8340,
    note: 'HIDA 특급 편도',
  ),
  _SuburbanRoute(
    city: '나고야',
    name: '시라카와고',
    anchor: LatLng(36.267, 136.902),
    fare: 6500,
    note: 'HIDA 경유 추정',
  ),

  // 오사카 근교
  _SuburbanRoute(
    city: '오사카',
    name: '간사이공항(라피트)',
    anchor: LatLng(34.427, 135.244),
    fare: 1190,
    note: '난바 기준',
  ),
  _SuburbanRoute(
    city: '오사카',
    name: '나라역',
    anchor: LatLng(34.685, 135.830),
    fare: 810,
    note: 'JR 야마토지선',
  ),
  _SuburbanRoute(
    city: '오사카',
    name: '고베 산노미야역',
    anchor: LatLng(34.691, 135.194),
    fare: 410,
    note: 'JR 특급',
  ),
  _SuburbanRoute(
    city: '오사카',
    name: '유니버설시티역',
    anchor: LatLng(34.667, 135.437),
    fare: 180,
    note: 'JR 유메사키선',
  ),
  _SuburbanRoute(
    city: '오사카',
    name: '헤이조쿄',
    anchor: LatLng(34.619, 135.786),
    fare: 680,
    note: 'JR/긴테츠 추정',
  ),

  // 교토 근교
  _SuburbanRoute(
    city: '교토',
    name: '우지역',
    anchor: LatLng(34.883, 135.803),
    fare: 240,
    note: 'JR 나라선 교토역 기준',
  ),
  _SuburbanRoute(
    city: '교토',
    name: '오사카 연계',
    anchor: LatLng(35.021, 135.764),
    fare: 580,
    note: 'JR 신쾌속',
  ),
  _SuburbanRoute(
    city: '교토',
    name: '아라시야마역',
    anchor: LatLng(35.017, 135.672),
    fare: 240,
    note: 'JR 사가아라시야마선',
  ),

  // 후쿠오카 근교
  _SuburbanRoute(
    city: '후쿠오카',
    name: '후쿠오카공항',
    anchor: LatLng(33.585, 130.451),
    fare: 260,
    note: '하카타역 기준 지하철',
  ),
  _SuburbanRoute(
    city: '후쿠오카',
    name: '다자이후역',
    anchor: LatLng(33.522, 130.535),
    fare: 400,
    note: '니시테츠 후쓰카이치 경유',
  ),
  _SuburbanRoute(
    city: '후쿠오카',
    name: '야나가와역',
    anchor: LatLng(33.165, 130.407),
    fare: 900,
    note: '니시테츠 특급',
  ),
  _SuburbanRoute(
    city: '후쿠오카',
    name: '이토시마',
    anchor: LatLng(33.556, 130.198),
    fare: 420,
    note: 'JR 지쿠히선',
  ),
  _SuburbanRoute(
    city: '후쿠오카',
    name: '기타큐슈 코쿠라',
    anchor: LatLng(33.884, 130.875),
    fare: 1290,
    note: 'JR 신칸센 제외 재래선',
  ),

  // 삿포로 근교
  _SuburbanRoute(
    city: '삿포로',
    name: '신치토세공항',
    anchor: LatLng(42.775, 141.692),
    fare: 1150,
    note: 'JR 쾌속 에어포트',
  ),
  _SuburbanRoute(
    city: '삿포로',
    name: '오타루역',
    anchor: LatLng(43.190, 140.994),
    fare: 750,
    note: 'JR 하코다테본선',
  ),
  _SuburbanRoute(
    city: '삿포로',
    name: '노보리베쓰역',
    anchor: LatLng(42.468, 141.105),
    fare: 2500,
    note: 'JR 특급 스즈란',
  ),
  _SuburbanRoute(
    city: '삿포로',
    name: '도야역',
    anchor: LatLng(42.554, 140.816),
    fare: 3000,
    note: 'JR 특급',
  ),
  _SuburbanRoute(
    city: '삿포로',
    name: '후라노역',
    anchor: LatLng(43.340, 142.383),
    fare: 2590,
    note: 'JR 특급 라벤더',
  ),

  // 가고시마 근교
  _SuburbanRoute(
    city: '가고시마',
    name: '사쿠라지마 항구',
    anchor: LatLng(31.581, 130.658),
    fare: 200,
    note: '가고시마항 페리 편도',
  ),
  _SuburbanRoute(
    city: '가고시마',
    name: '이부스키역',
    anchor: LatLng(31.253, 130.634),
    fare: 1020,
    note: 'JR 이부스키마쿠라자키선',
  ),
  _SuburbanRoute(
    city: '가고시마',
    name: '기리시마진구역',
    anchor: LatLng(31.892, 130.830),
    fare: 920,
    note: 'JR 닛포본선',
  ),

  // 시즈오카 근교
  _SuburbanRoute(
    city: '시즈오카',
    name: '후지산역(가와구치코)',
    anchor: LatLng(35.503, 138.769),
    fare: 2650,
    note: '시즈오카역 → 후지산역 버스',
  ),
  _SuburbanRoute(
    city: '시즈오카',
    name: '아타미역',
    anchor: LatLng(35.099, 139.074),
    fare: 980,
    note: 'JR 도카이도선',
  ),
  _SuburbanRoute(
    city: '시즈오카',
    name: '이토역',
    anchor: LatLng(34.972, 139.098),
    fare: 1340,
    note: 'JR 이토선',
  ),

  // 오키나와 근교
  _SuburbanRoute(
    city: '오키나와',
    name: '추라우미 수족관',
    anchor: LatLng(26.694, 127.878),
    fare: 2500,
    note: '나하 버스터미널 기준 고속버스',
  ),
  _SuburbanRoute(
    city: '오키나와',
    name: '류큐무라',
    anchor: LatLng(26.567, 127.893),
    fare: 1500,
    note: '나하 버스터미널 기준',
  ),
  _SuburbanRoute(
    city: '오키나와',
    name: '나하공항',
    anchor: LatLng(26.196, 127.646),
    fare: 270,
    note: '유이레일 공항~나하 시내',
  ),
];

// ── 도시별 거리 보정 계수 ─────────────────────────────────────
// 직선거리 × 계수 → 실제 노선 거리 추정
const Map<String, double> _cityDistCoeff = {
  '도쿄': 1.40, // 환승 많음, 지하철 밀도 높음
  '오사카': 1.30, // JR 직통 많음
  '교토': 1.30, // JR 직통 많음
  '나고야': 1.25, // 메이테츠 직선적
  '후쿠오카': 1.25, // 지하철 3개 노선, 비교적 직선적
  '삿포로': 1.25, // 지하철 3개 노선, 직선적
  '가고시마': 1.20, // 소규모 도시, 트램 중심
  '시즈오카': 1.20, // 시즈테츠 직선 노선
  '오키나와': 1.15, // 유이레일 직선 모노레일
};

// ── 도시별 IC카드 요금 테이블 (노선 거리 km → 엔, 2026 기준) ──
class _FareBand {
  final double maxKm;
  final int fare;
  const _FareBand(this.maxKm, this.fare);
}

const Map<String, List<_FareBand>> _cityFareTables = {
  '도쿄': [
    _FareBand(6, 180),
    _FareBand(11, 210),
    _FareBand(16, 240),
    _FareBand(21, 270),
    _FareBand(26, 300),
    _FareBand(double.infinity, 330),
  ],
  '오사카': [
    _FareBand(6, 210),
    _FareBand(11, 280),
    _FareBand(16, 320),
    _FareBand(21, 370),
    _FareBand(26, 420),
    _FareBand(double.infinity, 470),
  ],
  '교토': [
    _FareBand(6, 220),
    _FareBand(11, 260),
    _FareBand(16, 310),
    _FareBand(21, 360),
    _FareBand(26, 410),
    _FareBand(double.infinity, 460),
  ],
  '나고야': [
    _FareBand(6, 200),
    _FareBand(11, 250),
    _FareBand(16, 300),
    _FareBand(21, 350),
    _FareBand(26, 400),
    _FareBand(double.infinity, 450),
  ],
  '후쿠오카': [
    _FareBand(6, 210),
    _FareBand(11, 260),
    _FareBand(16, 300),
    _FareBand(21, 340),
    _FareBand(26, 380),
    _FareBand(double.infinity, 420),
  ],
  '삿포로': [
    _FareBand(6, 210),
    _FareBand(11, 250),
    _FareBand(16, 290),
    _FareBand(21, 330),
    _FareBand(26, 370),
    _FareBand(double.infinity, 410),
  ],
  '가고시마': [
    _FareBand(6, 180),
    _FareBand(11, 220),
    _FareBand(16, 260),
    _FareBand(21, 300),
    _FareBand(26, 340),
    _FareBand(double.infinity, 370),
  ],
  '시즈오카': [
    _FareBand(6, 200),
    _FareBand(11, 250),
    _FareBand(16, 300),
    _FareBand(21, 350),
    _FareBand(26, 400),
    _FareBand(double.infinity, 450),
  ],
  '오키나와': [
    _FareBand(6, 230),
    _FareBand(11, 270),
    _FareBand(16, 310),
    _FareBand(21, 350),
    _FareBand(26, 390),
    _FareBand(double.infinity, 430),
  ],
};

// ── 도시별 버스 균일 요금 ─────────────────────────────────────
const Map<String, int> _cityBusFlatFare = {
  '도쿄': 210,
  '오사카': 230,
  '교토': 230,
  '나고야': 210,
  '후쿠오카': 230,
  '삿포로': 210,
  '가고시마': 180, // 트램 균일 요금 기준
  '시즈오카': 220,
  '오키나와': 240,
};

// ── 장거리 fallback 요금 추정 공식 상수 ──────────────────────
// 35km 초과·근교 anchor 미매칭 구간에 적용
// 기본 특급료 + 거리당 가중치
const int _longDistanceBase = 1000; // 기본 특급료 추정
const double _longDistancePerKm = 25.0; // km당 추가 요금
const int _longDistanceMax = 5000; // 상한 (신칸센 제외 구간 기준)

// ── 도시 중심 좌표 (좌표 sanity check용) ────────────────────
const Map<String, LatLng> _cityCenters = {
  '도쿄': LatLng(35.6895, 139.6917),
  '오사카': LatLng(34.6937, 135.5023),
  '교토': LatLng(35.0116, 135.7681),
  '나고야': LatLng(35.1815, 136.9066),
  '후쿠오카': LatLng(33.5904, 130.4017),
  '삿포로': LatLng(43.0618, 141.3545),
  '가고시마': LatLng(31.5602, 130.5581),
  '시즈오카': LatLng(34.9756, 138.3827),
  '오키나와': LatLng(26.2124, 127.6792),
};
const double _cityRadiusKm = 120.0; // 도심 반경 120km 초과 시 잘못된 좌표로 간주 (근교 포함)

// ─────────────────────────────────────────────────────────────

class TransitCalculatorService {
  final Dio _dio = Dio();
  final String _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  String _currentCity = '도쿄';

  final Map<String, LatLng?> _coordCache = {};

  // ── 1. 좌표 Resolve ──────────────────────────────────────
  Future<LatLng?> _resolveCoordinate(Map<String, dynamic> slot) async {
    if (slot['lat'] != null && slot['lng'] != null) {
      final LatLng coord = LatLng(
        (slot['lat'] as num).toDouble(),
        (slot['lng'] as num).toDouble(),
      );
      // DB 좌표도 sanity check (잘못 저장된 경우 방어)
      return _isWithinCityRadius(coord) ? coord : null;
    }

    final String placeName = (slot['place_name'] as String? ?? '').trim();
    if (placeName.isEmpty) return null;

    if (_coordCache.containsKey(placeName)) return _coordCache[placeName];

    // 도시명을 검색어에 포함해 엉뚱한 좌표 반환 방지
    final String cityLabel = _normalizeCity(_currentCity).replaceAll(' 근교', '');
    final String query = '$placeName $cityLabel Japan';

    try {
      final response = await _dio.post(
        'https://places.googleapis.com/v1/places:searchText',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': _apiKey,
            'X-Goog-FieldMask': 'places.location',
          },
        ),
        data: {
          'textQuery': query,
          'languageCode': 'ja', // 일본어 우선 — 일본 장소 정확도 향상
        },
      );

      final places = response.data['places'] as List?;
      if (places != null && places.isNotEmpty) {
        final loc = places[0]['location'];
        final LatLng result = LatLng(
          (loc['latitude'] as num).toDouble(),
          (loc['longitude'] as num).toDouble(),
        );

        // sanity check: 도시 중심에서 50km 초과 시 잘못된 결과로 간주
        if (!_isWithinCityRadius(result)) {
          print('좌표 sanity check 실패 (도시 범위 초과): $placeName → $result');
          _coordCache[placeName] = null;
          return null;
        }

        _coordCache[placeName] = result;
        return result;
      }
    } catch (e) {
      print('Places API Resolve 실패: $placeName — $e');
    }

    _coordCache[placeName] = null;
    return null;
  }

  // 도시 중심 반경 내 좌표인지 확인
  bool _isWithinCityRadius(LatLng coord) {
    final String city = _normalizeCity(_currentCity);
    final LatLng? center = _cityCenters[city];
    if (center == null) return true; // 알 수 없는 도시는 통과
    return _haversineKm(coord, center) <= _cityRadiusKm;
  }

  // ── 2. Haversine 직선거리 (km) ───────────────────────────
  double _haversineKm(LatLng a, LatLng b) {
    const double r = 6371.0;
    final double dLat = _deg2rad(b.latitude - a.latitude);
    final double dLng = _deg2rad(b.longitude - a.longitude);
    final double h =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(a.latitude)) *
            cos(_deg2rad(b.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    return r * 2 * atan2(sqrt(h), sqrt(1 - h));
  }

  double _deg2rad(double deg) => deg * pi / 180;

  // ── 3. 도시명 정규화 ─────────────────────────────────────
  String _normalizeCity(String city) {
    for (final key in _cityFareTables.keys) {
      if (city.contains(key)) return key;
    }
    return '도쿄';
  }

  // ── 4. 구간 요금 추정 (휴리스틱) ────────────────────────
  int _estimateSegmentFare(LatLng origin, LatLng destination) {
    final double straightKm = _haversineKm(origin, destination);
    final String city = _normalizeCity(_currentCity);

    // 도보 거리 (1.5km 미만 — 같은 권역 내 이동 흡수)
    if (straightKm < 1.5) return 0;

    // 도심 구간 (30km 이하)
    if (straightKm <= 30.0) {
      final double coeff = _cityDistCoeff[city] ?? 1.35;
      final double railKm = straightKm * coeff;

      // 단거리 → 버스 균일 요금
      if (railKm < 3.0) return _cityBusFlatFare[city] ?? 210;

      return _lookupUrbanFare(railKm, city);
    }

    // 30km 초과 → 근교 anchor 룩업
    final _SuburbanRoute? matched = _lookupSuburbanRoute(destination, city);
    if (matched != null) return matched.fare;

    // anchor 미매칭 → 장거리 fallback 추정
    final int fallback = (_longDistanceBase + straightKm * _longDistancePerKm)
        .round()
        .clamp(0, _longDistanceMax);
    return fallback;
  }

  // 근교 anchor 룩업: 도시 필터 후 10km 이내 가장 가까운 anchor
  _SuburbanRoute? _lookupSuburbanRoute(LatLng destination, String city) {
    _SuburbanRoute? closest;
    double minDist = double.infinity;

    for (final route in _suburbanRoutes) {
      if (!route.city.contains(city)) continue;
      final double dist = _haversineKm(destination, route.anchor);
      if (dist < minDist) {
        minDist = dist;
        closest = route;
      }
    }

    return (closest != null && minDist <= 10.0) ? closest : null;
  }

  // 도시별 요금 테이블 룩업
  int _lookupUrbanFare(double railKm, String city) {
    final List<_FareBand> bands =
        _cityFareTables[city] ?? _cityFareTables['도쿄']!;
    for (final band in bands) {
      if (railKm <= band.maxKm) return band.fare;
    }
    return bands.last.fare;
  }

  // ── 5. 숙소 좌표 매핑 (다박 대응) ───────────────────────
  Future<Map<int, LatLng>> _resolveAccommodationMap(
    List<dynamic> accommodations,
  ) async {
    final Map<int, LatLng> dayToHotel = {};

    for (final acc in accommodations) {
      final Map<String, dynamic> accMap = acc is Map<String, dynamic>
          ? acc
          : (acc as dynamic).toJson() as Map<String, dynamic>;

      final String hotelName =
          (accMap['nearest_station'] as String? ?? '').isNotEmpty
          ? accMap['nearest_station'] as String
          : (accMap['area'] as String? ?? '');

      if (hotelName.isEmpty) continue;

      final LatLng? coords = await _resolveCoordinate({
        'place_name': hotelName,
      });
      if (coords == null) continue;

      final String nightsStr = accMap['nights'] as String? ?? '';
      final List<int> nums = RegExp(
        r'\d+',
      ).allMatches(nightsStr).map((m) => int.parse(m.group(0)!)).toList();

      if (nums.length == 2) {
        for (int i = nums[0]; i <= nums[1]; i++) dayToHotel[i] = coords;
      } else if (nums.length == 1) {
        dayToHotel[nums[0]] = coords;
      } else {
        dayToHotel[0] = coords;
      }
    }

    return dayToHotel;
  }

  // ── 6. 메인 계산 ─────────────────────────────────────────
  // 설계 원칙:
  //   - 숙소 좌표는 권역 기준점으로만 활용, 구간 계산에 포함하지 않음
  //     (숙소 출발·귀환을 매일 구간으로 잡으면 이중 계산)
  //   - 슬롯 간 이동만 계산: 슬롯1→슬롯2→...→슬롯N
  //   - 하루 최대 탑승 횟수 캡: 현실적으로 6회 초과 드묾
  Future<Map<String, dynamic>> calculatePlanFareResult(
    List<dynamic> itinerary,
    List<dynamic> accommodations,
    String cityName,
  ) async {
    _currentCity = cityName;

    const int maxDailyRides = 6; // 하루 최대 구간 수 캡

    final List<int> dailyFares = [];
    int incompleteSegments = 0;

    final hotelMap = await _resolveAccommodationMap(accommodations);

    for (final dayData in itinerary) {
      final Map<String, dynamic> dayMap = dayData is Map<String, dynamic>
          ? dayData
          : (dayData as dynamic).toJson() as Map<String, dynamic>;

      final int day = switch (dayMap['day']) {
        int d => d,
        double d => d.toInt(),
        String s => int.tryParse(s) ?? 1,
        _ => 1,
      };

      final List<dynamic> schedule = dayMap['schedule'] as List<dynamic>? ?? [];
      if (schedule.isEmpty) {
        dailyFares.add(0);
        continue;
      }

      final List<LatLng?> resolvedCoords = await Future.wait(
        schedule.map((slot) {
          final slotMap = slot is Map<String, dynamic>
              ? slot
              : (slot as dynamic).toJson() as Map<String, dynamic>;
          return _resolveCoordinate(slotMap);
        }),
      );

      // 유효 좌표만 추출 (숙소 제외 — 슬롯 간 이동만 계산)
      final List<LatLng> points = resolvedCoords.whereType<LatLng>().toList();

      // 좌표가 없으면 숙소 권역 기준 평균 요금으로 fallback
      if (points.isEmpty) {
        final LatLng? hotel = hotelMap[day] ?? hotelMap[0];
        if (hotel != null) {
          // 숙소 권역 기준 하루 평균 이동 추정 (4회 × 도심 기본 요금)
          final int baseFare =
              _cityFareTables[_normalizeCity(cityName)]?[1].fare ?? 210;
          dailyFares.add(baseFare * 4);
        } else {
          dailyFares.add(0);
        }
        continue;
      }

      // 구간별 요금 계산
      final List<int> segmentFares = [];
      for (int i = 0; i < points.length - 1; i++) {
        segmentFares.add(_estimateSegmentFare(points[i], points[i + 1]));
      }

      // 하루 최대 탑승 횟수 캡 적용
      // 요금 높은 구간 우선 (가장 현실적인 이동만 남김)
      if (segmentFares.length > maxDailyRides) {
        segmentFares.sort((a, b) => b.compareTo(a));
        segmentFares.removeRange(maxDailyRides, segmentFares.length);
      }

      dailyFares.add(segmentFares.fold(0, (a, b) => a + b));
    }

    final int totalFare = dailyFares.fold(0, (a, b) => a + b);

    return {
      'totalFare': totalFare,
      'dailyFares': dailyFares,
      'incompleteSegments': incompleteSegments,
      'isEstimated': true,
    };
  }

  // ── 7. 패스 비교 (Sliding Window) ────────────────────────
  Future<List<Map<String, dynamic>>> compareWithPasses(
    int totalFare,
    List<int> dailyFares,
    String city,
  ) async {
    final String normalizedCity = _normalizeCity(city);

    final snapshot = await FirebaseFirestore.instance
        .collection('transit_passes')
        .where('city', isEqualTo: normalizedCity)
        .get();

    final List<Map<String, dynamic>> results = [];

    for (final doc in snapshot.docs) {
      final pass = doc.data();
      final int price = switch (pass['price']) {
        int p => p,
        double p => p.toInt(),
        String s => int.tryParse(s) ?? 0,
        _ => 0,
      };
      final int durationDays = (pass['valid_days'] as num?)?.toInt() ?? 0;
      final bool isIcCard = pass['type'] == 'ic_card';

      // IC카드는 Sliding Window 불필요 — 전체 합산과 동일
      if (isIcCard || durationDays == 0) {
        results.add({
          'passName': pass['name'],
          'passPrice': price,
          'saving': totalFare - price,
          'isRecommended': false,
          'bestStartDay': null,
          'bestEndDay': null,
          'notes': pass['notes'] ?? '',
          'isIcCard': true,
        });
        continue;
      }

      // Sliding Window: durationDays 구간 중 가장 이득인 시점 탐색
      int maxWindowFare = 0;
      int bestStartDay = 1;

      final int totalDays = dailyFares.length;
      for (int start = 0; start <= totalDays - durationDays; start++) {
        final int windowFare = dailyFares
            .sublist(start, start + durationDays)
            .fold(0, (a, b) => a + b);
        if (windowFare > maxWindowFare) {
          maxWindowFare = windowFare;
          bestStartDay = start + 1; // 1-indexed
        }
      }

      // 패스 적용 기간 외 구간 요금
      final int outsideFare = totalFare - maxWindowFare;
      // 패스 구매 시 총 비용 = 패스 요금 + 패스 미적용 구간 요금
      final int totalWithPass = price + outsideFare;
      final int saving = totalFare - totalWithPass;

      results.add({
        'passName': pass['name'],
        'passPrice': price,
        'saving': saving,
        'isRecommended': saving > 0,
        'bestStartDay': bestStartDay,
        'bestEndDay': bestStartDay + durationDays - 1,
        'windowFare': maxWindowFare, // 해당 기간 개별 요금 (비교용)
        'notes': pass['notes'] ?? '',
        'isIcCard': false,
      });
    }

    // 절약 금액 내림차순 정렬
    results.sort((a, b) => (b['saving'] as int).compareTo(a['saving'] as int));
    return results;
  }

  // ── 캐시 초기화 ──────────────────────────────────────────
  void clearCache() => _coordCache.clear();
}
