import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/features/plan/models/place_model.dart';
import 'package:palette_michi/features/plan/providers/plan_provider.dart';
import 'package:palette_michi/features/plan/repositories/plan_repository.dart';
import 'package:palette_michi/features/plan/services/plan_service.dart';

// 기존 단순 Top N -> 권역 그룹 리스트로 변경
final areaGroupProvider = FutureProvider<List<AreaGroup>>((ref) async {
  final request = ref.watch(planProvider);
  final repository = ref.watch(planRepositoryProvider);
  final service = PlanService();

  final allPlaces = await repository.getCandidatePlaces(
    request.city ?? "도쿄",
    includeNearby: request.includeNearby, // 근교 포함 여부
  );

  final groups = service.groupByArea(allPlaces, request);
  return service.selectAreasForDays(groups, request.days ?? 3);
});

// 기존 recommendationProvider는 하위 호환용으로 유지
final recommendationProvider = FutureProvider<List<PlaceModel>>((ref) async {
  final groups = await ref.watch(areaGroupProvider.future);

  // 권역별 상위 장소들을 flat하게 펼쳐서 리턴
  // anchor 정렬 후 서브 스팟 순으로
  return groups.expand((g) {
    final anchor = g.places
        .where((sp) => sp.place.isAnchor)
        .map((sp) => sp.place);
    final subs = g.places
        .where((sp) => !sp.place.isAnchor)
        .map((sp) => sp.place);
    return [...anchor, ...subs];
  }).toList();
});
