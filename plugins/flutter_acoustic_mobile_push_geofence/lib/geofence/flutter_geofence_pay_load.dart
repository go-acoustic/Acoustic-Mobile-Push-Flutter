import 'dart:core';

class GeofencePayload {
  double latitude;
  double longitude;
  int radius;

  GeofencePayload(this.latitude, this.longitude, this.radius);

  Map<String, dynamic> createBundle() {
    // update in next patch
    // ignore: prefer_collection_literals
    Map<String, dynamic> data = Map();
    data["latitude"] = latitude;
    data["longitude"] = longitude;
    data["radius"] = radius;
    return data;
  }

  factory GeofencePayload.fromJson(dynamic json) {
    return GeofencePayload(json["latitude"] as double,
        json["longitude"] as double, json["radius"] as int);
  }
}
