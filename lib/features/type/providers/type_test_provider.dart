import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:palette_michi/features/type/models/travel_question_model.dart';
import 'package:palette_michi/features/type/services/score_service.dart';

// 현재 응답 중인 질문 인덱스
final typeTestIndexProvider = StateProvider<int>((ref) => 0);

// 사용자가 선택한 답변의 인덱스 리스트 (초기값 -1)
final userAnswersProvider = StateProvider<List<int>>(
  (ref) => List.filled(12, -1),
);

// 결과 계산 Provider
final typeTestResultProvider = Provider<TravelTypeResult?>((ref) {
  final answers = ref.watch(userAnswersProvider);

  // 모든 질문에 답변했는지 확인
  if (answers.contains(-1)) return null;

  // 엔진 호출하여 결과 산출
  return TravelTypeScoringEngine.calculate(travelTypeQuestions, answers);
});
