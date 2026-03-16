import 'package:flutter/material.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({super.key});

  static const _platforms = [
    _Platform(
      emoji: '🍽️',
      name: '타베로그',
      nameJp: 'Tabelog',
      description: '일본 최대 맛집 리뷰 플랫폼이에요. 평점 3.5 이상이면 현지에서도 인기 있는 맛집입니다. 예약까지 연동돼요.',
      url: 'https://tabelog.com/kr/',
      color: Color(0xFFE74C3C),
    ),
    _Platform(
      emoji: '🗺️',
      name: '구글맵',
      nameJp: 'Google Maps',
      description: '구글맵의 별점 4.0 이상 + 리뷰 200개 이상 식당은 대체로 믿을 수 있어요. 영업시간·혼잡도·메뉴 사진까지 확인 가능합니다.',
      url: 'https://maps.google.com',
      color: Color(0xFF4285F4),
    ),
    _Platform(
      emoji: '📱',
      name: '레티',
      nameJp: 'Retty',
      description: '일본판 맛집 SNS. 현지인 기반 리뷰라 타베로그보다 로컬 감성이 강해요. 도쿄·오사카 등 대도시 맛집 탐방에 적합합니다.',
      url: 'https://retty.me',
      color: Color(0xFFE8602C),
    ),
  ];

  static const _cityGuides = [
    _CityGuide(
      city: '도쿄',
      emoji: '🗼',
      spots: [
        '시부야·신주쿠 — 트렌디한 라멘·스시 오마카세 밀집',
        '아사쿠사 — 전통 텐푸라·야키토리',
        '긴자·마루노우치 — 고급 일식·프렌치',
        '나카메구로 — 카페·디저트 핫플',
      ],
    ),
    _CityGuide(
      city: '오사카',
      emoji: '🏯',
      spots: [
        '도톤보리 — 타코야키·오코노미야키·라멘',
        '쿠로몬 시장 — 해산물·꼬치구이 현지 먹거리',
        '신세카이 — 쿠시카츠(꼬치튀김) 원조 거리',
        '호젠지 요코초 — 숨은 이자카야 골목',
      ],
    ),
    _CityGuide(
      city: '교토',
      emoji: '⛩️',
      spots: [
        '니시키 시장 — 두부 요리·교토식 절임 반찬',
        '기온 — 카이세키(정통 코스) 전문점 밀집',
        '후시미 — 일본 사케 양조장 투어·시음',
        '아라시야마 — 유도후(두부 전골) 추천',
      ],
    ),
    _CityGuide(
      city: '후쿠오카',
      emoji: '🎡',
      spots: [
        '나카스 야타이 — 포장마차 거리, 라멘·모츠나베',
        '하카타역 주변 — 하카타 라멘 원조 가게들',
        '텐진 — 스시·야끼니쿠·메이드 카페',
        '오호리 공원 주변 — 조용한 카페 산책 코스',
      ],
    ),
  ];

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('링크를 열 수 없습니다: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          '일본 맛집 정보',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          // 플랫폼 섹션
          _SectionTitle(title: '🔍 맛집 찾기 플랫폼'),
          const SizedBox(height: 12),
          ..._platforms.map(
            (p) => _PlatformCard(
              platform: p,
              onTap: () => _launchUrl(context, p.url),
            ),
          ),
          const SizedBox(height: 28),

          // 도시별 가이드
          const _SectionTitle(title: '🗾 도시별 추천 맛집 거리'),
          const SizedBox(height: 12),
          ..._cityGuides.map((g) => _CityGuideCard(guide: g)),
        ],
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
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _Platform {
  final String emoji;
  final String name;
  final String nameJp;
  final String description;
  final String url;
  final Color color;

  const _Platform({
    required this.emoji,
    required this.name,
    required this.nameJp,
    required this.description,
    required this.url,
    required this.color,
  });
}

class _PlatformCard extends StatelessWidget {
  final _Platform platform;
  final VoidCallback onTap;

  const _PlatformCard({required this.platform, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: platform.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  platform.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        platform.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        platform.nameJp,
                        style: TextStyle(
                          fontSize: 11,
                          color: platform.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    platform.description,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new, size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _CityGuide {
  final String city;
  final String emoji;
  final List<String> spots;

  const _CityGuide({
    required this.city,
    required this.emoji,
    required this.spots,
  });
}

class _CityGuideCard extends StatelessWidget {
  final _CityGuide guide;

  const _CityGuideCard({required this.guide});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(guide.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                guide.city,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...guide.spots.map(
            (spot) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '•  ',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      spot,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
