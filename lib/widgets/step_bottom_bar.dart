import 'package:flutter/material.dart';
import 'package:palette_michi/core/theme/app_colors.dart';

/// 여행 계획 단계별 하단 버튼
///
/// [onPressed]가 null이면 버튼이 비활성화됩니다.
class StepBottomBar extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const StepBottomBar({
    super.key,
    this.label = '다음으로',
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.divider,
            foregroundColor: Colors.white,
            disabledForegroundColor: AppColors.textTertiary,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
