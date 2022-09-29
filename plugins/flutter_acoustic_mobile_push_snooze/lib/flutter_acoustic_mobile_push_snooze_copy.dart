import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_acoustic_mobile_push_snooze/snooze/flutter_snooze_payload.dart';

class FlutterAcousticMobilePushSnooze {
  static const MethodChannel _channel =
      MethodChannel('flutter_acoustic_mobile_push_snooze');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

class SnoozeModuleValue {
  Future<void> setSnoozeValue(SnoozePayload value) async {
    await const MethodChannel('flutter_acoustic_mobile_push_beacon')
        .invokeMethod('getIBeaconLocations', jsonEncode(value.createBundle()));
  }
}
