import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Vm/weather_vm.dart';

class WeatherView extends StatelessWidget {
  final WeatherVm vm;

  const WeatherView(this.vm, {super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Om det laddar, visa snurra
    if (vm.isLoading) return const Center(child: CircularProgressIndicator());

    // 2. KORRIGERING HÄR: 
    // Om vi har data i listan, visa ALLTID listan! 
    // (Även om vm.error är satt, för det hanteras av statusMessages i WeatherScreen)
    if (vm.weathers.isNotEmpty) {
      return ListView.builder(
        itemCount: vm.weathers.length,
        itemBuilder: (context, index) {
          final w = vm.weathers[index];
          // Formatera datum (kräver intl package och initiering i main)
          // Om du får fel här, använd w.date.toString() tillfälligt.
          String formattedDate = w.date.toString();
          try {
             formattedDate = DateFormat("EEE, dd MMM", 'sv_SE').format(w.date);
          } catch (e) {
             formattedDate = w.date.toString().substring(0, 16);
          }

          IconData icon;
          Color color;
          if (w.cloudiness > 6) {
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

    // 3. Om listan är TOM, DÅ visar vi felmeddelandet i mitten
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

    // 4. Tomt tillstånd
    return const Center(child: Text("Sök efter en plats för att se vädret."));
  }
}