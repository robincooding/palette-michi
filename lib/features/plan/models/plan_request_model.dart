import 'package:flutter/material.dart';

/// 여행 시간대
enum VisitTime {
  undecided(label: "미정", icon: Icons.help_outline),
  morning(label: "오전", icon: Icons.wb_sunny_outlined),
  afternoon(label: "오후", icon: Icons.wb_sunny),
  evening(label: "저녁", icon: Icons.nights_stay_outlined);

  final String label;
  final IconData icon;
  const VisitTime({required this.label, required this.icon});
}

/// Step 4-1: 여행의 큰 줄기를 결정하는 관심 카테고리
enum TripCategory {
  gourmet(
    label: "미식 탐방",
    description: "맛집, 이자카야, 지역 특산 요리, 미슐랭 맛집, 오마카세",
    recommendation: "현지 맛집과 특색 요리를 찾아다니며 먹는 즐거움을 추구하는 분",
    vibeColor: Color(0xFFEF5350),
  ),
  cafe(
    label: "카페 & 디저트",
    description: "감성 카페, 루프탑&뷰 카페, 스페셜티 커피, 킷사텐, 디저트 맛집, 베이커리",
    recommendation: "여유로운 카페 시간과 달콤한 디저트를 즐기고 싶은 분",
    vibeColor: Color(0xFFFFB74D),
  ),
  photo(
    label: "사진 & 감성",
    description: "인생샷 스팟, 도시 야경, 전망대, SNS 핫플, 팝업 스토어",
    recommendation: "특별한 순간을 사진으로 남기고 SNS에 공유하고 싶은 분",
    vibeColor: Color(0xFF29B6F6),
  ),
  culture(
    label: "전통 & 역사",
    description: "신사와 절, 전통 거리, 전통 가옥(마치야), 문화 체험",
    recommendation: "일본의 전통 문화와 역사를 깊이 있게 경험하고 싶은 분",
    vibeColor: Color(0xFF8D6E63),
  ),
  art(
    label: "예술 & 건축",
    description: "현대 미술관, 갤러리, 건축물 투어, 일러스트·캐릭터 아트 전시, 디자인 명소",
    recommendation: "현대 예술과 독특한 건축물을 감상하고 싶은 분",
    vibeColor: Color(0xFF7E57C2),
  ),
  nature(
    label: "자연 & 힐링",
    description: "온천, 료칸, 한적한 시골, 정원, 산책로, 계절 풍경",
    recommendation: "일상에서 벗어나 자연 속에서 여유롭게 쉬고 싶은 분",
    vibeColor: Color(0xFF66BB6A),
  ),
  shopping(
    label: "쇼핑 & 라이프",
    description: "빈티지샵, 셀렉트숍, 드럭스토어, 편집샵, 로컬 브랜드",
    recommendation: "일본 특유의 감각과 아이템을 발견하고 쇼핑하고 싶은 분",
    vibeColor: Color(0xFFEC407A),
  ),
  activity(
    label: "체험 & 액티비티",
    description: "애니 성지 순례, 요리 체험, 야외 활동, 원데이 클래스, 테마파크",
    recommendation: "특별한 체험과 활동적인 즐거움을 원하는 분",
    vibeColor: Color(0xFFFF7043),
  ),
  local(
    label: "현지인 모드",
    description: "센토, 슈퍼마켓, 주택가 산책, 동네 가게, 현지인의 일상",
    recommendation: "관광지보다 현지인의 일상을 경험하며 여행하고 싶은 분",
    vibeColor: Color(0xFF26A69A),
  );

  final String label;
  final String description;
  final String recommendation;
  final Color vibeColor;

  const TripCategory({
    required this.label,
    required this.description,
    required this.recommendation,
    required this.vibeColor,
  });
}

/// Step 4-2: 각 카테고리별 세부 스타일 (동적 질문용)
enum TripStyle {
  // Gourmet
  fineDining("미슐랭 & 고급 레스토랑", TripCategory.gourmet),
  omakase("오마카세 & 스시", TripCategory.gourmet),
  localEats("동네 맛집 & 이자카야", TripCategory.gourmet),
  streetFood("시장 & 길거리 음식", TripCategory.gourmet),
  // Cafe
  aestheticCafe("감성 공간 & 뷰 카페", TripCategory.cafe),
  traditional("전통 찻집 & 킷사텐", TripCategory.cafe),
  dessertFocus("디저트 & 베이커리", TripCategory.cafe),
  specialtyCoffee("스페셜티 커피", TripCategory.cafe),
  // Photo
  trending("SNS 핫플레이스", TripCategory.photo),
  hidden("나만 알고 싶은 숨은 명소", TripCategory.photo),
  nightscape("야경 & 전망대", TripCategory.photo),
  streetSnap("거리 스냅 & 골목길", TripCategory.photo),
  // Culture
  shrine("신사 & 절", TripCategory.culture),
  heritage("전통 거리 & 역사 유적", TripCategory.culture),
  experience("전통 문화 체험", TripCategory.culture),
  machiya("마치야(전통 가옥)", TripCategory.culture),
  // Art
  modernArt("현대 미술 & 갤러리", TripCategory.art),
  architecture("건축물 투어", TripCategory.art),
  museum("박물관 & 전시", TripCategory.art),
  illustArt("일러스트 & 캐릭터 아트 전시", TripCategory.art),
  // Nature
  onsen("온천 & 료칸", TripCategory.nature),
  scenic("계절 풍경 & 정원", TripCategory.nature),
  countryside("한적한 시골", TripCategory.nature),
  hiking("산책 & 트레킹", TripCategory.nature),
  // Shopping
  vintage("빈티지 & 중고샵", TripCategory.shopping),
  select("편집숍 & 브랜드", TripCategory.shopping),
  drugstore("드럭스토어", TripCategory.shopping),
  department("백화점 & 쇼핑몰", TripCategory.shopping),
  // Activity
  anime("애니 성지 순례", TripCategory.activity),
  outdoor("야외 활동", TripCategory.activity),
  workshop("원데이 클래스", TripCategory.activity),
  themePark("테마파크", TripCategory.activity),
  sports("스포츠 관람", TripCategory.activity),
  // Local
  residential("주택가 산책", TripCategory.local),
  market("현지 마트 & 시장", TripCategory.local),
  publicBath("대중목욕탕(센토)", TripCategory.local),
  neighborhood("로컬 아지트", TripCategory.local),
  izakayaBar("야간 포장마차 & 스탠드 술집(노미야)", TripCategory.local);

  final String label;
  final TripCategory category;
  const TripStyle(this.label, this.category);
}

/// 전체 여행 계획 요청 객체
class PlanRequest {
  final String? city;
  final int? days;
  final List<String> companions;
  final List<TripCategory> selectedCategories;
  final Map<TripCategory, List<TripStyle>> selectedStyles;
  final double density; // 0.0 ~ 1.0

  // 첫날과 마지막날 일정 고려
  final VisitTime arrivalTime;
  final VisitTime departureTime;

  // 근교 포함 여부
  final bool includeNearby;

  PlanRequest({
    this.city,
    this.days,
    this.companions = const [],
    this.selectedCategories = const [],
    this.selectedStyles = const {},
    this.density = 0.5,
    this.arrivalTime = VisitTime.undecided,
    this.departureTime = VisitTime.undecided,
    this.includeNearby = false,
  });

  PlanRequest copyWith({
    String? city,
    int? days,
    List<String>? companions,
    List<TripCategory>? selectedCategories,
    Map<TripCategory, List<TripStyle>>? selectedStyles,
    double? density,
    VisitTime? arrivalTime,
    VisitTime? departureTime,
    bool? includeNearby,
  }) {
    return PlanRequest(
      city: city ?? this.city,
      days: days ?? this.days,
      companions: companions ?? this.companions,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedStyles: selectedStyles ?? this.selectedStyles,
      density: density ?? this.density,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      departureTime: departureTime ?? this.departureTime,
      includeNearby: includeNearby ?? this.includeNearby,
    );
  }
}
