import 'dart:async';

import 'package:flutter/services.dart';

class FlutterAcousticMobilePushDisplayweb {
  static const MethodChannel _channel =
      MethodChannel('flutter_acoustic_mobile_push_displayweb');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

class WebURLValue {
  Future<void> setWebURL(String url) async {
    await const MethodChannel('flutter_acoustic_mobile_push_displayweb')
        .invokeMethod('displayWebAction', url);
  }
}
