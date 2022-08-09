import 'dart:core';

class IBeaconPayload {
  int major;
  int minor;
  String id;

  IBeaconPayload(this.id, this.major, this.minor);

  Map<String, dynamic> createBundle() {
    Map<String, dynamic> data = {};
    data["id"] = id;
    data["major"] = major;
    data["minor"] = minor;
    return data;
  }

  factory IBeaconPayload.fromJson(dynamic json) {
    return IBeaconPayload(
        json["id"] as String, json["major"] as int, json["minor"] as int);
  }
}
