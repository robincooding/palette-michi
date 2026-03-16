import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/core/providers/active_badge_provider.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/auth/providers/auth_provider.dart';
import 'package:palette_michi/features/auth/providers/firestore_service_provider.dart';
import 'package:palette_michi/features/type/models/travel_type_model.dart';
import 'package:palette_michi/features/type/screens/type_entrance_screen.dart';
import 'package:palette_michi/features/type/screens/type_result_screen.dart';

class MypageBadgeSection extends ConsumerWidget {
  final TravelType? selectedBadge;
  final ValueChanged<TravelType> onBadgeTap;
  final String? uid;

  const MypageBadgeSection({
    super.key,
    required this.selectedBadge,
    required this.onBadgeTap,
    this.uid,
  });

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, TravelType type) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('${type.emoji} ${type.colorName} 배지 삭제'),
        content: const Text('이 배지를 삭제하시겠어요?\n삭제 후에도 다시 테스트하면 얻을 수 있어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || uid == null) return;
    await ref.read(firestoreServiceProvider).removeTravelTypeBadge(uid!, type.name);
    ref.invalidate(userTravelTypeBadgesProvider);
    // 삭제된 배지가 현재 선택돼 있었다면 전역 state 초기화
    if (ref.read(activeBadgeProvider) == type) {
      ref.read(activeBadgeProvider.notifier).select(null);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(userTravelTypeBadgesProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '나의 여행 컬러',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
            ),
            padding: const EdgeInsets.all(16),
            child: badgesAsync.when(
              data: (badges) {
                if (badges.isEmpty) {
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TypeEntranceScreen())),
                    child: const _EmptyBadgeRow(),
                  );
                }

                final types = badges
                    .map((name) {
                      try {
                        return TravelType.values.firstWhere((t) => t.name == name);
                      } catch (_) {
                        return null;
                      }
                    })
                    .whereType<TravelType>()
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 탭 힌트 - 배지가 있을 때 항상 표시
                    _TapHintRow(selectedBadge: selectedBadge),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: types
                          .map((t) => MypageBadgeChip(
                                type: t,
                                isSelected: selectedBadge == t,
                                onTap: () => onBadgeTap(t),
                                onDelete: uid != null
                                    ? () => _confirmDelete(context, ref, t)
                                    : null,
                                onDetail: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TypeResultScreen(viewType: t),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    if (badges.length < 2)
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TypeEntranceScreen())),
                        child: Row(
                          children: [
                            Icon(Icons.add_circle_outline, size: 16, color: AppColors.primary.withValues(alpha: 0.7)),
                            const SizedBox(width: 6),
                            Text(
                              '배지 추가하기 (${badges.length}/2)',
                              style: TextStyle(fontSize: 12, color: AppColors.primary.withValues(alpha: 0.7), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        '최대 2개의 배지를 보유할 수 있어요.',
                        style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      ),
                  ],
                );
              },
              loading: () => const Center(
                child: SizedBox(height: 40, child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
              ),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 탭 힌트 행 ────────────────────────────────────────────────────────────────

class _TapHintRow extends StatelessWidget {
  final TravelType? selectedBadge;
  const _TapHintRow({required this.selectedBadge});

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedBadge != null;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Row(
        key: ValueKey(isSelected),
        children: [
          Icon(
            isSelected ? Icons.palette : Icons.touch_app_outlined,
            size: 13,
            color: isSelected
                ? Color(int.parse(selectedBadge!.hexColor.substring(1, 7), radix: 16) + 0xFF000000).withValues(alpha: 0.8)
                : AppColors.textTertiary,
          ),
          const SizedBox(width: 5),
          Text(
            isSelected ? '다시 탭하면 기본 테마로 돌아와요' : '배지를 탭해서 나만의 테마로 꾸며보세요',
            style: TextStyle(
              fontSize: 11,
              color: isSelected
                  ? Color(int.parse(selectedBadge!.hexColor.substring(1, 7), radix: 16) + 0xFF000000).withValues(alpha: 0.75)
                  : AppColors.textTertiary,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 빈 배지 행 ────────────────────────────────────────────────────────────────

class _EmptyBadgeRow extends StatelessWidget {
  const _EmptyBadgeRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('🎨', style: TextStyle(fontSize: 22)),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('아직 배지가 없어요', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              SizedBox(height: 2),
              Text('여행 유형 테스트로 나의 여행 컬러를 발견해보세요.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
      ],
    );
  }
}

// ── 배지 칩 ───────────────────────────────────────────────────────────────────

class MypageBadgeChip extends StatelessWidget {
  final TravelType type;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onDetail;

  const MypageBadgeChip({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
    this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(type.hexColor.substring(1, 7), radix: 16) + 0xFF000000);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedScale(
            scale: isSelected ? 1.04 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.18) : color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? color : color.withValues(alpha: 0.35),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(type.badgePath, width: 30, height: 30),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(type.colorName, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
                      Text(type.theme, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ],
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.check_circle_rounded, size: 15, color: color),
                  ],
                  if (onDelete != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.textTertiary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 11, color: AppColors.textTertiary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (onDetail != null) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onDetail,
            child: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline_rounded, size: 13, color: color.withValues(alpha: 0.8)),
                  const SizedBox(width: 4),
                  Text(
                    '유형 상세 보기',
                    style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_forward_rounded, size: 13, color: color),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
