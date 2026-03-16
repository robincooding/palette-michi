import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/core/providers/active_badge_provider.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/auth/providers/auth_provider.dart';
import 'package:palette_michi/features/auth/screens/login_screen.dart';
import 'package:palette_michi/features/booking/screens/booking_screen.dart';
import 'package:palette_michi/features/memo/screens/memo_screen.dart';
import 'package:palette_michi/features/mypage/screens/mypage_screen.dart';
import 'package:palette_michi/features/plan/screens/saved_plans_screen.dart';
import 'package:palette_michi/features/region/screens/favorite_regions_screen.dart';
import 'package:palette_michi/features/restaurant/screens/restaurant_screen.dart';
import 'package:palette_michi/features/tips/screens/travel_tips_screen.dart';
import 'package:palette_michi/features/type/models/travel_type_model.dart';
import 'package:palette_michi/features/type/screens/type_entrance_screen.dart';
import 'package:palette_michi/screens/app_info_screen.dart';

class HomeDrawer extends ConsumerWidget {
  /// 탭 셸 안에서 사용할 때만 전달. 특정 탭으로 이동 시 사용.
  final void Function(int tabIndex)? onGoToTab;
  const HomeDrawer({super.key, this.onGoToTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final nicknameAsync = ref.watch(userNicknameProvider);
    final profileImageUrlAsync = ref.watch(userProfileImageUrlProvider);
    final badgesAsync = ref.watch(userTravelTypeBadgesProvider);
    final activeBadge = ref.watch(activeBadgeProvider);
    final accentColor =
        ref.watch(activeBadgeColorProvider) ?? AppColors.primary;
    final headerBgColor = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.2),
      accentColor,
    );

    final double topPadding = MediaQuery.of(context).padding.top;

    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          // ── 프로필 헤더 ────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [headerBgColor, accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.fromLTRB(20, topPadding + 24, 20, 24),
            child: authState.when(
              data: (user) {
                if (user != null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Builder(
                            builder: (_) {
                              final imageUrl = profileImageUrlAsync.value;
                              return CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.white24,
                                backgroundImage: imageUrl != null
                                    ? CachedNetworkImageProvider(imageUrl)
                                    : null,
                                child: imageUrl == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 38,
                                        color: Colors.white,
                                      )
                                    : null,
                              );
                            },
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // 드로어 닫기
                              if (onGoToTab != null) {
                                onGoToTab!(4); // 마이페이지 탭 (index 4)
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MypageScreen(),
                                  ),
                                );
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              '프로필 편집',
                              style: TextStyle(
                                color: AppColors.textOnDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      nicknameAsync.when(
                        data: (nickname) => Text(
                          nickname ?? '여행가',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textOnDark,
                          ),
                        ),
                        loading: () => const SizedBox(height: 24),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                      // ── 배지 표시 ──────────────────────────────────
                      badgesAsync.when(
                        data: (badges) {
                          if (badges.isEmpty) return const SizedBox.shrink();
                          final types = badges
                              .map((name) {
                                try {
                                  return TravelType.values.firstWhere(
                                    (t) => t.name == name,
                                  );
                                } catch (_) {
                                  return null;
                                }
                              })
                              .whereType<TravelType>()
                              .toList();
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: types.map((t) {
                                final isActive = activeBadge == t;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.white.withValues(alpha: 0.28)
                                        : Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: isActive
                                          ? Colors.white.withValues(alpha: 0.7)
                                          : Colors.white.withValues(
                                              alpha: 0.25,
                                            ),
                                      width: isActive ? 1.5 : 1,
                                    ),
                                    boxShadow: isActive
                                        ? [
                                            BoxShadow(
                                              color: Colors.white.withValues(
                                                alpha: 0.15,
                                              ),
                                              blurRadius: 8,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: OverflowBox(
                                          maxWidth: 48,
                                          maxHeight: 48,
                                          child: Image.asset(t.badgePath, width: 48, height: 48),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        t.theme,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withValues(
                                            alpha: isActive ? 1.0 : 0.85,
                                          ),
                                          fontWeight: isActive
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                      if (isActive) ...[
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.check_rounded,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                    ],
                  );
                } else {
                  // 비로그인
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white24,
                          child: Icon(
                            Icons.person_outline,
                            size: 38,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '로그인 해주세요',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textOnDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '로그인 / 회원가입 →',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
              loading: () => const SizedBox(height: 80),
              error: (_, _) => const SizedBox(height: 80),
            ),
          ),

          // ── 메뉴 목록 ─────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 20),
                // 아이콘 카드 3개
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _DrawerIconCard(
                        icon: Icons.luggage_rounded,
                        label: '나의 여행',
                        accentColor: accentColor,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SavedPlansScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _DrawerIconCard(
                        icon: Icons.favorite_rounded,
                        label: '관심 여행지',
                        accentColor: accentColor,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FavoriteRegionsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _DrawerIconCard(
                        icon: Icons.edit_note_rounded,
                        label: '메모장',
                        accentColor: accentColor,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MemoScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(
                  color: AppColors.divider,
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                const SizedBox(height: 8),

                // 텍스트 메뉴
                _DrawerListTile(
                  icon: Icons.psychology_rounded,
                  label: '여행 타입 테스트',
                  accentColor: accentColor,
                  onTap: () {
                    Navigator.pop(context);
                    if (onGoToTab != null) {
                      onGoToTab!(3);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TypeEntranceScreen(),
                        ),
                      );
                    }
                  },
                ),

                const Divider(
                  color: AppColors.divider,
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),

                // ── 신규 메뉴 3개 ────────────────────────────────────
                _DrawerListTile(
                  icon: Icons.tips_and_updates_rounded,
                  label: '일본 여행 팁',
                  accentColor: accentColor,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TravelTipsScreen(),
                      ),
                    );
                  },
                ),
                _DrawerListTile(
                  icon: Icons.flight_rounded,
                  label: '항공·숙소 예약',
                  accentColor: accentColor,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BookingScreen()),
                    );
                  },
                ),
                _DrawerListTile(
                  icon: Icons.restaurant_menu_rounded,
                  label: '일본 맛집 정보',
                  accentColor: accentColor,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RestaurantScreen(),
                      ),
                    );
                  },
                ),

                const Divider(
                  color: AppColors.divider,
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),

                _DrawerListTile(
                  icon: Icons.info_outline_rounded,
                  label: '앱 소개',
                  accentColor: accentColor,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AppInfoScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerIconCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  const _DrawerIconCard({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentColor.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: accentColor, size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerListTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  const _DrawerListTile({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: accentColor, size: 22),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: AppColors.textTertiary,
      ),
      onTap: onTap,
    );
  }
}
