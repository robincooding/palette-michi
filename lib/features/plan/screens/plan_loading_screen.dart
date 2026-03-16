import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import '../providers/plan_result_provider.dart';
import 'final_itinerary_screen.dart';

class PlanLoadingScreen extends ConsumerStatefulWidget {
  const PlanLoadingScreen({super.key});

  @override
  ConsumerState<PlanLoadingScreen> createState() => _PlanLoadingScreenState();
}

class _PlanLoadingScreenState extends ConsumerState<PlanLoadingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(planResultProvider.notifier).generateFullPlan(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PlanResultState>(planResultProvider, (previous, next) {
      if (next.itinerary != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const FinalItineraryScreen()),
        );
      } else if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('일정 생성 실패: ${next.errorMessage}')),
        );
        Navigator.of(context).pop();
      }
    });

    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 30),
            Text(
              '최적의 동선을 설계하고 있어요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '잠시만 기다려주세요.\n나만의 팔레트가 완성되고 있습니다.',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
