import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/features/plan/models/itinerary_model.dart';
import 'package:palette_michi/features/plan/models/place_model.dart';

final planRepositoryProvider = Provider(
  (ref) => PlanRepository(FirebaseFirestore.instance),
);

class PlanRepository {
  final FirebaseFirestore _firestore;

  PlanRepository(this._firestore);

  // 1. 특정 도시와 일치하는 표준 일정(Itinerary) get
  Future<List<ItineraryModel>> getItinerariesByCity(
    String city,
    int days,
  ) async {
    final snapshot = await _firestore
        .collection('itineraries')
        .where('city', isEqualTo: city)
        .where('days', isEqualTo: days)
        .get();

    return snapshot.docs
        .map((doc) => ItineraryModel.fromFirestore(doc))
        .toList();
  }

  // 2. 특정 카테고리 및 바이브에 맞는 후보 장소 get
  Future<List<PlaceModel>> getCandidatePlaces(
    String city, {
    bool includeNearby = false,
  }) async {
    Query query = _firestore.collection('places');

    if (includeNearby) {
      // 도쿄 + 도쿄 근교 모두 조회
      query = query.where('city', whereIn: [city, '$city 근교']);
    } else {
      query = query.where('city', isEqualTo: city);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => PlaceModel.fromFirestore(doc)).toList();
  }

  // 3. Place ID로 특정 장소의 정보들 get
  Future<List<PlaceModel>> getPlacesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final snapshot = await _firestore
        .collection('places')
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    return snapshot.docs.map((doc) => PlaceModel.fromFirestore(doc)).toList();
  }
}
