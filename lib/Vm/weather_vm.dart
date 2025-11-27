import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lab_b2/Model/weather_service.dart';
import 'package:lab_b2/Model/weather.dart';

class WeatherVm extends ChangeNotifier {
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
    isOffline = false;
    notifyListeners();

    try {
      final connectivity = await Connectivity().checkConnectivity();
      
      bool noConnection = connectivity == ConnectivityResult.none; 
      
      if (noConnection) {
        await _loadSavedWeather();
        _setOfflineStatus();
        return; 
      }

      final allWeather = await weatherService.fetchWeather(lon, lat);
      
      weathers = _extract7Days(allWeather);
      await _saveWeatherLocally(weathers); 
      isOffline = false;

    } catch (e) {
      String errorMsg = e.toString();

      if (errorMsg.contains("404") || errorMsg.contains("400") || errorMsg.contains("out of bounds")) {
        weathers = []; 
        isOffline = false;
        error = "Platsen saknar väderdata (utanför SMHI:s område eller ogiltig).";
      } else {
        await _loadSavedWeather();
        
        if (weathers.isNotEmpty) {
          isOffline = true;
          error = "Kunde inte nå servern. Visar sparad data.";
        } else {
          weathers = [];
          isOffline = false;
          error = "Kunde inte ladda väder: $e";
        }
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Hjälpmetod för att sätta status när vi laddat cache manuellt
  void _setOfflineStatus() {
    if (weathers.isNotEmpty) {
      isOffline = true;
      error = "Inget internet, visar sparad väderdata";
    } else {
      error = "Inget internet och ingen sparad data";
    }
    notifyListeners();
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = weathers.map((w) => {
            'date': w.date.toIso8601String(),
            'temperatureC': w.temperatureC,
            'cloudiness': w.cloudiness,
          }).toList();
      
      await prefs.setString('saved_weather', jsonEncode(jsonList));
    } catch (e) {
      // Hantera sparfel tyst eller logga om nödvändigt
    }
  }

  /// Ladda sparad data (cache)
  Future<void> _loadSavedWeather() async {
    try {
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
      } else {
        weathers = [];
      }
    } catch (e) {
      weathers = [];
    }
  }

  /// Validera att lat/lon är giltiga decimaler
  bool validateLatLon(String latStr, String lonStr) {
    final lat = double.tryParse(latStr);
    final lon = double.tryParse(lonStr);
    return lat != null && lon != null;
  }
}