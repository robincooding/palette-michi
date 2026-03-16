import 'package:cloud_firestore/cloud_firestore.dart';

class ItineraryModel {
  final String id;
  final String city;
  final int days;
  final List<DayItinerary> dayPlan;

  ItineraryModel({
    required this.id,
    required this.city,
    required this.days,
    required this.dayPlan,
  });

  // get data from firestore
  factory ItineraryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final List<dynamic> dayPlanData = data['day_plan'] ?? [];

    return ItineraryModel(
      id: doc.id,
      city: data['city'] ?? '',
      days: data['days'] ?? 0,
      dayPlan: dayPlanData
          .map(
            (dayData) => DayItinerary.fromMap(dayData as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class DayItinerary {
  final int day;
  final String areaName; // 그날 방문할 지역
  final List<String> essentialPlaceIds;

  DayItinerary({
    required this.day,
    required this.areaName,
    required this.essentialPlaceIds,
  });

  // inner map transformation logic
  factory DayItinerary.fromMap(Map<String, dynamic> map) {
    return DayItinerary(
      day: map['day'] ?? 0,
      areaName: map['area_name'] ?? '',
      essentialPlaceIds: List<String>.from(map['essential_place_ids'] ?? []),
    );
  }
}
