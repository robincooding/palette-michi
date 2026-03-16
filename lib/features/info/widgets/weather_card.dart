import 'package:flutter/material.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/info/data/region_info.dart';
import 'package:palette_michi/features/info/models/weather_model.dart';
import 'package:palette_michi/features/info/services/info_service.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  final InfoService _infoService = InfoService();

  String _selectedCity = '도쿄';
  WeatherData? _weather;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() => _isLoading = true);

    final region = regionByName(_selectedCity) ?? supportedRegions.first;
    final weather = await _infoService.fetchFullWeather(
      region.lat,
      region.lng,
      cityName: _selectedCity, // 한국어 도시명 주입
    );

    if (mounted) {
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    }
  }

  void _onCityChanged(String city) {
    setState(() => _selectedCity = city);
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCitySelector(),
          const SizedBox(height: 18),
          _buildWeatherContent(),
        ],
      ),
    );
  }

  // ── 도시 선택 드롭다운 ───────────────────────────────────────
  Widget _buildCitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.15),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCity,
          isExpanded: true,
          isDense: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          items: supportedCityNames
              .map(
                (city) => DropdownMenuItem(
                  value: city,
                  child: Row(
                    children: [
                      const Text('📍 ', style: TextStyle(fontSize: 13)),
                      Text(city),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (city) {
            if (city != null) _onCityChanged(city);
          },
        ),
      ),
    );
  }

  // ── 날씨 콘텐츠 ─────────────────────────────────────────────
  Widget _buildWeatherContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_weather == null) {
      return const Center(child: Text('날씨 정보를 불러올 수 없습니다.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _weather!.city,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _weather!.condition,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Icon(
                _weather!.icon,
                size: 64,
                color: _getIconColor(_weather!.icon),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeatherDetail(
                '기온',
                '${_weather!.temp.toStringAsFixed(1)}°',
              ),
              _buildWeatherDetail(
                '체감',
                '${_weather!.feelsLike.toStringAsFixed(1)}°',
              ),
              _buildWeatherDetail('습도', '${_weather!.humidity}%'),
              _buildWeatherDetail(
                _weather!.pop != null ? '강수' : '풍속',
                _weather!.pop != null
                    ? '${_weather!.pop}%'
                    : '${_weather!.windSpeed}m/s',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getIconColor(IconData icon) {
    if (icon == Icons.wb_sunny) return Colors.orange;
    if (icon == Icons.cloud) return Colors.blueGrey;
    if (icon == Icons.umbrella) return Colors.blue;
    if (icon == Icons.flash_on) return Colors.amber;
    if (icon == Icons.ac_unit) return Colors.lightBlueAccent;
    return Colors.grey;
  }

  Widget _buildWeatherDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
