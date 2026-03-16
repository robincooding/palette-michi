import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/auth/providers/auth_provider.dart';
import 'package:palette_michi/features/auth/providers/firestore_service_provider.dart';
import 'package:palette_michi/features/type/models/travel_type_model.dart';
import 'package:palette_michi/features/type/providers/type_test_provider.dart';

class TypeResultScreen extends ConsumerStatefulWidget {
  /// 배지 열람 모드: 테스트 결과 없이 특정 타입을 직접 표시
  final TravelType? viewType;

  const TypeResultScreen({super.key, this.viewType});

  @override
  ConsumerState<TypeResultScreen> createState() => _TypeResultScreenState();
}

class _TypeResultScreenState extends ConsumerState<TypeResultScreen> {
  bool _isSaving = false;

  Future<void> _saveBadge(String uid, String typeName) async {
    setState(() => _isSaving = true);
    try {
      final badges = await ref
          .read(firestoreServiceProvider)
          .getTravelTypeBadges(uid);
      if (badges.length >= 2 && !badges.contains(typeName)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('배지는 최대 2개까지 저장할 수 있어요.')),
          );
        }
        setState(() => _isSaving = false);
        return;
      }
      await ref
          .read(firestoreServiceProvider)
          .saveTravelTypeBadge(uid, typeName);
      ref.invalidate(userTravelTypeBadgesProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('여행 컬러 배지가 저장되었어요!')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('저장 중 오류가 발생했습니다.')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(typeTestResultProvider);
    final authState = ref.watch(authStateProvider);
    final badgesAsync = ref.watch(userTravelTypeBadgesProvider);
    final user = authState.value;

    // viewType이 있으면 배지 열람 모드 (테스트 없이 직접 표시)
    final bool isBadgeViewMode = widget.viewType != null;
    final TravelType? type = widget.viewType ?? result?.primaryType;

    if (type == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final detail = type.detail;
    final themeColor = Color(
      int.parse(type.hexColor.substring(1, 7), radix: 16) + 0xFF000000,
    );
    final badges = badgesAsync.value ?? [];
    final alreadySaved = badges.contains(type.name);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: themeColor,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              title: Text(
                type.theme,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: [Shadow(color: Colors.black38, blurRadius: 8)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // 배경 그라디언트
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.alphaBlend(
                            Colors.black.withValues(alpha: 0.3),
                            themeColor,
                          ),
                          themeColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // 장식 원
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.25),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 배지 이미지 + 지역명
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 12,
                                spreadRadius: -4,
                              ),
                              BoxShadow(
                                color: themeColor.withValues(alpha: 0.35),
                                blurRadius: 24,
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            type.badgePath,
                            width: 200,
                            height: 200,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          type.region,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"${detail.signature}"',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    detail.description,
                    style: const TextStyle(
                      height: 1.7,
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildPairSection(themeColor, detail),
                  const SizedBox(height: 40),
                  _buildSectionTitle('유형 궁합'),
                  const SizedBox(height: 16),
                  ...detail.compatibleTypes.map(
                    (type) => Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: _buildRelationshipCard(
                        Icons.favorite,
                        '잘 맞는 유형',
                        type,
                        const Color(0xFF27AE60),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...detail.incompatibleTypes.map(
                    (type) => Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: _buildRelationshipCard(
                        Icons.not_interested,
                        '충돌하는 유형',
                        type,
                        const Color(0xFFC0392B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildSectionTitle('추천 여행 스팟 3'),
                  const SizedBox(height: 16),
                  ...List.generate(detail.recommendedSpots.length, (index) {
                    return _buildSpotCard(
                      index + 1,
                      detail.recommendedSpots[index],
                      detail.spotDescriptions[index],
                    );
                  }),
                  const SizedBox(height: 32),
                  // ── 배지 저장 버튼 (배지 열람 모드에서는 숨김) ──────────
                  if (user != null && !isBadgeViewMode)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: (_isSaving || alreadySaved)
                            ? null
                            : () => _saveBadge(user.uid, type.name),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: alreadySaved
                                ? AppColors.textTertiary
                                : themeColor,
                          ),
                          foregroundColor: alreadySaved
                              ? AppColors.textTertiary
                              : themeColor,
                        ),
                        child: _isSaving
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: themeColor,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    alreadySaved
                                        ? Icons.check_circle_outline
                                        : Icons.bookmark_add_outlined,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    alreadySaved ? '이미 저장된 배지예요' : '내 배지에 저장하기',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  if (user != null && !isBadgeViewMode)
                    const SizedBox(height: 12),
                  // ── 배지 열람: 닫기 / 테스트 결과: 다시 테스트 ──────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!isBadgeViewMode) {
                          ref.invalidate(userAnswersProvider);
                          ref.invalidate(typeTestIndexProvider);
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBadgeViewMode
                            ? themeColor
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isBadgeViewMode
                                ? Icons.close_rounded
                                : Icons.refresh,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isBadgeViewMode ? '닫기' : '다시 테스트하기',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildPairSection(Color color, TravelTypeDetail detail) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildColumnSection(color, '강점', detail.strengths)),
        const SizedBox(width: 20),
        Expanded(child: _buildColumnSection(color, '주의할 점', detail.weaknesses)),
      ],
    );
  }

  Widget _buildColumnSection(Color color, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              '• $item',
              style: const TextStyle(
                height: 1.4,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelationshipCard(
    IconData icon,
    String title,
    String content,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotCard(int number, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
