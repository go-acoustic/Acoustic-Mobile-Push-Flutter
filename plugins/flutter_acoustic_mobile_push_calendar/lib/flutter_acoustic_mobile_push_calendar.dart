import 'dart:async';

import 'package:flutter/services.dart';
import 'flutter_calendar_pay_load.dart';

class FlutterAcousticMobilePushCalendar {
  static const MethodChannel _channel =
      MethodChannel('flutter_acoustic_mobile_push_calendar');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

class CalendarValue {
  Future<void> sendCalendarAction(CalendarPayload payload) async {
    // plugin not currently in use
    // ignore: unused_local_variable
    final String? response =
        await const MethodChannel('flutter_acoustic_mobile_push_calendar')
            .invokeMethod('calendarAction', payload.createBundle());
  }
}
