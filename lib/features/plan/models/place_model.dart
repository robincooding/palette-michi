import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceModel {
  final String id;
  final String name;
  final String city;
  final String description;
  final GeoPoint location; // firestore 이용
  final String category;
  final Map<String, double> vibeScores;
  final List<String> tags;
  final int avgStayTime; // 평균 체류 시간
  final String? imageUrl;
  final bool isAnchor; // Anchor 장소인지
  final String areaName; // 아사쿠사, 시부야 등
  final List<String> areaTags; // ["아사쿠사", "스미다"]
  final List<String> nearbyAnchors; // Anchor 장소 근처에서 함께 볼만한 장소들
  final Map<String, String>? accessInfo; // 근교 이동 시간

  PlaceModel({
    required this.id,
    required this.name,
    required this.city,
    required this.description,
    required this.location,
    required this.category,
    required this.vibeScores,
    required this.tags,
    required this.avgStayTime,
    this.imageUrl,
    this.isAnchor = false,
    this.areaName = '',
    this.areaTags = const [],
    this.nearbyAnchors = const [],
    this.accessInfo,
  });

  // get data from firestore
  factory PlaceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PlaceModel(
      id: doc.id,
      name: data['name'] ?? '',
      city: data['city'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] as GeoPoint,
      category: data['category'] ?? '',
      vibeScores: Map<String, double>.from(data['vibe_scores'] ?? {}),
      tags: List<String>.from(data['tags'] ?? []),
      avgStayTime: data['avg_stay_time'] ?? 60,
      imageUrl: data['image_url'],
      isAnchor: data['is_anchor'] ?? false,
      areaName: data['area_name'] ?? '',
      areaTags: List<String>.from(data['area_tags'] ?? []),
      nearbyAnchors: List<String>.from(data['nearby_anchors'] ?? []),
      accessInfo: data['access_info'] != null
          ? Map<String, String>.from(data['access_info'])
          : null,
    );
  }

  // AI Prompt나 데이터 저장시 사용
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': {'lat': location.latitude, 'lng': location.longitude},
      'category': category,
      'area_name': areaName,
      'vibe_scores': vibeScores,
      'avg_stay_time': avgStayTime,
      'is_anchor': isAnchor,
      if (accessInfo != null) 'access_info': accessInfo,
    };
  }
}
