import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/type/models/travel_question_model.dart';
import 'package:palette_michi/features/type/providers/type_test_provider.dart';
import 'package:palette_michi/features/type/screens/type_result_loading_screen.dart';
import 'package:palette_michi/widgets/palette_app_bar.dart';

class TypeTestScreen extends ConsumerWidget {
  const TypeTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(typeTestIndexProvider);
    final answers = ref.watch(userAnswersProvider);
    final question = travelTypeQuestions[currentIndex];
    final progress = (currentIndex + 1) / travelTypeQuestions.length;
    final hasSelected = (answers[currentIndex] != -1);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaletteAppBar(
        title: '여행 성향 테스트',
        onBack: () => Navigator.pop(context),
        actions: [
          // 닫기(X) 버튼 역할을 trailing action으로 제공
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.divider,
                color: AppColors.primary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 40),
              Text(
                'Q${question.id}.',
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                question.text,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              ...question.options.asMap().entries.map((entry) {
                return _buildOptionButton(context, ref, entry.key, entry.value.text);
              }),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            if (currentIndex > 0) ...[
              Expanded(
                flex: 1,
                child: TextButton(
                  onPressed: () =>
                      ref.read(typeTestIndexProvider.notifier).state--,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: AppColors.textSecondary,
                  ),
                  child: const Text('이전', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: !hasSelected
                    ? null
                    : () {
                        if (currentIndex < 11) {
                          ref.read(typeTestIndexProvider.notifier).state++;
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TypeResultLoadingScreen(),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.divider,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  currentIndex == 11 ? '결과 보기' : '다음',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    WidgetRef ref,
    int index,
    String text,
  ) {
    final answers = [...ref.read(userAnswersProvider)];
    final currentIndex = ref.read(typeTestIndexProvider);
    final isSelected = answers[currentIndex] == index;

    return GestureDetector(
      onTap: () {
        final newAnswers = [...answers];
        newAnswers[currentIndex] = index;
        ref.read(userAnswersProvider.notifier).state = newAnswers;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: isSelected ? 1 : 0.1),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
