import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/auth/providers/auth_provider.dart';
import 'package:palette_michi/features/auth/providers/firestore_service_provider.dart';
import 'package:palette_michi/widgets/custom_action_button.dart';
import 'package:palette_michi/widgets/custom_text_field.dart';
import 'package:palette_michi/widgets/palette_app_bar.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final name = _nameController.text.trim();
    final nickname = _nicknameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || nickname.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 항목을 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authError = await ref.read(authServiceProvider).signUp(
      email: email,
      password: password,
    );

    if (authError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authError)));
        setState(() => _isLoading = false);
      }
      return;
    }

    await ref.read(firestoreServiceProvider).saveInfo(
      name: name,
      nickname: nickname,
      email: email,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Firebase는 signUp 시 자동 로그인 → 탭 셸로 바로 이동
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('환영합니다! 회원가입이 완료됐어요 🎉')),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaletteAppBar(title: '회원가입'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '함께 시작해요',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '여행을 더 특별하게 만들어 드릴게요',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(hintText: '이름', controller: _nameController),
                const SizedBox(height: 14),
                CustomTextField(hintText: '닉네임', controller: _nicknameController),
                const SizedBox(height: 14),
                CustomTextField(hintText: '이메일', controller: _emailController),
                const SizedBox(height: 14),
                CustomTextField(
                  hintText: '비밀번호 (6자 이상)',
                  controller: _passwordController,
                  isPassword: true,
                ),
                const SizedBox(height: 40),
                CustomActionButton(
                  text: _isLoading ? '가입 중...' : '가입하기',
                  color: AppColors.primary,
                  textColor: Colors.white,
                  onTap: _isLoading ? null : _handleSignup,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '이미 계정이 있어요',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
