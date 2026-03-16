import 'package:flutter/material.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  static const _services = [
    _BookingService(
      emoji: '✈️',
      name: '스카이스캐너',
      category: '항공권',
      description: '전 세계 항공사 가격을 한 번에 비교할 수 있어요. 최저가 항공권 검색에 강점이 있습니다.',
      url: 'https://www.skyscanner.co.kr',
      color: Color(0xFF0770E3),
    ),
    _BookingService(
      emoji: '🏨',
      name: '아고다',
      category: '숙소',
      description: '아시아 지역 숙소 가격 경쟁력이 높아요. 일본 호텔·호스텔·료칸 예약에 추천합니다.',
      url: 'https://www.agoda.com/ko-kr',
      color: Color(0xFFE50000),
    ),
    _BookingService(
      emoji: '🔍',
      name: '카약(KAYAK)',
      category: '항공 + 숙소',
      description: '항공권·호텔·렌터카를 한 번에 비교할 수 있는 메타서치 서비스예요.',
      url: 'https://www.kayak.co.kr',
      color: Color(0xFFFF690F),
    ),
    _BookingService(
      emoji: '🏠',
      name: '부킹닷컴',
      category: '숙소',
      description: '글로벌 최대 숙소 예약 플랫폼. 료칸(旅館), 게스트하우스 등 다양한 숙소 유형을 지원합니다.',
      url: 'https://www.booking.com',
      color: Color(0xFF003580),
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
          '항공·숙소 예약',
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: const Row(
              children: [
                Text('💡', style: TextStyle(fontSize: 22)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '아래 서비스로 이동하여 직접 예약하세요.\n팔레트 미치는 예약 과정에 관여하지 않습니다.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ..._services.map(
            (service) => _BookingCard(
              service: service,
              onTap: () => _launchUrl(context, service.url),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingService {
  final String emoji;
  final String name;
  final String category;
  final String description;
  final String url;
  final Color color;

  const _BookingService({
    required this.emoji,
    required this.name,
    required this.category,
    required this.description,
    required this.url,
    required this.color,
  });
}

class _BookingCard extends StatelessWidget {
  final _BookingService service;
  final VoidCallback onTap;

  const _BookingCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: service.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  service.emoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: service.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          service.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: service.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.open_in_new,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
