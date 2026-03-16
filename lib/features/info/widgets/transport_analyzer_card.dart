// lib/features/info/widgets/transport_analyzer_card.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/info/services/transit_calculator_service.dart';
import 'package:palette_michi/features/plan/providers/plan_provider.dart';
import 'package:palette_michi/features/plan/providers/plan_result_provider.dart';
import 'package:palette_michi/widgets/login_required_dialog.dart';

class TransportAnalyzerCard extends ConsumerStatefulWidget {
  const TransportAnalyzerCard({super.key});

  @override
  ConsumerState<TransportAnalyzerCard> createState() =>
      _TransportAnalyzerCardState();
}

class _TransportAnalyzerCardState extends ConsumerState<TransportAnalyzerCard> {
  final TransitCalculatorService _calculatorService =
      TransitCalculatorService();
  bool _isAnalyzing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.train_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Text(
                "나에게 맞는 패스는?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            "저장된 일정을 바탕으로 가장 경제적인 교통수단을 분석해드려요.",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isAnalyzing ? null : _handleTransportAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isAnalyzing
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("분석 시작하기"),
            ),
          ),
        ],
      ),
    );
  }

  // ── 진입점 ───────────────────────────────────────────────
  void _handleTransportAction() {
    final planState = ref.read(planResultProvider);
    final String currentCity = ref.read(planProvider).city ?? '';

    if (planState.itinerary != null && planState.itinerary!.isNotEmpty) {
      _runAnalysis(
        itinerary: planState.itinerary!,
        accommodations: planState.accommodations,
        cityName: currentCity,
      );
    } else {
      // 생성된 일정 없음 → 보관함에서 선택
      _showSavedPlanSelector();
    }
  }

  // ── 분석 실행 ────────────────────────────────────────────
  Future<void> _runAnalysis({
    required List<dynamic> itinerary,
    required List<dynamic> accommodations,
    required String cityName,
  }) async {
    setState(() => _isAnalyzing = true);

    try {
      final result = await _calculatorService.calculatePlanFareResult(
        itinerary,
        accommodations,
        cityName,
      );
      final passes = await _calculatorService.compareWithPasses(
        result['totalFare'] as int,
        List<int>.from(result['dailyFares'] as List),
        cityName,
      );

      if (mounted) {
        _showResultBottomSheet(
          totalFare: result['totalFare'] as int,
          incompleteSegments: result['incompleteSegments'] as int,
          isEstimated: result['isEstimated'] as bool? ?? true,
          passes: passes,
          cityName: cityName,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('분석 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  // ── 보관함 선택 바텀시트 ─────────────────────────────────
  void _showSavedPlanSelector() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showLoginRequiredDialog(
        context,
        message: '저장된 여행 일정을 확인하려면\n로그인이 필요합니다.',
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('itineraries')
            .where('uid', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('데이터를 불러오지 못했습니다: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const SizedBox(
              height: 200,
              child: Center(child: Text('보관된 일정이 없습니다.')),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  '분석할 일정을 선택해주세요',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final request =
                        data['request'] as Map<String, dynamic>? ?? {};
                    final cityName = request['city'] as String? ?? '알 수 없는 지역';

                    return ListTile(
                      leading: const Icon(Icons.map_outlined),
                      title: Text(data['title'] ?? '$cityName 여행'),
                      subtitle: Text('$cityName · ${request['days'] ?? ''}일'),
                      onTap: () {
                        Navigator.pop(context);
                        _runAnalysis(
                          itinerary: data['itinerary'] as List<dynamic>? ?? [],
                          accommodations:
                              data['accommodations'] as List<dynamic>? ?? [],
                          cityName: cityName,
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  // ── 결과 바텀시트 ────────────────────────────────────────
  void _showResultBottomSheet({
    required int totalFare,
    required int incompleteSegments,
    required bool isEstimated,
    required List<Map<String, dynamic>> passes,
    required String cityName,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            // 드래그 핸들
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Row(
                children: [
                  const Text(
                    '교통비 분석 결과',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    cityName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 총 교통비 표시
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'IC카드 개별 구매 기준',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (isEstimated) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '추정값',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '약 ¥$totalFare',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (incompleteSegments > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '* $incompleteSegments개 구간 미산출 (신칸센·특급 등 별도 티켓 구간)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 패스 비교 리스트
            Expanded(
              child: passes.isEmpty
                  ? const Center(child: Text('비교 가능한 패스 정보가 없습니다.'))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: passes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final pass = passes[index];
                        final bool isIcCard =
                            pass['isIcCard'] as bool? ?? false;
                        final bool isBenefit =
                            pass['isRecommended'] as bool? ?? false;
                        final int saving = pass['saving'] as int? ?? 0;
                        final int? bestStart = pass['bestStartDay'] as int?;
                        final int? bestEnd = pass['bestEndDay'] as int?;
                        final int? windowFare = pass['windowFare'] as int?;

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isBenefit
                                  ? Colors.green.shade200
                                  : AppColors.divider,
                              width: isBenefit ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 패스명 + 추천 뱃지
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      pass['passName'] as String? ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  if (isBenefit)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '추천',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // IC카드
                              if (isIcCard)
                                const Text(
                                  '충전식 IC카드 · 실사용 요금 차감',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                )
                              else ...[
                                // 패스 요금
                                Text(
                                  '¥${pass['passPrice']}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // 최적 사용 기간 (추천 패스에만 표시)
                                if (isBenefit &&
                                    bestStart != null &&
                                    bestEnd != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 12,
                                          color: AppColors.textTertiary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          bestStart == bestEnd
                                              ? '$bestStart일차에 사용하면 최적'
                                                    '${windowFare != null ? ' (당일 개별 요금 ¥$windowFare)' : ''}'
                                              : '$bestStart~$bestEnd일차에 사용하면 최적'
                                                    '${windowFare != null ? ' (해당 기간 개별 요금 ¥$windowFare)' : ''}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // 절약/추가 금액
                                Text(
                                  isBenefit
                                      ? '전체 여정 기준 ¥$saving 절약'
                                      : '¥${saving.abs()} 더 지출',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isBenefit
                                        ? Colors.green.shade600
                                        : Colors.red.shade400,
                                  ),
                                ),
                              ],

                              // 비고
                              if (pass['notes'] != null &&
                                  (pass['notes'] as String).isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    pass['notes'] as String,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
