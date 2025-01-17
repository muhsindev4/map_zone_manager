import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/enum/map_style.dart';
import '../data/models/zone.dart';
import '../utils/map_styles.dart';

/// Controller class for managing the zones and map-related operations.
class MapZoneManagerController extends ChangeNotifier {
  // Fields
  /// List of all the zones that have been created.
  final List<Zone> zones = [];

  /// Whether multiple zones are allowed to be created (defaults to true).
  final bool? multiZone;

  /// Callback function triggered when a new zone is added.
  final Function(Zone)? onZoneAdded;

  /// Minimum number of coordinates required for creating a zone.
  final int? minimumCoordinatesForAdding;

  /// The current zone being created. It is null if no zone is being created.
  Zone? _currentZoneCoordinates;

  /// The map controller to manipulate the map view.
  GoogleMapController? mapController;

  // Getters
  /// Getter to access the current zone being created.
  Zone? get currentZoneCoordinates => _currentZoneCoordinates;

  // Constructor
  /// Initializes the MapZoneManagerController with optional parameters.
  ///
  /// [onZoneAdded] is a callback triggered when a new zone is added.
  /// [minimumCoordinatesForAdding] specifies the minimum number of coordinates required to add a zone.
  /// [multiZone] determines if multiple zones can be added.
  MapZoneManagerController({
    this.onZoneAdded,
    this.minimumCoordinatesForAdding,
    this.multiZone,
  });

  // Private Methods
  /// Generates a unique ID for a new zone based on the current zone count.
  ///
  /// If multiple zones are allowed, the ID is generated as `zone_<number>`, otherwise it returns `zone`.
  String _generateZoneId() {
    return (multiZone ?? true) ? "zone_${zones.length}" : "zone";
  }

  /// Moves the map camera to fit the provided zone's coordinates with some padding.
  ///
  /// [coordinates] is a list of `LatLng` points that define the zone's boundaries.
  void _moveCameraToZone(List<LatLng> coordinates) {
    if (coordinates.isEmpty) return;

    double minLat = coordinates.first.latitude;
    double maxLat = coordinates.first.latitude;
    double minLng = coordinates.first.longitude;
    double maxLng = coordinates.first.longitude;

    for (LatLng point in coordinates) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    LatLng southwest = LatLng(minLat, minLng);
    LatLng northeast = LatLng(maxLat, maxLng);

    LatLngBounds bounds =
        LatLngBounds(southwest: southwest, northeast: northeast);

    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50),
      );
    }
  }

  // Public Methods
  /// Creates a new zone if no current zone is being created.
  ///
  /// Initializes the current zone with an empty list of coordinates and a unique zone ID.
  void createZone() {
    if (_currentZoneCoordinates == null) {
      _currentZoneCoordinates = Zone(
        coordinates: [],
        zoneId: _generateZoneId(),
        zoneName: 'default zone',
      );
      notifyListeners();
    }
  }

  /// Adds a new position to the current zone being created.
  ///
  /// [position] is the `LatLng` point to be added to the current zone's coordinates.
  void addPositionOnCurrentZone(LatLng position) {
    if (_currentZoneCoordinates != null) {
      _currentZoneCoordinates!.coordinates.add(position);
      notifyListeners();
    }
  }

  /// Adds the current zone to the list of zones if it meets the required coordinate count.
  ///
  /// [zone] is the zone to be added. If the zone has enough coordinates (based on [minimumCoordinatesForAdding]),
  /// it is added to the `zones` list and the camera is moved to the zone's coordinates.
  void addZone(Zone zone) {
    if ((minimumCoordinatesForAdding ?? 0) < zone.coordinates.length) {
      if (multiZone == false) {
        zones.clear();
      }
      zones.add(zone);
      _moveCameraToZone(zone.coordinates);
      _currentZoneCoordinates = null;
      notifyListeners();

      if (onZoneAdded != null) {
        onZoneAdded!(zone);
      }
    }
  }

  /// Clears all zones from the list.
  void clearAll() {
    zones.clear();
    notifyListeners();
  }

  /// Removes a specific zone from the list of zones.
  ///
  /// [zone] is the zone to be removed from the `zones` list.
  void remove(Zone zone) {
    zones.remove(zone);
    notifyListeners();
  }

  /// Resets the current zone, effectively discarding the current zone's coordinates.
  void resetCurrentZone() {
    _currentZoneCoordinates = null;
    notifyListeners();
  }

  /// Moves the camera to focus on a specific zone.
  ///
  /// [zone] is the zone whose coordinates will be focused on in the map.
  void moveCameraToZone(Zone zone) {
    _moveCameraToZone(zone.coordinates);
  }

  /// Moves the camera to focus on a specific zone using index.
  ///
  /// [index] is the zone whose coordinates will be focused on in the map.
  void moveCameraTo(int index) {
    _moveCameraToZone(zones[index].coordinates);
  }

  /// Moves the camera to position.
  void moveCamera(
    LatLng position,
  ) {
    if (mapController == null) return;
    mapController!.moveCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15)));
  }

  /// Returns the JSON style for the specified map style.
  ///
  /// [mapStyle] specifies the desired map style, such as `MapStyle.standard`, `MapStyle.dark`, etc.
  /// The corresponding style JSON is returned, or null for the standard style.
  String? getStyleJson(MapStyle mapStyle) {
    switch (mapStyle) {
      case MapStyle.standard:
        return null;
      case MapStyle.silver:
        return MapStyles.silver;
      case MapStyle.retro:
        return MapStyles.retro;
      case MapStyle.dark:
        return MapStyles.dark;
      case MapStyle.night:
        return MapStyles.night;
      case MapStyle.aubergine:
        return MapStyles.aubergine;
    }
  }

  @override
  void dispose() {
    super.dispose();
    clearAll();
    mapController?.dispose();
  }
}
