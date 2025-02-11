import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/map_zone_manager_controller.dart';
import '../data/enum/map_style.dart';
import '../data/models/location_prediction.dart';
import '../data/models/zone.dart';
import 'map_location_search.dart';
import 'zone_search_field.dart';

/// Widget to display a map with the ability to create zones and manage markers.
class MapZoneManager extends StatefulWidget {
  /// The initial camera position for the map.
  final CameraPosition? initialCameraPosition;

  /// The marker icon to be used on the map.
  final String? markerIcon;

  /// google map api key for search location
  final String? googleMapApiKey;

  /// Whether multiple zones can be added on the map.
  final bool multiZone;

  /// Whether the location search filed should be shown.
  final bool showLocationSearch;

  /// Whether the zone search filed should be shown.
  final bool showZoneSearch;

  /// Whether the add zone button should be shown.
  final bool showAddButton;

  /// Whether the close zone button should be shown.
  final bool showCloseButton;

  /// Whether the delete button should be shown.
  final bool showDeleteButton;

  /// Whether the map is in view-only mode.
  final bool viewOnly;

  /// Custom widget to replace the default add button.
  final Widget? addButtonWidget;

  /// Custom widget to replace the default delete button.
  final Widget? deleteButtonWidget;

  /// Custom widget to replace the default delete button.
  final Widget? closeButtonWidget;

  /// List of zones to be displayed on the map initially.
  final List<Zone>? zones;

  /// Callback function triggered when a zone is selected from autofill suggestions
  final Function(Zone)? onZoneSuggestionSelected;

  /// Callback function triggered when a location is selected from autofill suggestions
  final Function(LocationPrediction)? onLocationSuggestionSelected;

  /// Callback function triggered when a new zone is added.
  final Function(Zone)? onZoneAdded;

  final Function(String message)? onError;

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
  final void Function(LatLng)? onCoordinatesAdded;

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
    this.googleMapApiKey,
    this.multiZone = true,
    this.showLocationSearch = false,
    this.showZoneSearch = true,
    this.showAddButton = true,
    this.showCloseButton = true,
    this.showDeleteButton = true,
    this.viewOnly = false,
    this.addButtonWidget,
    this.deleteButtonWidget,
    this.closeButtonWidget,
    this.zones,
    this.onLocationSuggestionSelected,
    this.onZoneSuggestionSelected,
    this.onZoneAdded,
    this.onError,
    this.mapStyle = MapStyle.standard,
    this.mapZoneManagerController,
    this.minimumCoordinatesForAdding = 2,
    this.defaultZoneColor = Colors.yellow,
    this.defaultBorderColor = Colors.black,
    this.defaultBorderWidth = 2,
    this.currentZoneColor = Colors.red,
    this.currentBorderColor = Colors.black,
    this.currentBorderWidth = 2,
    this.onCoordinatesAdded,
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
            onError: widget.onError);
    if (widget.zones != null) {
      _mapZoneManagerController!.zones.addAll(widget.zones!);
    }
    _initialCameraPosition = widget.initialCameraPosition ??
        const CameraPosition(target: LatLng(0.0, 0.0), zoom: 1);

    if (widget.markerIcon != null) {
      try {
        _markerIcon = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(20, 20)),
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
    widget.onCoordinatesAdded?.call(position);
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
          onTap: () {
            if (zone.onTap != null) {
              zone.onTap!.call(zone);
            }
          },
          points: zone.coordinates,
          fillColor: zone.color ?? widget.defaultZoneColor,
          strokeColor: widget.defaultBorderColor,
          strokeWidth: widget.defaultBorderWidth,
        );
      }),
    );
    return polygons;
  }

  Widget _iconButton({
    required void Function() onPressed,
    required IconData icon,
  }) {
    return DecoratedBox(
        decoration:
            BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
        child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: Colors.white,
            )));
  }

  @override
  void dispose() {
    // Dispose the map controller when the widget is disposed
    _mapZoneManagerController?.mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      !(widget.showLocationSearch &&
          (widget.googleMapApiKey == null || widget.googleMapApiKey!.isEmpty)),
      'Google Map API key is required when showLocationSearch is true. Cannot enable search functionality without a valid API key.',
    );
    return ListenableBuilder(
        listenable: _mapZoneManagerController!,
        builder: (context, child) {
          return Stack(
            children: [
              GoogleMap(
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
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    spacing: 10,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.showCloseButton) ...[
                            widget.closeButtonWidget ??
                                _iconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: Icons.close),
                          ],
                          if (widget.showAddButton) ...[
                            widget.addButtonWidget ??
                                _iconButton(
                                    onPressed: () {
                                      if (_mapZoneManagerController!
                                              .zones.length >
                                          widget.minimumCoordinatesForAdding) {
                                        if (widget.onError != null) {
                                          widget.onError!(
                                              "At least ${widget.minimumCoordinatesForAdding} coordinates are required to create a zone.");
                                        }
                                        return;
                                      }
                                      if (_mapZoneManagerController!
                                              .currentZoneCoordinates !=
                                          null) {
                                        _mapZoneManagerController!.addZone(
                                            _mapZoneManagerController!
                                                .currentZoneCoordinates!);

                                        if (widget.onZoneAdded != null) {
                                          widget.onZoneAdded!(
                                              _mapZoneManagerController!
                                                  .currentZoneCoordinates!);
                                        }
                                      }
                                    },
                                    icon: Icons.check),
                          ]
                        ],
                      ),
                      if (widget.showLocationSearch)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: MapLocationSearch(
                            googleMapApiKey: widget.googleMapApiKey,
                            onSelected: (LocationPrediction? selectedLocation) {
                              if (selectedLocation != null) {
                                _mapZoneManagerController?.moveCamera(LatLng(
                                    selectedLocation.latitude!,
                                    selectedLocation.longitude!));

                                if (widget.onLocationSuggestionSelected !=
                                    null) {
                                  widget.onLocationSuggestionSelected
                                      ?.call(selectedLocation);
                                }
                              }
                            },
                          ),
                        ),
                      if (widget.showZoneSearch)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: ZoneSearchField(
                            onSelected: (Zone? zone) {
                              if (zone != null) {
                                _mapZoneManagerController
                                    ?.moveCameraToZone(zone);
                                if (widget.onZoneSuggestionSelected != null) {
                                  widget.onZoneSuggestionSelected?.call(zone);
                                }
                              }
                            },
                            zones: widget.zones ?? [],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (widget.showDeleteButton &&
                  (_mapZoneManagerController
                              ?.currentZoneCoordinates?.coordinates ??
                          [])
                      .isNotEmpty)
                widget.deleteButtonWidget ??
                    Positioned(
                      bottom: 15,
                      right: 15,
                      child: _iconButton(
                          onPressed: () {
                            _mapZoneManagerController?.resetCurrentZone();
                          },
                          icon: Icons.delete),
                    )
            ],
          );
        });
  }
}
