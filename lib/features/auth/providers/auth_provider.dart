import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/features/auth/providers/firestore_service_provider.dart';
import '../services/auth_service.dart';

// AuthService 인스턴스 제공
final authServiceProvider = Provider((ref) => AuthService());

// 현재 인증상태를 스트림으로 제공
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// 현재 로그인한 유저의 닉네임을 관리
final userNicknameProvider = FutureProvider<String?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  final currentUser = authState.value;
  // stream 값과 실제 Auth 상태를 이중 체크 (signOut 직후 race condition 방지)
  if (currentUser == null || FirebaseAuth.instance.currentUser == null) {
    return null;
  }
  return await firestoreService.getUserNickname(currentUser.uid);
});

// 프로필 이미지 URL
final userProfileImageUrlProvider = FutureProvider<String?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  final user = authState.value;
  if (user == null) return null;
  return await firestoreService.getUserProfileImageUrl(user.uid);
});

// 관심 여행지 스트림
final favoriteRegionsProvider = StreamProvider<List<String>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) return Stream.value([]);
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getFavoriteRegionsStream(user.uid);
});

// 여행 유형 배지 목록
final userTravelTypeBadgesProvider = FutureProvider<List<String>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  final user = authState.value;
  if (user == null) return [];
  return await firestoreService.getTravelTypeBadges(user.uid);
});

// 메모 스트림
final memosProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) return Stream.value([]);
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getMemosStream(user.uid);
});
