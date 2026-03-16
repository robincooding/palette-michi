import 'package:flutter/material.dart';
import 'package:palette_michi/core/theme/app_colors.dart';

class TravelTipsScreen extends StatelessWidget {
  const TravelTipsScreen({super.key});

  static const _tips = [
    _TipData(
      emoji: '💳',
      title: 'IC카드(Suica·ICOCA) 미리 발급',
      body: '전철, 버스, 편의점 결제까지 한 장으로 해결돼요. 한국에서 앱(Suica)으로 발급하거나 공항 도착 직후 자동판매기에서 구입하세요. 잔액 부족 시 역 내 충전기에서 현금으로 바로 충전 가능합니다.',
    ),
    _TipData(
      emoji: '📶',
      title: '현지 SIM 또는 포켓 Wi-Fi 준비',
      body: '일본은 무료 Wi-Fi가 제한적이에요. 인터넷 사용이 많다면 현지 e-SIM(예: IIJmio, AHaMobile)을 미리 구입하거나, 동행이 있다면 포켓 Wi-Fi 공유가 저렴합니다.',
    ),
    _TipData(
      emoji: '🗑️',
      title: '쓰레기통이 거의 없어요',
      body: '길거리 쓰레기통은 찾기 매우 어렵습니다. 편의점 구매 시 계산대 옆 쓰레기통을 이용하거나, 숙소로 가져가는 것이 기본 에티켓이에요.',
    ),
    _TipData(
      emoji: '🏪',
      title: '편의점을 적극 활용하세요',
      body: 'セブン-イレブン·ローソン·ファミマ의 음식 퀄리티는 한국 편의점과 다릅니다. 전자레인지 온열 서비스, ATM(해외카드 가능), 프린트, 공공요금 납부까지 다 돼요.',
    ),
    _TipData(
      emoji: '🧳',
      title: '역 코인락커를 적극 활용',
      body: '대형 짐은 역마다 있는 코인락커에 맡기고 가볍게 다니세요. 당일치기 이동 시 특히 유용하며, IC카드로도 결제할 수 있는 락커가 많아요.',
    ),
    _TipData(
      emoji: '🚌',
      title: '버스 탑승 방법은 지역마다 달라요',
      body: '오사카·교토는 앞문 탑승·앞문 하차(선불), 도쿄·후쿠오카는 뒷문 탑승·앞문 하차(후불) 방식이 많아요. 현지 버스 표시를 반드시 확인하세요.',
    ),
    _TipData(
      emoji: '🎫',
      title: '교통패스 미리 구입',
      body: 'JR Pass(7일·14일·21일)는 일본 입국 전 해외에서 구입해야 저렴해요. 오사카·교토 중심이라면 ICOCA+HARUKA 세트나 간사이 쓰루 패스도 체크해보세요.',
    ),
    _TipData(
      emoji: '♨️',
      title: '온천(온센) 이용 시 타투 주의',
      body: '대부분의 공중온천과 료칸 온천은 타투(문신)가 있으면 입욕이 금지됩니다. 타투가 있다면 사전에 시설 정책을 꼭 확인하세요. 개인실 온천은 대부분 가능해요.',
    ),
    _TipData(
      emoji: '🍱',
      title: '에키벤(駅弁) 꼭 경험해보세요',
      body: '역 도시락 에키벤은 일본 기차 여행의 묘미예요. 신칸센 탑승 전 역 내 매장에서 구입할 수 있으며 지역 특산물로 만든 한정 에키벤이 특히 인기입니다.',
    ),
    _TipData(
      emoji: '🗺️',
      title: '구글맵 오프라인 다운로드',
      body: '일본 주요 도시 지도를 출발 전 구글맵에서 오프라인으로 저장해두세요. 인터넷이 불안정한 지하철역·산간 지역에서도 지도를 쓸 수 있어요.',
    ),
    _TipData(
      emoji: '💴',
      title: '현금도 어느 정도 준비하세요',
      body: '일본은 아직 현금 사용 비율이 높아요. 소규모 음식점·신사·로컬 가게는 카드를 받지 않는 경우가 많습니다. 하루 5,000~10,000엔 정도 현금을 갖고 다니면 안전해요.',
    ),
    _TipData(
      emoji: '📅',
      title: '인기 식당은 사전 예약 필수',
      body: '유명 라멘집·스시·오마카세는 수 주 전에 마감되는 경우가 많아요. 타베로그(Tabelog)나 오픈 테이블(OpenTable Japan), 레티(Retty)에서 미리 예약하세요.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          '일본 여행 팁',
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
                Text('✈️', style: TextStyle(fontSize: 22)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '알아두면 여행이 훨씬 편해지는 나노 팁 모음이에요.\n지속적으로 업데이트됩니다!',
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
          ..._tips.map((tip) => _TipCard(tip: tip)),
        ],
      ),
    );
  }
}

class _TipData {
  final String emoji;
  final String title;
  final String body;

  const _TipData({
    required this.emoji,
    required this.title,
    required this.body,
  });
}

class _TipCard extends StatefulWidget {
  final _TipData tip;

  const _TipCard({required this.tip});

  @override
  State<_TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<_TipCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.tip.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.tip.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 10),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: 10),
              Text(
                widget.tip.body,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
