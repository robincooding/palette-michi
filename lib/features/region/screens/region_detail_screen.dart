import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/auth/providers/auth_provider.dart';
import 'package:palette_michi/features/auth/providers/firestore_service_provider.dart';
import '../models/region_model.dart';

class RegionDetailScreen extends ConsumerStatefulWidget {
  final RegionDetail detail;
  final RegionGroup group;

  const RegionDetailScreen({
    super.key,
    required this.detail,
    required this.group,
  });

  @override
  ConsumerState<RegionDetailScreen> createState() => _RegionDetailScreenState();
}

class _RegionDetailScreenState extends ConsumerState<RegionDetailScreen> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final Color regionColor = getGroupColor(widget.group);
    final Color textColor = getGroupTextColor(widget.group);
    final authState = ref.watch(authStateProvider);
    final favoritesAsync = ref.watch(favoriteRegionsProvider);
    final isFavorite =
        favoritesAsync.value?.contains(widget.group.name) ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: regionColor,
        foregroundColor: textColor,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.detail.nameKr,
              style: GoogleFonts.notoSansKr(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              widget.detail.name.toUpperCase(),
              style: GoogleFonts.notoSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: textColor.withValues(alpha: 0.6),
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColors.accent : textColor,
            ),
            onPressed: () async {
              final user = authState.value;
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('로그인 후 이용할 수 있어요.')),
                );
                return;
              }
              await ref
                  .read(firestoreServiceProvider)
                  .toggleFavoriteRegion(user.uid, widget.group.name);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 슬라이더
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  height: 280,
                  child: PageView.builder(
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemCount: widget.detail.images.length,
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: widget.detail.images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (_, _) => Container(
                          color: AppColors.inputFill,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: AppColors.inputFill,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: AppColors.textTertiary,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (widget.detail.images.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.detail.images.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // 콘텐츠 본문
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "지역 개요",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.detail.description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: AppColors.divider),
                  ),

                  _buildSection("🏙️ 주요 도시", widget.detail.majorCities),
                  _buildSection("📍 가볼만한 곳", widget.detail.topSpots),
                  _buildSection("🍱 유명 문화 및 음식", widget.detail.cultureAndFood),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
