import 'dart:ffi';

import 'package:lab_b2/Service/weather_service.dart';
import 'package:lab_b2/Model/weather.dart';

class WeatherVm {
  final WeatherService weatherService;

  WeatherVm(this.weatherService);

  List<Weather> weathers = [];
  bool isLoading = false;
  String? error;

  Future<void> loadWeather(double lon, double lat) async {
    isLoading = true;
    error = null;
    try {
      weathers = await weatherService.fetchWeather(lon, lat);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }
}