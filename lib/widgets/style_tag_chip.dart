import 'package:flutter/material.dart';
import 'package:palette_michi/features/plan/models/plan_request_model.dart';

class StyleTagChip extends StatelessWidget {
  final TripStyle style;
  final VoidCallback? onDelete;

  const StyleTagChip({super.key, required this.style, this.onDelete});

  @override
  Widget build(BuildContext context) {
    // 스타일이 속한 카테고리의 색상
    final color = style.category.vibeColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "#${style.label}",
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.close, size: 14, color: color),
            ),
          ],
        ],
      ),
    );
  }
}
