import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Vm/weather_vm.dart';

class WeatherView extends StatelessWidget {
  final WeatherVm vm;

  const WeatherView(this.vm, {super.key});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) return const Center(child: CircularProgressIndicator());
    if (vm.error != null) return Center(child: Text(vm.error!, style: const TextStyle(color: Colors.red)));
    if (vm.weathers.isEmpty) return const Center(child: Text("No weather data"));

    return ListView.builder(
      itemCount: vm.weathers.length,
      itemBuilder: (context, index) {
        final w = vm.weathers[index];
        final formattedDate = DateFormat("EEE, dd MMM", 'sv_SE').format(w.date);

        IconData icon;
        Color color;
        if (w.cloudiness > 70) {
          icon = Icons.cloud;
          color = Colors.blueGrey;
        } else if (w.cloudiness > 30) {
          icon = Icons.cloud_queue;
          color = Colors.grey;
        } else {
          icon = Icons.wb_sunny;
          color = Colors.orange;
        }

        return ListTile(
          leading: Icon(icon, size: 32, color: color),
          title: Text(formattedDate),
          subtitle: Text(
            "Temp: ${w.temperatureC.toStringAsFixed(1)} °C\nClouds: ${w.cloudiness}%",
          ),
        );
      },
    );
  }
}
