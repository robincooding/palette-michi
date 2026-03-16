import 'package:flutter/material.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/widgets/palette_app_bar.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaletteAppBar(title: '앱 소개', dark: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 헤더
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.travel_explore,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Palette Michi',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '나만의 색깔로 채우는 일본 여행',
                    style: TextStyle(fontSize: 15, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'v1.0.0',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    '앱 소개',
                    'Palette Michi는 AI 기반 일본 여행 플래너입니다. '
                        '여행 스타일과 취향을 분석해 나만을 위한 맞춤 일정을 생성해 드립니다. '
                        '"Palette"는 다채로운 여행 경험을, "Michi(道)"는 일본어로 길·여정을 의미합니다.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    '주요 기능',
                    null,
                    features: const [
                      (
                        '✈️',
                        'AI 여행 플래닝',
                        'Gemini AI가 나의 여행 스타일에 맞는 맞춤 일정을 만들어 드려요.',
                      ),
                      (
                        '🗾',
                        '일본 지역 가이드',
                        '홋카이도부터 오키나와까지 일본 10개 지역의 상세 정보를 확인하세요.',
                      ),
                      ('🧭', '여행 타입 테스트', '간단한 테스트로 나의 여행 스타일을 발견해 보세요.'),
                      ('📁', '일정 보관함', '생성한 여행 일정을 저장하고 언제든지 확인할 수 있어요.'),
                      ('❤️', '관심 여행지', '마음에 드는 지역을 저장하고 나중에 다시 확인하세요.'),
                      ('📝', '메모장', '여행 관련 메모를 자유롭게 기록하세요.'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow('제작', 'REDBREW'),
                  _buildInfoRow('버전', '1.0.0'),
                  _buildInfoRow('플랫폼', 'iOS / Android'),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    String? description, {
    List<(String, String, String)>? features,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (description != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.7,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        if (features != null)
          Column(
            children: features
                .map(
                  (f) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.$1, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.$2,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                f.$3,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 24),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
