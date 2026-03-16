import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/plan/providers/plan_provider.dart';
import 'package:palette_michi/features/plan/screens/select_vibe_screen.dart';
import 'package:palette_michi/widgets/palette_app_bar.dart';
import 'package:palette_michi/widgets/step_bottom_bar.dart';

class SelectCompanionScreen extends ConsumerWidget {
  const SelectCompanionScreen({super.key});

  final List<Map<String, dynamic>> companionOptions = const [
    {'label': '나홀로', 'icon': Icons.person_outline, 'desc': '오롯이 나에게 집중하는 시간'},
    {'label': '친구와', 'icon': Icons.people_outline, 'desc': '함께 웃고 즐기는 활기찬 여정'},
    {
      'label': '연인과',
      'icon': Icons.favorite_border,
      'desc': '둘만의 색으로 물드는 로맨틱한 순간',
    },
    {
      'label': '가족과',
      'icon': Icons.family_restroom_outlined,
      'desc': '소중한 사람들과 쌓아가는 추억',
    },
    {
      'label': '아이와',
      'icon': Icons.child_care_outlined,
      'desc': '함께 발견하는 세상의 즐거움',
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCompanion = ref.watch(planProvider).companions.firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaletteAppBar(title: '동반자 선택'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Text(
              '누구와 여행하시나요?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: companionOptions.length,
              itemBuilder: (context, index) {
                final option = companionOptions[index];
                final isSelected = (selectedCompanion == option['label']);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => ref
                        .read(planProvider.notifier)
                        .updateCompanion(option['label']),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            option['icon'],
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option['label'],
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? AppColors.accent
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                option['desc'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: StepBottomBar(
        onPressed: selectedCompanion != null
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SelectVibeScreen()),
                )
            : null,
      ),
    );
  }
}
