import 'package:flutter/material.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/info/services/info_service.dart';
import 'package:palette_michi/features/info/widgets/exchange_calculator_card.dart';
import 'package:palette_michi/features/info/widgets/shopping_card.dart';
import 'package:palette_michi/features/info/widgets/transport_analyzer_card.dart';
import 'package:palette_michi/features/info/widgets/weather_card.dart';
import 'package:palette_michi/widgets/palette_app_bar.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final InfoService _infoService = InfoService();
  final ScrollController _scrollController = ScrollController();

  bool _showBackToTop = false;
  bool _isExchangeLoading = true;
  double _currentJpyRate = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 300 != _showBackToTop) {
        setState(() => _showBackToTop = !_showBackToTop);
      }
    });
    _loadExchangeRate();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 환율만 info_screen에서 관리 (날씨·쇼핑은 각 위젯이 자체 관리)
  Future<void> _loadExchangeRate() async {
    setState(() => _isExchangeLoading = true);
    final rate = await _infoService.fetchExchangeRate();
    if (mounted) {
      setState(() {
        _currentJpyRate = rate;
        _isExchangeLoading = false;
      });
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildFab() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _showBackToTop ? 1.0 : 0.0,
      child: FloatingActionButton(
        onPressed: _scrollToTop,
        backgroundColor: AppColors.primary,
        mini: true,
        child: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaletteAppBar(title: '여행 필수 정보', dark: true),
      floatingActionButton: _showBackToTop ? _buildFab() : null,
      body: _isExchangeLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadExchangeRate,
              child: ListView(
                padding: const EdgeInsets.all(20),
                controller: _scrollController,
                children: [
                  /// 1. 환율 계산 (도시 무관)
                  _buildSectionTitle('실시간 환율 계산기'),
                  ExchangeCalculatorCard(currentJpyRate: _currentJpyRate),
                  const SizedBox(height: 30),

                  /// 2. 날씨 (WeatherCard 내부에서 도시 선택)
                  _buildSectionTitle('오늘의 날씨'),
                  const WeatherCard(),
                  const SizedBox(height: 30),

                  /// 3. 교통비 분석
                  _buildSectionTitle('교통비 분석'),
                  const TransportAnalyzerCard(),
                  const SizedBox(height: 30),

                  /// 4. 쇼핑 필수템 (ShoppingCard 내부에서 도시 선택)
                  _buildSectionTitle('쇼핑 필수템'),
                  ShoppingCard(scrollController: _scrollController),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}

Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 12),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    ),
  );
}
