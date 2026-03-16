import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:palette_michi/features/plan/services/plan_service.dart';
import 'package:palette_michi/features/plan/services/google_places_service.dart';
import '../models/plan_request_model.dart';

class PlanGeneratorService {
  final GenerativeModel _model;

  PlanGeneratorService(String apiKey)
    : _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

  Future<Map<String, dynamic>> generateItinerary({
    required PlanRequest request,
    required List<AreaGroup> areaGroups,
    Map<String, List<PlaceSuggestion>>? placesApiSuggestions,
  }) async {
    // DB에 이미 있는 장소명 수집 — Places API 중복 제거용
    final dbPlaceNames = areaGroups
        .expand((g) => g.places.map((sp) => sp.place.name.toLowerCase()))
        .toSet();

    final areasInfo = areaGroups
        .map(
          (group) => {
            'area_name': group.areaName,
            'anchor': {
              'id': group.anchor.id,
              'name': group.anchor.name,
              'description': group.anchor.description,
              'avg_stay_time': group.anchor.avgStayTime,
              if (group.anchor.accessInfo != null)
                'access_info': group.anchor.accessInfo,
            },
            'sub_places': group.places
                .where((sp) => !sp.place.isAnchor)
                .take(3)
                .map(
                  (sp) => {
                    'id': sp.place.id,
                    'name': sp.place.name,
                    'description': sp.place.description,
                    'avg_stay_time': sp.place.avgStayTime,
                    'category': sp.place.category,
                  },
                )
                .toList(),
            if (placesApiSuggestions != null &&
                placesApiSuggestions[group.areaName] != null &&
                placesApiSuggestions[group.areaName]!.isNotEmpty)
              'food_and_lifestyle_nearby': placesApiSuggestions[group.areaName]!
                  .where((s) => !dbPlaceNames.contains(s.name.toLowerCase()))
                  .where((s) => s.normalizedCategory != 'other')
                  .map((s) => s.toPromptMap())
                  .toList(),
          },
        )
        .toList();

    final prompt =
        '''
당신은 베테랑 여행 플래너입니다.
아래 권역(area) 데이터를 활용하여 ${request.city} ${request.days}일 여행 일정을 짜주세요.

[사용자 정보]
- 여행 인원: ${request.companions.join(', ')}
- 여행 밀도: ${request.density} (0.0 매우 여유 ~ 1.0 매우 빡빡)
- 관심 카테고리: ${request.selectedCategories.map((c) => c.label).join(', ')}
${_buildFlightContext(request)}
${_buildStyleContext(request)}

[권역 데이터]
${jsonEncode(areasInfo)}

[food_and_lifestyle_nearby 활용 규칙]
- food_and_lifestyle_nearby는 Google Places API 기반 실제 영업 중인 맛집·카페·생활 스팟입니다.
- 각 장소의 normalizedCategory를 기준으로 슬롯을 배정하세요:
  · meal* (meal / meal_fine / meal_omakase / meal_izakaya / meal_local) → 식사 슬롯
  · cafe* (cafe / cafe_coffee / cafe_dessert / cafe_traditional) → 카페 슬롯
  · shopping → 하루 마지막 슬롯
- normalizedCategory가 없거나 'other'인 장소는 배정하지 마세요.
- 동일한 장소명을 전체 일정에서 두 번 이상 사용하지 마세요.
${_buildFoodFallbackRule()}

[미식 — meal* 배치 가이드]
${_buildMealSlotGuide(request)}

[카페 — cafe* 배치 가이드]
${_buildCafeSlotGuide(request)}

${_buildFoodAndLifestyleContext(request)}

[카테고리 준수 규칙]
- 이 규칙은 Firestore DB 기반 관광·쇼핑·문화 장소에만 적용됩니다. food_and_lifestyle_nearby 데이터에는 적용되지 않습니다.
- 선택된 카테고리 장소는 메인 슬롯(place_name)에 적극 배치하세요.
- 선택되지 않은 카테고리의 장소는 메인 슬롯에 넣지 마세요. 단, 해당 권역에서 자연스럽게 마주칠 수 있는 장소라면 tip 안에서 가볍게 한 줄로만 언급할 수 있습니다.
- 예: 애니메·서브컬처(アニメイト, まんだらけ 등) → 액티비티+애니 스타일 미선택 시 tip에서만 언급
- 예: 센토·요코초 → 현지인 카테고리 미선택 시 tip에서만 언급
${_buildCategoryBalanceGuide(request)}

${_buildTransportGuide(request)}

[동선 규칙]
1. 하루에 1~2개 권역만 배정하세요. 지리적으로 인접한 권역끼리 같은 날 묶어주세요.
2. 각 권역은 anchor를 중심으로 sub_places를 함께 배치하세요.
3. 점심(12:00~13:00)과 저녁(18:00~19:00)에는 반드시 식사 일정을 넣어주세요.
4. 체류 시간(duration)은 avg_stay_time을 기준으로 밀도(${request.density})에 따라 조정하세요.
5. ドン・キホーテ(돈키호테)·드럭스토어·슈퍼마켓 등 부피 있는 쇼핑 장소는 반드시 하루 일정의 마지막 슬롯에 배치하세요. 해당 슬롯의 tip에는 "쇼핑 후 숙소 방향으로 바로 이동 가능"처럼 귀환 동선을 안내하세요.
6. 드럭스토어·돈키호테 방문은 전체 일정 통틀어 최대 2회로 제한하세요. 쇼핑 카테고리 선택 여부와 무관하게 한 번은 자연스럽게 포함하되, 매일 저녁 반복하지 마세요. 이미 쇼핑 카테고리가 선택된 경우엔 해당 카테고리 슬롯에 통합하세요.
7. 장소명이 "기념품 샵", "주변 점심" 등 일반 설명형일 때는 반드시 권역명·거리명을 포함하세요. 예: "기온 거리 기념품샵", "니시키 시장 점심", "아사쿠사 나카미세도리 간식".
8. 하루 일정의 마지막 슬롯은 duration + 숙소까지 이동 시간을 합산해 21:30 이전에 귀환 완료되도록 역산하여 배치하세요. 온천·이자카야·야경 전망대 등 체류 시간이 긴 저녁 슬롯은 시작 시간이 늦어지지 않도록 주의하세요.

${_buildNearbyRoutingRule(request)}
${_buildFlightScheduleRule(request)}

[숙소 추천 규칙]
- 전체 일정을 고려해 최적의 숙소 위치를 추천하세요.
${_buildAccommodationRule(request)}
- 숙소가 바뀌는 경우 nights를 구간으로 표기하세요. 예: "1~2박", "3박"

[tip 작성 규칙]
- tip은 여행자 입장의 자연스러운 안내 문장으로만 작성하세요.
- 카테고리명(미식, 현지인 모드, 쇼핑 등), 스타일명, 선택 옵션 정보는 tip에 절대 노출하지 마세요.
- 예: "미식 탐방: 동네 맛집 & 이자카야" (❌) → "현지인들이 즐겨 찾는 이자카야 골목" (✅)
- 예: "현지인 모드: 야간 포장마차" (❌) → "밤에 야타이 골목을 걸어보세요" (✅)

[응답 형식 — 반드시 준수]
slot_type 값: "meal" | "cafe" | "lifestyle" | "sightseeing"
- meal: 아침·점심·저녁 식사, 이자카야
- cafe: 카페·베이커리·디저트
- lifestyle: 쇼핑·드럭스토어·슈퍼마켓·센토·편의점 등 생활 스팟
- sightseeing: 관광지·문화시설·공원·신사 등 일반 관광

{
  "accommodations": [
    {
      "nights": "1~2박",
      "area": "신주쿠",
      "nearest_station": "신주쿠역",
      "reason": "추천 이유"
    }
  ],
  "itinerary": [
    {
      "day": 1,
      "area": "아사쿠사",
      "schedule": [
        {
          "place_name": "센소지",
          "arrival_time": "10:00",
          "duration": 90,
          "transport_time": 20,
          "tip": "짧은 팁",
          "slot_type": "sightseeing"
        }
      ]
    }
  ]
}
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text != null) {
        return jsonDecode(response.text!) as Map<String, dynamic>;
      }
      return {'accommodations': [], 'itinerary': []};
    } catch (e) {
      debugPrint('Gemini 일정 생성 오류: $e');
      rethrow;
    }
  }

  // ── VisitTime 헬퍼 ────────────────────────────────────

  VisitTime _resolveArrival(VisitTime time) =>
      time == VisitTime.undecided ? VisitTime.afternoon : time;

  VisitTime _resolveDeparture(VisitTime time) =>
      time == VisitTime.undecided ? VisitTime.morning : time;

  int _startHour(VisitTime time) => switch (time) {
    VisitTime.morning => 9,
    VisitTime.afternoon => 13,
    VisitTime.evening => 17,
    VisitTime.undecided => 9,
  };

  int _endHour(VisitTime time) => switch (time) {
    VisitTime.morning => 11,
    VisitTime.afternoon => 17,
    VisitTime.evening => 21,
    VisitTime.undecided => 17,
  };

  // ── 프롬프트 빌더 ─────────────────────────────────────

  String _buildFlightContext(PlanRequest request) {
    final arrival = _resolveArrival(request.arrivalTime);
    final departure = _resolveDeparture(request.departureTime);

    final arrivalNote = request.arrivalTime == VisitTime.undecided
        ? '(미정 — 오후 도착 기준으로 일정을 구성하세요)'
        : '';
    final departureNote = request.departureTime == VisitTime.undecided
        ? '(미정 — 오전 출발 기준, 11:00 이전 일정 마감)'
        : '';

    return '- 첫날 도착 시간대: ${arrival.label} (${_startHour(arrival)}:00 기준) $arrivalNote\n'
        '- 마지막날 출발 시간대: ${departure.label} (${_endHour(departure)}:00 기준) $departureNote';
  }

  String _buildStyleContext(PlanRequest request) {
    if (request.selectedStyles.isEmpty) return '';
    final lines = <String>[];
    for (final cat in request.selectedCategories) {
      final styles = request.selectedStyles[cat];
      if (styles != null && styles.isNotEmpty) {
        lines.add('  · ${cat.label}: ${styles.map((s) => s.label).join(', ')}');
      }
    }
    if (lines.isEmpty) return '';
    return '[선택된 세부 스타일 — 메인 슬롯 최우선 반영]\n'
        '${lines.join('\n')}\n'
        '→ 장소 배치 시 세부 스타일을 카테고리보다 더 구체적인 기준으로 삼으세요.\n'
        '→ 단, 세부 스타일에 해당하는 장소가 전체 일정의 30%를 넘지 않도록 다른 카테고리와 균형을 맞추세요.';
  }

  /// meal 슬롯 상호명 사용 원칙 — 있을 때/없을 때 명확히 분리
  String _buildFoodFallbackRule() {
    return '- ⚠️ food_and_lifestyle_nearby의 meal*/cafe* 장소는 사용자가 미식·카페 카테고리를 선택하지 않았더라도 상호명을 그대로 사용해야 합니다. 아래 [카테고리 준수 규칙]은 이 데이터에 적용되지 않습니다.\n'
        '- food_and_lifestyle_nearby에 meal* 장소가 있으면 반드시 그 상호명을 place_name에 그대로 사용하세요.\n'
        '- food_and_lifestyle_nearby에 cafe* 장소가 있으면 반드시 그 상호명을 place_name에 그대로 사용하세요.\n'
        '- meal* 장소가 없는 식사 슬롯에 한해, 권역명과 음식 장르를 조합한 탐방 제안형'
        '(예: "사카에 골목 이자카야 탐방", "오오스 상점가 히츠마부시 탐방")으로 작성하세요. '
        '이 경우 실제 존재가 불확실한 구체적 상호명은 사용하지 마세요.';
  }

  /// meal* 슬롯 배치 가이드 — 미식 선택 여부·스타일에 따라 분기
  String _buildMealSlotGuide(PlanRequest request) {
    final buf = StringBuffer();
    final cats = request.selectedCategories;

    if (!cats.contains(TripCategory.gourmet)) {
      buf.writeln('- 기본 meal 장소를 점심·저녁에 배치하세요. tip은 간단한 한 줄로 충분합니다.');
      return buf.toString().trim();
    }

    buf.writeln('- 미식 관심 사용자입니다. meal* 장소를 점심·저녁에 적극 배치하고 tip에 구체적 메뉴를 명시하세요.');

    final gs = request.selectedStyles[TripCategory.gourmet] ?? [];
    if (gs.contains(TripStyle.fineDining)) {
      buf.writeln('  · meal_fine → 저녁 1회 우선 배치. tip: "코스 구성: ○○, 예약 필수"');
    }
    if (gs.contains(TripStyle.omakase)) {
      buf.writeln('  · meal_omakase → 저녁 1회 강조 배치. tip: "카운터석 예약, 코스 2~3만엔"');
    }
    if (gs.contains(TripStyle.localEats)) {
      buf.writeln('  · meal_izakaya → 저녁 1~2회 배치. tip: "대표 안주: ○○, 사케 페어링 추천"');
    }
    if (gs.contains(TripStyle.streetFood)) {
      buf.writeln('  · meal_local → 점심 전후 배치. tip: "현금 지참 권장"');
    }

    return buf.toString().trim();
  }

  /// cafe* 슬롯 배치 가이드 — 카페 선택 여부·스타일에 따라 분기
  String _buildCafeSlotGuide(PlanRequest request) {
    final buf = StringBuffer();
    final cats = request.selectedCategories;

    if (!cats.contains(TripCategory.cafe)) {
      buf.writeln(
        '- 카페를 별도 선택하지 않았더라도 하루 1회는 반드시 오전·오후 중간 슬롯에 cafe* 장소를 배치하세요.',
      );
      buf.writeln(
        '- food_and_lifestyle_nearby에 cafe* 장소가 있으면 반드시 그 상호명을 place_name에 사용하세요.',
      );
      return buf.toString().trim();
    }

    buf.writeln('- 카페 관심 사용자입니다. cafe* 장소를 오전·오후 중간 슬롯에 배치하세요.');

    final cs = request.selectedStyles[TripCategory.cafe] ?? [];
    if (cs.contains(TripStyle.dessertFocus)) {
      buf.writeln('  · cafe_dessert → 오후 슬롯 우선 배치. tip: "시그니처: ○○ 파르페/케이크"');
    }
    if (cs.contains(TripStyle.traditional)) {
      buf.writeln('  · cafe_traditional → 오전 슬롯 배치. tip: "나폴리탄·크림소다·모닝 세트"');
    }
    if (cs.contains(TripStyle.aestheticCafe)) {
      buf.writeln('  · cafe / cafe_coffee → 공간 특징 명시. tip: "루프탑 뷰 / 창가석 추천"');
    }
    if (cs.contains(TripStyle.specialtyCoffee)) {
      buf.writeln('  · cafe_coffee → tip: "싱글 오리진: ○○ 에티오피아 예가체프 추천"');
    }

    return buf.toString().trim();
  }

  /// 카테고리별 배치 보조 컨텍스트
  /// — meal/cafe 가이드·동선 규칙·카테고리 밸런스와 역할 분리:
  ///   현지인 생활 스팟 동선 힌트 + 액티비티 포함/제외 기준 + 미식 길거리 동선 힌트
  String _buildFoodAndLifestyleContext(PlanRequest request) {
    final buf = StringBuffer();
    final cats = request.selectedCategories;

    // 미식 — 길거리 음식 동선 힌트 (tip 작성 가이드는 _buildMealSlotGuide에서 처리)
    if (cats.contains(TripCategory.gourmet)) {
      final gs = request.selectedStyles[TripCategory.gourmet] ?? [];
      if (gs.contains(TripStyle.streetFood)) {
        buf.writeln(
          '- 시장 & 길거리 음식: 타코야키·야키토리·노점·아침 시장을 점심 전후 또는 저녁 산책 동선에 포함하세요.',
        );
      }
    }

    // 현지인 — 생활 스팟 동선 힌트 (빈도 제한은 _buildCategoryBalanceGuide에서 처리)
    if (cats.contains(TripCategory.local)) {
      buf.writeln(
        '- 현지인 모드: food_and_lifestyle_nearby에 銭湯(센토)·横丁(요코초)·喫茶店(킷사텐) 등이 있으면 저녁·오전 일정에 포함하세요.',
      );
    }

    // 액티비티 — 포함/제외 기준
    if (cats.contains(TripCategory.activity)) {
      final styles = request.selectedStyles[TripCategory.activity] ?? [];
      final hasAnime = styles.contains(TripStyle.anime);
      if (hasAnime) {
        buf.writeln('- 애니 성지 순례: アニメイト·まんだらけ를 전체 여행 중 1~2곳으로 제한해 포함하세요.');
      } else {
        final styleLabels = styles.isNotEmpty
            ? styles.map((s) => s.label).join(', ')
            : '원데이 클래스·테마파크·야외 활동';
        buf.writeln(
          '- 액티비티: アニメイト·まんだらけ는 포함하지 마세요. 선택 스타일($styleLabels)에 맞는 체험을 우선 배치하세요.',
        );
      }
    }

    final result = buf.toString().trim();
    if (result.isEmpty) return '';
    return '[카테고리별 배치 힌트]\n$result';
  }

  /// 카테고리별 추천 빈도·밸런스 가이드
  String _buildCategoryBalanceGuide(PlanRequest request) {
    final buf = StringBuffer();
    final cats = request.selectedCategories;
    final days = request.days;

    buf.writeln('[카테고리별 추천 밸런스]');

    if (cats.contains(TripCategory.shopping)) {
      buf.writeln(
        '- 쇼핑: 백화점·쇼핑몰은 전체 일정 중 최대 1~2회로 제한하세요. 드럭스토어·빈티지숍·로컬마켓·편집숍 등 다양한 유형을 골고루 배치하세요. 같은 번화가에 백화점이 여러 개 붙어있더라도 하나만 배정하세요.',
      );
    }

    if (cats.contains(TripCategory.local)) {
      final maxSento = days! <= 3 ? 1 : 2;
      buf.writeln(
        '- 현지인: 센토는 전체 일정 중 최대 $maxSento회만 배정하세요. 센토 외에도 요코초 탐방·새벽 시장·동네 슈퍼·킷사텐 등 다양한 현지 경험을 고루 배치하세요.',
      );
    }

    if (cats.contains(TripCategory.photo)) {
      final ps = request.selectedStyles[TripCategory.photo] ?? [];
      final hints = <String>[];
      if (ps.contains(TripStyle.nightscape)) {
        hints.add('야경 전망대·라이트업 신사·야간 항구 뷰 (골든아워·블루아워 시간대 명시)');
      }
      if (ps.contains(TripStyle.trending)) {
        hints.add('SNS 핫플(색감 계단·벽화 골목·포토제닉 카페 외관·팝업 스토어)');
      }
      if (ps.contains(TripStyle.hidden)) {
        hints.add('숨은 명소(이끼 낀 돌계단·오래된 상점가·반사 수면·한적한 도리이)');
      }
      if (ps.contains(TripStyle.streetSnap)) {
        hints.add('거리 스냅(인파·간판·골목 원근감·인력거·시장 활기)');
      }
      final spotGuide = hints.isNotEmpty
          ? hints.join(' / ')
          : '골든아워 전망대·포토제닉 골목·반영 포인트·야경 스팟';
      buf.writeln(
        '- 사진: 촬영 특화 스팟($spotGuide)을 하루 1~2곳씩 명시적으로 배정하세요. sightseeing 슬롯 tip에는 최적 촬영 시간대와 구도 힌트를 반드시 포함하세요.',
      );
    }

    if (cats.contains(TripCategory.activity)) {
      final styles = request.selectedStyles[TripCategory.activity] ?? [];
      final styleHint = styles.isNotEmpty
          ? styles.map((s) => s.label).join('·')
          : '원데이 클래스·테마파크·야외 스포츠';
      buf.writeln(
        '- 체험·액티비티: 직접 참여하는 체험($styleHint)을 전체 일정에서 2회 이상 배정하세요. 예약이 필요한 체험은 tip에 "사전 예약 권장"을 명시하세요. 체험 슬롯의 duration은 90~180분으로 설정하세요.',
      );
    }

    if (cats.contains(TripCategory.cafe)) {
      final maxCafe = days! <= 2 ? 3 : (days <= 4 ? 5 : 7);
      final cafeStyles = request.selectedStyles[TripCategory.cafe] ?? [];
      if (cafeStyles.contains(TripStyle.dessertFocus)) {
        final minDessert = days <= 2 ? 2 : (days <= 4 ? 3 : 4);
        buf.writeln(
          '- 카페·디저트: 카페/디저트 슬롯은 최대 $maxCafe회로 제한하세요. 그 중 $minDessert회 이상은 디저트 전문점을 명시적으로 배정하고, 권역마다 서로 다른 디저트 장르를 배치하세요.',
        );
      } else {
        buf.writeln(
          '- 카페: 카페 슬롯은 최대 $maxCafe회로 제한하세요. 단순 휴식 카페보다 그 권역을 대표하는 감성 카페·로스터리·뷰 카페를 선별해 배치하세요.',
        );
      }
    }

    if (cats.contains(TripCategory.gourmet)) {
      final gs = request.selectedStyles[TripCategory.gourmet] ?? [];
      final styleNotes = <String>[];
      if (gs.contains(TripStyle.fineDining)) styleNotes.add('미슐랭·고급 레스토랑 1회');
      if (gs.contains(TripStyle.omakase)) styleNotes.add('오마카세 1회');
      if (gs.contains(TripStyle.localEats)) styleNotes.add('이자카야·동네 정식');
      if (gs.contains(TripStyle.streetFood)) styleNotes.add('길거리 음식·시장');
      final styleNote = styleNotes.isNotEmpty
          ? ' 선택 스타일(${styleNotes.join('·')}) 반드시 포함.'
          : '';
      buf.writeln(
        '- 미식: 같은 유형의 식당을 반복하지 마세요. 점심·저녁마다 서로 다른 장르(라멘·돈가스·이자카야·스시·텟판야키·야키토리·향토 요리 등)를 배치해 다양성을 확보하세요.$styleNote',
      );
    }

    if (cats.contains(TripCategory.culture) ||
        cats.contains(TripCategory.art)) {
      buf.writeln(
        '- 문화·예술: 박물관·미술관·신사·사찰을 하루에 3개 이상 몰아넣지 마세요. 1~2개씩 여유 있게 배치하세요.',
      );
    }

    if (cats.contains(TripCategory.culture)) {
      final cs = request.selectedStyles[TripCategory.culture] ?? [];
      if (cs.contains(TripStyle.experience)) {
        buf.writeln(
          '- 전통 문화 체험: 차도·도자기·기모노·화도·서예·인력거·전통 공예·화과자 만들기 등 직접 참여 체험을 최소 1~2회 배정하세요. 예약이 필요한 체험은 tip에 "사전 예약 권장"을 명시하세요.',
        );
      }
      if (cs.contains(TripStyle.heritage)) {
        buf.writeln(
          '- 전통 거리 & 역사 유적: 마치야 밀집 골목·역사 상점가를 산책 동선에 포함하세요. tip에 역사적 배경이나 볼거리를 한 줄로 언급하세요.',
        );
      }
    }

    return buf.toString().trim();
  }

  String _buildTransportGuide(PlanRequest request) {
    final city = request.city ?? '';
    final buf = StringBuffer();
    buf.writeln('[이동 시간 계산 기준]');
    buf.writeln('- transport_time은 다음 장소까지의 실제 이동 시간(분)입니다. 과소 추정하지 마세요.');
    buf.writeln('- 도보: 500m당 약 7분 (신호 대기 포함)');
    buf.writeln('- 지하철: 탑승 대기 3~5분 + 역간 2~3분 + 개찰구 통과 + 도착역→목적지 도보');
    buf.writeln('- 같은 권역 내 도보 이동: 5~15분');
    buf.writeln('- 인접 권역 간 지하철 이동: 20~35분');

    if (city.contains('도쿄')) {
      buf.writeln('- 도쿄 야마노테선 역간: 평균 2분 / 시부야↔신주쿠 5분 / 시부야↔우에노 30분');
      buf.writeln('- 아사쿠사↔시부야 약 40분, 아키하바라↔신주쿠 약 25분, 시부야↔이케부쿠로 약 20분');
    } else if (city.contains('오사카')) {
      buf.writeln('- 오사카 미도스지선 역간: 평균 2분 / 우메다↔난바 10분 / 난바↔텐노지 10분');
      buf.writeln('- 같은 구(区) 안이라도 도보 불가 구간은 지하철+도보 합산 20~35분으로 계산하세요.');
      buf.writeln(
        '- 주요 권역 간 이동 기준: 우메다↔신사이바시·난바 15분 / 우메다↔덴노지 25분 / 우메다↔나니와노유(기타구 동쪽) 30~35분 / 신사이바시↔도톤보리 10분 / 난바↔덴노지 10분 / 우메다↔오사카성 25분',
      );
      buf.writeln(
        '- Grand Green Osaka↔나니와노유는 같은 기타구이지만 지하철+도보 약 30~35분. 절대 5~10분으로 설정하지 마세요.',
      );
    } else if (city.contains('교토')) {
      buf.writeln('- 교토 시내 버스: 정류장 간 3~5분, 주요 관광지 간 25~45분 (혼잡 포함)');
      buf.writeln('- 교토는 버스 환승이 잦아 예상보다 이동이 길어질 수 있습니다. 여유 있게 설정하세요.');
      buf.writeln(
        '- 권역 간 주요 이동 시간 기준: 후시미 이나리↔기온·시조 40~50분 / 후시미 이나리↔아라시야마 60~70분 / 아라시야마↔기온 50~60분 / 킨카쿠지↔기온 40~50분 / 기온↔시조가와라마치 10분 / 교토역↔아라시야마 40분 / 교토역↔후시미 이나리 10~15분',
      );
      buf.writeln(
        '- 후시미 이나리에서 다른 권역으로 이동 시 transport_time을 절대 10분 이하로 설정하지 마세요.',
      );
    } else if (city.contains('후쿠오카')) {
      buf.writeln('- 후쿠오카 공항선: 하카타↔텐진 6분 / 하카타↔공항 5분');
    } else if (city.contains('삿포로')) {
      buf.writeln('- 삿포로 지하철: 역간 평균 2분 / 오도리↔삿포로역 2분 / 스스키노↔오도리 2분');
    } else if (city.contains('나고야')) {
      buf.writeln('- 나고야 지하철: 역간 평균 2분 / 나고야역↔사카에 5분 / 사카에↔오스 5분');
    }

    buf.writeln(
      '- 관광지 내 줄서기·이동은 duration에 포함. transport_time은 장소 간 이동 시간만 계산.',
    );
    return buf.toString().trim();
  }

  String _buildNearbyRoutingRule(PlanRequest request) {
    if (!request.includeNearby) return '';

    final city = request.city ?? '';
    final buf = StringBuffer();

    buf.writeln('[근교 동선 규칙]');
    buf.writeln('- 근교 일정은 이동 시간이 길기 때문에 원칙적으로 1일 1근교 권역을 배정합니다.');
    buf.writeln('- 아래 명시된 연계 권장 조합을 제외한 모든 근교는 단독 1일 코스로 배정합니다.');
    buf.writeln(
      '- 서로 다른 근교를 무리하게 한 날에 여러 곳 붙이지 않고, 이동 시간·환승 횟수·체력 소모를 고려해 동선을 설계합니다.',
    );

    if (city.contains('삿포로')) {
      buf.writeln('''
[삿포로 근교 동선]
- 조잔케이: 삿포로에서 가까운 온천 지역으로 반나절~1일 코스로 단독 배정합니다.
- 오타루: 삿포로 출발 대표 당일 코스로 단독 1일 배정을 기본으로 합니다.
- 노보리베츠 + 도야호: 당일 버스 투어로 함께 묶거나, 1박2일 온천 숙박 루트로 나누어 배정하는 것도 허용합니다.
- 비에이 + 후라노: 당일 투어로 함께 방문하거나, 일정 여유가 있으면 비에이 1일 + 후라노 1일로 분리 배정도 허용합니다.
- 하코다테: 이동 거리가 길어 단독 1일 또는 1박 이상 독립 일정으로 배정하며, 다른 근교와 같은 날 묶지 않습니다.
- 샤코탄: 계절·날씨 영향을 많이 받는 해안 드라이브 코스로, 단독 1일 코스로 배정합니다.''');
    }

    if (city.contains('나고야')) {
      buf.writeln('''
[나고야 근교 동선]
- 다카야마 + 시라카와고: 1박2일 루트(1일차 다카야마 숙박 → 2일차 시라카와고 경유 귀환)를 권장합니다. 일정이 짧은 경우 나고야 출발 당일 버스로 두 곳을 함께 도는 코스도 허용합니다.
- 시라카와고 + 다카야마 + 구조 하치만 3곳 연계: 체력·이동 시간을 고려해 2일 이상으로 나누어 배정하는 것이 기본이며, 초고압축 일정이 필요한 경우에만 예외적으로 1일 연계를 허용합니다.
- 이세 신궁 + 오카게 요코초: 도보로 연계 방문이 일반적이므로 반드시 같은 날에 배정합니다.
- 그 외 근교(구조 하치만, 도요타, 이누야마, 기후 등): 단독 1일 코스로 배정하며, 근교끼리 같은 날 복수 배정하지 않습니다.''');
    }

    if (city.contains('시즈오카')) {
      buf.writeln('''
[시즈오카 근교 동선]
- 아타미 + 이토: 동일 이즈 선상에 있어 당일 연계 루트를 허용합니다. 온천 숙박 위주 일정에서는 각 1일 단독 배정도 허용합니다. 단, 아타미·이토는 이즈반도 권역(슈젠지·도가시마 등)과 별개의 권역으로 취급하며, 같은 날 이즈반도 내륙 스폿과 묶지 마세요.
- 이즈반도(슈젠지·도가시마·조가사키 해안·미시마 스카이워크): 1박 이상 로드트립/온천 여행으로 여러 스폿을 묶어 도는 패턴이 많으므로, 이즈반도 권역 안에서 1~2일 일정으로 조합 배정을 허용합니다. 단, 1일에 2~3개 거점 위주로 묶고 과도하게 많은 포인트를 넣지 마세요.
- 후지노미야: 후지산 남쪽 관문으로 1일 단독 코스로 배정합니다.
- 하마마쓰: 시즈오카 서부 개별 도시로 다른 근교와 묶지 않고 1일 단독 배정을 기본으로 합니다.''');
    }

    if (city.contains('가고시마')) {
      buf.writeln(
        '''
[가고시마 근교 동선]
- 키리시마 권역(키리시마 온천 마을·키리시마 신궁·에비노 고원): 온천 마을·신궁·고원 트레킹이 한 권역 안에서 연계되는 패턴이 많습니다. 권역 안에서 1일 또는 1박2일로 유연하게 조합을 허용하며, 온천 숙박 중심 일정에서는 최소 1박을 권장합니다.
- 사쿠라지마: 가고시마 시내와 반일+반일 조합은 허용하되, 이부스키·치란·키리시마와의 복수 근교 조합은 기본적으로 피합니다.
- 이부스키: 모래찜질 온천 중심의 체류지로 1일 단독 또는 온천 1박 코스로 배정합니다.
- 치란: 1일 단독 또는 가고시마 시내와 연계한 1일 코스로 배정하되, 이부스키·키리시마와 같은 날 장거리 다중 조합은 예외적인 경우에만 허용합니다.''',
      );
    }

    if (city.contains('오사카')) {
      buf.writeln('''
[오사카 근교 동선]
- 나라: 대표 당일 코스로 1일 단독 배정을 기본으로 합니다.
- 고베: 단독 1일 배정을 기본으로 하되, 초단기 일정에서는 오사카 시내 반일 + 고베 반일 조합도 허용합니다.
- 나라 + 고베를 같은 날 배정하지 마세요. 체류 시간이 지나치게 짧아집니다.''');
    }

    if (city.contains('후쿠오카')) {
      buf.writeln('''
[후쿠오카 근교 동선]
- 다자이후: 반일 코스로, 후쿠오카 시내 반일 + 다자이후 반일 조합을 허용합니다.
- 야나가와: 1일 단독 코스를 기본으로 하되, 후쿠오카 시내와 반일+반일 조합도 상황에 따라 허용합니다.
- 유후인 + 벳푸: 1일에 함께 도는 당일 루트도 있으나, 온천 체류 퀄리티를 고려해 최소 1박2일(각 1일)로 나누어 배정하는 것을 기본으로 합니다.
- 이토시마: 1일 단독 배정을 기본으로 합니다.
- 기타큐슈(모지코): 이동 시간이 길어 1일 단독 배정을 기본으로 하며, 다른 근교와 같은 날 묶지 않습니다.''');
    }

    if (city.contains('도쿄')) {
      buf.writeln('''
[도쿄 근교 동선]
- 하코네: 당일·1박 모두 허용하며 1일 단독 또는 1박 이상 코스로 배정합니다.
- 닛코: 이동 시간이 길어 1일 단독 또는 1박 코스로 배정하며, 다른 근교와 같은 날 묶지 않습니다.
- 가마쿠라 + 에노시마: JR·에노덴으로 연계하는 당일 코스가 보편적이므로 같은 날 연계 배정을 권장합니다.
- 가와구치코: 1일 단독 또는 1박 코스로 배정하며, 다른 근교와 같은 날 묶지 않습니다.
- 요코하마: 1일 단독 배정을 기본으로 하되, 도쿄 도심과 반일+반일 조합도 허용합니다.
- 디즈니랜드/디즈니시: 1일 전용 일정으로 배정하며, 다른 근교와 같은 날 배정하지 않습니다.
- 사이타마: 도쿄 도심과 반일+반일 조합도 허용합니다.''');
    }

    if (city.contains('교토')) {
      buf.writeln('''
[교토 근교 동선]
- 우지: 교토 시내 반일 + 우지 반일 조합 또는 1일 단독 코스로 배정합니다.
- 쿠라마·키부네 일대: 산행·온천 요소를 가진 근교로 1일 단독 코스를 기본으로 하며, 무리한 다중 근교 연계는 피합니다.''');
    }

    buf.writeln(
      '''
[편향 방지 및 밸런스]
- 동일 거점 도시 내에서 2~3개 이상의 근교가 고르게 노출되도록 배정하세요. 특정 근교에 과도하게 추천이 몰리지 않도록 주의하세요.
- 계절에 따른 선호도 차이는 반영하되, 비시즌이라도 기본 매력이 충분한 근교가 일정 비율 이상 포함되도록 하세요.
- 한 날에 여러 근교를 연계하는 경우, 총 이동 시간이 3시간을 초과하는 조합은 배정하지 마세요.

[근교 숙박 시]
- 연계 묶음 권역에서 숙박지가 A로 결정된 경우, 당일 저녁 식사·체크인 슬롯은 반드시 A 내에서만 배정하세요. B 시설의 서비스를 A 숙박일 저녁에 배치하지 마세요.''',
    );

    return buf.toString().trim();
  }

  String _buildFlightScheduleRule(PlanRequest request) {
    final arrival = _resolveArrival(request.arrivalTime);
    final departure = _resolveDeparture(request.departureTime);
    final city = request.city ?? '';
    final airportHint = _buildAirportTransportHint(city);

    final buf = StringBuffer();
    buf.writeln(
      '- 첫날은 ${arrival.label} ${_startHour(arrival)}:00 이후 일정만 배치하고, '
      '마지막날은 ${departure.label} ${_endHour(departure)}:00 기준으로 역산하여 일정을 마감하세요.',
    );
    buf.writeln(
      '- 첫날 첫 번째 슬롯은 반드시 공항/역 → 숙소 체크인·짐 보관 (slot_type: lifestyle)으로 시작하세요. '
      'tip에는 실제 이동 수단과 소요 시간을 자연스럽게 안내하세요.',
    );
    buf.writeln(
      '- 마지막날 마지막 슬롯은 반드시 숙소 → 공항/역 이동 (slot_type: lifestyle)으로 마무리하세요. '
      'tip에는 이동 수단과 "항공편 2시간 전 공항 도착 권장" 같은 여유 안내를 포함하세요.',
    );
    if (airportHint.isNotEmpty) {
      buf.write('- 공항 이동 수단 참고: $airportHint');
    }
    return buf.toString().trim();
  }

  String _buildAirportTransportHint(String city) {
    if (city.contains('오사카')) {
      return '간사이 공항↔난바: 난카이 라피트 약 45분 / 이타미 공항↔우메다: 리무진버스 약 30분';
    }
    if (city.contains('도쿄')) {
      return '나리타↔도쿄: N\'EX 약 60분 / 하네다↔도쿄: 케이큐선 약 30분';
    }
    if (city.contains('나고야')) {
      return '중부국제공항(센트레아)↔나고야역: 메이테츠 뮤스카이 약 28분';
    }
    if (city.contains('후쿠오카')) {
      return '후쿠오카 공항↔하카타역: 지하철 약 5분 / 하카타역↔텐진역: 지하철 약 6분';
    }
    if (city.contains('삿포로')) {
      return '신치토세 공항↔삿포로역: JR 쾌속 에어포트 약 37분';
    }
    if (city.contains('교토')) {
      return '간사이 공항↔교토역: 하루카 약 75분 / 이타미 공항↔교토역: 리무진버스 약 55분';
    }
    if (city.contains('가고시마')) {
      return '가고시마 공항↔가고시마추오역: 리무진버스 약 40분';
    }
    if (city.contains('시즈오카')) {
      return '후지산 시즈오카 공항↔시즈오카역: 리무진버스 약 40분';
    }
    return '';
  }

  String _buildAccommodationRule(PlanRequest request) {
    if (request.includeNearby) {
      return '- 근교 일정이 포함되어 있습니다. 근교 이동이 있는 날 전날은 해당 근교 출발에 유리한 터미널/역 근처 숙소를 별도로 제안하고, 나머지 날은 도심 중심부 숙소를 추천하세요.';
    }
    return '- 선택된 권역들의 지리적 중심에 가까운 역 근처 숙소를 추천하세요.';
  }
}
