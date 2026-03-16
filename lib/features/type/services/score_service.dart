import 'dart:math';

import 'package:palette_michi/features/type/models/axis_score_model.dart';
import 'package:palette_michi/features/type/models/travel_question_model.dart';
import 'package:palette_michi/features/type/models/travel_type_model.dart';

// ─────────────────────────────────────────────
// 채점 엔진
//    코사인 유사도(Cosine Similarity) 기반 6축 벡터 매칭
//    + 구조적 경계 유형 보정 로직
// ─────────────────────────────────────────────

class TravelTypeResult {
  final TravelType primaryType;
  final TravelType secondaryType;
  final double primaryScore;
  final double secondaryScore;
  final AxisScore userProfile;
  final Map<TravelType, double> allScores;

  const TravelTypeResult({
    required this.primaryType,
    required this.secondaryType,
    required this.primaryScore,
    required this.secondaryScore,
    required this.userProfile,
    required this.allScores,
  });

  // 1·2위 점수 차이 < 0.08 이면 복합 경계형
  bool get isBorderline => (primaryScore - secondaryScore) < 0.08;

  @override
  String toString() {
    final pct = (primaryScore * 100).toStringAsFixed(1);
    final sPct = (secondaryScore * 100).toStringAsFixed(1);
    return '${primaryType.emoji} ${primaryType.colorName} '
        '(${primaryType.region}) [$pct%]\n'
        '2위: ${secondaryType.emoji} ${secondaryType.colorName} [$sPct%]\n'
        '축 프로파일: $userProfile\n'
        '경계형: $isBorderline';
  }
}

class TravelTypeScoringEngine {
  static TravelTypeResult calculate(
    List<Question> questions,
    List<int> selectedOptionIndices,
  ) {
    assert(questions.length == selectedOptionIndices.length);

    // Step 1: 가중치 반영 사용자 축 점수 합산
    final userProfile = _buildUserProfile(questions, selectedOptionIndices);

    // Step 2: 기본 코사인 유사도 계산 + 클램핑 (음수가 나오면 0으로)
    final scores = <TravelType, double>{};
    for (final type in TravelType.values) {
      scores[type] = _cosineSimilarity(
        userProfile,
        type.profile,
      ).clamp(0.0, 1.0);
    }

    // Step 3: 경계형 보정
    // ─ 보정 원칙 ─────────────────────────────────────────────────────────
    // Sakura Pink와 Silver Mist는 다른 유형과 축이 구조적으로 겹치는 경계 유형.
    // 순수 코사인 유사도만으로 안정적 분리가 어렵기 때문에,
    // 핵심 식별 조건을 충족하고 기본 점수도 어느 정도 나온 경우에만
    // 보정 점수를 가산해 최종 순위를 확정한다.

    // ─ Sakura Pink: 계획적이고 사교적인 미식가 ──────────────────────────
    // 식별 조건: social > 0 (사교성), explore < 0 (계획형), refinement > 0 (감도)
    // 프로파일 변경(Social 0→+1.5, Refinement +3→+2)에 따라 조건 업데이트
    // 기본 점수 임계값 > 0.30
    if (userProfile.social > 0 &&
        userProfile.explore < 0 &&
        userProfile.refinement > 0) {
      if ((scores[TravelType.sakuraPink] ?? 0) > 0.30) {
        scores[TravelType.sakuraPink] =
            (scores[TravelType.sakuraPink] ?? 0) + 0.10;
      }
    }

    // ─ Silver Mist: 도시 심미 감도가 극단적으로 높은 탐험가 ────────────────
    // 식별 조건: refinement > 20 (심미 누적), nature < -2 (강한 도시 지향)
    // nature 임계값 강화: 5→-2 (새 Q6 도시야경, Q8 럭셔리호텔 등으로 SM 유저는 nature 누적이 매우 낮음)
    // 기본 점수 임계값 > 0.40
    if (userProfile.refinement > 20 && userProfile.nature < -2) {
      if ((scores[TravelType.silverMist] ?? 0) > 0.40) {
        scores[TravelType.silverMist] =
            (scores[TravelType.silverMist] ?? 0) + 0.08;
      }
    }

    // Step 4: 정렬 -> 최종 유형 결정
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return TravelTypeResult(
      primaryType: sorted[0].key,
      secondaryType: sorted[1].key,
      primaryScore: sorted[0].value,
      secondaryScore: sorted[1].value,
      userProfile: userProfile,
      allScores: scores,
    );
  }

  // ── 내부 유틸 ──────────────────────────────────────────────────────────

  static AxisScore _buildUserProfile(
    List<Question> questions,
    List<int> selectedOptionIndices,
  ) {
    var profile = AxisScore();
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final idx = selectedOptionIndices[i];
      if (idx < 0 || idx >= q.options.length) continue;
      final raw = q.options[idx].score;
      final w = q.weight;
      profile =
          profile +
          AxisScore(
            speed: raw.speed * w,
            explore: raw.explore * w,
            social: raw.social * w,
            sensory: raw.sensory * w,
            nature: raw.nature * w,
            refinement: raw.refinement * w,
          );
    }
    return profile;
  }

  /// 코사인 유사도: -1(정반대) ~ 1(완전 일치)
  /// 반환 전 clamp(0, 1) 적용 — "얼마나 안 닮았는가"는 순위에 개입시키지 않음
  static double _cosineSimilarity(AxisScore a, AxisScore b) {
    final dot =
        a.speed * b.speed +
        a.explore * b.explore +
        a.social * b.social +
        a.sensory * b.sensory +
        a.nature * b.nature +
        a.refinement * b.refinement;
    final mag = _magnitude(a) * _magnitude(b);
    final similarity = mag == 0 ? 0.0 : dot / mag;
    return similarity.clamp(0.0, 1.0);
  }

  static double _magnitude(AxisScore s) => sqrt(
    s.speed * s.speed +
        s.explore * s.explore +
        s.social * s.social +
        s.sensory * s.sensory +
        s.nature * s.nature +
        s.refinement * s.refinement,
  );

  static void debugPrint(TravelTypeResult result) {
    // ignore: avoid_print
    print('━' * 50);
    print('🎨 팔레트 미치 타입 결과');
    print('━' * 50);
    print(result);
    print('');
    print('전체 유형 유사도:');
    final sorted = result.allScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (final e in sorted) {
      final bar = _bar(e.value);
      final pct = (e.value * 100).toStringAsFixed(1).padLeft(5);
      print('  ${e.key.emoji} ${e.key.colorName.padRight(16)} $pct%  $bar');
    }
    print('━' * 50);
  }

  static String _bar(double v) {
    final n = (v * 20).round().clamp(0, 20);
    return '[${'█' * n}${'░' * (20 - n)}]';
  }
}
