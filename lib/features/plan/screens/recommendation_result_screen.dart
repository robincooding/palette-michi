import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/plan/models/plan_request_model.dart';
import 'package:palette_michi/features/plan/screens/plan_loading_screen.dart';
import 'package:palette_michi/widgets/palette_app_bar.dart';
import '../providers/recommendation_provider.dart';
import '../providers/plan_provider.dart';
import '../models/place_model.dart';

class RecommendationResultScreen extends ConsumerWidget {
  const RecommendationResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationAsync = ref.watch(recommendationProvider);
    final planRequest = ref.watch(planProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaletteAppBar(title: '나만의 팔레트 결과'),
      body: recommendationAsync.when(
        data: (places) => Column(
          children: [
            _buildSelectionSummary(planRequest),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '취향 일치도 순으로 정렬되었습니다',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: places.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _PlaceRecommendationCard(
                    place: places[index],
                    rank: index + 1,
                  );
                },
              ),
            ),
          ],
        ),
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) =>
            Center(child: Text('데이터를 불러오지 못했습니다: $err')),
      ),
      bottomNavigationBar: _buildBottomAction(context),
    );
  }

  Widget _buildSelectionSummary(PlanRequest planRequest) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${planRequest.city} 여행 페르소나',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...planRequest.selectedCategories.map(
                (c) => Chip(
                  label: Text(c.name),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                  labelStyle: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                  side: BorderSide.none,
                ),
              ),
              ...planRequest.selectedStyles.values
                  .expand((styles) => styles)
                  .map(
                    (s) => Chip(
                      label: Text('#${s.label}'),
                      backgroundColor: AppColors.accent.withValues(alpha: 0.08),
                      labelStyle: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                      ),
                      side: BorderSide.none,
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PlanLoadingScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          '이 장소들로 AI 일정 생성하기',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _PlaceRecommendationCard extends StatelessWidget {
  final PlaceModel place;
  final int rank;

  const _PlaceRecommendationCard({required this.place, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    color: AppColors.inputFill,
                    child: place.imageUrl != null && place.imageUrl!.isNotEmpty
                        ? Image.asset(place.imageUrl!, fit: BoxFit.cover)
                        : const Icon(Icons.place, color: AppColors.textTertiary),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$rank위',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        place.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Wrap(
                        spacing: 4,
                        children: place.tags
                            .take(3)
                            .map(
                              (tag) => Text(
                                '#$tag',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    Text(
                      '${place.avgStayTime}분',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
