// ─────────────────────────────────────────────
// 축(Axis) 6개 정의
// ─────────────────────────────────────────────
//
// [Speed]      여행 속도      : 빠름(+) ↔ 느림(−)
// [Explore]    탐색 방식      : 즉흥·발굴(+) ↔ 계획·검증(−)
// [Social]     관계 지향      : 현지인·어울림(+) ↔ 혼자·감상(−)
// [Sensory]    감각 방식      : 경험·몸(+) ↔ 감성·시각(−)
// [Nature]     환경 선호      : 자연·계절(+) ↔ 도시·공간(−)
// [Refinement] 심미 감도      : 공간·감도(+) ↔ 실용·열기(−)
//
// 유형별 축 프로파일:
//   Torii Red      : Speed+  Explore−  Social+  Sensory+  Nature−  Refinement−
//   Sunrise Orange : Speed+  Explore+  Social+  Sensory+  Nature−  Refinement−
//   Deep Indigo    : Speed−  Explore−  Social−  Sensory−  Nature−  Refinement+
//   Sakura Pink    : Speed0  Explore−  Social+  Sensory0  Nature0  Refinement+
//   Sky Blue       : Speed−  Explore0  Social−  Sensory+  Nature+  Refinement0
//   Snow White     : Speed−  Explore0  Social−  Sensory−  Nature+  Refinement0
//   Silver Mist    : Speed−  Explore−  Social−  Sensory−  Nature−  Refinement++
//   Matcha Green   : Speed0  Explore+  Social+  Sensory0  Nature0  Refinement−

class AxisScore {
  double speed; // 빠름(+) ↔ 느림(−)
  double explore; // 즉흥·발굴(+) ↔ 계획·검증(−)
  double social; // 현지·어울림(+) ↔ 혼자·감상(−)
  double sensory; // 경험·몸(+) ↔ 감성·시각(−)
  double nature; // 자연·계절(+) ↔ 도시·공간(−)
  double refinement; // 심미·공간 감도(+) ↔ 실용·열기(−)

  AxisScore({
    this.speed = 0,
    this.explore = 0,
    this.social = 0,
    this.sensory = 0,
    this.nature = 0,
    this.refinement = 0,
  });

  AxisScore operator +(AxisScore other) => AxisScore(
    speed: speed + other.speed,
    explore: explore + other.explore,
    social: social + other.social,
    sensory: sensory + other.sensory,
    nature: nature + other.nature,
    refinement: refinement + other.refinement,
  );

  @override
  String toString() =>
      'Speed:${speed.toStringAsFixed(1)} '
      'Explore:${explore.toStringAsFixed(1)} '
      'Social:${social.toStringAsFixed(1)} '
      'Sensory:${sensory.toStringAsFixed(1)} '
      'Nature:${nature.toStringAsFixed(1)} '
      'Refinement:${refinement.toStringAsFixed(1)}';
}
