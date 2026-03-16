import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/auth/providers/auth_provider.dart';
import 'package:palette_michi/features/auth/screens/signup_screen.dart';
import 'package:palette_michi/widgets/custom_action_button.dart';
import 'package:palette_michi/widgets/custom_text_field.dart';
import 'package:palette_michi/widgets/palette_app_bar.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaletteAppBar(title: ''),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset('./assets/logo.png', width: 180),
              const SizedBox(height: 12),
              Text(
                'Palette Michi',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '당신의 취향을 여행에 입히다',
                style: GoogleFonts.notoSansKr(
                  fontSize: 14,
                  letterSpacing: -0.2,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              CustomActionButton(
                text: '로그인',
                color: AppColors.primary,
                textColor: Colors.white,
                onTap: () => _showLoginModal(context, ref),
              ),
              const SizedBox(height: 14),
              CustomActionButton(
                text: '회원가입',
                color: AppColors.surface,
                textColor: AppColors.primary,
                borderColor: AppColors.primary.withValues(alpha: 0.3),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                ),
              ),
              const SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLoginModal(BuildContext context, WidgetRef ref) async {
    final loggedIn = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LoginModalContent(),
    );

    if (loggedIn == true && context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}

class LoginModalContent extends ConsumerStatefulWidget {
  const LoginModalContent({super.key});

  @override
  ConsumerState<LoginModalContent> createState() => _LoginModalContentState();
}

class _LoginModalContentState extends ConsumerState<LoginModalContent> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    final error = await ref.read(authServiceProvider).signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.62,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 28,
            right: 28,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '로그인',
                style: GoogleFonts.notoSansKr(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 28),
              CustomTextField(hintText: '이메일', controller: _emailController),
              const SizedBox(height: 14),
              CustomTextField(
                hintText: '비밀번호',
                controller: _passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 28),
              CustomActionButton(
                text: _isLoading ? '로그인 중...' : '로그인',
                color: AppColors.primary,
                textColor: Colors.white,
                onTap: _isLoading ? null : _handleLogin,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
