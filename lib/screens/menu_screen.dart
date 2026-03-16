import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_michi/core/providers/active_badge_provider.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/auth/providers/auth_provider.dart';
import 'package:palette_michi/features/info/screens/info_screen.dart';
import 'package:palette_michi/features/mypage/screens/mypage_screen.dart';
import 'package:palette_michi/features/plan/screens/plan_screen.dart';
import 'package:palette_michi/features/region/screens/region_screen.dart';
import 'package:palette_michi/features/type/screens/type_entrance_screen.dart';
import 'package:palette_michi/widgets/home_drawer.dart';

// ── 탭 정의 ────────────────────────────────────────────────────────────────────

class _Tab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _Tab(this.icon, this.activeIcon, this.label);
}

const _tabs = [
  _Tab(Icons.home_outlined, Icons.home_rounded, '홈'),
  _Tab(Icons.flight_takeoff_outlined, Icons.flight_takeoff_rounded, '여행 계획'),
  _Tab(Icons.map_outlined, Icons.map_rounded, '지역 가이드'),
  _Tab(Icons.psychology_outlined, Icons.psychology_rounded, '타입 테스트'),
  _Tab(Icons.person_outline_rounded, Icons.person_rounded, '마이페이지'),
];

// ── 메인 셸 ────────────────────────────────────────────────────────────────────

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  int _selectedIndex = 0;

  void goToTab(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final accentColor = ref.watch(activeBadgeColorProvider) ?? AppColors.primary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: PopScope(
        canPop: _selectedIndex == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) setState(() => _selectedIndex = 0);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          drawer: HomeDrawer(onGoToTab: goToTab),
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              _HomeTab(onTabTap: goToTab),
              const PlanScreen(),
              const RegionScreen(),
              const TypeEntranceScreen(),
              const MypageScreen(),
            ],
          ),
          bottomNavigationBar: _FloatingNavBar(
            selectedIndex: _selectedIndex,
            accentColor: accentColor,
            onTap: (i) => setState(() => _selectedIndex = i),
          ),
        ),
      ),
    );
  }
}

// ── Floating Nav Bar ──────────────────────────────────────────────────────────

class _FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final Color accentColor;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.selectedIndex,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom > 0 ? bottom : 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.09),
              blurRadius: 28,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: accentColor.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: AppColors.divider.withValues(alpha: 0.8),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _tabs.length,
              (i) => _NavItem(
                tab: _tabs[i],
                isSelected: selectedIndex == i,
                accentColor: accentColor,
                onTap: () => onTap(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _Tab tab;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? tab.activeIcon : tab.icon,
                key: ValueKey(isSelected),
                size: 22,
                color: isSelected ? accentColor : AppColors.textTertiary,
              ),
            ),
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          tab.label,
                          style: GoogleFonts.notoSansKr(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 홈 탭 ─────────────────────────────────────────────────────────────────────

class _HomeTab extends ConsumerWidget {
  final void Function(int) onTabTap;
  const _HomeTab({required this.onTabTap});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 6) return '밤새 잘 주무셨나요 🌙';
    if (h < 11) return '좋은 아침이에요 ☀️';
    if (h < 17) return '즐거운 오후 보내세요 🌤️';
    if (h < 21) return '좋은 저녁이에요 🌇';
    return '오늘도 수고하셨어요 ✨';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accentColor = ref.watch(activeBadgeColorProvider) ?? AppColors.primary;
    final authState = ref.watch(authStateProvider);
    final nicknameAsync = ref.watch(userNicknameProvider);

    final nickname = nicknameAsync.value;
    final isLoggedIn = authState.value != null;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── 상단 헤더 ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting,
                          style: GoogleFonts.notoSansKr(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.notoSansKr(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                            children: [
                              if (isLoggedIn && nickname != null && nickname.isNotEmpty)
                                TextSpan(text: '$nickname님, '),
                              const TextSpan(text: '여행을 계획해볼까요?'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 드로어 버튼
                  Builder(
                    builder: (ctx) => GestureDetector(
                      onTap: () => Scaffold.of(ctx).openDrawer(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.menu_rounded, color: accentColor, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 히어로 배너 ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
              child: _HeroBanner(
                accentColor: accentColor,
                onTap: () => onTabTap(1),
              ),
            ),
          ),

          // ── 빠른 이동 카드 ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle('주요 기능'),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.map_rounded,
                          title: '지역 가이드',
                          subtitle: '지역별 특징 파악',
                          color: const Color(0xFF3AAFA9),
                          onTap: () => onTabTap(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.psychology_rounded,
                          title: '타입 테스트',
                          subtitle: '나의 여행 스타일',
                          color: const Color(0xFFE07A5F),
                          onTap: () => onTabTap(3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── 여행 정보 ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle('여행 정보'),
                  const SizedBox(height: 14),
                  _InfoCard(
                    icon: Icons.info_outline_rounded,
                    title: '여행 필수 정보',
                    subtitle: '환율 · 교통 · 날씨 등 일본 여행에 필요한 정보',
                    accentColor: accentColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const InfoScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 하단 여백 (nav bar 높이)
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ── 히어로 배너 ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final Color accentColor;
  final VoidCallback onTap;
  const _HeroBanner({required this.accentColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        height: 156,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accentColor, accentColor.withValues(alpha: 0.55)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.28),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -24,
              top: -36,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              right: 24,
              bottom: -24,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '✈️  AI 일정 추천',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '어디로 떠날까요?',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '나만의 일본 여행 일정을 만들어보세요',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 피처 카드 ─────────────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(height: 14),
            Text(title, style: GoogleFonts.notoSansKr(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            )),
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.notoSansKr(
              fontSize: 11,
              color: AppColors.textSecondary,
            )),
          ],
        ),
      ),
    );
  }
}

// ── 정보 카드 ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.notoSansKr(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.notoSansKr(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  )),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── 섹션 타이틀 ───────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.notoSansKr(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
      ),
    );
  }
}
