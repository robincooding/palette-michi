import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/type/providers/type_test_provider.dart';
import 'package:palette_michi/features/type/screens/type_test_screen.dart';
import 'package:palette_michi/widgets/palette_app_bar.dart';

class TypeEntranceScreen extends ConsumerWidget {
  const TypeEntranceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaletteAppBar(title: '여행 성향 테스트'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎨', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 20),
              const Text(
                '나의 여행 컬러는 무엇일까?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                '8가지 컬러로 분석하는 나의 여행 타입',
                style: TextStyle(
                  color: AppColors.textPrimary.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    ref.read(typeTestIndexProvider.notifier).state = 0;
                    ref.read(userAnswersProvider.notifier).state = List.filled(
                      12,
                      -1,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TypeTestScreen()),
                    );
                  },
                  child: const Text(
                    '테스트 시작하기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
