import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lab_b2/Parser/weather_parser.dart';
import 'package:lab_b2/Model/weather.dart';

class WeatherService {
  final WeatherParser parser = WeatherParser();

  Future<List<Weather>> fetchWeather(double lon, double lat) async {

    final url = Uri.parse(
      'https://opendata-download-metfcst.smhi.se/api/category/pmp3g/version/2/geotype/point/lon/$lon/lat/$lat/data.json',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('API returned status ${response.statusCode}');
    }

    final Map<String, dynamic> json = jsonDecode(response.body);

    return parser.parse(json);
  }
}
