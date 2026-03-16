import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/plan_generator_service.dart';
import '../services/google_places_service.dart';
import '../providers/plan_provider.dart';
import '../providers/recommendation_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ── 일정 생성 상태 ────────────────────────────────────────
class PlanResultState {
  final bool isLoading;
  final List<dynamic>? itinerary;
  final List<dynamic> accommodations;
  final String? errorMessage;

  PlanResultState({
    this.isLoading = false,
    this.itinerary,
    this.accommodations = const [],
    this.errorMessage,
  });

  PlanResultState copyWith({
    bool? isLoading,
    List<dynamic>? itinerary,
    List<dynamic>? accommodations,
    String? errorMessage,
  }) {
    return PlanResultState(
      isLoading: isLoading ?? this.isLoading,
      itinerary: itinerary ?? this.itinerary,
      accommodations: accommodations ?? this.accommodations,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────
class PlanResultNotifier extends StateNotifier<PlanResultState> {
  final Ref ref;

  PlanResultNotifier(this.ref) : super(PlanResultState());

  Future<void> generateFullPlan() async {
    state = PlanResultState(isLoading: true);

    try {
      final request = ref.read(planProvider);
      final areaGroups = await ref.read(areaGroupProvider.future);

      // Google Places API — Gemini 프롬프트 보강용
      final placesApiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
      if (placesApiKey.isEmpty) {
        throw Exception('GOOGLE_PLACES_API_KEY가 설정되지 않았습니다.');
      }
      final placesService = GooglePlacesService(placesApiKey);
      final placesApiSuggestions = await placesService.fetchForAreas(
        areaGroups: areaGroups,
        request: request,
      );

      // Gemini — 일정 생성
      final geminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      if (geminiApiKey.isEmpty) {
        throw Exception('GEMINI_API_KEY가 설정되지 않았습니다.');
      }
      final service = PlanGeneratorService(geminiApiKey);

      final result = await service.generateItinerary(
        request: request,
        areaGroups: areaGroups,
        placesApiSuggestions: placesApiSuggestions,
      );

      state = PlanResultState(
        isLoading: false,
        itinerary: result['itinerary'] as List<dynamic>? ?? [],
        accommodations: result['accommodations'] as List<dynamic>? ?? [],
      );
    } catch (e) {
      state = PlanResultState(isLoading: false, errorMessage: e.toString());
    }
  }

  // ── 보관함에 저장 ─────────────────────────────────────
  Future<void> saveItinerary(String title) async {
    if (state.itinerary == null) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('로그인이 필요합니다.');

    try {
      final request = ref.read(planProvider);
      await FirebaseFirestore.instance.collection('itineraries').add({
        'uid': currentUser.uid,
        'title': title,
        'createdAt': FieldValue.serverTimestamp(),
        'request': {
          'city': request.city,
          'days': request.days,
          'companions': request.companions,
        },
        'itinerary': state.itinerary,
        'accommodations': state.accommodations,
      });
    } catch (e) {
      debugPrint('저장 실패: $e');
      rethrow;
    }
  }

  // ── 보관함에서 삭제 ───────────────────────────────────
  Future<void> deleteItinerary(String docId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('로그인이 필요합니다.');

    try {
      await FirebaseFirestore.instance
          .collection('itineraries')
          .doc(docId)
          .delete();
    } catch (e) {
      debugPrint('삭제 실패: $e');
      rethrow;
    }
  }

  // ── 보관함에서 불러오기 ───────────────────────────────
  void loadItinerary(
    List<dynamic> savedItinerary, {
    List<dynamic> accommodations = const [],
  }) {
    state = PlanResultState(
      itinerary: savedItinerary,
      accommodations: accommodations,
    );
  }

  // ── 상태 초기화 ───────────────────────────────────────
  void reset() {
    state = PlanResultState();
  }
}

final planResultProvider =
    StateNotifierProvider<PlanResultNotifier, PlanResultState>(
      (ref) => PlanResultNotifier(ref),
    );
