import 'package:flutter/material.dart';
import 'package:lab_b2/Vm/weather_vm.dart';

class WeatherView extends StatelessWidget{
  WeatherVm weathervm;

  WeatherView(this.weathervm);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: weathervm.weathers.length,
      itemBuilder: (context, index) {
        final weather = weathervm.weathers[index];
        return ListTile(
          title: Text('${weather.date.toLocal()}'),
          subtitle: Text('Temperature: ${weather.temperatureC} °C'),
        );
      },
    );
  }
}