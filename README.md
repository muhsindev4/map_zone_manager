
# MapZoneManager

`MapZoneManager` is a Flutter package that provides a widget and controller to manage zones on a Google Map. It allows you to create, update, and manage multiple zones, with features for handling map markers, polygons, and custom actions like adding or resetting zones. It supports both single and multi-zone management and is highly customizable with features like custom buttons and map styles.

[-](https://github.com/muhsindev4/map_zone_manager/blob/main/create_zone_demo.gif)
[-](https://github.com/muhsindev4/map_zone_manager/blob/main/view_zone_demo.gif)


## Features

- **Zone Creation**: Create zones by tapping on the map and adding coordinates to form a polygon.
- **Multiple Zones**: Supports managing multiple zones on the map.
- **Customizable**: Customize zone colors, border colors, and border width.
- **View-Only Mode**: Ability to display zones in a read-only mode (no zone creation).
- **Custom Buttons**: Option to replace the default add/reset zone buttons with custom widgets.
- **Markers & Polygons**: Displays markers and polygons for each zone created on the map.
- **Zoom Controls**: Enable/disable zoom controls and gestures.
- **Location Services**: Enable location tracking and display of the user's current location.
- **Map Styles**: Apply different map styles to customize the appearance of the map.
  
## Installation

To add the package to your Flutter project, update your `pubspec.yaml` file:
Run `flutter pub get` to install the dependencies.

    dependencies:
      map_zone_manager: ^0.0.1 

## Usage

### Basic Usage

To use the `MapZoneManager` widget, you need to add it to your widget tree. Here's a basic example:

    import 'package:flutter/material.dart';
    import 'package:google_maps_flutter/google_maps_flutter.dart';
    import 'package:map_zone_manager/map_zone_manager.dart';
    
    void main() => runApp(MyApp());
    
    class MyApp extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        return MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: Text('Map Zone Manager')),
            body: MapZoneManager(
              initialCameraPosition: CameraPosition(target: LatLng(37.7749, -122.4194), zoom: 12),
              multiZone: true,
              showAddButton: true,
              showResetButton: true,
              viewOnly: false,
              onZoneAdded: (zone) {
                print('New Zone Added: ${zone.zoneId}');
              },
            ),
          ),
        );
      }
    }

### Parameters

#### MapZoneManager

-   `initialCameraPosition`: The initial camera position for the map (optional).
-   `markerIcon`: The icon for the markers (optional).
-   `multiZone`: Whether multiple zones can be added (default is `true`).
-   `showAddButton`: Whether to show the button to add a zone (default is `true`).
-   `showResetButton`: Whether to show the button to reset the zone (default is `true`).
-   `viewOnly`: Whether the map is in view-only mode (default is `false`).
-   `addButtonWidget`: Custom widget for the add button (optional).
-   `resetButtonWidget`: Custom widget for the reset button (optional).
-   `zones`: A list of initial zones to display on the map (optional).
-   `onZoneAdded`: A callback triggered when a new zone is added (optional).
-   `mapStyle`: The map style to apply (optional, defaults to `MapStyle.standard`).
-   `mapZoneManagerController`: A controller to manage map zones (optional).
-   `minimumCoordinatesForAdding`: The minimum number of coordinates required to create a zone (default is 2).
-   `defaultZoneColor`: The default fill color for zones (default is `Colors.yellow`).
-   `defaultBorderColor`: The default border color for zones (default is `Colors.black`).
-   `defaultBorderWidth`: The default border width for zones (default is `2`).
-   `currentZoneColor`: The color for the current zone being created (default is `Colors.red`).
-   `currentBorderColor`: The color for the current zone's border (default is `Colors.black`).
-   `currentBorderWidth`: The width of the current zone's border (default is `2`).
-   `onTap`: A callback triggered when the map is tapped (optional).
-   `onLongPress`: A callback triggered when the map is long-pressed (optional).
-   `zoomControlsEnabled`: Whether zoom controls are enabled (default is `true`).
-   `zoomGesturesEnabled`: Whether zoom gestures are enabled (default is `true`).
-   `myLocationEnabled`: Whether the user's current location is displayed (default is `false`).
-   `myLocationButtonEnabled`: Whether the "My Location" button is enabled (default is `true`).

### MapZoneManagerController

The `MapZoneManagerController` is a controller class for managing zones and map-related operations. You can use this controller to manage zones, add coordinates, and move the camera to fit a zone.

    MapZoneManagerController controller = MapZoneManagerController(
      onZoneAdded: (zone) {
        print('New Zone Added: ${zone.zoneId}');
      },
      multiZone: true,
    );
    
    controller.createZone();
    controller.addPositionOnCurrentZone(LatLng(37.7749, -122.4194));

## License

This package is licensed under the MIT License. See the LICENSE file for more details.
