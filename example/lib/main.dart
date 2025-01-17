import 'package:flutter/material.dart';
import 'package:map_zone_manager/data/enum/map_style.dart';
import 'package:map_zone_manager/widgets/map_zone_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: MapZoneManager(
          multiZone: true,
          currentBorderColor: Colors.red,
          currentBorderWidth: 2,
          currentZoneColor: Colors.red.withValues(alpha: 0.5),
          defaultBorderColor: Colors.yellow,
          defaultBorderWidth: 2,
          defaultZoneColor: Colors.yellow.withValues(alpha: 0.5),
          mapStyle: MapStyle.silver,
        ),
      ),
    );
  }
}
