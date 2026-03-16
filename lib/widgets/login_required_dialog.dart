import 'package:flutter/material.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/auth/screens/login_screen.dart';

/// 로그인이 필요한 기능 접근 시 공통 다이얼로그
Future<void> showLoginRequiredDialog(
  BuildContext context, {
  String message = '이 기능을 사용하려면\n로그인이 필요합니다.',
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        '로그인 필요',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '나중에',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: const Text('로그인하기', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
