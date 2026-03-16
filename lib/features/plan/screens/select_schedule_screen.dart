import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/plan/models/plan_request_model.dart';
import 'package:palette_michi/features/plan/providers/plan_provider.dart';
import 'package:palette_michi/features/plan/screens/select_companion_screen.dart';
import 'package:palette_michi/widgets/palette_app_bar.dart';
import 'package:palette_michi/widgets/step_bottom_bar.dart';

class SelectScheduleScreen extends ConsumerStatefulWidget {
  const SelectScheduleScreen({super.key});

  @override
  ConsumerState<SelectScheduleScreen> createState() =>
      _SelectScheduleScreenState();
}

class _SelectScheduleScreenState extends ConsumerState<SelectScheduleScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _timeKey = GlobalKey();
  final GlobalKey _nearbyKey = GlobalKey();

  final List<Map<String, dynamic>> scheduleOptions = [
    {'title': '당일치기', 'days': 1, 'subtitle': '가볍게 떠나는 하루의 색채'},
    {'title': '1박 2일', 'days': 2, 'subtitle': '주말을 활용한 짧고 강렬한 휴식'},
    {'title': '2박 3일', 'days': 3, 'subtitle': '가장 대중적인 여행의 농도'},
    {'title': '3박 4일', 'days': 4, 'subtitle': '도시의 구석구석을 채우는 시간'},
    {'title': '4박 5일', 'days': 5, 'subtitle': '여유롭게 즐기는 나만의 아지트'},
    {'title': '5박 6일', 'days': 6, 'subtitle': '일상에서 완전히 벗어난 긴 여정'},
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = key.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final planRequest = ref.watch(planProvider);
    final int? selectedDays = planRequest.days;
    final bool isDayTrip = (selectedDays == 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaletteAppBar(title: '여행의 길이'),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // section 1. 여행 기간
            const _SectionTitle(title: '얼마나 오래 여행하시나요?'),
            const SizedBox(height: 16),
            ...scheduleOptions.map((option) {
              final isSelected = (selectedDays == option['days']);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () {
                    ref.read(planProvider.notifier).updateDays(option['days']);
                    if (option['days'] == 1) {
                      _scrollTo(_nearbyKey);
                    } else {
                      _scrollTo(_timeKey);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accent
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppColors.accent
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              option['subtitle'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: AppColors.accent),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // section 2. 도착/출발 시간대 (당일치기 아닐 때만)
            if (selectedDays != null && !isDayTrip) ...[
              const SizedBox(height: 28),
              SizedBox(key: _timeKey, height: 0),
              const _SectionTitle(title: '도착/출발 시간대'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _VisitTimeSelector(
                      title: '첫날 도착',
                      selected: planRequest.arrivalTime,
                      onSelected: (t) {
                        ref.read(planProvider.notifier).updateArrivalTime(t);
                        _scrollTo(_nearbyKey);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _VisitTimeSelector(
                      title: '마지막날 출발',
                      selected: planRequest.departureTime,
                      onSelected: (t) {
                        ref.read(planProvider.notifier).updateDepartureTime(t);
                        _scrollTo(_nearbyKey);
                      },
                    ),
                  ),
                ],
              ),
            ],

            // section 3. 근교 포함 여부
            if (selectedDays != null) ...[
              const SizedBox(height: 28),
              SizedBox(key: _nearbyKey, height: 0),
              _SectionTitle(title: '근교도 포함할까요?'),
              const SizedBox(height: 8),
              Text(
                isDayTrip ? '당일치기는 근교 포함이 어려워요' : '근교 여행지를 포함합니다',
                style: TextStyle(
                  fontSize: 13,
                  color: isDayTrip
                      ? AppColors.textTertiary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _ToggleChip(
                    label: '포함',
                    icon: Icons.train_outlined,
                    isSelected: planRequest.includeNearby,
                    isDisabled: isDayTrip,
                    onTap: isDayTrip
                        ? null
                        : () => ref
                              .read(planProvider.notifier)
                              .toggleIncludeNearby(),
                  ),
                  const SizedBox(width: 10),
                  _ToggleChip(
                    label: '제외',
                    icon: Icons.location_city_outlined,
                    isSelected: !planRequest.includeNearby,
                    isDisabled: isDayTrip,
                    onTap: isDayTrip
                        ? null
                        : () {
                            if (planRequest.includeNearby) {
                              ref
                                  .read(planProvider.notifier)
                                  .toggleIncludeNearby();
                            }
                          },
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
      bottomNavigationBar: StepBottomBar(
        onPressed: selectedDays != null
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SelectCompanionScreen(),
                  ),
                )
            : null,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _VisitTimeSelector extends StatelessWidget {
  final String title;
  final VisitTime? selected;
  final ValueChanged<VisitTime> onSelected;

  const _VisitTimeSelector({
    required this.title,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          ...VisitTime.values.map((t) {
            final isSelected = (selected == t);
            return GestureDetector(
              onTap: () => onSelected(t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.inputFill,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      t.icon,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      t.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _ToggleChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isDisabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isDisabled
              ? AppColors.inputFill
              : isSelected
              ? AppColors.primary
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDisabled
                ? AppColors.textTertiary
                : isSelected
                ? AppColors.primary
                : AppColors.timelineBar,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDisabled
                  ? AppColors.textTertiary
                  : isSelected
                  ? Colors.white
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDisabled
                    ? AppColors.textTertiary
                    : isSelected
                    ? Colors.white
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
