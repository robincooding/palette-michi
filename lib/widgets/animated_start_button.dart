import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:palette_michi/core/theme/app_colors.dart';

class AnimatedStartButton extends StatefulWidget {
  final VoidCallback onTap;

  const AnimatedStartButton({super.key, required this.onTap});

  @override
  State<AnimatedStartButton> createState() => _AnimatedStartButtonState();
}

// 애니메이션 로직을 분리된 위젯 안에서 관리 (Stateful)
class _AnimatedStartButtonState extends State<AnimatedStartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap, //
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(64),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(64),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.05),
                  width: 1.5,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "시작하기",
                    style: TextStyle(
                      color: AppColors.background,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    CupertinoIcons.chevron_forward,
                    color: AppColors.background,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
