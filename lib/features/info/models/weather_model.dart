import 'package:flutter/material.dart';

class WeatherData {
  final String city;
  final double temp;
  final double feelsLike;
  final String condition;
  final int humidity;
  final double windSpeed;
  final int? pop;
  final IconData icon;

  WeatherData({
    required this.city,
    required this.temp,
    required this.feelsLike,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    this.pop,
    required this.icon,
  });

  /// cityName: 선택한 한국어 도시명을 외부에서 주입
  factory WeatherData.fromJson(
    Map<String, dynamic> json, {
    required String cityName,
  }) {
    final mainWeather = json['weather']?[0]?['main'] as String?;
    final description = json['weather']?[0]?['description'] as String?;

    return WeatherData(
      city: cityName, // API 영문명 대신 한국어 도시명 사용
      temp: (json['main']['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['main']['feels_like'] as num?)?.toDouble() ?? 0.0,
      condition: _translateCondition(description, mainWeather),
      humidity: json['main']['humidity'] as int? ?? 0,
      windSpeed: (json['wind']['speed'] as num?)?.toDouble() ?? 0.0,
      icon: _getIconFromWeather(mainWeather),
    );
  }

  WeatherData copyWith({
    String? city,
    double? temp,
    double? feelsLike,
    String? condition,
    int? humidity,
    double? windSpeed,
    int? pop,
    IconData? icon,
  }) {
    return WeatherData(
      city: city ?? this.city,
      temp: temp ?? this.temp,
      feelsLike: feelsLike ?? this.feelsLike,
      condition: condition ?? this.condition,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      pop: pop ?? this.pop,
      icon: icon ?? this.icon,
    );
  }

  // ── 날씨 설명 영→한 변환 ──────────────────────────────────
  static String _translateCondition(String? description, String? main) {
    if (description == null) return '정보 없음';

    const Map<String, String> conditionMap = {
      // Clear
      'clear sky': '맑음',
      // Clouds
      'few clouds': '구름 조금',
      'scattered clouds': '구름 많음',
      'broken clouds': '흐림',
      'overcast clouds': '완전 흐림',
      // Drizzle
      'light intensity drizzle': '가벼운 이슬비',
      'drizzle': '이슬비',
      'heavy intensity drizzle': '강한 이슬비',
      'light intensity drizzle rain': '이슬비 섞인 비',
      'drizzle rain': '이슬비 섞인 비',
      'shower rain and drizzle': '소나기와 이슬비',
      // Rain
      'light rain': '가벼운 비',
      'moderate rain': '비',
      'heavy intensity rain': '강한 비',
      'very heavy rain': '폭우',
      'extreme rain': '매우 강한 폭우',
      'freezing rain': '결빙 비',
      'light intensity shower rain': '가벼운 소나기',
      'shower rain': '소나기',
      'heavy intensity shower rain': '강한 소나기',
      'ragged shower rain': '불규칙 소나기',
      // Thunderstorm
      'thunderstorm with light rain': '뇌우 (약한 비)',
      'thunderstorm with rain': '뇌우',
      'thunderstorm with heavy rain': '뇌우 (강한 비)',
      'light thunderstorm': '약한 뇌우',
      'thunderstorm': '뇌우',
      'heavy thunderstorm': '강한 뇌우',
      'ragged thunderstorm': '불규칙 뇌우',
      'thunderstorm with light drizzle': '뇌우 (이슬비)',
      'thunderstorm with drizzle': '뇌우 (이슬비)',
      'thunderstorm with heavy drizzle': '뇌우 (강한 이슬비)',
      // Snow
      'light snow': '가벼운 눈',
      'snow': '눈',
      'heavy snow': '폭설',
      'sleet': '진눈깨비',
      'light shower sleet': '가벼운 진눈깨비',
      'shower sleet': '진눈깨비 소나기',
      'light rain and snow': '비와 눈',
      'rain and snow': '비와 눈',
      'light shower snow': '가벼운 눈 소나기',
      'shower snow': '눈 소나기',
      'heavy shower snow': '강한 눈 소나기',
      // Atmosphere
      'mist': '안개',
      'smoke': '연무',
      'haze': '실안개',
      'sand/dust whirls': '황사',
      'fog': '짙은 안개',
      'sand': '황사',
      'dust': '먼지',
      'volcanic ash': '화산재',
      'squalls': '돌풍',
      'tornado': '토네이도',
    };

    return conditionMap[description.toLowerCase()] ??
        _translateByMain(main) ??
        description; // 매핑 없으면 원문 그대로
  }

  /// description 매핑 실패 시 main 카테고리로 폴백
  static String? _translateByMain(String? main) {
    switch (main?.toLowerCase()) {
      case 'clear':
        return '맑음';
      case 'clouds':
        return '흐림';
      case 'rain':
        return '비';
      case 'drizzle':
        return '이슬비';
      case 'thunderstorm':
        return '뇌우';
      case 'snow':
        return '눈';
      case 'mist':
      case 'fog':
        return '안개';
      default:
        return null;
    }
  }

  static IconData _getIconFromWeather(String? main) {
    switch (main?.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.umbrella;
      case 'drizzle':
        return Icons.umbrella;
      case 'snow':
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.flash_on;
      default:
        return Icons.cloudy_snowing;
    }
  }
}
