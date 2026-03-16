import 'package:flutter/material.dart';

/// Palette Michi 앱 공통 디자인 토큰
abstract final class AppColors {
  // ── Brand ───────────────────────────────────────────────
  /// Deep Midnight: 앱 기본 primary 색상
  static const primary = Color(0xFF1B263B);

  /// Lighter Midnight: gradient 등에 활용
  static const primaryLight = Color(0xFF415A77);

  /// Torii Red: 선택 상태, 액션 포인트
  static const accent = Color(0xFFE63946);

  // ── Backgrounds ─────────────────────────────────────────
  /// Cloud White: Scaffold 배경
  static const background = Color(0xFFF8F9FA);

  /// 카드/시트 배경
  static const surface = Colors.white;

  /// 인풋 필드 배경
  static const inputFill = Color(0xFFF1F3F5);

  // ── Text ────────────────────────────────────────────────
  static const textPrimary = Color(0xFF1B263B);

  /// Slate Grey: 본문 보조 텍스트
  static const textSecondary = Color(0xFF4A5568);

  static const textTertiary = Color(0xFFADB5BD);

  /// 어두운 배경 위의 텍스트 (AppBar 등)
  static const textOnDark = Color(0xFFE0E6ED);

  /// 어두운 배경 위의 비활성 텍스트 (미선택 탭 레이블 등)
  static const textOnDarkMuted = Color(0xFF778DA9);

  // ── UI Elements ─────────────────────────────────────────
  static const divider = Color(0xFFE9ECEF);

  /// 삭제/위험 액션
  static const danger = Color(0xFFE63946);

  /// 타임라인 연결선
  static const timelineBar = Color(0xFFCFD8DC);

  // ── 일정 슬롯 아이콘 ─────────────────────────────────────
  static const mealIconBg = Color(0xFFFFF3E0);
  static const mealIconColor = Color(0xFFE65100);
  static const cafeIconBg = Color(0xFFF3F0FF);
  static const cafeIconColor = Color(0xFF6741D9);
}
