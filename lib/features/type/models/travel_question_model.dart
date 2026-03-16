import 'package:palette_michi/features/type/models/axis_score_model.dart';

// ─────────────────────────────────────────────
// 질문 및 선택지 모델
// ─────────────────────────────────────────────

class AnswerOption {
  final String text;
  final AxisScore score;
  const AnswerOption({required this.text, required this.score});
}

class Question {
  final int id;
  final String text;
  final List<AnswerOption> options;

  /// 질문 가중치: 1.0 = 기본, 1.5 = 중요, 2.0 = 핵심 타이브레이커
  final double weight;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    this.weight = 1.0,
  });
}

// ─────────────────────────────────────────────
// 12개 질문 데이터
// ─────────────────────────────────────────────

final List<Question> travelTypeQuestions = [
  Question(
    id: 1,
    text: '여행 출발 전날 밤, 당신은?',
    weight: 1.0,
    options: [
      AnswerOption(
        text: '동선과 예약을 마지막으로 한 번 더 점검한다',
        score: AxisScore(
          speed: 1.5,
          explore: -2.0,
          social: 0.0,
          sensory: 0.0,
          nature: 0.0,
          refinement: -1.0,
        ),
      ),
      AnswerOption(
        text: '딱히 준비 없이 설레는 마음으로 일찍 잠든다',
        score: AxisScore(
          speed: -1.0,
          explore: 0.5,
          social: 0.0,
          sensory: -1.0,
          nature: 0.5,
          refinement: 0.5,
        ),
      ),
      AnswerOption(
        text: 'SNS에서 현지 핫플을 밤새 저장한다',
        score: AxisScore(
          speed: 2.0,
          explore: -0.5,
          social: 1.0,
          sensory: 0.5,
          nature: -1.0,
          refinement: -1.5,
        ),
      ),
      AnswerOption(
        text: '짐만 대충 싸고 나머지는 현지에서 결정한다',
        score: AxisScore(
          speed: 0.0,
          explore: 2.0,
          social: 0.5,
          sensory: 0.5,
          nature: 0.0,
          refinement: 0.0,
        ),
      ),
    ],
  ),

  Question(
    id: 2,
    text: '공항에 내리자마자 가장 먼저 하고 싶은 것은?',
    weight: 1.0,
    options: [
      AnswerOption(
        text: '숙소에 짐 풀고 첫 목적지로 바로 출발',
        score: AxisScore(
          speed: 2.0,
          explore: -0.5,
          social: 0.5,
          sensory: 0.5,
          nature: -0.5,
          refinement: -2.0,
        ),
      ),
      AnswerOption(
        text: '편의점에 들러 현지 분위기를 먼저 흡수',
        score: AxisScore(
          speed: 0.5,
          explore: 1.0,
          social: 1.5,
          sensory: 1.5,
          nature: 0.0,
          refinement: -1.0,
        ),
      ),
      AnswerOption(
        text: '카페에 앉아 오늘 하루 흐름을 천천히 그려본다',
        score: AxisScore(
          speed: -1.5,
          explore: -1.0,
          social: -1.0,
          sensory: -1.5,
          nature: 0.0,
          refinement: 2.0,
        ),
      ),
      AnswerOption(
        text: '일단 밖으로 나가 걷고 바람을 맡는다',
        score: AxisScore(
          speed: -0.5,
          explore: 1.5,
          social: -0.5,
          sensory: 0.5,
          nature: 1.5,
          refinement: 0.0,
        ),
      ),
    ],
  ),

  Question(
    id: 3,
    text: '교토 골목을 걷다가 지도에 없는 작은 신사를 발견했다. 당신은?',
    weight: 1.5,
    options: [
      AnswerOption(
        text: '일단 들어가서 구석구석 탐색한다',
        score: AxisScore(
          speed: -0.5,
          explore: 2.0,
          social: 0.5,
          sensory: 0.5,
          nature: 0.5,
          refinement: 0.0,
        ),
      ),
      AnswerOption(
        text: '사진을 찍고 이 순간을 여행의 하이라이트로 기억한다',
        score: AxisScore(
          speed: -1.0,
          explore: 0.0,
          social: -1.0,
          sensory: -2.0,
          nature: 0.0,
          refinement: 1.5,
        ),
      ),
      AnswerOption(
        text: '다음 목적지가 있으니 겉만 보고 지나친다',
        score: AxisScore(
          speed: 2.0,
          explore: -1.5,
          social: 0.0,
          sensory: 0.0,
          nature: 0.0,
          refinement: -2.0,
        ),
      ),
      AnswerOption(
        text: '왜 지도에 없지? 찾아보고 맥락을 파악한다',
        score: AxisScore(
          speed: -0.5,
          explore: -1.0,
          social: -1.0,
          sensory: -1.5,
          nature: 0.0,
          refinement: 2.0,
        ),
      ),
    ],
  ),

  // Q4: Deep Indigo(역사·문화) vs Silver Mist(도시 심미 공간) 핵심 구분 질문
  // 교체 이전: "계획 틀어졌을 때" → Speed/Explore 중복 측정
  Question(
    id: 4,
    text: '여행지에서 예상치 못한 여유 시간이 생겼다. 제일 먼저 하는 것은?',
    weight: 1.5,
    options: [
      AnswerOption(
        text: '근처 사찰이나 유적지에 들어가 배경을 천천히 들여다본다',
        score: AxisScore(
          speed: -1.5,
          explore: -0.5,
          social: -1.5,
          sensory: -1.5,
          nature: 0.5,
          refinement: 1.5,
        ),
      ),
      AnswerOption(
        text: '평점 좋은 카페를 검색해 직접 분위기를 확인하러 간다',
        score: AxisScore(
          speed: -0.5,
          explore: 0.5,
          social: -1.0,
          sensory: -1.5,
          nature: -2.0,
          refinement: 2.5,
        ),
      ),
      AnswerOption(
        text: '지도 없이 골목을 걷다 마음에 드는 곳에 들어간다',
        score: AxisScore(
          speed: -0.5,
          explore: 2.0,
          social: 0.5,
          sensory: 1.0,
          nature: 0.5,
          refinement: -0.5,
        ),
      ),
      AnswerOption(
        text: '계획했던 다음 목적지로 바로 이동한다',
        score: AxisScore(
          speed: 2.0,
          explore: -1.5,
          social: 0.5,
          sensory: 0.5,
          nature: -0.5,
          refinement: -1.5,
        ),
      ),
    ],
  ),

  Question(
    id: 5,
    text: '동행자가 "오늘 각자 자유롭게 다니자"고 한다면?',
    weight: 1.5,
    options: [
      AnswerOption(
        text: '반갑다. 혼자 걷고 싶었던 골목이 있었다',
        score: AxisScore(
          speed: -0.5,
          explore: 1.0,
          social: -2.0,
          sensory: -1.0,
          nature: 0.5,
          refinement: 1.5,
        ),
      ),
      AnswerOption(
        text: '아쉽다. 같이 움직이는 게 더 재밌는데',
        score: AxisScore(
          speed: 0.5,
          explore: 0.0,
          social: 2.0,
          sensory: 1.0,
          nature: 0.0,
          refinement: -1.0,
        ),
      ),
      AnswerOption(
        text: '좋아! 바로 혼자만의 맛집 루트를 가동한다',
        score: AxisScore(
          speed: 1.0,
          explore: 1.0,
          social: 0.0,
          sensory: 2.0,
          nature: -0.5,
          refinement: 0.5,
        ),
      ),
      AnswerOption(
        text: '상관없다. 원래 내 페이스대로 다닐 생각이었다',
        score: AxisScore(
          speed: -1.0,
          explore: 0.5,
          social: -1.5,
          sensory: -0.5,
          nature: 0.5,
          refinement: 0.5,
        ),
      ),
    ],
  ),

  // Q6: Nature 축 집중 측정 + Silver Mist(도시) / Deep Indigo(문화) 추가 구분
  // 교체 이전: "아깝다고 느끼는 순간" → 추상적이고 변별력 낮음
  Question(
    id: 6,
    text: '지금 이 순간 가장 설레는 여행지 풍경을 하나 고른다면?',
    weight: 1.5,
    options: [
      AnswerOption(
        text: '도시 야경 — 빌딩 불빛과 네온사인이 반짝이는 밤거리',
        score: AxisScore(
          speed: 0.5,
          explore: 0.0,
          social: -1.0,
          sensory: -1.5,
          nature: -3.0,
          refinement: 2.5,
        ),
      ),
      AnswerOption(
        text: '광활한 자연 — 설원이나 에메랄드 바다 앞에 서 있는 나',
        score: AxisScore(
          speed: -2.0,
          explore: 0.5,
          social: -1.5,
          sensory: 0.5,
          nature: 3.0,
          refinement: 0.0,
        ),
      ),
      AnswerOption(
        text: '활기찬 야시장 — 사람들의 열기와 맛있는 냄새',
        score: AxisScore(
          speed: 0.5,
          explore: 1.5,
          social: 2.5,
          sensory: 2.0,
          nature: -1.0,
          refinement: -1.5,
        ),
      ),
      AnswerOption(
        text: '고즈넉한 사찰 정원 — 이끼 낀 돌담과 조용한 골목',
        score: AxisScore(
          speed: -1.5,
          explore: -0.5,
          social: -2.0,
          sensory: -1.0,
          nature: 0.5,
          refinement: 1.5,
        ),
      ),
    ],
  ),

  Question(
    id: 7,
    text: '여행 사진을 찍는 나의 스타일은?',
    weight: 1.5,
    options: [
      AnswerOption(
        text: '풍경과 분위기 위주 — 사람이 거의 안 나온다',
        score: AxisScore(
          speed: -1.0,
          explore: 0.0,
          social: -1.5,
          sensory: -2.0,
          nature: 1.0,
          refinement: 1.5,
        ),
      ),
      AnswerOption(
        text: '음식과 거리 스냅 — 현장감이 중요하다',
        score: AxisScore(
          speed: 0.5,
          explore: 1.0,
          social: 1.0,
          sensory: 2.0,
          nature: -0.5,
          refinement: -1.0,
        ),
      ),
      AnswerOption(
        text: '셀카와 인물 — 내가 거기 있었다는 게 중요하다',
        score: AxisScore(
          speed: 1.0,
          explore: 0.0,
          social: 1.5,
          sensory: 0.5,
          nature: -1.0,
          refinement: -1.5,
        ),
      ),
      AnswerOption(
        text: '잘 안 찍는다. 눈으로 담는 게 먼저다',
        score: AxisScore(
          speed: -1.5,
          explore: 0.5,
          social: -2.0,
          sensory: -1.5,
          nature: 0.5,
          refinement: 2.0,
        ),
      ),
    ],
  ),

  Question(
    id: 8,
    text: '나에게 이상적인 여행 숙소는?',
    weight: 1.5,
    options: [
      AnswerOption(
        text: '오래된 료칸이나 마치야 — 공간 자체가 여행이다',
        score: AxisScore(
          speed: -1.5,
          explore: -0.5,
          social: -1.0,
          sensory: -2.0,
          nature: 0.0,
          refinement: 2.5,
        ),
      ),
      AnswerOption(
        text: '접근성 좋은 비즈니스 호텔 — 숙소는 잠만 자는 곳이다',
        score: AxisScore(
          speed: 2.0,
          explore: -1.0,
          social: 0.0,
          sensory: 0.5,
          nature: -1.0,
          refinement: -2.5,
        ),
      ),
      AnswerOption(
        text: '바다나 자연이 보이는 리조트 — 숙소가 목적지다',
        score: AxisScore(
          speed: -2.0,
          explore: 0.0,
          social: 0.5,
          sensory: 0.5,
          nature: 2.5,
          refinement: 0.5,
        ),
      ),
      AnswerOption(
        text: '현지인 동네의 아파트형 숙소 — 생활감이 좋다',
        score: AxisScore(
          speed: 0.0,
          explore: 1.5,
          social: 2.0,
          sensory: 0.5,
          nature: -0.5,
          refinement: -0.5,
        ),
      ),
      AnswerOption(
        text: '좋은 호텔이나 럭셔리 숙소에서 제대로 쉬고 싶다 - 예산을 더 써도 좋다',
        score: AxisScore(
          speed: -1.0,
          explore: -1.0,
          social: -0.5,
          sensory: -1.0,
          nature: -2.0,
          refinement: 3.0,
        ),
      ),
    ],
  ),

  Question(
    id: 9,
    text: '현지에서 밥을 먹을 때 나는?',
    weight: 2.0,
    options: [
      AnswerOption(
        text: '미리 찾아둔 맛집 리스트를 따른다',
        score: AxisScore(
          speed: 0.5,
          explore: -2.0,
          social: -0.5,
          sensory: 1.0,
          nature: -0.5,
          refinement: 2.5,
        ),
      ),
      AnswerOption(
        text: '줄 서있는 곳, 사람 많은 곳으로 무조건 들어간다',
        score: AxisScore(
          speed: 1.0,
          explore: 0.5,
          social: 2.0,
          sensory: 2.0,
          nature: -0.5,
          refinement: -2.0,
        ),
      ),
      AnswerOption(
        text: '골목 안쪽 이름 없는 식당에서 현지인과 함께 먹는다',
        score: AxisScore(
          speed: -0.5,
          explore: 2.0,
          social: 2.0,
          sensory: 1.0,
          nature: 0.0,
          refinement: -0.5,
        ),
      ),
      AnswerOption(
        text: '음식보다 분위기가 좋은 카페나 레스토랑을 고른다',
        score: AxisScore(
          speed: -0.5,
          explore: -0.5,
          social: -0.5,
          sensory: -2.0,
          nature: -1.0,
          refinement: 2.5,
        ),
      ),
    ],
  ),

  Question(
    id: 10,
    text: '여행 중 예상치 못한 폭우가 쏟아졌다. 당신은?',
    weight: 1.0,
    options: [
      AnswerOption(
        text: '근처 카페에 들어가 빗소리를 들으며 멍을 때린다',
        score: AxisScore(
          speed: -2.0,
          explore: 0.0,
          social: -1.0,
          sensory: -1.5,
          nature: 0.5,
          refinement: 2.0,
        ),
      ),
      AnswerOption(
        text: '편의점 우산을 사서 원래 계획을 그대로 진행한다',
        score: AxisScore(
          speed: 2.0,
          explore: -1.5,
          social: 0.0,
          sensory: 0.0,
          nature: -0.5,
          refinement: -2.0,
        ),
      ),
      AnswerOption(
        text: '비 맞는 거리 자체가 새로운 경험이라며 그냥 걷는다',
        score: AxisScore(
          speed: 0.0,
          explore: 2.0,
          social: 0.5,
          sensory: 1.5,
          nature: 1.0,
          refinement: 0.0,
        ),
      ),
      AnswerOption(
        text: '실내 관광지나 시장으로 동선을 즉흥적으로 바꾼다',
        score: AxisScore(
          speed: 0.5,
          explore: 1.5,
          social: 1.0,
          sensory: 1.0,
          nature: -1.0,
          refinement: -0.5,
        ),
      ),
    ],
  ),

  Question(
    id: 11,
    text: '여행 마지막 날 저녁, 이상적인 마무리는?',
    weight: 1.0,
    options: [
      AnswerOption(
        text: '조용한 골목 선술집에서 혼자 조용히 한 잔',
        score: AxisScore(
          speed: -0.5,
          explore: 0.5,
          social: -2.0,
          sensory: -0.5,
          nature: 0.0,
          refinement: 2.5,
        ),
      ),
      AnswerOption(
        text: '왁자지껄한 이자카야에서 여행의 에너지를 마무리',
        score: AxisScore(
          speed: 0.5,
          explore: 0.5,
          social: 2.0,
          sensory: 1.5,
          nature: -0.5,
          refinement: -1.5,
        ),
      ),
      AnswerOption(
        text: '숙소에서 짐 정리하며 여행을 조용히 회고한다',
        score: AxisScore(
          speed: -1.0,
          explore: -1.0,
          social: -2.0,
          sensory: -1.5,
          nature: 0.0,
          refinement: 1.5,
        ),
      ),
      AnswerOption(
        text: '마지막까지 야경 스팟을 찾아 돌아다닌다',
        score: AxisScore(
          speed: 1.5,
          explore: 1.0,
          social: 0.0,
          sensory: -1.0,
          nature: 0.5,
          refinement: 0.5,
        ),
      ),
    ],
  ),

  /// Q12 — 타이브레이커 (6개 장면, 각 유형에 강한 시그널)
  Question(
    id: 12,
    text: '지금 이 순간, 가장 끌리는 일본의 장면은?',
    weight: 2.0,
    options: [
      AnswerOption(
        text: '새벽 안개 낀 후시미이나리의 붉은 도리이', // Deep Indigo
        score: AxisScore(
          speed: -2.0,
          explore: -1.0,
          social: -2.0,
          sensory: -2.5,
          nature: 0.5,
          refinement: 2.0,
        ),
      ),
      AnswerOption(
        text: '도톤보리의 네온사인과 사람들의 열기', // Sunrise Orange
        score: AxisScore(
          speed: 1.5,
          explore: 1.5,
          social: 2.5,
          sensory: 2.0,
          nature: -2.0,
          refinement: -2.5,
        ),
      ),
      AnswerOption(
        text: '광활한 설원 위 아무도 없는 홋카이도의 길', // Snow White
        score: AxisScore(
          speed: -2.5,
          explore: 0.5,
          social: -2.0,
          sensory: -1.5,
          nature: 3.0,
          refinement: 0.5,
        ),
      ),
      AnswerOption(
        text: '항구가 내려다보이는 고베 언덕 위 카페', // Silver Mist
        score: AxisScore(
          speed: -1.5,
          explore: -1.0,
          social: -1.5,
          sensory: -2.5,
          nature: -1.0,
          refinement: 3.0,
        ),
      ),
      AnswerOption(
        text: '오키나와 에메랄드빛 바다 위 선셋', // Sky Blue
        score: AxisScore(
          speed: -2.0,
          explore: 0.5,
          social: -1.0,
          sensory: 1.0,
          nature: 2.5,
          refinement: 0.5,
        ),
      ),
      AnswerOption(
        text: '나고야 아침 시장에서 현지인들 틈에 섞여 있는 나', // Matcha Green
        // Social +2.5→+0.5: 관찰·스며들기형, Nature -0.5→+0.5: 주택가·생활 환경 선호
        score: AxisScore(
          speed: 0.0,
          explore: 2.0,
          social: 0.5,
          sensory: 1.0,
          nature: 0.5,
          refinement: -1.0,
        ),
      ),
    ],
  ),
];
