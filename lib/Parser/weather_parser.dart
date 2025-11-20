import 'package:lab_b2/Model/weather.dart';

class WeatherParser {
  List<Weather> parse(Map<String, dynamic> json) {
    final timeSeries = json['timeSeries'] as List<dynamic>?;

    if (timeSeries == null) throw Exception('JSON missing "timeSeries"');

    return timeSeries.map((entry) {
      final validTime = entry['validTime'] as String?;
      final parameters = entry['parameters'] as List<dynamic>?;

      if (validTime == null || parameters == null) {
        throw Exception('Invalid entry in timeSeries');
      }

      // Temperatur
      final tempParam = parameters.firstWhere(
        (p) => p['name'] == 't',
        orElse: () => null,
      );
      final temperatureC = (tempParam?['values']?[0] as num?)?.toDouble() ?? 0.0;

      // Molnighet
      final cloudParam = parameters.firstWhere(
        (p) => p['name'] == 'tcc_mean',
        orElse: () => null,
      );
      final cloudiness = (cloudParam?['values']?[0] as num?)?.toDouble() ?? 0.0;

      return Weather(
        date: DateTime.parse(validTime),
        temperatureC: temperatureC,
        cloudiness: cloudiness,
      );
    }).toList();
  }
}
