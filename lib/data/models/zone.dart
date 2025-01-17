import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A model class representing a zone, with coordinates and zone ID.
class Zone {
  List<LatLng> coordinates;
  String zoneId;
  String zoneName;
  Color? color;
  void Function(Zone zone)? onTap;

  Zone({required this.coordinates, required this.zoneId,required this.zoneName, this.color,this.onTap});
}
