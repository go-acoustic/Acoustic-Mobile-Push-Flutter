import 'dart:async';
import 'package:flutter/services.dart';
import 'package:event/event.dart';
import 'package:flutter_acoustic_mobile_push/flutter_acoustic_sdk_push.dart';

class FlutterAcousticMobilePushLocation {
  static const MethodChannel _channel =
      MethodChannel('flutter_acoustic_mobile_push_location');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

class LocationModuleValue {
  final locationPermissionStatus = Event<ValueEventArgs>();

  Future<void> checkLocationPermission() async {
    getLocationPermissionStatus();
    final String? response =
        await const MethodChannel('flutter_acoustic_mobile_push_location')
            .invokeMethod('checkLocationPermission');
    if (response == null || response.isEmpty) {
      locationPermissionStatus.broadcast(ValueEventArgs("Error"));
    } else {
      locationPermissionStatus.broadcast(ValueEventArgs(response));
    }
  }

  Future<void> getLocationPermissionStatus() async {
    const MethodChannel('flutter_acoustic_mobile_push_location')
        .setMethodCallHandler((methodCall) async {
      if (methodCall.method == "locationPermission") {
        locationPermissionStatus
            .broadcast(ValueEventArgs(methodCall.arguments.toString()));
      }
    });
  }
}
