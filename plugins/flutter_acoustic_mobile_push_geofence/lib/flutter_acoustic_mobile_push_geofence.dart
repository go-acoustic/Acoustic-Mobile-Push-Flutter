import 'dart:async';
import 'dart:convert';
import 'package:event/event.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acoustic_mobile_push_geofence/geofence/flutter_geofence_pay_load.dart';
import 'dart:developer' as dev;

class FlutterAcousticMobilePushGeofence {
  static const MethodChannel _channel =
      MethodChannel('flutter_acoustic_mobile_push_geofence');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

class GeofencesValue {
  final geofenceLocations = Event<ArrayListEventArgs>();
  String tag = "Geofence";

  Future<void> sendLocationPermission() async {
    final String? response =
        await const MethodChannel('flutter_acoustic_mobile_push_geofence')
            .invokeMethod('sendLocationPermission', null);
    dev.log("@@@ sendLocationPermission --> $response", name: tag);
  }

  Future<void> geofencesNearCoordinate(GeofencePayload payload) async {
    dev.log("@@@ Geofence --> ${payload.createBundle()}", name: tag);

    String? response =
        await const MethodChannel('flutter_acoustic_mobile_push_geofence')
            .invokeMethod('geofencesNearCoordinate', payload.createBundle());
    dev.log("@@@ Geofence response--> $response", name: tag);
    if (response == null || response.isEmpty) {
      geofenceLocations.broadcast(ArrayListEventArgs(List.empty()));
    } else {
      var listJson = jsonDecode(response) as List;
      List<GeofencePayload> lists =
          listJson.map((list) => GeofencePayload.fromJson(list)).toList();
      geofenceLocations.broadcast(ArrayListEventArgs(lists));
    }
  }
}

class ArrayListEventArgs extends EventArgs {
  List<dynamic> changedValue;
  ArrayListEventArgs(this.changedValue);
}
