import 'package:palette_michi/features/info/models/region_info_model.dart';

// supported city 목록
const List<RegionInfo> supportedRegions = [
  RegionInfo(name: '도쿄', lat: 35.6895, lng: 139.6917),
  RegionInfo(name: '오사카', lat: 34.6937, lng: 135.5023),
  RegionInfo(name: '교토', lat: 35.0116, lng: 135.7681),
  RegionInfo(name: '나고야', lat: 35.1815, lng: 136.9066),
  RegionInfo(name: '후쿠오카', lat: 33.5904, lng: 130.4017),
  RegionInfo(name: '삿포로', lat: 43.0618, lng: 141.3545),
  RegionInfo(name: '시즈오카', lat: 34.9769, lng: 138.3831),
  RegionInfo(name: '가고시마', lat: 31.5966, lng: 130.5571),
  RegionInfo(name: '오키나와', lat: 26.2124, lng: 127.6809),
];

// 도시명 리스트 (드롭다운·칩 등 UI용)
List<String> get supportedCityNames =>
    supportedRegions.map((r) => r.name).toList();

// 도시명으로 RegionInfo 조회
RegionInfo? regionByName(String name) {
  try {
    return supportedRegions.firstWhere((r) => r.name == name);
  } catch (_) {
    return null;
  }
}
