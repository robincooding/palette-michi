import 'package:palette_michi/features/type/models/axis_score_model.dart';

// ─────────────────────────────────────────────
// 8유형 정의
// ─────────────────────────────────────────────

enum TravelType {
  toriiRed,
  sunriseOrange,
  deepIndigo,
  sakuraPink,
  skyBlue,
  snowWhite,
  silverMist,
  matchaGreen,
}

// 상세 데이터 구조체
class TravelTypeDetail {
  final String signature; // 시그니처 멘트
  final String description; // 여행 정체성
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> compatibleTypes;
  final List<String> incompatibleTypes;
  final List<String> recommendedSpots;
  final List<String> spotDescriptions; // 추천 스팟 상세 설명

  const TravelTypeDetail({
    required this.signature,
    required this.description,
    required this.strengths,
    required this.weaknesses,
    required this.compatibleTypes,
    required this.incompatibleTypes,
    required this.recommendedSpots,
    required this.spotDescriptions,
  });
}

extension TravelTypeInfo on TravelType {
  String get colorName => _mapInfo['colorName']!;
  String get region => _mapInfo['region']!;
  String get theme => _mapInfo['theme']!;
  String get emoji => _mapInfo['emoji']!;
  String get hexColor => _mapInfo['hexColor']!;

  /// assets/badges 폴더의 배지 이미지 경로
  String get badgePath {
    switch (this) {
      case TravelType.toriiRed:     return 'assets/badges/badge_tokyo.png';
      case TravelType.sunriseOrange: return 'assets/badges/badge_osaka.png';
      case TravelType.deepIndigo:   return 'assets/badges/badge_kyoto.png';
      case TravelType.sakuraPink:   return 'assets/badges/badge_fukuoka.png';
      case TravelType.skyBlue:      return 'assets/badges/badge_okinawa.png';
      case TravelType.snowWhite:    return 'assets/badges/badge_sapporo.png';
      case TravelType.silverMist:   return 'assets/badges/badge_kobe.png';
      case TravelType.matchaGreen:  return 'assets/badges/badge_nagoya.png';
    }
  }

  /// 상세 데이터 매핑
  TravelTypeDetail get detail {
    switch (this) {
      case TravelType.toriiRed:
        return const TravelTypeDetail(
          signature: "3박 4일에 20곳은 가야지",
          description:
              "당신의 여행은 에너지 그 자체입니다. 출발 전부터 동선을 촘촘하게 짜고, 현지에 도착하면 가장 먼저 지도를 펼쳐요. 트렌디한 카페, 화제의 팝업, 인스타그램 핫플 — 지금 가장 뜨거운 것들을 직접 두 눈으로 확인하고 싶어하죠. 도쿄처럼 끊임없이 움직이고, 끊임없이 새로운 자극을 흡수하는 당신은 진정한 도시 정복자입니다.",
          strengths: ["빠른 판단력", "높은 실행력", "여행에서 아무것도 놓치지 않겠다는 강한 의지"],
          weaknesses: ["빡빡한 일정 탓에 예상치 못한 여백의 아름다움을 지나치는 경우가 있어요."],
          compatibleTypes: [
            "Matcha Green 나고야형 - 당신이 끌고 가면, 나고야형이 숨겨진 로컬 명소를 발굴해줘요.",
            "Sunrise Orange 오사카형 — 오사카형의 즉흥 감각에 당신의 추진력이 더해지면 일정이 쉬지 않고 굴러가요.",
          ],
          incompatibleTypes: [
            "Snow White 삿포로형 — 당신이 세 곳을 다녀오는 동안 Snow White는 아직 설원을 바라보고 있어요.",
          ],
          recommendedSpots: [
            "시부야 스크램블 교차로 & 미야시타 파크",
            "하라주쿠 & 오모테산도",
            "아키하바라 & 긴자 식스",
          ],
          spotDescriptions: [
            "도쿄의 에너지를 온몸으로 느낄 수 있는 상징적 공간",
            "트렌드의 최전선, 팝업과 플래그십 스토어가 밀집",
            "서브컬처부터 럭셔리까지, 취향 스펙트럼이 넓은 정복자를 위한 선택지",
          ],
        );
      case TravelType.sunriseOrange:
        return const TravelTypeDetail(
          signature: "여행은 먹으러 가는 것",
          description:
              "당신에게 여행의 진짜 맛은 계획 밖에 있어요. 줄 서있는 식당에 무작정 들어가고, 낯선 골목 끝까지 따라가 보고, 현지인이 건네는 한 마디에 예정에 없던 곳을 가기도 하죠. 오사카처럼 활기차고 따뜻하고 솔직한 당신은 여행지 어디서든 자연스럽게 그 공기 속으로 녹아들어요. 먹고 웃고 부딪히는 것, 그게 당신의 여행입니다.",
          strengths: ["어디서든 즐길 거리를 찾아내는 탁월한 현장 감각", "개방적인 에너지"],
          weaknesses: ["즉흥성이 강한 만큼 이동과 대기에서 예상보다 시간을 많이 쓸 수 있어요."],
          compatibleTypes: [
            "Torii Red 도쿄형 - 도쿄형의 계획에 즉흥적인 즐거움을 더해줄 수 있어요.",
            "Matcha Green 나고야형 — 당신의 활기에 나고야형의 발굴 감각이 더해지면 아무도 모르는 골목 맛집이 계속 나타나요.",
          ],
          incompatibleTypes: [
            "Deep Indigo 교토형 — 교토형의 세밀한 계획과 당신의 즉흥성이 충돌하는 경우가 있어요.",
          ],
          recommendedSpots: ["도톤보리 & 쿠로몬 시장", "신세카이 & 쟝쟝 요코초", "오사카 츠루하시 시장"],
          spotDescriptions: [
            "오사카 에너지의 중심. 먹고 싶은 건 다 여기 있어요.",
            "현지인 냄새가 물씬 나는 골목 선술집 투어",
            "거대한 재래시장, 발길 닿는 대로 들어가면 됩니다",
          ],
        );
      case TravelType.deepIndigo:
        return const TravelTypeDetail(
          signature: "여기서 2시간 있어도 돼",
          description:
              "당신은 여행을 '깊이'로 경험합니다. 관광지에서 셔터를 누르기 전에 먼저 그 공간을 느끼고, 역사적 맥락을 이해하고, 왜 지금 내가 여기에 있는지를 생각해요. 계획을 꼼꼼하게 짜지만, 좋은 골목을 발견하면 기꺼이 두 시간을 그 자리에 쏟을 수 있어요. 교토처럼 층층이 쌓인 아름다움을 아는 사람, 그게 바로 당신입니다.",
          strengths: ["깊은 관찰력", "섬세한 감수성", "어디서든 남다른 시선으로 여행을 기록"],
          weaknesses: ["한 곳에 오래 머무는 성향 탓에 일정이 뒤로 밀리는 경우가 많아요."],
          compatibleTypes: [
            "Silver Mist 고베형 — 감도가 비슷해서 서로의 취향을 자연스럽게 존중해요.",
            "Snow White 삿포로형 — 삿포로형도 계절 하나를 위해 떠나는 사람. 서두르지 않는 여행 태도가 서로 통해요.",
          ],
          incompatibleTypes: [
            "Sunrise Orange 오사카형 — 즉흥적인 오사카형과는 여행 리듬이 맞지 않을 수 있어요.",
          ],
          recommendedSpots: [
            "후시미이나리 새벽 탐방",
            "니시키 시장 골목 & 기온 옛거리",
            "아라시야마 텐류지 & 대나무 숲",
          ],
          spotDescriptions: [
            "사람 없는 이른 아침, 진짜 교토를 만나는 시간",
            "계획 없이 걷다가 발견하는 숨은 공간들",
            "소리와 빛이 달라지는 경험, 분석가만이 포착할 수 있는 순간",
          ],
        );
      case TravelType.sakuraPink:
        return const TravelTypeDetail(
          signature: "적당히 보고 적당히 쉬자",
          description:
              "당신의 여행은 균형을 아는 사람만이 만들 수 있는 작품이에요. 너무 바쁘지도, 너무 느리지도 않게. 하루 서너 곳을 여유 있게 다니고, 맛있는 라멘 한 그릇에 30분을 쓰는 것도 아깝지 않아요. 후쿠오카처럼 콤팩트하면서도 콘텐츠가 꽉 찬 당신의 여행은 돌아오고 나서도 피로감보다 여운이 더 오래 남아요.",
          strengths: ["여행과 휴식 사이의 균형을 본능적으로 잡는 능력", "동행을 편하게 만들어요."],
          weaknesses: ["모험적인 시도보다 검증된 선택을 선호해서 뜻밖의 발견이 적을 수 있어요."],
          compatibleTypes: [
            "Silver Mist 고베형 — 감도의 결이 같아요. 어떤 카페를 고를지, 어떤 골목을 걸을지 말하지 않아도 통해요.",
          ],
          incompatibleTypes: [
            "Sunrise Orange 오사카형 — 오사카형의 줄서기·즉흥 행보에 당신의 섬세한 계획이 계속 무너져요.",
          ],
          recommendedSpots: [
            "나카스 야타이 포장마차 거리",
            "다자이후 텐만구 & 카나마치",
            "하카타 리버레인 & 캐널시티",
          ],
          spotDescriptions: [
            "후쿠오카의 낭만이 집약된 밤, 라멘과 모츠나베가 기다려요",
            "역사와 감성이 공존하는 후쿠오카의 여유로운 반나절",
            "쇼핑과 산책, 카페가 자연스럽게 이어지는 미식가의 동선",
          ],
        );
      case TravelType.skyBlue:
        return const TravelTypeDetail(
          signature: "아무것도 안 하는 게 목표",
          description:
              "당신에게 여행의 이유는 단 하나, '완전한 해방'이에요. 알림을 끄고, 일정표를 접고, 에메랄드빛 바다 앞에 그냥 앉아 있는 것. 오키나와의 햇살처럼 느리고 따뜻하게 흐르는 당신의 여행은 남들 눈에 심심해 보일 수 있지만, 당신은 알아요. 진짜 재충전은 아무것도 하지 않는 데서 온다는 것을.",
          strengths: ["여행에서 제대로 된 휴식", "돌아왔을 때 에너지가 완전히 회복"],
          weaknesses: ["구체적인 일정이 없어 동행과 갈등이 생길 수 있고, 여행지를 충분히 못 볼 수도 있어요."],
          compatibleTypes: [
            "Snow White 삿포로형 — 둘 다 자연 앞에서 멈출 줄 알아요. 빠른 일정 없이 느릿느릿, 여행 리듬이 딱 맞아요.",
          ],
          incompatibleTypes: [
            "Torii Red 도쿄형 — 당신이 바다를 바라보는 동안 도쿄형은 이미 세 군데를 다녀와요.",
          ],
          recommendedSpots: ["잔파곶 & 에메랄드 비치", "국제거리 & 마키시 공설시장", "코우리섬 드라이브"],
          spotDescriptions: [
            "사오키나와 북부의 조용한 해변. 사람 없이 바다를 온전히 독점하고 싶을 때",
            "해변 사이사이 여유로운 쇼핑과 오키나와 음식 탐방",
            "다리 위에서 바라보는 수평선, 속도를 낮추면 더 아름다운 길",
          ],
        );
      case TravelType.snowWhite:
        return const TravelTypeDetail(
          signature: "눈 보러 가는 여행",
          description:
              "당신의 여행에는 뚜렷한 이유가 있어요. 눈이 오기 때문에, 단풍이 지기 때문에, 벚꽃이 피기 때문에. 계절과 자연이 당신의 여행을 설계해요. 삿포로의 눈밭처럼 고요하고 순백한 풍경 속에서 당신은 비로소 숨을 고를 수 있어요. 번잡한 관광보다 자연이 주는 압도적인 순간 하나가, 당신에게는 열 개의 핫플보다 가치 있어요.",
          strengths: ["계절과 자연을 활용한 여행 타이밍 감각", "여행에서 진짜 감동을 찾아냄"],
          weaknesses: ["날씨와 계절에 여행이 좌우되어, 예상과 다를 때 실망이 클 수 있어요."],
          compatibleTypes: [
            "Sky Blue 오키나와형 — 둘 다 자연이 부르면 움직이는 타입. 말 없이 바다와 설원을 함께 바라보는 여행이 잘 맞아요.",
            "Deep Indigo 교토형 — 교토형도 한 곳에 오래 머무는 타입. 계절을 온전히 느끼는 속도가 잘 맞아요.",
          ],
          incompatibleTypes: [
            "Torii Red 도쿄형 — 자연 앞에서 멈추고 싶은 당신과, 다음 목적지로 달리고 싶은 도쿄형은 충돌해요.",
          ],
          recommendedSpots: [
            "삿포로 눈 축제 (2월) & 오도리 공원 ",
            "노보리베츠 지옥계곡 & 온천",
            "후라노 & 비에이 드라이브",
          ],
          spotDescriptions: [
            "사눈으로 가득 찬 삿포로의 정점, 매년 이 시기를 위해 떠나요",
            "설원 속 온천",
            "계절마다 전혀 다른 얼굴을 보여주는 홋카이도의 진수",
          ],
        );
      case TravelType.silverMist:
        return const TravelTypeDetail(
          signature: "여기서 커피 한 잔은 마셔야지",
          description:
              "당신은 여행에서 '감도'를 추구해요. 어떤 카페를 고르는지, 어떤 골목을 걷는지, 어떤 기념품을 사는지 등 모든 선택에서 당신만의 심미안이 드러납니다. 이국적인 항구 도시 고베처럼 서양과 일본이 세련되게 섞인 공간에서 당신은 특히 빛나요. 화려함보다 정갈함, 유행보다 클래식을 아는 사람입니다.",
          strengths: ["공간과 분위기를 읽는 탁월한 심미적 감각", "누가 가르쳐주지 않아도 좋은 것을 알아봄"],
          weaknesses: ["완벽한 분위기를 찾다 보면 결정이 느려지고, 일정이 카페 중심으로 흘러갈 수 있어요."],
          compatibleTypes: [
            "Deep Indigo 교토형 — 감성의 결이 비슷해서 말 없이도 여행 취향이 맞아요.",
            "Sakura Pink 후쿠오카형 — 후쿠오카형도 공간의 감도를 아는 사람. 둘이 고른 카페는 항상 정답이에요.",
          ],
          incompatibleTypes: [
            "Sunrise Orange 오사카형 — 오사카형의 에너지와 즉흥성에 Silver Mist는 금방 피로감을 느낄 수 있어요.",
          ],
          recommendedSpots: [
            "기타노 이진칸 언덕 & 풍견관",
            "메리켄 파크 & 모토마치 상점가",
            "아리마 온천 & 고베 야경",
          ],
          spotDescriptions: [
            "고베 이국성의 정수, 공간 자체가 미적 경험",
            "항구 뷰와 세련된 쇼핑 거리가 이어지는 동선",
            "도시 감성과 전통이 공존하는 고베만의 조합",
          ],
        );
      case TravelType.matchaGreen:
        return const TravelTypeDetail(
          signature: "관광객 말고 현지인처럼",
          description:
              "당신은 유명 관광지보다 그 도시 사람들이 실제로 사는 풍경에 더 끌려요. 아침 시장에서 현지인들과 함께 줄을 서고, 관광객이 잘 모르는 동네 이자카야에서 저녁을 먹고, 이름도 없는 골목 공원에서 잠깐 쉬는 것. 나고야처럼 '잘 모르는 사람은 그냥 지나치는' 도시에서 오히려 보석을 발견하는 타입이 바로 당신이에요.",
          strengths: ["발굴의 기쁨을 아는 여행자", "아무도 모르는 곳을 발견했을 때의 쾌감"],
          weaknesses: ["정보 수집에 시간을 많이 써서 여행 전 준비가 길어지거나, 기대와 다를 때 실망할 수 있어요."],
          compatibleTypes: [
            "Torii Red 도쿄형 — 도쿄형이 빠르게 이동할 때, 당신이 숨겨진 로컬 명소를 콕 찍어줘요.",
            "Sunrise Orange 오사카형 — 오사카형의 활기에 당신의 발굴 감각이 더해지면 아무도 모르는 맛집과 골목이 계속 나타나요.",
          ],
          incompatibleTypes: [
            "Deep Indigo 교토형 — 당신이 시장 골목을 열 번 돌 때 Deep Indigo는 첫 번째 신사에서 아직 나오지 않았어요.",
          ],
          recommendedSpots: [
            "오오스 상점가 & 오오스 칸논",
            "나고야 성 & 주변 골목",
            "사카에 지하상가 & 이마이케 카페 거리",
          ],
          spotDescriptions: [
            "나고야 로컬의 일상이 그대로 담긴 번화가, 현지인 간식 탐방 필수",
            "관광지이지만 그 주변 골목에서 진짜 나고야를 발견할 수 있어요",
            "현지 MZ 세대가 모이는 공간, 아직 한국 여행자에게 덜 알려진 곳",
          ],
        );
    }
  }

  /// 데이터 통합 맵
  Map<String, String> get _mapInfo {
    switch (this) {
      case TravelType.toriiRed:
        return {
          'colorName': 'Torii Red',
          'region': '도쿄 (Tokyo)',
          'theme': '열정적인 정복자',
          'emoji': '🔴',
          'hexColor': '#C0392B',
        };
      case TravelType.sunriseOrange:
        return {
          'colorName': 'Sunrise Orange',
          'region': '오사카 (Osaka)',
          'theme': '낭만적 즉흥가',
          'emoji': '🟠',
          'hexColor': '#E67E22',
        };
      case TravelType.deepIndigo:
        return {
          'colorName': 'Deep Indigo',
          'region': '교토 (Kyoto)',
          'theme': '꼼꼼한 분석가',
          'emoji': '🟣',
          'hexColor': '#4A235A',
        };
      case TravelType.sakuraPink:
        return {
          'colorName': 'Sakura Pink',
          'region': '후쿠오카 (Fukuoka)',
          'theme': '로맨틱한 미식가',
          'emoji': '🩷',
          'hexColor': '#D98095',
        };
      case TravelType.skyBlue:
        return {
          'colorName': 'Sky Blue',
          'region': '오키나와 (Okinawa)',
          'theme': '자유로운 바다 여행가',
          'emoji': '🔵',
          'hexColor': '#2980B9',
        };
      case TravelType.snowWhite:
        return {
          'colorName': 'Snow White',
          'region': '삿포로 (Sapporo)',
          'theme': '겨울 낭만가',
          'emoji': '⬜',
          'hexColor': '#7F8C8D',
        };
      case TravelType.silverMist:
        return {
          'colorName': 'Silver Mist',
          'region': '고베 (Kobe)',
          'theme': '감도 높은 도시 탐험가',
          'emoji': '🩶',
          'hexColor': '#5D6D7E',
        };
      case TravelType.matchaGreen:
        return {
          'colorName': 'Matcha Green',
          'region': '나고야 (Nagoya)',
          'theme': '여유로운 현지 탐방가',
          'emoji': '🟢',
          'hexColor': '#27AE60',
        };
    }
  }

  /// 각 유형의 이상적 축 프로파일 (코사인 유사도 계산용)
  AxisScore get profile {
    switch (this) {
      case TravelType.toriiRed:
        return AxisScore(
          speed: 2.0,
          explore: -0.5,
          social: 1.5,
          sensory: 1.0,
          nature: -1.5,
          refinement: -2.0,
        );
      case TravelType.sunriseOrange:
        return AxisScore(
          speed: 1.5,
          explore: 2.0,
          social: 2.0,
          sensory: 1.5,
          nature: -1.0,
          refinement: -1.5,
        );
      case TravelType.deepIndigo:
        return AxisScore(
          speed: -2.0,
          explore: -1.5,
          social: -2.0,
          sensory: -2.0,
          nature: -0.5,
          refinement: 1.0,
        );
      case TravelType.sakuraPink:
        // Social+1.5: 미식을 함께 즐기는 사교형, Sensory+0.5: 음식 경험 중심
        // Refinement 3→2: Silver Mist와 코사인 유사도 78%→25%로 분리
        return AxisScore(
          speed: -0.5,
          explore: -1.5,
          social: 1.5,
          sensory: 0.5,
          nature: 0.0,
          refinement: 2.0,
        );
      case TravelType.skyBlue:
        return AxisScore(
          speed: -1.5,
          explore: 0.5,
          social: -0.5,
          sensory: 1.0,
          nature: 2.0,
          refinement: 0.5,
        );
      case TravelType.snowWhite:
        return AxisScore(
          speed: -1.5,
          explore: -0.5,
          social: -1.5,
          sensory: -1.5,
          nature: 2.5,
          refinement: 0.5,
        );
      case TravelType.silverMist:
        // Speed 0: 목적지 명확하므로 정체 않음. Explore 0: 심미 공간을 능동적으로 탐색
        // Deep Indigo와 코사인 유사도 77%→60%, Sakura Pink와 78%→25%로 분리
        return AxisScore(
          speed: 0.0,
          explore: 0.0,
          social: -1.5,
          sensory: -2.0,
          nature: -2.5,
          refinement: 3.5,
        );
      case TravelType.matchaGreen:
        // Social 1.5→0: 로컬에 '스며드는' 관찰자, 큰 무리와 어울리지 않음
        // Nature -0.5→+0.5: 주택가·골목·공원 등 생활 환경 선호
        // Sunrise Orange와 코사인 유사도 86%→58%로 분리
        return AxisScore(
          speed: 0.0,
          explore: 2.0,
          social: 0.0,
          sensory: 0.5,
          nature: 0.5,
          refinement: -0.5,
        );
    }
  }
}
