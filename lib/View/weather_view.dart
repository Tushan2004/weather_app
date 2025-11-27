import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Vm/weather_vm.dart';


class WeatherView extends StatelessWidget {
  final WeatherVm vm;

  const WeatherView(this.vm, {super.key});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) return const Center(child: CircularProgressIndicator());

    if (vm.weathers.isNotEmpty) {
      return ListView.builder(
        itemCount: vm.weathers.length,
        itemBuilder: (context, index) {
          final w = vm.weathers[index];
          String formattedDate = w.date.toString();
          try {
             formattedDate = DateFormat("EEE, dd MMM", 'sv_SE').format(w.date);
          } catch (e) {
             formattedDate = w.date.toString().substring(0, 16);
          }

          IconData icon;
          Color color;
          if (w.cloudiness > 70) {
            icon = Icons.cloud;
            color = Colors.blueGrey;
          } else if (w.cloudiness > 30) {
            icon = Icons.cloud;
            color = Colors.grey;
          } else {
            icon = Icons.wb_sunny;
            color = Colors.orange;
          }

          return ListTile(
            leading: Icon(icon, size: 32, color: color),
            title: Text(formattedDate),
            subtitle: Text(
              "Temp: ${w.temperatureC.toStringAsFixed(1)} °C",
            ),
             trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                    Text("Moln: ${w.cloudiness.toStringAsFixed(0)}%"),
                ],
            ),
          );
        },
      );
    }

    if (vm.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            vm.error!, 
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        )
      );
    }

    return const Center(child: Text("Sök efter en plats för att se vädret."));
  }
}