import 'dart:convert';
import 'package:lab_b2/Model/weather.dart';
import 'package:http/http.dart' as http;


class WeatherService {
  Future<List<Weather>> fetchWeather(double lon, double lat) async {
    final url = Uri.parse('https://maceo.sth.kth.se/weather/forecast?lonLat=lon/$lon/lat/$lat');
    
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load weather data');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final series = data['timeSeries'] as List<dynamic>;  
    
    return series.map((entry) {
      final validTime = entry['validTime'] as String;
      final params = entry['parameters'] as List<dynamic>;
      final tempParam = params.firstWhere((p) => p['name'] == 't');
      final temp = (tempParam['values'][0] as num).toDouble();

      return Weather(
        date: DateTime.parse(validTime),
        temperatureC: temp,
      );
    }).toList();
    }
}