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

    // Nollställ endast flaggor, behåll gammal cached data
    setState(() {
      vm.isOffline = false;
      vm.error = null;
      // vm.weathers = []; <-- tas bort för att behålla cached data offline
    });

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
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    final inputFields = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _latController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Latitude"),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _lonController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Longitude"),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _fetchWeather,
          ),
        ],
      ),
    );

    final statusMessages = Column(
      children: [
        if (vm.isOffline && vm.weathers.isNotEmpty)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Offline visar sparad data",
              style: TextStyle(color: Colors.red),
            ),
          ),
        if (vm.error != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              vm.error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );

    final weatherList = Expanded(child: WeatherView(vm));

    return Scaffold(
      appBar: AppBar(title: const Text("SMHI Forecast")),
      body: isPortrait
          ? Column(
              children: [
                inputFields,
                statusMessages,
                weatherList,
              ],
            )
          : Row(
              children: [
                Flexible(
                  flex: 1,
                  child: Column(
                    children: [
                      inputFields,
                      statusMessages,
                    ],
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: weatherList,
                ),
              ],
            ),
    );
  }
}
