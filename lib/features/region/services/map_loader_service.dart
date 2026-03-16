import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:palette_michi/features/region/models/region_model.dart';

/// 지도를 불러올 때 반환할 데이터 묶음
class MapDataResult {
  final List<JapanRegion> allRegions;
  final Map<RegionGroup, Path> combinedPaths; // 지역 그룹별 경계선

  MapDataResult({required this.allRegions, required this.combinedPaths});
}

class MapLoaderService {
  // 일본 지도의 위경도 범위 (대략적인 보정값)
  // 큐슈에서 홋카이도까지의 범위를 화면에 꽉 차게 그리기 위함
  static const double minLon = 128.0;
  static const double maxLon = 146.0;
  static const double minLat = 30.0;
  static const double maxLat = 46.0;

  // 1. JSON파일 로드 및 변환
  static Future<MapDataResult> loadJapanMap(Size screenSize) async {
    final String response = await rootBundle.loadString(
      'assets/japan_region.json',
    );
    final data = json.decode(response);

    List<JapanRegion> allRegions = [];
    Map<RegionGroup, Path> combinedPaths = {};

    for (var feature in data['features']) {
      String id = feature['properties']['id'] ?? ''; // JSON내 ID추출
      String name = feature['properties']['name'] ?? '';
      var geometry = feature['geometry'];
      RegionGroup group = getGroup(id);

      List<Path> regionPaths = [];

      if (geometry['type'] == 'MultiPolygon' || geometry['type'] == 'Polygon') {
        var polygons = geometry['type'] == 'MultiPolygon'
            ? geometry['coordinates']
            : [geometry['coordinates']];

        for (var polygon in polygons) {
          for (var ring in polygon) {
            final Path path = _convertToPath(ring, screenSize, id);
            regionPaths.add(path);

            // 지역 그룹별 path 병합
            if (group != RegionGroup.nowhere) {
              combinedPaths[group] = combinedPaths.containsKey(group)
                  ? Path.combine(
                      PathOperation.union,
                      combinedPaths[group]!,
                      path,
                    )
                  : path;
            }
          }
        }
      }

      allRegions.add(
        JapanRegion(id: id, name: name, group: group, paths: regionPaths),
      );
    }
    return MapDataResult(allRegions: allRegions, combinedPaths: combinedPaths);
  }

  // 2. 위경도 좌표를 Flutter Canvas 좌표로 변환하는 로직
  static Path _convertToPath(List coordinates, Size size, String id) {
    Path path = Path();

    for (int i = 0; i < coordinates.length; i++) {
      double lon = coordinates[i][0].toDouble();
      double lat = coordinates[i][1].toDouble();
      double x, y;

      // 오키나와 위치 이동 (약 2배 확대 후 좌측 상단으로 이동)
      if (id == "JP47") {
        double scale = 2;
        x =
            (lon - 127.0) * scale * (size.width / (maxLon - minLon)) +
            (size.width * 0.15);
        y =
            (size.height * 0.35) -
            (lat - 26.0) * scale * (size.height / (maxLat - minLat));
      } else {
        // 위경도를 화면 비율에 맞춰 0.0 ~ 1.0 사이로 정규화
        x = (lon - minLon) / (maxLon - minLon) * size.width;
        // 지도는 위쪽이 위도가 높으므로 y축은 반전 처리
        y = size.height - ((lat - minLat) / (maxLat - minLat) * size.height);
      }

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }
}
