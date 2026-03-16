import '../models/shopping_item_model.dart';

/// 도시별 + 카테고리별 쇼핑 필수템 static 데이터
/// city == null → 전국 공통 / city == '도쿄' 등 → 해당 도시 전용
class ShoppingItems {
  ShoppingItems._();

  /// 전국 공통 아이템
  static const List<ShoppingItem> _commonItems = [
    // ── 편의점 ──────────────────────────────────────────
    ShoppingItem(
      id: 'cv_tamagosando',
      title: '타마고 산도',
      category: '편의점',
      categoryType: ShoppingCategory.convenienceStore,
      description: '폭신폭신한 계란의 정석. 세븐일레븐이 원조, 아침 식사로 강추!',
      tags: ['#필수먹템', '#아침식사', '#가성비'],
    ),
    ShoppingItem(
      id: 'cv_onigiri',
      title: '오니기리',
      category: '편의점',
      categoryType: ShoppingCategory.convenienceStore,
      description: '참치마요·연어·매실 등 종류가 다양. 100~160엔대 가성비 간식.',
      tags: ['#가성비', '#간식'],
    ),
    ShoppingItem(
      id: 'cv_melon_bread',
      title: '멜론빵 아이스크림',
      category: '편의점',
      categoryType: ShoppingCategory.convenienceStore,
      description: '멜론빵 안에 소프트아이스크림을 넣은 일본 편의점 명물.',
      tags: ['#필수먹템', '#SNS핫템'],
    ),

    // ── 드럭스토어·돈키 ─────────────────────────────────
    ShoppingItem(
      id: 'drug_megurism',
      title: '메구리즘 안대',
      category: '드럭스토어·돈키',
      categoryType: ShoppingCategory.drugstore,
      description: '비행기·숙소에서 눈을 따뜻하게 감싸주는 스팀 안대. 선물용 강추.',
      tags: ['#꿀잠템', '#선물용', '#기내필수'],
    ),
    ShoppingItem(
      id: 'drug_salonpas',
      title: '샤론파스',
      category: '드럭스토어·돈키',
      categoryType: ShoppingCategory.drugstore,
      description: '걷다 지친 다리에 붙이면 시원함 두 배. 일본 드럭스토어 베스트셀러.',
      tags: ['#여행필수', '#선물용'],
    ),
    ShoppingItem(
      id: 'drug_hada_labo',
      title: '하다라보 화장수',
      category: '드럭스토어·돈키',
      categoryType: ShoppingCategory.drugstore,
      description: '한국보다 저렴하게 살 수 있는 히알루론산 수분 화장수.',
      tags: ['#뷰티', '#가성비', '#선물용'],
    ),
    ShoppingItem(
      id: 'drug_rohto',
      title: '로토 안약',
      category: '드럭스토어·돈키',
      categoryType: ShoppingCategory.drugstore,
      description: '강력한 청량감이 특징. 종류가 많으니 점원에게 추천받으세요.',
      tags: ['#뷰티', '#선물용'],
    ),
    ShoppingItem(
      id: 'drug_biore',
      title: '비오레 UV 아쿠아리치 선크림',
      category: '드럭스토어·돈키',
      categoryType: ShoppingCategory.drugstore,
      description: '워터리 제형으로 메이크업 전 사용 최적, 2026 드럭스토어 랭킹 상위.[web:26]',
      tags: ['#뷰티', '#여름필수', '#가성비'],
    ),
    ShoppingItem(
      id: 'donki_jagabee',
      title: '자가비 명란맛',
      category: '드럭스토어·돈키',
      categoryType: ShoppingCategory.drugstore,
      description: '짭짤 고소한 일본 감자스틱. 맥주 안주로 최고. 대용량 팩 추천.',
      tags: ['#과자', '#단짠단짠', '#야식'],
    ),
    ShoppingItem(
      id: 'donki_umaibo',
      title: '우마이봉 대용량',
      category: '드럭스토어·돈키',
      categoryType: ShoppingCategory.drugstore,
      description: '30엔짜리 일본 국민 과자. 돈키에서 박스째 사면 가성비 폭발.',
      tags: ['#과자', '#가성비', '#선물용'],
    ),
    ShoppingItem(
      id: 'donki_collagen',
      title: '콜라겐 드링크',
      category: '드럭스토어·돈키',
      categoryType: ShoppingCategory.drugstore,
      description: '종류·용량이 다양하고 한국보다 저렴. 돈키 뷰티 코너에서 발견 가능.',
      tags: ['#뷰티', '#건강'],
    ),
    ShoppingItem(
      id: 'donki_eve',
      title: 'EVE 진통제',
      category: '드럭스토어·돈키',
      categoryType: ShoppingCategory.drugstore,
      description: '두통·치통에 강력 효과, 수입 제한으로 돈키호테 필수 구매템.[web:25]',
      tags: ['#의약품', '#여행필수', '#최신핫템'],
    ),

    // ── 슈퍼·마트 ───────────────────────────────────────
    ShoppingItem(
      id: 'super_dashi',
      title: '혼다시 다시팩',
      category: '슈퍼·마트',
      categoryType: ShoppingCategory.supermarket,
      description: '일본 요리 맛의 핵심. 한국에서 구하기 어려운 가쓰오부시 다시.',
      tags: ['#식료품', '#선물용', '#주방템'],
    ),
    ShoppingItem(
      id: 'super_pocky',
      title: '포키 한정 맛',
      category: '슈퍼·마트',
      categoryType: ShoppingCategory.supermarket,
      description: '일본 슈퍼에서만 파는 지역·계절 한정 포키. 매장마다 구성이 달라요.',
      tags: ['#과자', '#선물용', '#한정판'],
    ),
    ShoppingItem(
      id: 'super_curry',
      title: '즉석 카레 (버몬트/코쿠마로)',
      category: '슈퍼·마트',
      categoryType: ShoppingCategory.supermarket,
      description: '일본 가정식 카레의 대명사. 한국 마트보다 훨씬 저렴.',
      tags: ['#식료품', '#가성비', '#선물용'],
    ),

    // ── 백화점·쇼핑몰 ────────────────────────────────────
    ShoppingItem(
      id: 'mall_wagashi',
      title: '백화점 지하 화과자',
      category: '백화점·쇼핑몰',
      categoryType: ShoppingCategory.shoppingMall,
      description: '데파치카(지하 식품관)의 고급 화과자. 포장이 예뻐 선물용으로 최적.',
      tags: ['#선물용', '#고급', '#화과자'],
    ),
    ShoppingItem(
      id: 'mall_tenugui',
      title: '데누구이 (てぬぐい)',
      category: '백화점·쇼핑몰',
      categoryType: ShoppingCategory.shoppingMall,
      description: '일본 전통 면 손수건. 백화점 잡화 코너에서 디자인이 다양.',
      tags: ['#전통공예', '#선물용', '#잡화'],
    ),
  ];

  /// 도시별 전용 아이템
  static const Map<String, List<ShoppingItem>> _cityItems = {
    '도쿄': [
      ShoppingItem(
        id: 'tokyo_baum',
        title: '도쿄 바나나',
        category: '백화점·쇼핑몰',
        categoryType: ShoppingCategory.shoppingMall,
        description: '도쿄 공항·역 한정 바나나 크림 카스텔라. 도쿄 대표 기념품.',
        tags: ['#도쿄한정', '#기념품', '#선물용'],
        city: '도쿄',
      ),
      ShoppingItem(
        id: 'tokyo_shiroi',
        title: '시로이 코이비토 (도쿄점)',
        category: '백화점·쇼핑몰',
        categoryType: ShoppingCategory.shoppingMall,
        description: '홋카이도 원산지만큼은 아니지만 도쿄 한정 패키지도 인기.',
        tags: ['#기념품', '#선물용', '#과자'],
        city: '도쿄',
      ),
      ShoppingItem(
        id: 'tokyo_specialty_nori',
        title: '아사쿠사 김 (야마모토야마)',
        category: '지역특산품',
        categoryType: ShoppingCategory.localSpecialty,
        description: '260년 역사의 아사쿠사 노포 김. 선물 세트 구성이 다양.',
        tags: ['#도쿄한정', '#선물용', '#전통식품'],
        city: '도쿄',
      ),
      ShoppingItem(
        id: 'tokyo_numbernine',
        title: '넘버슈가 카라멜',
        category: '백화점·쇼핑몰',
        categoryType: ShoppingCategory.shoppingMall,
        description: '오모테산도 한정 살살 녹는 생카라멜, 번호별 플레이버로 선물 인기.[web:6]',
        tags: ['#도쿄한정', '#SNS핫템', '#선물용'],
        city: '도쿄',
      ),
    ],
    '오사카': [
      ShoppingItem(
        id: 'osaka_551',
        title: '551 호라이 부타만',
        category: '슈퍼·마트',
        categoryType: ShoppingCategory.supermarket,
        description: '오사카 소울푸드 돼지고기만두. 오사카역·난바에 매장 다수.',
        tags: ['#오사카한정', '#필수먹템', '#줄서도OK'],
        city: '오사카',
      ),
      ShoppingItem(
        id: 'osaka_kuidaore',
        title: '쿠이다오레 타로 과자',
        category: '지역특산품',
        categoryType: ShoppingCategory.localSpecialty,
        description: '도톤보리 명물 타로 캐릭터 패키지 과자. 오사카 대표 기념품.',
        tags: ['#오사카한정', '#기념품', '#선물용'],
        city: '오사카',
      ),
      ShoppingItem(
        id: 'osaka_takoyaki_kit',
        title: '타코야키 믹스 가루',
        category: '슈퍼·마트',
        categoryType: ShoppingCategory.supermarket,
        description: '집에서 오사카 타코야키 재현! 슈퍼에서 저렴하게 구입 가능.',
        tags: ['#오사카한정', '#식료품', '#가성비'],
        city: '오사카',
      ),
    ],
    '교토': [
      ShoppingItem(
        id: 'kyoto_matcha_kit',
        title: '말차 킷캣',
        category: '드럭스토어·돈키',
        categoryType: ShoppingCategory.drugstore,
        description: '교토산 말차를 사용한 진한 녹차 킷캣. 교토 한정 패키지.',
        tags: ['#교토한정', '#선물용', '#말차'],
        city: '교토',
      ),
      ShoppingItem(
        id: 'kyoto_yatsuhashi',
        title: '야츠하시 (생·굽기)',
        category: '지역특산품',
        categoryType: ShoppingCategory.localSpecialty,
        description: '교토 1300년 전통 쌀가루 과자. 니키니키 생야츠하시가 특히 유명.',
        tags: ['#교토한정', '#전통과자', '#기념품'],
        city: '교토',
      ),
      ShoppingItem(
        id: 'kyoto_uchu',
        title: '우츄 교토 화과자',
        category: '백화점·쇼핑몰',
        categoryType: ShoppingCategory.shoppingMall,
        description: '심플한 모양의 고급 화과자 세트, 선물용으로 인기 있는 교토 감성 스위츠.',
        tags: ['#교토한정', '#고급', '#선물용'],
        city: '교토',
      ),
    ],
    '나고야': [
      ShoppingItem(
        id: 'nagoya_ogura_toast',
        title: '오구라 토스트 스프레드',
        category: '슈퍼·마트',
        categoryType: ShoppingCategory.supermarket,
        description: '나고야식 단팥버터 토스트를 집에서 즐길 수 있는 잼 스프레드.[web:38]',
        tags: ['#나고야한정', '#식료품', '#아침식사'],
        city: '나고야',
      ),
      ShoppingItem(
        id: 'nagoya_uirou',
        title: '나고야 우이로',
        category: '지역특산품',
        categoryType: ShoppingCategory.localSpecialty,
        description: '쫀득한 식감의 전통 증편 과자, 개별 포장으로 선물하기 좋음.[web:33]',
        tags: ['#나고야한정', '#전통과자', '#선물용'],
        city: '나고야',
      ),
      ShoppingItem(
        id: 'nagoya_misokatsu_sauce',
        title: '미소카츠 소스',
        category: '슈퍼·마트',
        categoryType: ShoppingCategory.supermarket,
        description: '붉은 된장을 사용한 진한 미소카츠 소스, 돈카츠에 곁들이면 현지 맛 그대로.[web:32]',
        tags: ['#나고야한정', '#식료품', '#주방템'],
        city: '나고야',
      ),
    ],
    '삿포로': [
      ShoppingItem(
        id: 'sapporo_shiroi',
        title: '시로이 코이비토',
        category: '지역특산품',
        categoryType: ShoppingCategory.localSpecialty,
        description: '홋카이도 대표 화이트초콜릿 샌드 과자. 삿포로 공장 한정 패키지.',
        tags: ['#삿포로한정', '#기념품', '#선물용'],
        city: '삿포로',
      ),
      ShoppingItem(
        id: 'sapporo_soup_curry',
        title: '수프 카레 루',
        category: '슈퍼·마트',
        categoryType: ShoppingCategory.supermarket,
        description: '삿포로 명물 수프카레를 집에서. 현지 슈퍼에서만 구할 수 있는 브랜드.',
        tags: ['#삿포로한정', '#식료품', '#선물용'],
        city: '삿포로',
      ),
      ShoppingItem(
        id: 'sapporo_butter_sand',
        title: '홋카이도 버터샌드',
        category: '지역특산품',
        categoryType: ShoppingCategory.localSpecialty,
        description: '진한 버터크림과 쿠키가 특징인 과자, 공항·역에서 인기.[web:11]',
        tags: ['#홋카이도한정', '#과자', '#선물용'],
        city: '삿포로',
      ),
    ],
    '후쿠오카': [
      ShoppingItem(
        id: 'fukuoka_mentaiko',
        title: '명란젓 (후쿠야)',
        category: '지역특산품',
        categoryType: ShoppingCategory.localSpecialty,
        description: '후쿠오카 명란의 원조. 선물용 포장 세트가 다양.',
        tags: ['#후쿠오카한정', '#선물용', '#명란'],
        city: '후쿠오카',
      ),
      ShoppingItem(
        id: 'fukuoka_hakata_ramen_kit',
        title: '하카타 라멘 세트',
        category: '슈퍼·마트',
        categoryType: ShoppingCategory.supermarket,
        description: '현지 마트에서만 구할 수 있는 하카타 돈코츠 라멘 팩.',
        tags: ['#후쿠오카한정', '#식료품', '#가성비'],
        city: '후쿠오카',
      ),
      ShoppingItem(
        id: 'fukuoka_hiyoko',
        title: '히요코 만쥬',
        category: '지역특산품',
        categoryType: ShoppingCategory.localSpecialty,
        description: '병아리 모양의 귀여운 과자, 후쿠오카 대표 기념품 중 하나.[web:27]',
        tags: ['#후쿠오카한정', '#기념품', '#전통과자'],
        city: '후쿠오카',
      ),
    ],
    '시즈오카': [
      ShoppingItem(
        id: 'shizuoka_green_tea',
        title: '시즈오카 녹차 티백 세트',
        category: '지역특산품',
        categoryType: ShoppingCategory.localSpecialty,
        description: '일본 최대 차 산지답게 향과 맛이 진한 녹차 세트.[web:22]',
        tags: ['#시즈오카한정', '#전통식품', '#선물용'],
        city: '시즈오카',
      ),
      ShoppingItem(
        id: 'shizuoka_matcha_sweets',
        title: '말차 과자 모음',
        category: '슈퍼·마트',
        categoryType: ShoppingCategory.supermarket,
        description: '말차 쿠키·초콜릿 등 녹차 향 가득한 디저트 세트.',
        tags: ['#시즈오카한정', '#과자', '#말차'],
        city: '시즈오카',
      ),
      ShoppingItem(
        id: 'shizuoka_wasabizuke',
        title: '와사비즈케',
        category: '지역특산품',
        categoryType: ShoppingCategory.localSpecialty,
        description: '시즈오카산 와사비를 사용한 절임 반찬, 밥·술안주로 잘 어울림.[web:29]',
        tags: ['#시즈오카한정', '#전통식품', '#안주'],
        city: '시즈오카',
      ),
    ],

    '가고시마': [
      ShoppingItem(
        id: 'kagoshima_satsuma_imokan',
        title: '사츠마 고구마 양갱',
        category: '지역특산품',
        categoryType: ShoppingCategory.localSpecialty,
        description: '가고시마 특산 사츠마 고구마로 만든 달콤한 양갱.[web:30]',
        tags: ['#가고시마한정', '#전통과자', '#선물용'],
        city: '가고시마',
      ),
      ShoppingItem(
        id: 'kagoshima_kurobuta_curry',
        title: '흑돼지 카레 루',
        category: '슈퍼·마트',
        categoryType: ShoppingCategory.supermarket,
        description: '가고시마 흑돼지를 사용한 진한 카레 루, 집에서 현지 맛 구현.[web:30]',
        tags: ['#가고시마한정', '#식료품', '#가성비'],
        city: '가고시마',
      ),
      ShoppingItem(
        id: 'kagoshima_shochu',
        title: '사츠마 쇼추 미니병',
        category: '지역특산품',
        categoryType: ShoppingCategory.localSpecialty,
        description: '고구마 베이스 지역 소주, 미니 사이즈로 기념품·선물로 적합.[web:23]',
        tags: ['#가고시마한정', '#주류', '#선물용'],
        city: '가고시마',
      ),
    ],

    '오키나와': [
      ShoppingItem(
        id: 'okinawa_chinsuko',
        title: '치인스코(ちんすこう)',
        category: '지역특산품',
        categoryType: ShoppingCategory.localSpecialty,
        description: '버터 풍미가 진한 전통 쿠키, 다양한 맛 세트로 판매.[web:24]',
        tags: ['#오키나와한정', '#전통과자', '#선물용'],
        city: '오키나와',
      ),
      ShoppingItem(
        id: 'okinawa_beniimo_tart',
        title: '벤이모 타르트',
        category: '지역특산품',
        categoryType: ShoppingCategory.localSpecialty,
        description: '보라색 고구마를 사용한 달콤한 타르트, 오키나와 대표 기념품.',
        tags: ['#오키나와한정', '#디저트', '#SNS핫템'],
        city: '오키나와',
      ),
      ShoppingItem(
        id: 'okinawa_salt',
        title: '오키나와 소금 세트',
        category: '슈퍼·마트',
        categoryType: ShoppingCategory.supermarket,
        description: '다양한 산호·바다 소금 미니 세트, 요리와 선물용으로 인기.[web:31]',
        tags: ['#오키나와한정', '#전통식품', '#주방템'],
        city: '오키나와',
      ),
    ],
  };

  /// 도시에 맞는 아이템 반환 (공통 + 해당 도시 전용)
  static List<ShoppingItem> getItemsForCity(String city) {
    final citySpecific = _cityItems[city] ?? [];
    return [..._commonItems, ...citySpecific];
  }

  /// 카테고리 필터 적용
  static List<ShoppingItem> getFilteredItems({
    required String city,
    required ShoppingCategory category,
  }) {
    final all = getItemsForCity(city);
    if (category == ShoppingCategory.all) return all;
    return all.where((item) => item.categoryType == category).toList();
  }
}
