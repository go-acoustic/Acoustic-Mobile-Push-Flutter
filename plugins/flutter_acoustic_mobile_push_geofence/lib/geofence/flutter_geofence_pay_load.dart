import 'dart:core';

class GeofencePayload {
  String id;
  double latitude;
  double longitude;
  int radius;

  GeofencePayload(this.latitude, this.longitude, this.radius, {this.id = ""});

  Map<String, dynamic> createBundle() {
    Map<String, dynamic> data = {};
    data["latitude"] = latitude;
    data["longitude"] = longitude;
    data["radius"] = radius;

    return data;
  }

  factory GeofencePayload.fromJson(dynamic json) {
    return GeofencePayload(
      json["latitude"] as double,
      json["longitude"] as double,
      json["radius"] as int,
      id: json["id"] as String,
    );
  }
}
