import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A model class representing a zone, with coordinates and zone ID.
class Zone {
  List<LatLng> coordinates;
  String zoneId;
  Color? color;

  Zone({required this.coordinates, required this.zoneId, this.color});
}
