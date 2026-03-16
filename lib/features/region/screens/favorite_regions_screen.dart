import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/auth/providers/auth_provider.dart';
import 'package:palette_michi/features/auth/providers/firestore_service_provider.dart';
import 'package:palette_michi/features/region/data/region_details_data.dart';
import 'package:palette_michi/features/region/models/region_model.dart';
import 'package:palette_michi/features/region/screens/region_detail_screen.dart';
import 'package:palette_michi/widgets/palette_app_bar.dart';

class FavoriteRegionsScreen extends ConsumerWidget {
  const FavoriteRegionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final favoritesAsync = ref.watch(favoriteRegionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaletteAppBar(title: '관심 여행지', dark: true),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '로그인 후 이용할 수 있어요',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
          return favoritesAsync.when(
            data: (favorites) {
              if (favorites.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '관심 여행지가 없어요',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '일본 지역 가이드에서\n마음에 드는 지역을 저장해 보세요!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final validFavorites = favorites
                  .map((name) {
                    try {
                      return RegionGroup.values.firstWhere(
                        (g) => g.name == name,
                      );
                    } catch (_) {
                      return null;
                    }
                  })
                  .whereType<RegionGroup>()
                  .where((g) => g != RegionGroup.nowhere)
                  .toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: validFavorites.length,
                itemBuilder: (context, index) {
                  final group = validFavorites[index];
                  final detail = regionDetails[group];
                  if (detail == null) return const SizedBox.shrink();
                  final color = getGroupColor(group);

                  return _FavoriteRegionCard(
                    group: group,
                    detail: detail,
                    color: color,
                    uid: user.uid,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RegionDetailScreen(detail: detail, group: group),
                        ),
                      );
                    },
                    onRemove: () {
                      ref
                          .read(firestoreServiceProvider)
                          .toggleFavoriteRegion(user.uid, group.name);
                    },
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (_, _) => const Center(child: Text('오류가 발생했습니다.')),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }
}

class _FavoriteRegionCard extends StatelessWidget {
  final RegionGroup group;
  final RegionDetail detail;
  final Color color;
  final String uid;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteRegionCard({
    required this.group,
    required this.detail,
    required this.color,
    required this.uid,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 8,
                color: color, // clipBehavior가 모서리 처리하므로 borderRadius 불필요
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getGroupKoreanName(group),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        detail.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detail.majorCities.take(2).join(' · '),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: AppColors.accent),
                onPressed: onRemove,
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ), // Row
        ), // IntrinsicHeight
      ), // Container
    ); // GestureDetector
  }
}
