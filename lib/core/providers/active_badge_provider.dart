import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/features/auth/providers/auth_provider.dart';
import 'package:palette_michi/features/type/models/travel_type_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kActiveBadgeKey = 'active_badge';

/// 앱 시작 시 main.dart에서 override되어 주입됩니다.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

/// 현재 활성화된 여행 배지 (마이페이지에서 선택 → 앱 전체 반영 + 영속 저장)
class ActiveBadgeNotifier extends Notifier<TravelType?> {
  @override
  TravelType? build() {
    // 로그아웃(auth → null) 감지 시 배지 자동 초기화
    ref.listen<AsyncValue<User?>>(authStateProvider, (_, next) {
      if (!next.isLoading && next.value == null) {
        select(null);
      }
    });

    // 비로그인 상태에서는 저장된 배지를 복원하지 않음
    if (FirebaseAuth.instance.currentUser == null) return null;

    final prefs = ref.read(sharedPreferencesProvider);
    final saved = prefs.getString(_kActiveBadgeKey);
    if (saved == null) return null;
    try {
      return TravelType.values.firstWhere((t) => t.name == saved);
    } catch (_) {
      return null;
    }
  }

  void select(TravelType? badge) {
    state = badge;
    final prefs = ref.read(sharedPreferencesProvider);
    if (badge == null) {
      prefs.remove(_kActiveBadgeKey);
    } else {
      prefs.setString(_kActiveBadgeKey, badge.name);
    }
  }

  void toggle(TravelType badge) => select(state == badge ? null : badge);
}

final activeBadgeProvider =
    NotifierProvider<ActiveBadgeNotifier, TravelType?>(ActiveBadgeNotifier.new);

/// 활성 배지의 accent 색상 (없으면 null)
final activeBadgeColorProvider = Provider<Color?>((ref) {
  final badge = ref.watch(activeBadgeProvider);
  if (badge == null) return null;
  return Color(
    int.parse(badge.hexColor.substring(1, 7), radix: 16) + 0xFF000000,
  );
});
