import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/region/data/region_details_data.dart';
import 'package:palette_michi/features/region/screens/favorite_regions_screen.dart';
import 'package:palette_michi/features/region/screens/region_detail_screen.dart';
import 'package:palette_michi/widgets/japan_map_painter.dart';
import 'package:palette_michi/widgets/palette_app_bar.dart';
import '../models/region_model.dart';
import '../services/map_loader_service.dart';

class RegionScreen extends StatefulWidget {
  const RegionScreen({super.key});

  @override
  State<RegionScreen> createState() => _RegionScreenState();
}

class _RegionScreenState extends State<RegionScreen> {
  late Future<MapDataResult> _mapFuture;
  MapDataResult? _mapData;
  RegionGroup? _selectedGroup;

  bool _isMapInitialized = false;

  @override
  void initState() {
    super.initState();
    // 매 build마다 로드되지 않도록 Future를 변수에 저장
    // 사이즈는 대략적인 초기값을 주고, LayoutBuilder에서 확정된 데이터를 사용하도록 구조화 가능
    // 여기서는 간단하게 첫 빌드 시점의 Context를 활용하기 위해 지연 호출하거나
    // LayoutBuilder 안에서 로직을 유지하되 _mapData 캐싱을 활용합니다.
  }

  void _handleTap(TapUpDetails details, Size size) {
    if (_mapData == null) return;

    final Offset tapPos = details.localPosition;

    // 1. 오키나와 프레임 내부 (Painter 정의와 일치)
    final RRect okinawaFrame = RRect.fromLTRBR(
      30,
      15,
      size.width * 0.5,
      size.height * 0.35,
      const Radius.circular(10),
    );

    if (okinawaFrame.contains(tapPos)) {
      if (_selectedGroup == RegionGroup.okinawa) return;
      setState(() => _selectedGroup = RegionGroup.okinawa);
      HapticFeedback.lightImpact();
      return;
    }

    // 2. 본토 지역 판정
    RegionGroup foundGroup = RegionGroup.nowhere;
    for (var region in _mapData!.allRegions) {
      for (var path in region.paths) {
        if (path.contains(tapPos)) {
          foundGroup = region.group;
          break;
        }
      }
      if (foundGroup != RegionGroup.nowhere) break;
    }

    if (_selectedGroup != foundGroup) {
      setState(() => _selectedGroup = foundGroup);
      if (foundGroup != RegionGroup.nowhere) {
        HapticFeedback.lightImpact();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSelection =
        _selectedGroup != null && _selectedGroup != RegionGroup.nowhere;
    final Color appBarColor = hasSelection
        ? getGroupColor(_selectedGroup!)
        : AppColors.primary;
    final bool appBarDark =
        !hasSelection ||
        getGroupColor(_selectedGroup!).computeLuminance() < 0.4;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaletteAppBar(
        title: "일본 지역 가이드",
        dark: appBarDark,
        backgroundColor: appBarColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_rounded),
            tooltip: '관심 여행지',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoriteRegionsScreen()),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          if (!_isMapInitialized) {
            _mapFuture = MapLoaderService.loadJapanMap(size);
            _isMapInitialized = true;
          }

          return FutureBuilder<MapDataResult>(
            // MapLoaderService에 size 전달
            future: _mapFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  _mapData == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "지도를 불러올 수 없습니다.",
                    style: TextStyle(color: AppColors.danger),
                  ),
                );
              }

              _mapData = snapshot.data;

              return Stack(
                children: [
                  // 배경 클릭 시 선택 해제 영역
                  GestureDetector(
                    onTap: () {
                      if (hasSelection) {
                        setState(() => _selectedGroup = RegionGroup.nowhere);
                      }
                    },
                    child: Container(color: Colors.transparent),
                  ),

                  // 지도 레이어
                  Center(
                    child: GestureDetector(
                      onTapUp: (details) => _handleTap(details, size),
                      child: CustomPaint(
                        size: size,
                        painter: JapanMapPainter(
                          combinedGroupPaths: _mapData!.combinedPaths,
                          selectedGroup: _selectedGroup,
                        ),
                      ),
                    ),
                  ),

                  // 하단 정보 카드 (애니메이션 적용)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    bottom:
                        (_selectedGroup != null &&
                            _selectedGroup != RegionGroup.nowhere)
                        ? 40
                        : -120,
                    left: 20,
                    right: 20,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity:
                          (_selectedGroup != null &&
                              _selectedGroup != RegionGroup.nowhere)
                          ? 1.0
                          : 0.0,
                      child: _buildInfoCard(),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoCard() {
    if (_selectedGroup == null || _selectedGroup == RegionGroup.nowhere) {
      return const SizedBox.shrink();
    }

    final detail = regionDetails[_selectedGroup!];
    if (detail == null) return const SizedBox.shrink();

    final Color cardColor = getGroupColor(_selectedGroup!);
    final Color textColor = getGroupTextColor(_selectedGroup!);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RegionDetailScreen(detail: detail, group: _selectedGroup!),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: cardColor.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      detail.nameKr,
                      style: GoogleFonts.notoSansKr(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail.name.toUpperCase(),
                      style: GoogleFonts.notoSans(
                        color: textColor.withValues(alpha: 0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
              ),
              Text(
                "자세히 보기",
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: textColor.withValues(alpha: 0.15),
                radius: 18,
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: textColor,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
