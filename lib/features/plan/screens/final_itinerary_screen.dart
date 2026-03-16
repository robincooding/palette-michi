import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/auth/screens/login_screen.dart';
import 'package:palette_michi/features/plan/providers/plan_provider.dart';
import 'package:palette_michi/widgets/palette_app_bar.dart';
import '../providers/plan_result_provider.dart';

// ── slot_type 열거형 ─────────────────────────────────────
enum _SlotType { meal, cafe, lifestyle, sightseeing }

_SlotType _parseSlotType(dynamic item) {
  final raw = item['slot_type'] as String?;
  if (raw != null) {
    switch (raw.toLowerCase().trim()) {
      case 'meal':
        return _SlotType.meal;
      case 'cafe':
        return _SlotType.cafe;
      case 'lifestyle':
        return _SlotType.lifestyle;
      case 'sightseeing':
        return _SlotType.sightseeing;
    }
  }

  // 하위 호환: slot_type 없는 구버전 일정 — place_name + 시간대 추론
  final placeName = (item['place_name'] as String?) ?? '';
  final arrivalTime = (item['arrival_time'] as String?) ?? '';
  final hour = int.tryParse(arrivalTime.split(':').firstOrNull ?? '') ?? -1;

  final isMealByName =
      placeName.contains('점심') ||
      placeName.contains('저녁') ||
      placeName.contains('아침') ||
      placeName.contains('식사') ||
      placeName.contains('레스토랑') ||
      placeName.contains('런치') ||
      placeName.contains('디너') ||
      placeName.contains('맛집') ||
      placeName.contains('라멘') ||
      placeName.contains('스시') ||
      placeName.contains('야타이') ||
      placeName.contains('이자카야');
  final isMealByTime =
      hour >= 0 && ((hour >= 11 && hour <= 14) || (hour >= 17 && hour <= 21));

  if (isMealByName || isMealByTime) return _SlotType.meal;

  final isCafeByName =
      placeName.contains('카페') ||
      placeName.contains('커피') ||
      placeName.contains('디저트') ||
      placeName.contains('베이커리') ||
      placeName.contains('킷사') ||
      placeName.contains('티룸');
  final isCafeByTime = hour >= 14 && hour <= 17;

  if (isCafeByName || isCafeByTime) return _SlotType.cafe;

  return _SlotType.sightseeing;
}

IconData _slotIcon(_SlotType type) => switch (type) {
  _SlotType.meal => Icons.restaurant_outlined,
  _SlotType.cafe => Icons.local_cafe_outlined,
  _SlotType.lifestyle => Icons.location_on_outlined,
  _SlotType.sightseeing => Icons.location_on_outlined,
};

Color _slotIconBg(_SlotType type) => switch (type) {
  _SlotType.meal => AppColors.mealIconBg,
  _SlotType.cafe => AppColors.cafeIconBg,
  _SlotType.lifestyle => AppColors.primary.withValues(alpha: 0.07),
  _SlotType.sightseeing => AppColors.primary.withValues(alpha: 0.07),
};

Color _slotIconColor(_SlotType type) => switch (type) {
  _SlotType.meal => AppColors.mealIconColor,
  _SlotType.cafe => AppColors.cafeIconColor,
  _SlotType.lifestyle => AppColors.primary,
  _SlotType.sightseeing => AppColors.primary,
};

// ──────────────────────────────────────────────────────────
//  FinalItineraryScreen
// ──────────────────────────────────────────────────────────
class FinalItineraryScreen extends ConsumerStatefulWidget {
  final String? docId;

  const FinalItineraryScreen({super.key, this.docId});

  @override
  ConsumerState<FinalItineraryScreen> createState() =>
      _FinalItineraryScreenState();
}

class _FinalItineraryScreenState extends ConsumerState<FinalItineraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _accommodationExpanded = true;

  @override
  void initState() {
    super.initState();
    final itinerary = ref.read(planResultProvider).itinerary ?? [];
    _tabController = TabController(length: itinerary.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planResult = ref.watch(planResultProvider);
    final itinerary = planResult.itinerary ?? [];
    final accommodations = planResult.accommodations;

    if (itinerary.isEmpty || itinerary.length != _tabController.length) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: SizedBox.shrink(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(itinerary),
      body: Column(
        children: [
          if (accommodations.isNotEmpty)
            _buildAccommodationSection(accommodations),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: itinerary.map((dayData) {
                final schedules = (dayData['schedule'] as List<dynamic>?) ?? [];
                final dayArea = (dayData['area'] as String?) ?? '';
                return _buildDayTimeline(schedules, dayArea);
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.docId == null
          ? _buildBottomBar(context)
          : null,
    );
  }

  // ── AppBar ────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(List<dynamic> itinerary) {
    return PaletteAppBar(
      title: '나의 여행 팔레트',
      dark: true,
      actions: [
        if (widget.docId != null)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            onPressed: _showDeleteDialog,
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Container(
          color: AppColors.primary,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppColors.textOnDark,
            indicatorWeight: 2.5,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textOnDarkMuted,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 13,
            ),
            tabs: itinerary.map((day) {
              final areaName = (day['area'] as String?) ?? '';
              return Tab(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${day['day']}일차'),
                      if (areaName.isNotEmpty)
                        Text(
                          areaName,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ── 숙소 추천 섹션 ────────────────────────────────────
  Widget _buildAccommodationSection(List<dynamic> accommodations) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(
              () => _accommodationExpanded = !_accommodationExpanded,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.hotel_outlined,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '추천 숙소 위치',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _accommodationExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_accommodationExpanded) ...[
            const Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: accommodations.asMap().entries.map((entry) {
                  final isLast = entry.key == accommodations.length - 1;
                  return _buildAccommodationItem(entry.value, isLast);
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccommodationItem(dynamic acc, bool isLast) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              acc['nights'] ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    Text(
                      acc['area'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      '·',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      acc['nearest_station'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  acc['reason'] ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 날짜별 타임라인 ───────────────────────────────────
  Widget _buildDayTimeline(List<dynamic> schedules, String dayArea) {
    if (schedules.isEmpty) {
      return const Center(
        child: Text(
          '일정 데이터가 없어요.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final item = schedules[index];
        final isLast = index == schedules.length - 1;
        return _buildTimelineRow(item, isLast);
      },
    );
  }

  Widget _buildTimelineRow(dynamic item, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Column(
              children: [
                Text(
                  item['arrival_time'] ?? '--:--',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: AppColors.timelineBar),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                _PlaceCard(item: item),
                if (!isLast) _buildTransportChip(item['transport_time']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportChip(dynamic transportTime) {
    if (transportTime == null) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const SizedBox(width: 2),
          const Icon(
            Icons.directions_subway_outlined,
            size: 13,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 6),
          Text(
            '약 $transportTime분 이동',
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ── 하단 버튼 ─────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: ElevatedButton(
          onPressed: () => _onSavePressed(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bookmark_outline, size: 18),
              SizedBox(width: 8),
              Text(
                '일정 저장하고 홈으로',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 저장 로직 ─────────────────────────────────────────
  Future<void> _onSavePressed(BuildContext context) async {
    final defaultCity = ref.read(planProvider).city ?? '일본';
    final titleController = TextEditingController(text: '$defaultCity 여행');

    final customTitle = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SaveDialog(controller: titleController),
    );

    if (customTitle == null || customTitle.trim().isEmpty) return;

    try {
      await ref
          .read(planResultProvider.notifier)
          .saveItinerary(customTitle.trim());

      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ref.read(planProvider.notifier).reset();
        ref.read(planResultProvider.notifier).reset();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('보관함에 안전하게 저장되었습니다! 🎨'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) _showLoginRequiredDialog(context);
    }
  }

  // ── 다이얼로그 ────────────────────────────────────────
  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '로그인 필요',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('일정을 저장하려면\n로그인이 필요합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '나중에',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text('로그인하기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '일정 삭제',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('이 일정을 보관함에서 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(planResultProvider.notifier)
                    .deleteItinerary(widget.docId!);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('일정이 삭제되었습니다.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('삭제 중 오류가 발생했습니다.')),
                  );
                }
              }
            },
            child: const Text('삭제', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
//  _PlaceCard
// ──────────────────────────────────────────────────────────
class _PlaceCard extends StatelessWidget {
  final dynamic item;

  const _PlaceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final placeName = (item['place_name'] as String?) ?? '';
    final tip = (item['tip'] as String?) ?? '';
    final duration = item['duration'];
    final slotType = _parseSlotType(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _slotIconBg(slotType),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _slotIcon(slotType),
                    size: 14,
                    color: _slotIconColor(slotType),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    placeName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (duration != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      '$duration분',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            if (tip.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tip,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── 저장 다이얼로그 ───────────────────────────────────────
class _SaveDialog extends StatelessWidget {
  final TextEditingController controller;

  const _SaveDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        '여행 보관함에 저장',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이 여행의 이름을 지어주세요.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '예: 가족과 함께하는 도쿄',
              hintStyle: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 13,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '취소',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, controller.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: const Text('저장하기', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
