import 'dart:ui';

import 'package:flutter/material.dart' show Colors;

enum RegionGroup {
  hokkaido,
  tohoku,
  kanto,
  hokurikuShinetsu,
  tokai,
  kansai,
  chugoku,
  shikoku,
  kyushu,
  okinawa,
  nowhere,
}

class JapanRegion {
  final String id; // 예: JP01, JP02...
  final String name;
  final RegionGroup group; // 예: Kanto, Kyushu...
  final List<Path> paths;

  JapanRegion({
    required this.id,
    required this.name,
    required this.group,
    required this.paths,
  });
}

// 지역별 그룹 매핑
RegionGroup getGroup(String id) {
  final int idNum = int.parse(id.replaceAll("JP", ""));
  if (idNum == 1) return RegionGroup.hokkaido;
  if (idNum >= 2 && idNum <= 7) return RegionGroup.tohoku;
  if (idNum >= 8 && idNum <= 14) return RegionGroup.kanto;
  if (idNum >= 15 && idNum <= 18 || idNum == 20)
    return RegionGroup.hokurikuShinetsu;
  if (idNum == 19 && idNum >= 21 || idNum <= 24) return RegionGroup.tokai;
  if (idNum >= 25 && idNum <= 30) return RegionGroup.kansai;
  if (idNum >= 31 && idNum <= 35) return RegionGroup.chugoku;
  if (idNum >= 36 && idNum <= 39) return RegionGroup.shikoku;
  if (idNum >= 40 && idNum <= 46) return RegionGroup.kyushu;
  if (idNum == 47) return RegionGroup.okinawa;

  return RegionGroup.nowhere;
}

// 지역별 컬러 매핑
Color getGroupColor(RegionGroup group) {
  switch (group) {
    case RegionGroup.hokkaido:
      return const Color(0xFF81D4FA); // Light Blue
    case RegionGroup.tohoku:
      return const Color(0xFFA5D6A7); // Green
    case RegionGroup.kanto:
      return const Color(0xFFEF9A9A); // Red/Pink
    case RegionGroup.hokurikuShinetsu:
      return const Color(0xFFFFF59D); // Yellow
    case RegionGroup.tokai:
      return const Color(0xFFCE93D8); // Purple
    case RegionGroup.kansai:
      return const Color(0xFFCFD0FE); // Blue Purple
    case RegionGroup.chugoku:
      return const Color(0xFFFFCC80); // Orange
    case RegionGroup.shikoku:
      return const Color(0xFF80CBC4); // Teal
    case RegionGroup.kyushu:
      return const Color(0xFFFFAB91); // Deep Orange
    case RegionGroup.okinawa:
      return const Color(0xFFECEAE4); // Ivory
    case RegionGroup.nowhere:
      return const Color(0xFFFFFFFF);
  }
}

/// 지역 그룹의 한국어 이름을 반환합니다.
String getGroupKoreanName(RegionGroup group) {
  switch (group) {
    case RegionGroup.hokkaido:
      return '홋카이도';
    case RegionGroup.tohoku:
      return '도호쿠';
    case RegionGroup.kanto:
      return '간토';
    case RegionGroup.hokurikuShinetsu:
      return '호쿠리쿠신에츠';
    case RegionGroup.tokai:
      return '도카이';
    case RegionGroup.kansai:
      return '간사이';
    case RegionGroup.chugoku:
      return '주고쿠';
    case RegionGroup.shikoku:
      return '시코쿠';
    case RegionGroup.kyushu:
      return '규슈';
    case RegionGroup.okinawa:
      return '오키나와';
    case RegionGroup.nowhere:
      return '';
  }
}

/// 지역 배경색의 밝기에 따라 적절한 전경(텍스트/아이콘) 색상을 반환합니다.
/// luminance > 0.4이면 밝은 배경 → 어두운 텍스트, 아니면 흰 텍스트.
Color getGroupTextColor(RegionGroup group) {
  final bg = getGroupColor(group);
  return bg.computeLuminance() > 0.4
      ? const Color(0xFF1B263B) // AppColors.textPrimary
      : Colors.white;
}

class RegionDetail {
  final String name;
  final String nameKr;
  final String description;
  final List<String> majorCities;
  final List<String> topSpots;
  final List<String> cultureAndFood;
  final List<String> images; // 이미지 파일 경로 또는 URL 리스트

  const RegionDetail({
    required this.name,
    required this.nameKr,
    required this.description,
    required this.majorCities,
    required this.topSpots,
    required this.cultureAndFood,
    required this.images,
  });
}
