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
    // 1. KORRIGERING: Registrera lyssnare för MVVM State Management
    // Detta gör att build-metoden körs om när VM ändrar status (offline-data, isLoading, error)
    vm.addListener(_onVmChange);
  }

  // 2. KORRIGERING: Metod som anropas av VM:en
  void _onVmChange() {
    setState(() {}); // Rita om UI:n
  }

  @override
  void dispose() {
    // 3. KORRIGERING: Ta bort lyssnare för att undvika minnesläckor
    vm.removeListener(_onVmChange);
    _latController.dispose();
    _lonController.dispose();
    // vm.dispose(); // Lägg till om du har dispose i VM
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    final latText = _latController.text;
    final lonText = _lonController.text;

    // KORRIGERING: Ta bort alla setState() block härifrån!
    // VM:en hanterar nu isLoading, isOffline och error.

    final lat = double.tryParse(latText);
    final lon = double.tryParse(lonText);

    if (lat == null || lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid latitude or longitude")),
      );
      return;
    }

    try {
      // Anropet vm.loadWeather(lon, lat) är korrekt för SMHI API
      await vm.loadWeather(lon, lat);
    } catch (e) {
      // Felmeddelanden hanteras av VM och visas i build-metoden via vm.error
      // Du kan behålla SnackBar här om du vill ha ett extra UI-meddelande
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    final inputFields = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // 4. KORRIGERING: Ändrad ordning i UI för att visa Longitud först
          Expanded(
            child: TextField(
              controller: _lonController, // Longitud Controller
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Longitude"), // Longitude Fält
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _latController, // Latitud Controller
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Latitude"), // Latitude Fält
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: vm.isLoading ? null : _fetchWeather, // Förhindra dubbelklick under laddning
          ),
        ],
      ),
    );

    final statusMessages = Column(
      children: [
        // Lägg till laddningsindikator
        if (vm.isLoading) const LinearProgressIndicator(), 
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