import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:palette_michi/features/info/models/weather_model.dart';

class InfoService {
  final String _weatherApiKey = dotenv.env['WEATHER_API_KEY'] ?? '';
  final String _rateApiKey = dotenv.env['RATE_API_KEY'] ?? '';

  Future<double> fetchExchangeRate() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://oapi.koreaexim.go.kr/site/program/financial/exchangeJSON?authkey=$_rateApiKey&data=AP01',
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> dataList = json.decode(response.body);
        if (dataList.isEmpty) {
          print("⚠️ 비영업시간: 임시 환율 데이터를 사용합니다.");
          return 9.44;
        }
        final jpyItem = dataList.firstWhere(
          (item) => item['cur_unit'] == 'JPY(100)',
          orElse: () => null,
        );
        return jpyItem != null
            ? double.parse(jpyItem['deal_bas_r'].replaceAll(',', '')) / 100
            : 9.44;
      }
      return 9.44;
    } catch (e) {
      return 9.44;
    }
  }

  Future<WeatherData?> fetchFullWeather(
    double lat,
    double lng, {
    required String cityName, // 한국어 도시명
  }) async {
    try {
      final responses = await Future.wait([
        http.get(
          Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lng&appid=$_weatherApiKey&units=metric&lang=ko',
          ),
        ),
        http.get(
          Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lng&appid=$_weatherApiKey&units=metric&lang=ko',
          ),
        ),
      ]);

      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final currentData = json.decode(responses[0].body);
        final forecastData = json.decode(responses[1].body);

        // cityName을 올바르게 전달
        WeatherData weather = WeatherData.fromJson(
          currentData,
          cityName: cityName,
        );
        final popValue =
            (forecastData['list'][0]['pop'] as num).toDouble() * 100;

        return weather.copyWith(pop: popValue.toInt());
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
