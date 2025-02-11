import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/models/location_prediction.dart';
import 'auto_input_box.dart';

class MapLocationSearch extends StatefulWidget {
  final String? googleMapApiKey;
  final Function(LocationPrediction? selectedLocation) onSelected;

  const MapLocationSearch(
      {super.key, required this.onSelected, this.googleMapApiKey});

  @override
  State<MapLocationSearch> createState() => _MapLocationSearchState();
}

class _MapLocationSearchState extends State<MapLocationSearch> {
  final TextEditingController _controller = TextEditingController();

  List<LocationPrediction> _locationPredictions = [];
  // Store LocationPredictions
  final ValueNotifier<bool> _haveText = ValueNotifier(false);

  // Fetch location predictions from Google Places API
  Future<void> _fetchLocationPredictions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _locationPredictions = [];
      });
      return;
    }

    final String url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=${widget.googleMapApiKey}";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final predictions = data['predictions'] as List;

        setState(() {
          _locationPredictions =
              predictions.map((e) => LocationPrediction.fromMap(e)).toList();
        });
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      setState(() {
        _locationPredictions = [];
      });
    }
  }

  // Fetch the details (lat, lng, address) of the selected location
  Future<LocationPrediction?> _fetchLocationDetails(String placeId) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${widget.googleMapApiKey}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final locationData = data['result'];

        final LocationPrediction prediction = LocationPrediction.fromMap({
          'description': locationData['formatted_address'],
          'geometry': {
            'location': {
              'lat': locationData['geometry']['location']['lat'],
              'lng': locationData['geometry']['location']['lng']
            }
          }
        });

        return prediction;
      } else {
        throw Exception('Failed to load location details');
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AutoInputBox<LocationPrediction>(
      textEditingController: _controller,
      textStyle: Theme.of(context)
          .textTheme
          .bodyMedium!
          .copyWith(fontWeight: FontWeight.w600),
      suggestions: _locationPredictions,
      inputDecoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        suffixIcon: ValueListenableBuilder(
            valueListenable: _haveText,
            builder: (context, value, widget) {
              if (_haveText.value) {
                return IconButton(
                    onPressed: () {
                      setState(() {
                        _controller.clear();
                        FocusManager.instance.primaryFocus?.unfocus();
                      });
                    },
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey,
                    ));
              } else {
                return SizedBox.shrink();
              }
            }),
        prefixIcon: Icon(
          Icons.search,
          color: Colors.grey,
        ),
        hintText: "Search location",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 8, // Adjust vertical padding to reduce height
          horizontal: 16, // Adjust horizontal padding as needed
        ),
      ),
      onItemSelected: (selectedLocation) async {
        FocusManager.instance.primaryFocus?.unfocus();
        widget
            .onSelected(await _fetchLocationDetails(selectedLocation.placeId!));
      },
      toDisplayString: (LocationPrediction prediction) {
        return prediction.address ?? "_";
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      _fetchLocationPredictions(_controller.text);
      _haveText.value = _controller.text.isNotEmpty ? true : false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
