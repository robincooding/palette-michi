import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/type/screens/type_result_screen.dart';

class TypeResultLoadingScreen extends ConsumerStatefulWidget {
  const TypeResultLoadingScreen({super.key});

  @override
  ConsumerState<TypeResultLoadingScreen> createState() =>
      _TypeResultLoadingScreenState();
}

class _TypeResultLoadingScreenState
    extends ConsumerState<TypeResultLoadingScreen> {
  @override
  void initState() {
    super.initState();
    // 의도적인 딜레이를 주어 채점 엔진이 작동하는 '분석 중' 느낌 제공
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TypeResultScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 20),
            Text(
              "당신의 여행 컬러를 분석하고 있습니다...",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
