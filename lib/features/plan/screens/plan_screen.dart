import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/auth/providers/auth_provider.dart';
import 'package:palette_michi/features/plan/screens/saved_plans_screen.dart';
import 'package:palette_michi/features/plan/screens/select_city_screen.dart';
import 'package:palette_michi/widgets/login_required_dialog.dart';
import 'package:palette_michi/widgets/palette_app_bar.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaletteAppBar(title: '나의 여행 팔레트'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                '새로운 색채의\n여행을 그려볼까요?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '당신만의 취향이 담긴\n일본 여행 일정을 AI가 제안해 드립니다.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              _buildPlanCard(
                context,
                title: '새로운 일정 만들기',
                subtitle: '목적지부터 취향까지 처음부터 설정하기',
                icon: Icons.add_circle_outline,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SelectCityScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildPlanCard(
                context,
                title: '보관함에서 불러오기',
                subtitle: '작성 중이거나 저장된 일정을 확인하세요',
                icon: Icons.folder_open_outlined,
                onTap: () {
                  final user = authState.value;
                  if (user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SavedPlansScreen(),
                      ),
                    );
                  } else {
                    showLoginRequiredDialog(
                      context,
                      message: '저장된 여행 일정을 확인하려면\n로그인이 필요합니다.',
                    );
                  }
                },
              ),
              const Spacer(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Text(
                    'Palette Michi: Your Color, Your Journey',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.textSecondary.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.accent, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
