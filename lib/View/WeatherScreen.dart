import 'package:flutter/material.dart';
import '../Vm/weather_vm.dart';
import '../Service/weather_service.dart';
import 'weather_view.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late WeatherVm vm;
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    vm = WeatherVm(WeatherService());
  }

  Future<void> _fetchWeather() async {
    final latText = _latController.text;
    final lonText = _lonController.text;

    final lat = double.tryParse(latText);
    final lon = double.tryParse(lonText);

    if (lat == null || lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid latitude or longitude")),
      );
      return;
    }

    setState(() {
      vm.isLoading = true;
    });

    try {
      await vm.loadWeather(lon, lat);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading weather: $e")),
      );
    } finally {
      setState(() {
        vm.isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SMHI Forecast")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Latitude"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _lonController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Longitude"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _fetchWeather,
                ),
              ],
            ),
          ),
          Expanded(child: WeatherView(vm)),
        ],
      ),
    );
  }
}
