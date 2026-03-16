import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/plan_request_model.dart';
import 'plan_service.dart';

/// Google Places API (New) 결과를 담는 경량 모델
class PlaceSuggestion {
  final String name;
  final double? rating;
  final int? ratingCount;
  final String? address;
  final String primaryType;
  final String normalizedCategory;
  final double lat;
  final double lng;

  /// 도시 명물 키워드 검색 출처 — null이면 nearbySearch/공통키워드 결과
  /// 슬림화 버킷 분리에 사용 (normalizedCategory + sourceKeyword 조합)
  final String? sourceKeyword;

  PlaceSuggestion({
    required this.name,
    this.rating,
    this.ratingCount,
    this.address,
    required this.primaryType,
    required this.normalizedCategory,
    required this.lat,
    required this.lng,
    this.sourceKeyword,
  });

  /// Gemini 프롬프트 보강용 직렬화
  Map<String, dynamic> toPromptMap() => {
    'name': name,
    'normalizedCategory': normalizedCategory,
    if (rating != null) 'rating': rating,
    if (ratingCount != null) 'rating_count': ratingCount,
  };
}

/// Google Places API (New) 연동 서비스 — 최적화 버전
///
/// [역할] Gemini 프롬프트 보강용 맛집·카페·생활 스팟 수집
/// UI 표시 없이 프롬프트에만 활용됨
///
/// [호출 수 최적화 전략]
/// 1. includedTypes 통합: 카테고리별 types를 하나의 nearbySearch로 병합
///    → 권역당 nearbySearch 호출: 최대 2회 (식사/카페 통합 1회 + 생활/문화 통합 1회)
/// 2. 키워드 검색(돈키호테·센토 등)은 권역별로 유지:
///    도시 중심 검색 시 외곽 권역 누락 가능성이 있어 정교함 보존을 위해 권역별 검색 유지
///
/// [예상 호출 수]
/// 권역 5개 × (2 + 활성키워드 수) = 약 25회
class GooglePlacesService {
  final String _apiKey;

  static const List<String> _allFoodTypes = [
    'restaurant',
    'japanese_restaurant',
    'chinese_restaurant',
    'korean_restaurant',
    'ramen_restaurant',
    'sushi_restaurant',
    'yakiniku_restaurant',
    'tempura_restaurant',
    'fine_dining_restaurant',
    'izakaya_restaurant',
    'bar',
    'bbq_restaurant',
    'fast_food_restaurant',
  ];
  static const List<String> _allCafeTypes = [
    'cafe',
    'coffee_shop',
    'tea_house',
    'bakery',
    'dessert_shop',
    'ice_cream_shop',
  ];

  // ── primaryType → normalizedCategory 매핑 ────────────
  static const Map<String, String> _typeToCategory = {
    // meal categorizing
    'fine_dining_restaurant': 'meal_fine',
    'sushi_restaurant': 'meal_omakase',
    'izakaya_restaurant': 'meal_izakaya',
    'ramen_restaurant': 'meal_local',
    'yakiniku_restaurant': 'meal_local',
    'tempura_restaurant': 'meal_local',
    'bbq_restaurant': 'meal_local',
    'fast_food_restaurant': 'meal_local',
    'bar': 'meal_izakaya',
    // meal standard
    'restaurant': 'meal',
    'japanese_restaurant': 'meal',
    'chinese_restaurant': 'meal',
    'korean_restaurant': 'meal',
    // cafe categorizing
    'dessert_shop': 'cafe_dessert',
    'ice_cream_shop': 'cafe_dessert',
    'bakery': 'cafe_dessert',
    'coffee_shop': 'cafe_coffee',
    'tea_house': 'cafe_traditional',
    // cafe standard
    'cafe': 'cafe',
    // shopping: pharmacy만 해당 — shopping_mall/department_store는 _typeToCategory 미등록으로
    // 'other' 처리됨. 즉 shopping normalizedCategory = 드럭스토어 전용
    'pharmacy': 'shopping',
    // others
    'art_gallery': 'art',
    'grocery_store': 'local',
    'supermarket': 'local',
  };

  static const String _nearbySearchUrl =
      'https://places.googleapis.com/v1/places:searchNearby';
  static const String _textSearchUrl =
      'https://places.googleapis.com/v1/places:searchText';

  static const String _fieldMask =
      'places.id,'
      'places.displayName,'
      'places.rating,'
      'places.userRatingCount,'
      'places.primaryType,'
      'places.location,'
      'places.formattedAddress';

  // ── 카테고리 → nearbySearch types 매핑 ───────────────────
  static const Map<TripCategory, List<String>> _categoryTypes =
      <TripCategory, List<String>>{
        TripCategory.shopping: ['shopping_mall', 'department_store'],
        TripCategory.local: ['grocery_store', 'supermarket', 'bar'],
        TripCategory.activity: [],
        TripCategory.art: ['art_gallery', 'museum'],
        TripCategory.gourmet: [],
        TripCategory.cafe: [],
        TripCategory.nature: [],
        TripCategory.culture: [],
        TripCategory.photo: [],
      };

  // ── 공통 키워드 검색 대상 ─────────────────────────────────
  // null = 카테고리 무관 항상 검색 / TripCategory = 해당 카테고리 선택 시에만 검색
  static const Map<String, TripCategory?> _keywordConditions =
      <String, TripCategory?>{
        // 드럭스토어: 동선 규칙상 전 일정 1회 포함이므로 항상 검색
        'ドラッグストア': null,
        'ドン・キホーテ': null,
        // 센토·요코초: local 선택 시에만
        '銭湯': TripCategory.local,
        '横丁': TripCategory.local,
        // 킷사텐: cafe 선택 시에만
        '喫茶店': TripCategory.cafe,
        // 서브컬처: activity 선택 시에만
        'アニメイト': TripCategory.activity,
        'まんだらけ': TripCategory.activity,
      };

  // ── 도시별 명물 키워드 ────────────────────────────────────
  // null = 카테고리 무관 / TripCategory = 해당 카테고리 선택 시에만
  static const Map<String, List<MapEntry<String, TripCategory?>>>
  _cityKeywords = {
    '도쿄': [
      MapEntry('もんじゃ焼き', TripCategory.gourmet), // 몬자야키
      MapEntry('立ち飲み', TripCategory.local), // 다치노미
      MapEntry('角打ち', TripCategory.local), // 카쿠우치
    ],
    '오사카': [
      MapEntry('たこ焼き', TripCategory.gourmet), // 타코야키
      MapEntry('お好み焼き', TripCategory.gourmet), // 오코노미야키
      MapEntry('串カツ', TripCategory.gourmet), // 쿠시카츠
      MapEntry('立ち飲み', TripCategory.local),
    ],
    '교토': [
      MapEntry('湯豆腐', TripCategory.gourmet), // 유도후
      MapEntry('おばんざい', TripCategory.gourmet), // 오반자이
      MapEntry('抹茶スイーツ', TripCategory.cafe), // 말차 디저트
      MapEntry('町家カフェ', TripCategory.cafe), // 마치야 카페
    ],
    '나고야': [
      MapEntry('矢場とん', TripCategory.gourmet), // 야바톤 (미소카츠)
      MapEntry('コメダ珈琲', TripCategory.cafe), // 코메다커피
      MapEntry('世界の山ちゃん', TripCategory.gourmet), // 세카이노야마짱 (데바사키)
      MapEntry('あんかけスパ', TripCategory.gourmet), // 앙카케스파
      MapEntry('ひつまぶし', TripCategory.gourmet), // 히츠마부시
      MapEntry('小倉トースト', TripCategory.cafe), // 오구라토스트
    ],
    '삿포로': [
      MapEntry('スープカレー', TripCategory.gourmet), // 수프카레
      MapEntry('ジンギスカン', TripCategory.gourmet), // 징기스칸
      MapEntry('味噌ラーメン', TripCategory.gourmet), // 미소라멘
      MapEntry('パフェ', TripCategory.cafe), // 파르페
    ],
    '후쿠오카': [
      MapEntry('屋台', TripCategory.gourmet), // 야타이
      MapEntry('もつ鍋', TripCategory.gourmet), // 모츠나베
      MapEntry('水炊き', TripCategory.gourmet), // 미즈타키
      MapEntry('博多ラーメン', TripCategory.gourmet), // 하카타라멘
    ],
    '가고시마': [
      MapEntry('黒豚しゃぶしゃぶ', TripCategory.gourmet), // 쿠로부타샤부샤부
      MapEntry('さつま揚げ', TripCategory.gourmet), // 사츠마아게
      MapEntry('鶏刺し', TripCategory.gourmet), // 토리사시
      MapEntry('芋焼酎', TripCategory.local), // 이모쇼추 이자카야
    ],
    '오키나와': [
      MapEntry('沖縄そば', TripCategory.gourmet), // 오키나와소바
      MapEntry('ゴーヤーチャンプルー', TripCategory.gourmet), // 고야참플
      MapEntry('サーターアンダギー', TripCategory.cafe), // 사타안다기
      MapEntry('泡盛', TripCategory.local), // 아와모리 이자카야
    ],
    '시즈오카': [
      MapEntry('うなぎ', TripCategory.gourmet), // 장어
      MapEntry('静岡おでん', TripCategory.gourmet), // 시즈오카오뎅
      MapEntry('桜えび', TripCategory.gourmet), // 사쿠라에비
      MapEntry('富士宮やきそば', TripCategory.gourmet), // 후지노미야야키소바
    ],
  };

  GooglePlacesService(this._apiKey);

  /// 선택된 권역 목록에 대해 Places API 결과를 패치
  /// Returns: { areaName → List<PlaceSuggestion> }
  Future<Map<String, List<PlaceSuggestion>>> fetchForAreas({
    required List<AreaGroup> areaGroups,
    required PlanRequest request,
  }) async {
    if (_apiKey.isEmpty || areaGroups.isEmpty) return {};

    final results = await Future.wait(
      areaGroups.map((group) async {
        final suggestions = await _fetchForArea(
          lat: group.anchor.location.latitude,
          lng: group.anchor.location.longitude,
          request: request,
        );

        // 중복 제거 + 평점 필터
        final seen = <String>{};
        final deduped = suggestions
            .where(
              (p) =>
                  p.name.isNotEmpty && (p.rating == null || p.rating! >= 3.8),
            )
            .where((p) => seen.add(p.name))
            .toList();

        // 슬림화: nearbySearch는 normalizedCategory 버킷(상위 3개),
        // 도시 키워드 출처는 keyword별 독립 버킷(상위 2개)으로 분리
        // → 야바톤·히츠마부시 등 같은 meal 버킷 안에서 메뉴 중복 방지
        final slimmed = <String, List<PlaceSuggestion>>{};
        for (final p in deduped) {
          if (p.normalizedCategory == 'other') continue;
          final bucketKey = p.sourceKeyword != null
              ? '${p.normalizedCategory}::${p.sourceKeyword}'
              : p.normalizedCategory;
          final limit = p.sourceKeyword != null ? 2 : 3;
          slimmed.putIfAbsent(bucketKey, () => []);
          if (slimmed[bucketKey]!.length < limit) {
            slimmed[bucketKey]!.add(p);
          }
        }

        return MapEntry(
          group.areaName,
          slimmed.values.expand((list) => list).toList(),
        );
      }),
    );

    return Map.fromEntries(results);
  }

  // ── 권역별 검색 ──────────────────────────────────────────
  Future<List<PlaceSuggestion>> _fetchForArea({
    required double lat,
    required double lng,
    required PlanRequest request,
  }) async {
    final suggestions = <PlaceSuggestion>[];

    // [호출 1a] 식사/카페 타입 — POPULARITY 상위 결과
    final foodTypes = _buildFoodTypes(request);
    if (foodTypes.isNotEmpty) {
      final foodPopularity = await _nearbySearch(
        lat: lat,
        lng: lng,
        includedTypes: foodTypes,
        maxResults: _resolveFoodMaxResults(request),
        rankPreference: 'POPULARITY',
      );
      suggestions.addAll(foodPopularity);

      // [호출 1b] 동일 타입 — DISTANCE 기준 근거리 우선 병행 검색
      final foodDistance = await _nearbySearch(
        lat: lat,
        lng: lng,
        includedTypes: foodTypes,
        maxResults: _resolveFoodMaxResults(request),
        rankPreference: 'DISTANCE',
      );
      suggestions.addAll(foodDistance);
    }

    // [호출 2] 카테고리별 생활/문화 타입 통합 검색
    final extraTypes = request.selectedCategories
        .expand((cat) => _categoryTypes[cat] ?? <String>[])
        .toSet()
        .toList();

    if (extraTypes.isNotEmpty) {
      final extras = await _nearbySearch(
        lat: lat,
        lng: lng,
        includedTypes: extraTypes,
        maxResults: 5,
      );
      suggestions.addAll(extras);
    }

    // [호출 3~N] 공통 키워드 검색
    final activeKeywords = _keywordConditions.entries
        .where(
          (e) =>
              e.value == null || request.selectedCategories.contains(e.value),
        )
        .map((e) => e.key)
        .toList();

    await Future.wait(
      activeKeywords.map((keyword) async {
        final places = await _textSearch(query: keyword, lat: lat, lng: lng);
        suggestions.addAll(places);
      }),
    );

    // [호출 N+1~M] 도시별 명물 키워드 검색
    final cityEntry = _cityKeywords.entries.firstWhere(
      (e) => (request.city ?? '').contains(e.key),
      orElse: () => const MapEntry('', []),
    );

    await Future.wait(
      cityEntry.value
          .where(
            (e) =>
                e.value == null || request.selectedCategories.contains(e.value),
          )
          .map((e) async {
            final places = await _textSearch(query: e.key, lat: lat, lng: lng);
            // sourceKeyword 태깅 — 슬림화 버킷 분리용
            suggestions.addAll(
              places.map(
                (p) => PlaceSuggestion(
                  name: p.name,
                  rating: p.rating,
                  ratingCount: p.ratingCount,
                  address: p.address,
                  primaryType: p.primaryType,
                  normalizedCategory: p.normalizedCategory,
                  lat: p.lat,
                  lng: p.lng,
                  sourceKeyword: e.key,
                ),
              ),
            );
          }),
    );

    return suggestions;
  }

  // ── 헬퍼 ────────────────────────────────────────────────

  List<String> _buildFoodTypes(PlanRequest request) {
    final types = <String>{};

    types.addAll(_allFoodTypes);
    types.addAll(_allCafeTypes);

    final gourmetStyles = request.selectedStyles[TripCategory.gourmet] ?? [];
    if (gourmetStyles.contains(TripStyle.fineDining)) {
      types.add('fine_dining_restaurant');
    }

    final cafeStyles = request.selectedStyles[TripCategory.cafe] ?? [];
    if (cafeStyles.contains(TripStyle.dessertFocus)) {
      types.add('dessert_shop');
    }

    if (request.selectedCategories.contains(TripCategory.shopping)) {
      types.add('pharmacy');
    }

    return types.toList();
  }

  int _resolveFoodMaxResults(PlanRequest request) {
    return 15;
  }

  // ── Places API 호출 ──────────────────────────────────────
  Future<List<PlaceSuggestion>> _nearbySearch({
    required double lat,
    required double lng,
    required List<String> includedTypes,
    int maxResults = 5,
    String rankPreference = 'POPULARITY',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_nearbySearchUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _apiKey,
          'X-Goog-FieldMask': _fieldMask,
        },
        body: jsonEncode({
          'locationRestriction': {
            'circle': {
              'center': {'latitude': lat, 'longitude': lng},
              'radius': 2000.0,
            },
          },
          'includedTypes': includedTypes,
          'maxResultCount': maxResults,
          'rankPreference': rankPreference,
          'languageCode': 'ko',
        }),
      );

      if (response.statusCode != 200) return [];
      return _parsePlaces(response.body);
    } catch (_) {
      return [];
    }
  }

  Future<List<PlaceSuggestion>> _textSearch({
    required String query,
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_textSearchUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _apiKey,
          'X-Goog-FieldMask': _fieldMask,
        },
        body: jsonEncode({
          'textQuery': query,
          'locationBias': {
            'circle': {
              'center': {'latitude': lat, 'longitude': lng},
              'radius': 2000.0,
            },
          },
          'maxResultCount': 2,
          'minRating': 3.5,
          'languageCode': 'ko',
        }),
      );

      if (response.statusCode != 200) return [];
      return _parsePlaces(response.body);
    } catch (_) {
      return [];
    }
  }

  List<PlaceSuggestion> _parsePlaces(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final places = data['places'] as List<dynamic>? ?? [];

      return places
          .map((p) {
            final name =
                (p['displayName'] as Map<String, dynamic>?)?['text']
                    as String? ??
                '';
            final primaryType = p['primaryType'] as String? ?? '';
            return PlaceSuggestion(
              name: name,
              rating: (p['rating'] as num?)?.toDouble(),
              ratingCount: p['userRatingCount'] as int?,
              address: p['formattedAddress'] as String?,
              primaryType: primaryType,
              normalizedCategory: _typeToCategory[primaryType] ?? 'other',
              lat: (p['location']?['latitude'] as num?)?.toDouble() ?? 0,
              lng: (p['location']?['longitude'] as num?)?.toDouble() ?? 0,
            );
          })
          .where((p) => p.name.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
