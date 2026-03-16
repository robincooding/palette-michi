import 'package:flutter/material.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/region/models/region_model.dart';

class JapanMapPainter extends CustomPainter {
  final Map<RegionGroup, Path> combinedGroupPaths;
  final RegionGroup? selectedGroup;

  JapanMapPainter({required this.combinedGroupPaths, this.selectedGroup});

  @override
  void paint(Canvas canvas, Size size) {
    final bool isOkinawaSelected = (selectedGroup == RegionGroup.okinawa);

    // 1. 오키나와 돋보기 프레임
    final framePaint = Paint()
      ..color = isOkinawaSelected
          ? getGroupColor(RegionGroup.okinawa).withValues(alpha: 0.5)
          : Colors.grey.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isOkinawaSelected ? 2.0 : 1.0;

    // 왼쪽상단 가이드선
    final RRect frameRect = RRect.fromLTRBR(
      30,
      15,
      size.width * 0.5,
      size.height * 0.35,
      const Radius.circular(10),
    );

    if (isOkinawaSelected) {
      canvas.drawRRect(
        frameRect,
        Paint()
          ..color = getGroupColor(RegionGroup.okinawa).withValues(alpha: 0.1),
      );
    }

    canvas.drawRRect(frameRect, framePaint);

    // 'Okinawa' 텍스트 라벨 추가 (선택 사항)
    _drawText(canvas, "Okinawa", Offset(45, size.height * 0.05));

    // 지역 그리기
    combinedGroupPaths.forEach((group, path) {
      if (group == RegionGroup.nowhere) return;

      final bool isSelected = (group == selectedGroup);
      final Color groupColor = getGroupColor(group);

      final paint = Paint()
        ..color = isSelected ? groupColor : AppColors.inputFill
        ..style = PaintingStyle.fill;

      // 그룹 경계선
      final borderPaint = Paint()
        ..color = isSelected ? groupColor : AppColors.timelineBar
        ..strokeWidth = isSelected ? 1.5 : 0.8
        ..style = PaintingStyle.stroke;

      canvas.drawPath(path, paint);
      canvas.drawPath(path, borderPaint);
    });
  }

  @override
  bool shouldRepaint(JapanMapPainter oldDelegate) =>
      oldDelegate.selectedGroup != selectedGroup ||
      oldDelegate.combinedGroupPaths != combinedGroupPaths;
}

void _drawText(Canvas canvas, String text, Offset offset) {
  final textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  textPainter.paint(canvas, offset);
}
