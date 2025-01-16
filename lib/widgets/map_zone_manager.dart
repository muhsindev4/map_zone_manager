import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_zone_manager/controllers/map_zone_manager_controller.dart';
import '../data/enum/map_style.dart';
import '../data/models/zone.dart';

/// Widget to display a map with the ability to create zones and manage markers.
class MapZoneManager extends StatefulWidget {
  /// The initial camera position for the map.
  final CameraPosition? initialCameraPosition;

  /// The marker icon to be used on the map.
  final String? markerIcon;

  /// Whether multiple zones can be added on the map.
  final bool multiZone;

  /// Whether the add zone button should be shown.
  final bool showAddButton;

  /// Whether the reset button should be shown.
  final bool showResetButton;

  /// Whether the map is in view-only mode.
  final bool viewOnly;

  /// Custom widget to replace the default add button.
  final Widget? addButtonWidget;

  /// Custom widget to replace the default reset button.
  final Widget? resetButtonWidget;

  /// List of zones to be displayed on the map initially.
  final List<Zone>? zones;

  /// Callback function triggered when a new zone is added.
  final Function(Zone)? onZoneAdded;

  /// The style to be applied to the map.
  final MapStyle mapStyle;

  /// The controller to manage map zones.
  final MapZoneManagerController? mapZoneManagerController;

  /// Minimum number of coordinates required to create a zone.
  final int minimumCoordinatesForAdding;

  /// The default color for the zone's fill.
  final Color defaultZoneColor;

  /// The default color for the zone's border.
  final Color defaultBorderColor;

  /// The default width for the zone's border.
  final int defaultBorderWidth;

  /// The color for the current zone being created.
  final Color currentZoneColor;

  /// The color for the current zone's border.
  final Color currentBorderColor;

  /// The width for the current zone's border.
  final int currentBorderWidth;

  /// Callback function triggered when the map is tapped.
  final void Function(LatLng)? onTap;

  /// Callback function triggered when the map is long-pressed.
  final void Function(LatLng)? onLongPress;

  /// Whether zoom controls are enabled on the map.
  final bool zoomControlsEnabled;

  /// Whether zoom gestures are enabled on the map.
  final bool zoomGesturesEnabled;

  /// Whether the user's current location should be displayed on the map.
  final bool myLocationEnabled;

  /// Whether the "My Location" button is enabled on the map.
  final bool myLocationButtonEnabled;

  /// Widget to display a map with the ability to create zones and manage markers.
  const MapZoneManager({
    super.key,
    this.initialCameraPosition,
    this.markerIcon,
    this.multiZone = true,
    this.showAddButton = true,
    this.showResetButton = true,
    this.viewOnly = false,
    this.addButtonWidget,
    this.resetButtonWidget,
    this.zones,
    this.onZoneAdded,
    this.mapStyle = MapStyle.standard,
    this.mapZoneManagerController,
    this.minimumCoordinatesForAdding = 2,
    this.defaultZoneColor = Colors.yellow,
    this.defaultBorderColor = Colors.black,
    this.defaultBorderWidth = 2,
    this.currentZoneColor = Colors.red,
    this.currentBorderColor = Colors.black,
    this.currentBorderWidth = 2,
    this.onTap,
    this.onLongPress,
    this.zoomControlsEnabled = true,
    this.zoomGesturesEnabled = true,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = true,
  });

  @override
  State<MapZoneManager> createState() => _MapZoneManagerState();
}

class _MapZoneManagerState extends State<MapZoneManager> {
  /// The initial camera position for the map, either provided by the user or defaulted to LatLng(0, 0).
  late CameraPosition _initialCameraPosition;

  /// The controller to manage map zones and interactions.
  MapZoneManagerController? _mapZoneManagerController;

  /// The icon used for markers on the map.
  BitmapDescriptor _markerIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  /// Initializes the map zone manager controller, sets up the map, and loads the marker icon.
  Future<void> _initialize() async {
    _mapZoneManagerController = widget.mapZoneManagerController ??
        MapZoneManagerController(
          onZoneAdded: widget.onZoneAdded,
          multiZone: widget.multiZone,
          minimumCoordinatesForAdding: widget.minimumCoordinatesForAdding,
        );
    if (widget.zones != null) {
      _mapZoneManagerController!.zones.addAll(widget.zones!);
    }
    _initialCameraPosition = widget.initialCameraPosition ??
        const CameraPosition(target: LatLng(0.0, 0.0), zoom: 1);

    if (widget.markerIcon != null) {
      try {
        _markerIcon = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(48, 48)),
          widget.markerIcon!,
        );
      } catch (e) {
        debugPrint('Error loading marker icon: $e');
        _markerIcon = BitmapDescriptor.defaultMarker;
      }
    }

    setState(() {});
  }

  /// Handles a tap on the map and adds the tapped position to the current zone.
  void _handleMapTap(LatLng position) {
    _mapZoneManagerController!.createZone();
    _mapZoneManagerController!.addPositionOnCurrentZone(position);
    widget.onTap?.call(position);
  }

  /// Builds the set of markers to be displayed on the map based on the current zone coordinates.
  Set<Marker> _buildMarkers() {
    if (_mapZoneManagerController
            ?.currentZoneCoordinates?.coordinates.isEmpty ??
        true) {
      return {};
    }
    return _mapZoneManagerController!.currentZoneCoordinates!.coordinates
        .map((coordinate) {
      return Marker(
        markerId: MarkerId(coordinate.toString()),
        position: coordinate,
        icon: _markerIcon,
      );
    }).toSet();
  }

  /// Builds the set of polygons to represent the zones on the map.
  Set<Polygon> _buildPolygons() {
    final polygons = <Polygon>{};
    if (_mapZoneManagerController!.currentZoneCoordinates != null) {
      polygons.add(Polygon(
        polygonId: PolygonId(
            _mapZoneManagerController!.currentZoneCoordinates!.zoneId),
        points: _mapZoneManagerController!.currentZoneCoordinates!.coordinates,
        fillColor: widget.currentZoneColor,
        strokeColor: widget.currentBorderColor,
        strokeWidth: widget.currentBorderWidth,
      ));
    }
    polygons.addAll(
      _mapZoneManagerController!.zones.map((zone) {
        return Polygon(
          polygonId: PolygonId(zone.zoneId),
          points: zone.coordinates,
          fillColor: zone.color ?? widget.defaultZoneColor,
          strokeColor: widget.defaultBorderColor,
          strokeWidth: widget.defaultBorderWidth,
        );
      }),
    );
    return polygons;
  }

  @override
  void dispose() {
    // Dispose the map controller when the widget is disposed
    _mapZoneManagerController?.mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _mapZoneManagerController!,
        builder: (context, child) {
          return GoogleMap(
            zoomControlsEnabled: widget.zoomControlsEnabled,
            zoomGesturesEnabled: widget.zoomGesturesEnabled,
            myLocationEnabled: widget.myLocationEnabled,
            myLocationButtonEnabled: widget.myLocationButtonEnabled,
            style: _mapZoneManagerController!.getStyleJson(widget.mapStyle),
            initialCameraPosition: _initialCameraPosition,
            onLongPress: widget.onLongPress,
            onMapCreated: (controller) {
              _mapZoneManagerController!.mapController = controller;
            },
            onTap: widget.viewOnly ? null : _handleMapTap,
            markers: _buildMarkers(),
            polygons: _buildPolygons(),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.showAddButton)
            widget.addButtonWidget ??
                FloatingActionButton(
                  heroTag: 'add_zone',
                  onPressed: () {
                    if (_mapZoneManagerController!.currentZoneCoordinates !=
                        null) {
                      _mapZoneManagerController!.addZone(
                          _mapZoneManagerController!.currentZoneCoordinates!);
                    }
                  },
                  child: const Icon(Icons.check),
                ),
          const SizedBox(height: 10),
          if (widget.showResetButton)
            widget.resetButtonWidget ??
                FloatingActionButton(
                  heroTag: 'reset_zone',
                  onPressed: () {
                    _mapZoneManagerController!.resetCurrentZone();
                  },
                  child: const Icon(Icons.clear),
                ),
        ],
      ),
    );
  }
}
