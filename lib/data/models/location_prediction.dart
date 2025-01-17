class LocationPrediction {
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? placeId;

  LocationPrediction({
     this.address,
     this.latitude,
     this.longitude,
     this.placeId,
  });

  // Factory method to create an instance from the API response
  factory LocationPrediction.fromMap(Map<String, dynamic> map) {
    return LocationPrediction(
      address: map['description'] ,
      latitude: map['geometry']?['location']?['lat'] ,
      longitude: map['geometry']?['location']?['lng'] ,
      placeId: map['place_id'] ,
    );
  }

  // Convert the object to a map for easier use with APIs
  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'placeId': placeId,
    };
  }
}
