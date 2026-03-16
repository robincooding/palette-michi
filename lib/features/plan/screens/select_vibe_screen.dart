import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/plan/screens/select_density_screen.dart';
import 'package:palette_michi/widgets/palette_app_bar.dart';
import 'package:palette_michi/widgets/step_bottom_bar.dart';
import '../models/plan_request_model.dart';
import '../providers/plan_provider.dart';

class SelectVibeScreen extends ConsumerStatefulWidget {
  const SelectVibeScreen({super.key});

  @override
  ConsumerState<SelectVibeScreen> createState() => _SelectVibeScreenState();
}

class _SelectVibeScreenState extends ConsumerState<SelectVibeScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final planRequest = ref.watch(planProvider);
    final selectedCats = planRequest.selectedCategories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaletteAppBar(
        title: _currentStep == 0 ? '여행의 색채' : '세밀한 붓터치',
        onBack: () {
          if (_currentStep > 0) {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
            setState(() => _currentStep--);
          } else {
            Navigator.pop(context);
          }
        },
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildCategoryStep(selectedCats),
          _buildStyleStep(planRequest),
        ],
      ),
      bottomNavigationBar: StepBottomBar(
        label: _currentStep == 0 ? '다음으로' : '팔레트 완성하기',
        onPressed: selectedCats.isEmpty ? null : _onNextPressed,
      ),
    );
  }

  Widget _buildCategoryStep(List<TripCategory> selectedCats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeader(
          title: '어떤 여행을 원하시나요?',
          subtitle: '팔레트에 올릴 기본 물감을 1~4개 골라주세요.',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 15,
                runSpacing: 20,
                children: TripCategory.values.map((cat) {
                  final isSelected = selectedCats.contains(cat);
                  return _CategoryBubble(
                    category: cat,
                    isSelected: isSelected,
                    onTap: () =>
                        ref.read(planProvider.notifier).toggleCategory(cat),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyleStep(PlanRequest request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepHeader(
          title: '조금 더 자세히 알려주세요!',
          subtitle:
              '선택하신 ${request.selectedCategories.length}개의 물감에 디테일을 더합니다.',
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: request.selectedCategories.length,
            itemBuilder: (context, index) {
              final cat = request.selectedCategories[index];
              return _StyleSelectionCard(
                category: cat,
                selectedStyles: request.selectedStyles[cat] ?? [],
                onStyleToggled: (style) {
                  ref.read(planProvider.notifier).toggleStyle(cat, style);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _onNextPressed() {
    if (_currentStep == 0) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      setState(() => _currentStep++);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SelectDensityScreen()),
      );
    }
  }
}

class _CategoryBubble extends StatelessWidget {
  final TripCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryBubble({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? category.vibeColor : AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: category.vibeColor.withValues(alpha: 0.4),
                blurRadius: 10,
                spreadRadius: 2,
              ),
          ],
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.divider,
          ),
        ),
        child: Center(
          child: Text(
            category.label.replaceAll(' ', '\n'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _StyleSelectionCard extends StatelessWidget {
  final TripCategory category;
  final List<TripStyle> selectedStyles;
  final Function(TripStyle) onStyleToggled;

  const _StyleSelectionCard({
    required this.category,
    required this.selectedStyles,
    required this.onStyleToggled,
  });

  @override
  Widget build(BuildContext context) {
    final availableStyles = TripStyle.values
        .where((s) => s.category == category)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: category.vibeColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 6, backgroundColor: category.vibeColor),
              const SizedBox(width: 10),
              Text(
                category.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            children: availableStyles.map((style) {
              final isSelected = selectedStyles.contains(style);
              return FilterChip(
                label: Text(style.label),
                selected: isSelected,
                onSelected: (_) => onStyleToggled(style),
                selectedColor: category.vibeColor.withValues(alpha: 0.2),
                checkmarkColor: category.vibeColor,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final String title, subtitle;
  const _StepHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
