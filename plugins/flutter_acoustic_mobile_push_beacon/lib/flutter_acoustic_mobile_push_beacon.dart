import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:event/event.dart';
import 'package:flutter_acoustic_mobile_push_beacon/ibeacon/flutter_ibeacon_pay_load.dart';
import 'dart:developer' as dev;

class FlutterAcousticMobilePushBeacon {
  static const MethodChannel _channel =
      MethodChannel('flutter_acoustic_mobile_push_beacon');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

class IbeaconModuleValue {
  final beaconLocations = Event<ArrayListEventArgs>();
  final locationPermision = Event<ValueEventArgs>();
  final uuidValue = Event<ValueEventArgs>();
  final beaconValues = Event<BeaconEventArgs>();

  String tag = "IBeacons";

  Future<void> getIBeaconLocations() async {
    getBeaconStatus();
    final String? response =
        await const MethodChannel('flutter_acoustic_mobile_push_beacon')
            .invokeMethod('getIBeaconLocations');

    if (response == null || response.isEmpty) {
      beaconLocations.broadcast(ArrayListEventArgs(List.empty()));
    } else {
      var beaconListJson = jsonDecode(response) as List;
      List<IBeaconPayload> beaconList = beaconListJson
          .map((beaconJson) => IBeaconPayload.fromJson(beaconJson))
          .toList();

      beaconLocations.broadcast(ArrayListEventArgs(beaconList));
    }
  }

  Future<void> sendLocationPermission() async {
    final String? response =
        await const MethodChannel('flutter_acoustic_mobile_push_beacon')
            .invokeMethod('sendLocationPermission', null);
    dev.log("@@@ sendLocationPermission --> $response", name: tag);
  }

  Future<void> getBeaconStatus() async {
    const MethodChannel('flutter_acoustic_mobile_push_beacon')
        .setMethodCallHandler((methodCall) async {
      if (methodCall.method == "locationPermission") {
        locationPermision
            .broadcast(ValueEventArgs(methodCall.arguments.toString()));
      } else if (methodCall.method == "EnteredGeofence") {
        final IBeaconPayload data =
            json.decode(methodCall.arguments.toString());
        beaconValues.broadcast(BeaconEventArgs(data));
      } else if (methodCall.method == "ExitedGeofence") {
        final IBeaconPayload data =
            json.decode(methodCall.arguments.toString());
        beaconValues.broadcast(BeaconEventArgs(data));
      } else if (methodCall.method == "UUID") {
        uuidValue.broadcast(ValueEventArgs(methodCall.arguments.toString()));
      }
    });
  }
}

class BeaconEventArgs extends EventArgs {
  IBeaconPayload beaconValue;
  BeaconEventArgs(this.beaconValue);
}

class ValueEventArgs extends EventArgs {
  String changedValue;
  ValueEventArgs(this.changedValue);
}

class ArrayListEventArgs extends EventArgs {
  List<IBeaconPayload> changedValue;

  ArrayListEventArgs(this.changedValue);
}
