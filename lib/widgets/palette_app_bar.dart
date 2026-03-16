import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:palette_michi/core/theme/app_colors.dart';

/// 앱 공통 AppBar
///
/// [dark] = true  → primary 배경
/// [dark] = false → white 배경 (플로우 스크린 기본)
///
/// 탭 셸 안에 있는 스크린(Navigator.canPop == false)에서는 back 버튼이 자동으로
/// 숨겨지고, 서브 스크린(push로 열린 경우)에서는 자동으로 표시됩니다.
class PaletteAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool dark;
  final Color? backgroundColor;
  final bool centerTitle;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  /// 탭 루트 스크린에서 드로어 버튼 등 커스텀 leading을 쓰고 싶을 때
  final Widget? leading;

  const PaletteAppBar({
    super.key,
    required this.title,
    this.dark = false,
    this.backgroundColor,
    this.centerTitle = true,
    this.onBack,
    this.actions,
    this.bottom,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = backgroundColor ?? (dark ? AppColors.primary : Colors.white);
    final Color fg = dark ? AppColors.textOnDark : AppColors.primary;
    final canPop = Navigator.canPop(context);

    Widget? effectiveLeading;
    if (leading != null) {
      // 명시적 leading 우선
      effectiveLeading = leading;
    } else if (canPop) {
      // 뒤로 갈 스크린이 있을 때만 back 버튼 표시
      effectiveLeading = IconButton(
        icon: Icon(CupertinoIcons.chevron_back, color: fg),
        onPressed: onBack ?? () => Navigator.pop(context),
      );
    }
    // canPop == false + leading == null → leading 없음 (탭 루트 스크린)

    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      iconTheme: IconThemeData(color: fg),
      leading: effectiveLeading,
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: fg),
      ),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}
