import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lab_b2/Service/weather_service.dart';
import 'package:lab_b2/Model/weather.dart';

class WeatherVm {
  final WeatherService weatherService;

  WeatherVm(this.weatherService);

  List<Weather> weathers = [];
  bool isLoading = false;
  bool isOffline = false;
  String? error;

  /// Ladda väderdata för givna koordinater
  Future<void> loadWeather(double lon, double lat) async {
    isLoading = true;
    error = null;
    isOffline = false; // Nollställ offline-flaggan

    try {
      // Kontrollera internet
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        // Ingen internet → ladda cache
        await _loadSavedWeather();
        if (weathers.isNotEmpty) {
          isOffline = true;
          error = "No internet, showing cached weather";
        } else {
          error = "No internet and no saved data";
        }
        return;
      }

      // Internet finns → hämta från nätet
      final allWeather = await weatherService.fetchWeather(lon, lat);
      weathers = _extract7Days(allWeather);
      await _saveWeatherLocally(weathers);
      isOffline = false; // online → inte offline

    } catch (e) {
      // Internet finns men API fel → visa endast error, töm gammal cache
      weathers = [];
      isOffline = false;
      error = "Failed to load weather: $e";
    } finally {
      isLoading = false;
    }
  }

  /// Filtrera till 7 dagar
  List<Weather> _extract7Days(List<Weather> allWeather) {
    final Map<String, Weather> daily = {};
    for (var w in allWeather) {
      final day = w.date.toIso8601String().substring(0, 10);
      if (!daily.containsKey(day)) daily[day] = w;
      if (daily.length >= 7) break;
    }
    return daily.values.toList();
  }

  /// Spara data lokalt (cache)
  Future<void> _saveWeatherLocally(List<Weather> weathers) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = weathers.map((w) => {
          'date': w.date.toIso8601String(),
          'temperatureC': w.temperatureC,
          'cloudiness': w.cloudiness,
        }).toList();
    prefs.setString('saved_weather', jsonEncode(jsonList));
  }

  /// Ladda sparad data (cache)
  Future<void> _loadSavedWeather() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('saved_weather');
    if (saved != null) {
      final List<dynamic> jsonList = jsonDecode(saved);
      weathers = jsonList.map((json) {
        return Weather(
          date: DateTime.parse(json['date']),
          temperatureC: (json['temperatureC'] as num).toDouble(),
          cloudiness: (json['cloudiness'] as num).toDouble(),
        );
      }).toList();
    }
  }

  /// Validera att lat/lon är giltiga decimaler
  bool validateLatLon(String latStr, String lonStr) {
    final lat = double.tryParse(latStr);
    final lon = double.tryParse(lonStr);
    return lat != null && lon != null;
  }
}
