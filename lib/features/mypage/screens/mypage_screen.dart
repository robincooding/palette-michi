import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:palette_michi/core/providers/active_badge_provider.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/auth/providers/auth_provider.dart';
import 'package:palette_michi/features/auth/providers/firestore_service_provider.dart';
import 'package:palette_michi/features/auth/screens/login_screen.dart';
import 'package:palette_michi/features/mypage/widgets/mypage_badge_section.dart';
import 'package:palette_michi/features/mypage/widgets/mypage_menu_widgets.dart';
import 'package:palette_michi/features/plan/screens/saved_plans_screen.dart';
import 'package:palette_michi/features/type/models/travel_type_model.dart';
import 'package:palette_michi/widgets/palette_app_bar.dart';

class MypageScreen extends ConsumerStatefulWidget {
  const MypageScreen({super.key});

  @override
  ConsumerState<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends ConsumerState<MypageScreen> {
  final _nicknameController = TextEditingController();
  final _picker = ImagePicker();

  bool _isEditing = false;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  bool _nicknameInitialized = false;
  String? _localProfileImageUrl;
  String? _currentUid;
  TravelType? _selectedBadge;

  @override
  void initState() {
    super.initState();
    // 앱 재실행 후 저장된 배지 상태 복원
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final saved = ref.read(activeBadgeProvider);
      if (saved != null && mounted) {
        setState(() => _selectedBadge = saved);
      }
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Color? get _accentColor {
    if (_selectedBadge == null) return null;
    return Color(int.parse(_selectedBadge!.hexColor.substring(1, 7), radix: 16) + 0xFF000000);
  }

  List<Color> get _headerGradient {
    final base = _accentColor;
    if (base != null) {
      final darker = Color.alphaBlend(Colors.black.withValues(alpha: 0.28), base);
      return [darker, base];
    }
    return [Color.alphaBlend(Colors.black.withValues(alpha: 0.15), AppColors.primary), AppColors.primaryLight];
  }

  Future<void> _saveNickname(String uid) async {
    final newNickname = _nicknameController.text.trim();
    if (newNickname.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(firestoreServiceProvider).updateNickname(uid, newNickname);
      ref.invalidate(userNicknameProvider);
      setState(() { _isEditing = false; _isSaving = false; });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('닉네임이 변경되었습니다.')));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('저장 중 오류가 발생했습니다.')));
        setState(() => _isSaving = false);
      }
    }
  }

  void _showBadgePinEffect(TravelType type) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _BadgePinOverlay(type: type, onDone: () => entry.remove()),
    );
    Overlay.of(context).insert(entry);
  }

  Future<void> _pickAndUploadImage(String uid) async {
    final source = await _showImageSourceSheet(context);
    if (source == null) return;

    final image = await _picker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 75);
    if (image == null) return;

    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('이미지 업로드 설정이 필요합니다.')));
      return;
    }

    setState(() => _isUploadingImage = true);
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final publicId = '${uid}_${DateTime.now().millisecondsSinceEpoch}';
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = 'palette_michi/profiles'
        ..fields['public_id'] = publicId
        ..files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      final body = await response.stream.bytesToString();
      if (response.statusCode != 200) throw Exception('Cloudinary ${response.statusCode}: $body');

      final url = (jsonDecode(body) as Map<String, dynamic>)['secure_url'] as String;
      if (_localProfileImageUrl != null) await CachedNetworkImage.evictFromCache(_localProfileImageUrl!);
      await ref.read(firestoreServiceProvider).updateProfileImageUrl(uid, url);
      if (mounted) setState(() => _localProfileImageUrl = url);
      ref.invalidate(userProfileImageUrlProvider);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('프로필 사진이 변경되었습니다.')));
    } catch (e) {
      debugPrint('[Profile Upload Error] $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이미지 업로드에 실패했습니다. ($e)')));
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final nicknameAsync = ref.watch(userNicknameProvider);
    final profileImageUrlAsync = ref.watch(userProfileImageUrlProvider);

    ref.listen<AsyncValue<User?>>(authStateProvider, (_, next) {
      final newUid = next.value?.uid;
      if (newUid != _currentUid) {
        setState(() {
          _currentUid = newUid;
          _nicknameInitialized = false;
          _isEditing = false;
          _isSaving = false;
          _localProfileImageUrl = null;
          _selectedBadge = null;
        });
      }
    });

    return Scaffold(
      backgroundColor: _headerGradient.first,
      appBar: PaletteAppBar(
        title: '마이페이지',
        dark: true,
        backgroundColor: _headerGradient.first,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      body: authState.when(
        data: (user) {
          if (user == null) return const _LoggedOutView();
          return nicknameAsync.when(
            data: (nickname) {
              if (!_nicknameInitialized && nickname != null) {
                _nicknameController.text = nickname;
                _nicknameInitialized = true;
              }
              final profileImageUrl = _localProfileImageUrl ?? profileImageUrlAsync.value;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileHeader(
                      gradient: _headerGradient,
                      profileImageUrl: profileImageUrl,
                      isUploading: _isUploadingImage,
                      onTap: () => _pickAndUploadImage(user.uid),
                      displayName: _isEditing && _nicknameController.text.isNotEmpty
                          ? _nicknameController.text
                          : nickname ?? '여행가',
                      selectedBadge: _selectedBadge,
                    ),
                    ColoredBox(
                      color: AppColors.background,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                      child: _NicknameEditor(
                        controller: _nicknameController,
                        isEditing: _isEditing,
                        isSaving: _isSaving,
                        nickname: nickname,
                        onEditTap: () => setState(() => _isEditing = true),
                        onCancelTap: () {
                          _nicknameController.text = nickname ?? '';
                          setState(() => _isEditing = false);
                        },
                        onSaveTap: () => _saveNickname(user.uid),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionLabel('나의 여행 기록'),
                          const SizedBox(height: 10),
                          MypageMenuCard(
                            items: [
                              MypageMenuItem(
                                icon: Icons.folder_special_rounded,
                                title: '나만의 보관함',
                                subtitle: '저장된 여행 일정을 확인하세요.',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedPlansScreen())),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    MypageBadgeSection(
                      selectedBadge: _selectedBadge,
                      uid: user.uid,
                      onBadgeTap: (type) {
                        final next = (_selectedBadge == type) ? null : type;
                        setState(() => _selectedBadge = next);
                        // 전역 provider 동기화 → 탭 바 색상 반영
                        ref.read(activeBadgeProvider.notifier).select(next);
                        // 배지 장착 효과 (새로 선택할 때만)
                        if (next != null) _showBadgePinEffect(next);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionLabel('계정'),
                          const SizedBox(height: 10),
                          MypageMenuCard(
                            items: [
                            MypageMenuItem(
                              icon: Icons.logout_rounded,
                              title: '로그아웃',
                              titleColor: AppColors.danger,
                              onTap: () async {
                                // 배지/테마 초기화 (SharedPreferences 저장값 포함)
                                ref.read(activeBadgeProvider.notifier).select(null);
                                await ref.read(authServiceProvider).signOut();
                                // MypageScreen은 MenuScreen의 탭이므로 pop 금지
                                // authStateProvider가 null을 emit하면 _LoggedOutView로 자동 전환
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('로그아웃 되었습니다.'), duration: Duration(seconds: 1)),
                                );
                              },
                            ),
                          ]),
                        ],
                      ),
                    ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (_, _) => const Center(child: Text('오류가 발생했습니다.')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }
}

// ── 이미지 소스 시트 (독립 함수) ──────────────────────────────────────────────

Future<ImageSource?> _showImageSourceSheet(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
            title: const Text('갤러리에서 선택', style: TextStyle(fontWeight: FontWeight.w600)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
            title: const Text('사진 찍기', style: TextStyle(fontWeight: FontWeight.w600)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
        ],
      ),
    ),
  );
}

// ── 분리된 위젯들 ─────────────────────────────────────────────────────────────

class _LoggedOutView extends StatelessWidget {
  const _LoggedOutView();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            const Text('로그인이 필요해요', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('로그인하기'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final List<Color> gradient;
  final String? profileImageUrl;
  final bool isUploading;
  final VoidCallback onTap;
  final String displayName;
  final TravelType? selectedBadge;

  const _ProfileHeader({
    required this.gradient,
    required this.profileImageUrl,
    required this.isUploading,
    required this.onTap,
    required this.displayName,
    required this.selectedBadge,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeaderWaveClipper(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // 상단 우측 빛 반사 효과
            Positioned(
              top: -70,
              right: -70,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.white.withValues(alpha: 0.18), Colors.transparent],
                  ),
                ),
              ),
            ),
            // 하단 좌측 보조 광원
            Positioned(
              bottom: 10,
              left: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.white.withValues(alpha: 0.09), Colors.transparent],
                  ),
                ),
              ),
            ),
            // 중앙 content
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 44, 0, 52),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: isUploading ? null : onTap,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 아바타 글로우 링
                        Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2.5),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16, spreadRadius: 2),
                            ],
                          ),
                          child: ClipOval(
                            child: profileImageUrl != null
                                ? CachedNetworkImage(imageUrl: profileImageUrl!, fit: BoxFit.cover)
                                : const ColoredBox(
                                    color: Colors.white24,
                                    child: Icon(Icons.person, size: 56, color: Colors.white),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: isUploading
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.camera_alt, size: 13, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    displayName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, shadows: [
                      Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                    ]),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutBack,
                    child: selectedBadge != null
                        ? Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Column(
                              children: [
                                _BadgeImage(type: selectedBadge!),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
                                  ),
                                  child: Text(
                                    selectedBadge!.theme,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
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

class _HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 28);
    path.quadraticBezierTo(size.width * 0.5, size.height + 18, size.width, size.height - 28);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _NicknameEditor extends StatelessWidget {
  final TextEditingController controller;
  final bool isEditing;
  final bool isSaving;
  final String? nickname;
  final VoidCallback onEditTap;
  final VoidCallback onCancelTap;
  final VoidCallback onSaveTap;
  final ValueChanged<String> onChanged;

  const _NicknameEditor({
    required this.controller,
    required this.isEditing,
    required this.isSaving,
    required this.nickname,
    required this.onEditTap,
    required this.onCancelTap,
    required this.onSaveTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('닉네임', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isEditing ? AppColors.primary : AppColors.divider, width: isEditing ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: isEditing,
                  onChanged: onChanged,
                  style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: InputBorder.none,
                    hintText: '닉네임을 입력하세요',
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                  ),
                ),
              ),
              if (!isEditing)
                TextButton(
                  onPressed: onEditTap,
                  child: const Text('수정', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ),
        if (isEditing) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancelTap,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  child: const Text('취소', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isSaving ? null : onSaveTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('저장'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── 배지 이미지 (헤더에 표시) ────────────────────────────────────────────────

class _BadgeImage extends StatefulWidget {
  final TravelType type;
  const _BadgeImage({required this.type});

  @override
  State<_BadgeImage> createState() => _BadgeImageState();
}

class _BadgeImageState extends State<_BadgeImage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.25).chain(CurveTween(curve: Curves.easeOut)), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.9).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
    ]).animate(_controller);
    _rotation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: -0.08, end: 0.06).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.06, end: 0.0).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
    ]).animate(_controller);
    _controller.forward();
  }

  @override
  void didUpdateWidget(_BadgeImage old) {
    super.didUpdateWidget(old);
    if (old.type != widget.type) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(widget.type.hexColor.substring(1, 7), radix: 16) + 0xFF000000);
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Transform.rotate(
        angle: _rotation.value,
        child: Transform.scale(
          scale: _scale.value,
          child: child,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 16, spreadRadius: 2),
            BoxShadow(color: Colors.white.withValues(alpha: 0.3), blurRadius: 6, spreadRadius: 0),
          ],
        ),
        child: Image.asset(widget.type.badgePath, width: 72, height: 72),
      ),
    );
  }
}

// ── 배지 장착 오버레이 ─────────────────────────────────────────────────────────

class _BadgePinOverlay extends StatefulWidget {
  final TravelType type;
  final VoidCallback onDone;
  const _BadgePinOverlay({required this.type, required this.onDone});

  @override
  State<_BadgePinOverlay> createState() => _BadgePinOverlayState();
}

class _BadgePinOverlayState extends State<_BadgePinOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<double> _offsetY;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.2).chain(CurveTween(curve: Curves.easeOutBack)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85).chain(CurveTween(curve: Curves.easeIn)), weight: 20),
    ]).animate(_ctrl);

    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 12),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 68),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 20),
    ]).animate(_ctrl);

    _offsetY = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 80),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -24.0).chain(CurveTween(curve: Curves.easeIn)), weight: 20),
    ]).animate(_ctrl);

    _ctrl.forward().then((_) => widget.onDone());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(widget.type.hexColor.substring(1, 7), radix: 16) + 0xFF000000);
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _offsetY.value),
            child: Transform.scale(
              scale: _scale.value,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 글로우 링 + 배지 이미지
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 36, spreadRadius: 8),
                          BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 60, spreadRadius: 16),
                        ],
                      ),
                      child: Image.asset(widget.type.badgePath, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 16),
                    // "배지 장착!" 라벨
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.military_tech_rounded, size: 16, color: color),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.type.colorName} 배지 장착!',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
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
        ),
      ),
    );
  }
}
