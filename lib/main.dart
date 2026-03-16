import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_michi/core/providers/active_badge_provider.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  final prefs = await SharedPreferences.getInstance();
  // 상태바 투명 + 아이콘 다크
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = GoogleFonts.notoSansKrTextTheme();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Palette Michi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.surface,
        ),
        // ── 폰트: Noto Sans KR 전역 적용 ─────────────────────────
        textTheme: baseTextTheme.copyWith(
          displayLarge: baseTextTheme.displayLarge?.copyWith(
            color: AppColors.textPrimary,
          ),
          displayMedium: baseTextTheme.displayMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
          headlineMedium: baseTextTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          titleLarge: baseTextTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: baseTextTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: baseTextTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary,
          ),
          bodyMedium: baseTextTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          bodySmall: baseTextTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
          labelLarge: baseTextTheme.labelLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        // ── 컴포넌트 테마 ─────────────────────────────────────────
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.notoSansKr(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textOnDark,
          ),
          iconTheme: const IconThemeData(color: AppColors.textOnDark),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: GoogleFonts.notoSansKr(fontWeight: FontWeight.w600),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 3,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        useMaterial3: true,
      ),
      // ── 라우트 ────────────────────────────────────────────────
      home: const SplashScreen(),
    );
  }
}
