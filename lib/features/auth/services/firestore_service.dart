import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveInfo({
    required String name,
    required String nickname,
    required String email,
    required String password,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _db.collection('users').doc(uid).set({
        'name': name,
        'nickname': nickname,
        'email': email,
        'password': password,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<String?> getUserNickname(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['nickname'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching nickname: $e");
      return null;
    }
  }

  Future<void> updateNickname(String uid, String nickname) async {
    await _db
        .collection('users')
        .doc(uid)
        .set({'nickname': nickname}, SetOptions(merge: true));
  }

  // ─── Profile Image ──────────────────────────────────────────────────────────

  Future<String?> getUserProfileImageUrl(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['profileImageUrl'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProfileImageUrl(String uid, String url) async {
    await _db
        .collection('users')
        .doc(uid)
        .set({'profileImageUrl': url}, SetOptions(merge: true));
  }

  // ─── Favorites ──────────────────────────────────────────────────────────────

  Stream<List<String>> getFavoriteRegionsStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return [];
      final favs = doc.data()?['favoriteRegions'] as List<dynamic>?;
      return favs?.cast<String>() ?? [];
    });
  }

  Future<void> toggleFavoriteRegion(String uid, String regionName) async {
    final ref = _db.collection('users').doc(uid);
    final doc = await ref.get();
    List<String> favs = [];
    if (doc.exists) {
      favs =
          (doc.data()?['favoriteRegions'] as List<dynamic>?)?.cast<String>() ??
          [];
    }
    if (favs.contains(regionName)) {
      favs.remove(regionName);
    } else {
      favs.add(regionName);
    }
    await ref.set({'favoriteRegions': favs}, SetOptions(merge: true));
  }

  // ─── Travel Type Badges ──────────────────────────────────────────────────────

  Future<List<String>> getTravelTypeBadges(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return (doc.data()?['travelTypeBadges'] as List<dynamic>?)
                ?.cast<String>() ??
            [];
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching travel type badges: $e');
      return [];
    }
  }

  /// 이미 저장된 유형이면 무시 (중복 방지), 최대 2개까지 저장
  Future<void> saveTravelTypeBadge(String uid, String typeName) async {
    final ref = _db.collection('users').doc(uid);
    final doc = await ref.get();
    List<String> badges = [];
    if (doc.exists) {
      badges =
          (doc.data()?['travelTypeBadges'] as List<dynamic>?)?.cast<String>() ??
          [];
    }
    if (badges.contains(typeName)) return;
    if (badges.length >= 2) return; // 최대 2개 제한
    badges.add(typeName);
    await ref.set({'travelTypeBadges': badges}, SetOptions(merge: true));
  }

  /// 배지 삭제
  Future<void> removeTravelTypeBadge(String uid, String typeName) async {
    final ref = _db.collection('users').doc(uid);
    final doc = await ref.get();
    if (!doc.exists) return;
    final badges =
        ((doc.data()?['travelTypeBadges'] as List<dynamic>?)?.cast<String>() ?? [])
          ..remove(typeName);
    await ref.set({'travelTypeBadges': badges}, SetOptions(merge: true));
  }

  // ─── Memos ──────────────────────────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> getMemosStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('memos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }

  Future<void> addMemo(String uid, String content) async {
    await _db.collection('users').doc(uid).collection('memos').add({
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateMemo(String uid, String memoId, String content) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('memos')
        .doc(memoId)
        .update({'content': content});
  }

  Future<void> deleteMemo(String uid, String memoId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('memos')
        .doc(memoId)
        .delete();
  }
}
