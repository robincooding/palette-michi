import 'package:flutter_riverpod/legacy.dart';
import 'package:palette_michi/features/plan/models/plan_request_model.dart';

// 외부에서 접근할 때
final planProvider = StateNotifierProvider<PlanNotifier, PlanRequest>((ref) {
  return PlanNotifier();
});

// PlanRequest 상태 관리 Notifier
class PlanNotifier extends StateNotifier<PlanRequest> {
  PlanNotifier() : super(PlanRequest());

  // Step1. 도시 선택 반영
  void updateCity(String city) {
    state = state.copyWith(city: city);
  }

  // Step2. 일정 선택 반영
  void updateDays(int days) {
    // 당일치기(days = 1)인 경우 근교 체크 해제
    state = state.copyWith(
      days: days,
      includeNearby: days == 1 ? false : state.includeNearby,
    );
  }

  // Step3. 여행 동반자 선택 반영
  void updateCompanion(String companion) {
    // 간편한 구현을 위해 우선 단일 선택 로직으로
    state = state.copyWith(companions: [companion]);
  }

  // Step4-1. toggle categories
  void toggleCategory(TripCategory category) {
    final currentCategories = List<TripCategory>.from(state.selectedCategories);
    final currentStyles = Map<TripCategory, List<TripStyle>>.from(
      state.selectedStyles,
    );
    if (currentCategories.contains(category)) {
      currentCategories.remove(category);
      currentStyles.remove(category); // 해당 카테고리를 해제하면, 관련 스타일도 함께 해제
    } else {
      // 최대 선택 개수 제한(4개로)
      if (currentCategories.length < 4) {
        currentCategories.add(category);
      }
    }

    state = state.copyWith(
      selectedCategories: currentCategories,
      selectedStyles: currentStyles,
    );
  }

  // Step4-2. toggle styles
  void toggleStyle(TripCategory category, TripStyle style) {
    final currentStyles = Map<TripCategory, List<TripStyle>>.from(
      state.selectedStyles,
    );
    final categoryStyles = List<TripStyle>.from(currentStyles[category] ?? []);

    if (categoryStyles.contains(style)) {
      categoryStyles.remove(style);
    } else {
      categoryStyles.add(style);
    }

    currentStyles[category] = categoryStyles;

    state = state.copyWith(selectedStyles: currentStyles);
  }

  // Step5. 여행 일정 밀도(농도) 반영
  void updateDensity(double density) {
    state = state.copyWith(density: density);
  }

  // 항공 시간 설정
  void updateArrivalTime(VisitTime time) {
    state = state.copyWith(arrivalTime: time);
  }

  void updateDepartureTime(VisitTime time) {
    state = state.copyWith(departureTime: time);
  }

  // 근교 포함 여부 토글
  void toggleIncludeNearby() {
    state = state.copyWith(includeNearby: !state.includeNearby);
  }

  // 상태 초기화
  void reset() {
    state = PlanRequest();
  }
}
