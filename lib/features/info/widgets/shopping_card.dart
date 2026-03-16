import 'package:flutter/material.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/info/data/region_info.dart';
import 'package:palette_michi/features/info/data/shopping_items.dart';
import 'package:palette_michi/features/info/models/shopping_item_model.dart';
import 'package:palette_michi/features/info/widgets/shopping_item_card.dart';

class ShoppingCard extends StatefulWidget {
  const ShoppingCard({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<ShoppingCard> createState() => _ShoppingCardState();
}

class _ShoppingCardState extends State<ShoppingCard> {
  String _selectedCity = '도쿄';
  ShoppingCategory _selectedCategory = ShoppingCategory.all;
  bool _specialtyExpanded = false;

  void _onCityChanged(String city) {
    setState(() {
      _selectedCity = city;
      _selectedCategory = ShoppingCategory.all;
      _specialtyExpanded = false;
    });
  }

  void _toggleSpecialty() {
    final willExpand = !_specialtyExpanded;
    setState(() => _specialtyExpanded = willExpand);

    if (!willExpand) return;
    // AnimatedSize duration(300ms) 완료 후 페이지 최하단으로 스크롤
    Future.delayed(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      final sc = widget.scrollController;
      if (sc.hasClients) {
        sc.animateTo(
          sc.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  List<ShoppingItem> get _mainItems => ShoppingItems.getFilteredItems(
    city: _selectedCity,
    category: _selectedCategory,
  );

  List<ShoppingItem> get _specialtyItems => ShoppingItems.getFilteredItems(
    city: _selectedCity,
    category: ShoppingCategory.localSpecialty,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 도시 선택
        _buildCitySelector(),
        const SizedBox(height: 16),

        // 카테고리 필터 탭
        _buildFilterTabs(),
        const SizedBox(height: 16),

        // 일반 아이템 리스트
        _buildItemList(_mainItems, emptyMessage: '해당 카테고리 아이템이 없습니다'),
        const SizedBox(height: 16),

        // 지역 특산품 펼침 섹션
        _buildSpecialtySection(),
      ],
    );
  }

  // ── 도시 선택 드롭다운 ───────────────────────────────────────
  Widget _buildCitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.15),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCity,
          isExpanded: true,
          isDense: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          items: supportedCityNames
              .map(
                (city) => DropdownMenuItem(
                  value: city,
                  child: Row(
                    children: [
                      const Text('📍 ', style: TextStyle(fontSize: 13)),
                      Text(city),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (city) {
            if (city != null) _onCityChanged(city);
          },
        ),
      ),
    );
  }

  // ── 카테고리 필터 탭 (localSpecialty 제외) ──────────────────
  Widget _buildFilterTabs() {
    final categories = ShoppingCategory.values
        .where((c) => c != ShoppingCategory.localSpecialty)
        .toList();
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: categories.map(_buildCategoryChip).toList(),
      ),
    );
  }

  Widget _buildCategoryChip(ShoppingCategory category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          category.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ── 아이템 리스트 ───────────────────────────────────────────
  Widget _buildItemList(
    List<ShoppingItem> items, {
    required String emptyMessage,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            emptyMessage,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) => ShoppingItemCard(item: items[index]),
      ),
    );
  }

  // ── 지역 특산품 펼침 섹션 ───────────────────────────────────
  Widget _buildSpecialtySection() {
    final hasItems = _specialtyItems.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 토글 헤더
        GestureDetector(
          onTap: _toggleSpecialty,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.primaryLight.withValues(alpha: 0.12),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                const Text('🎁', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_selectedCity 지역 특산품',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '이 도시에서만 살 수 있는 기념품·먹거리',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _specialtyExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 펼침 콘텐츠
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _specialtyExpanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: hasItems
                      ? _buildItemList(
                          _specialtyItems,
                          emptyMessage: '$_selectedCity 전용 특산품 정보를 준비 중이에요',
                        )
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              '$_selectedCity 전용 특산품 정보를 준비 중이에요',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ),
                        ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
