import 'package:palette_michi/features/plan/models/place_model.dart';
import 'package:palette_michi/features/plan/models/plan_request_model.dart';

typedef ScoredPlace = ({PlaceModel place, double score});

// 권역 그룹 모델
class AreaGroup {
  final String areaName;
  final PlaceModel anchor;
  final List<ScoredPlace> places;

  AreaGroup({
    required this.areaName,
    required this.anchor,
    required this.places,
  });

  // 권역 대표 점수: anchor 60% + 나머지 평균 40%
  double get areaScore {
    final anchorScore = places.firstWhere((p) => p.place.isAnchor).score;
    final othersAvg =
        places
            .where((p) => !p.place.isAnchor)
            .map((p) => p.score)
            .fold(0.0, (a, b) => a + b) /
        (places.where((p) => !p.place.isAnchor).length.clamp(1, 999));
    return anchorScore * 0.6 + othersAvg * 0.4;
  }
}

/// 추천 점수 가중치 상수
class _Weights {
  // 카테고리 점수 비중 -> 전체의 40%
  static const double category = 0.4;

  // 세부 스타일 점수 비중 -> 전체의 60% (정밀도 향상)
  static const double style = 0.6;

  // 카테고리가 일치하지 않더라도 스타일이 맞는 장소에 주는 보정치
  static const double styleOverflowBonus = 0.05;
}

class PlanService {
  double calculateScore(PlaceModel place, PlanRequest request) {
    final categoryScore = _calcCategoryScore(place, request);
    final styleScore = _calcStyleScore(place, request);

    return categoryScore * _Weights.category + styleScore * _Weights.style;
  }

  // 카테고리 점수 (0.0~1.0으로 정규화)
  double _calcCategoryScore(PlaceModel place, PlanRequest request) {
    if (request.selectedCategories.isEmpty) return 0.0;

    var total = request.selectedCategories.fold(0.0, (sum, cat) {
      return sum + (place.vibeScores[cat.name] ?? 0.0);
    });
    return total / request.selectedCategories.length; // normalization
  }

  // 세부 스타일 점수 (0.0~1.0으로 정규화)
  double _calcStyleScore(PlaceModel place, PlanRequest request) {
    if (request.selectedStyles.isEmpty) return 0.0;

    double total = 0.0;
    int count = 0;

    request.selectedStyles.forEach((cat, styles) {
      final isCategorySelected = request.selectedCategories.contains(cat);

      for (var style in styles) {
        var styleScore = place.vibeScores[style.name] ?? 0.0;

        if (isCategorySelected) {
          // 선택한 카테고리의 스타일 점수는 그대로 반영
          total += styleScore;
        } else {
          // 선택한 카테고리가 아닌데 스타일이 강하게 매치될 때의 보정치
          total += styleScore * _Weights.styleOverflowBonus;
        }
        count++;
      }
    });
    return count > 0 ? (total / count).clamp(0.0, 1.0) : 0.0;
  }

  // 하위 호환용 - 최종 후보군 추출 (Top N)
  List<PlaceModel> getTopCandidates(
    List<PlaceModel> allPlaces,
    PlanRequest request,
    int limit,
  ) {
    final scored = allPlaces.map((place) {
      return (place: place, score: calculateScore(place, request));
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));

    return scored.take(limit).map((e) => e.place).toList();
  }

  // area grouping
  List<AreaGroup> groupByArea(List<PlaceModel> allPlaces, PlanRequest request) {
    // 1.전체 scoring
    final scored = allPlaces
        .map((place) => (place: place, score: calculateScore(place, request)))
        .toList();

    // 2. areaName 기준 grouping
    final map = <String, List<ScoredPlace>>{};
    for (final sp in scored) {
      map.putIfAbsent(sp.place.areaName, () => []).add(sp);
    }

    // 3. AreaGroup 생성 (anchor없는 권역 제외)
    final groups = <AreaGroup>[];
    for (final entry in map.entries) {
      final anchor = entry.value.where((sp) => sp.place.isAnchor).toList();
      if (anchor.isEmpty) continue;

      groups.add(
        AreaGroup(
          areaName: entry.key,
          anchor: anchor.first.place,
          places: entry.value..sort((a, b) => b.score.compareTo(a.score)),
        ),
      );
    }

    // 4. 권역 점수 순 정렬
    groups.sort((a, b) => b.areaScore.compareTo(a.areaScore));
    return groups;
  }

  // 여행 일수에 맞게 상위 권역 선택
  List<AreaGroup> selectAreasForDays(
    List<AreaGroup> groups,
    int days, {
    double density = 0.5,
  }) {
    // density 반영: 밀도 높을수록 하루에 더 많은 권역 배정
    // density 0.0~0.4 → 하루 1권역
    // density 0.4~0.7 → 하루 1~2권역
    // density 0.7~1.0 → 하루 2권역
    final areasPerDay = density >= 0.7 ? 2 : 1;
    final limit = (days * areasPerDay).clamp(1, groups.length);
    return groups.take(limit).toList();
  }
}
