import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/screens/menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // 로고
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  // 앱 이름 + 태그라인
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;

  // 전체 페이드아웃
  late final Animation<double> _screenFade;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // 로고: 0~50% — scale + fade in
    _logoScale = Tween(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );
    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    // 텍스트: 25~65% — slide up + fade in
    _titleOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.6, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // 전체 페이드아웃: 82~100%
    _screenFade = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.82, 1.0, curve: Curves.easeInCubic),
      ),
    );

    _controller.forward();

    // 애니메이션 완료 후 메인 화면으로 이동
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, a1, a2) => const MenuScreen(),
            transitionDuration: Duration.zero,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return FadeTransition(
              opacity: _screenFade,
              child: RepaintBoundary(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primaryLight.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SafeArea(
                    child: Stack(
                      children: [
                        // 배경 장식 원들
                        Positioned(
                          top: -60,
                          right: -60,
                          child: _DecorCircle(size: 220, opacity: 0.06),
                        ),
                        Positioned(
                          bottom: 60,
                          left: -40,
                          child: _DecorCircle(size: 160, opacity: 0.05),
                        ),
                        // 중앙 컨텐츠
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 로고
                              FadeTransition(
                                opacity: _logoOpacity,
                                child: ScaleTransition(
                                  scale: _logoScale,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withValues(
                                            alpha: 0.08,
                                          ),
                                          blurRadius: 30,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/logo.png',
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.48,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              // 앱 이름
                              FadeTransition(
                                opacity: _titleOpacity,
                                child: SlideTransition(
                                  position: _titleSlide,
                                  child: Column(
                                    children: [
                                      Text(
                                        'Palette Michi',
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 1.6,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        '당신의 취향을 여행에 입히다',
                                        style: GoogleFonts.notoSansKr(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white.withValues(
                                            alpha: 0.68,
                                          ),
                                          letterSpacing: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
