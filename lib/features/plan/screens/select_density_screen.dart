import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/plan/providers/plan_provider.dart';
import 'package:palette_michi/features/plan/screens/plan_loading_screen.dart';
import 'package:palette_michi/widgets/palette_app_bar.dart';
import 'package:palette_michi/widgets/step_bottom_bar.dart';

class SelectDensityScreen extends ConsumerWidget {
  const SelectDensityScreen({super.key});

  String _getDensityMessage(double density) {
    if (density < 0.3) return '여유롭게 즐기는 여행';
    if (density < 0.6) return '적당히 활기찬 여행';
    if (density < 0.8) return '촘촘하게 채우는 여행';
    return '밀도있고 열정적인 여행';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDensity = ref.watch(planProvider).density;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaletteAppBar(title: '여행의 농도'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              '어떤 여행을 선호하시나요?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 60),
            Center(
              child: Column(
                children: [
                  Text(
                    '${(selectedDensity * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getDensityMessage(selectedDensity),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.primary.withValues(alpha: 0.1),
                thumbColor: AppColors.accent,
                overlayColor: AppColors.accent.withValues(alpha: 0.12),
                trackHeight: 4.0,
              ),
              child: Slider(
                value: selectedDensity,
                onChanged: (value) {
                  ref.read(planProvider.notifier).updateDensity(value);
                },
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '여유로운',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                Text(
                  '촘촘한',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: StepBottomBar(
        label: '팔레트 완성하기',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PlanLoadingScreen()),
        ),
      ),
    );
  }
}
