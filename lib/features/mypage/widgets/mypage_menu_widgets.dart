import 'package:flutter/material.dart';
import 'package:palette_michi/core/theme/app_colors.dart';

class MypageMenuCard extends StatelessWidget {
  final List<Widget> items;

  const MypageMenuCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(children: items),
    );
  }
}

class MypageMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? titleColor;

  const MypageMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(color: AppColors.textSecondary))
          : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
