import 'dart:core';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:event/event.dart';
import 'package:flutter_acoustic_mobile_push/event/flutter_event_pay_load.dart';
import 'package:flutter_acoustic_mobile_push/user_attribute/flutter_attribute_pay_load.dart';

class FlutterAcousticSdkPush {
  static const MethodChannel _channel =
      MethodChannel('flutter_acoustic_mobile_push');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String?> get register async {
    final String? version = await _channel.invokeMethod('register');
    return version;
  }

  static Future<String?> customAction(String actionType) async {
    final String? version =
        await _channel.invokeMethod('customAction', actionType);
    return version;
  }

  static Future<String?> updateUserAttributes(List attributePayLoad) async {
    final String? version = await _channel.invokeMethod('updateUserAttributes',
        AttributePayLoad(attributePayLoad).createBundle());
    return version;
  }

  static Future<String?> deleteUserAttributes(List attributePayLoad) async {
    final String? version =
        await _channel.invokeMethod('deleteUserAttributes', attributePayLoad);
    return version;
  }

  static Future<String?> sendEvent(EventPayLoad eventPayLoad) async {
    final String? version =
        await _channel.invokeMethod('sendEvents', eventPayLoad.createBundle());
    return version;
  }

  static Future<String?> sendEventAction(
      Map<String, Object> eventPayLoad) async {
    final String? version = await _channel.invokeMethod('sendEvents');
    return version;
  }

  static void getRegisterValue() {}
}

class CustomActionValue {
  final regisiteredEvent = Event<ValueEventArgs>();
  final unregisiteredEvent = Event<ValueEventArgs>();
  final regisiteredValueEvent = Event<ValueEventArgs>();

  Future<void> registerCustomAction(String actionType) async {
    final String? response =
        await const MethodChannel('flutter_acoustic_mobile_push')
            .invokeMethod('registerCustomAction', actionType);
    if (response == null || response.isEmpty) {
      regisiteredEvent.broadcast(ValueEventArgs("Unregisted"));
    } else {
      regisiteredEvent.broadcast(ValueEventArgs(response));
    }
  }

  Future<void> registerCustomActionAndValue(
      CustomActionPayLoad eventObject) async {
    final String? response =
        await const MethodChannel('flutter_acoustic_mobile_push').invokeMethod(
            'registerCustomActionTypeAndValue', eventObject.createBundle());
    if (response == null || response.isEmpty) {
      regisiteredValueEvent.broadcast(ValueEventArgs("Unregisted"));
    } else {
      regisiteredValueEvent.broadcast(ValueEventArgs(response));
    }
  }

  Future<void> unregisterCustomAction(String actionType) async {
    final String? response =
        await const MethodChannel('flutter_acoustic_mobile_push')
            .invokeMethod('unregisterCustomAction', actionType);
    if (response == null || response.isEmpty) {
      unregisiteredEvent.broadcast(ValueEventArgs("Unregisted"));
    } else {
      unregisiteredEvent.broadcast(ValueEventArgs(response));
    }
  }
}

class RegisiterValue {
  final valueChangedEvent = Event<ValueEventArgs>();
  final userId = Event<ValueEventArgs>();
  final channelId = Event<ValueEventArgs>();
  final appKey = Event<ValueEventArgs>();

  Future<void> getRegisterValue() async {
    final String? response = await FlutterAcousticSdkPush.register;
    if (response == null || response.isEmpty) {
      userId.broadcast(ValueEventArgs("Unregisted"));
      channelId.broadcast(ValueEventArgs("Unregisted"));
      appKey.broadcast(ValueEventArgs("No Available AppKey Data"));
    } else {
      final data = await json.decode(response);
      if (data != null && data["userId"].toString().isNotEmpty) {
        userId.broadcast(ValueEventArgs(data["userId"]));
      } else {
        userId.broadcast(ValueEventArgs("Unregisted"));
      }
      if (data != null && data["channelId"].toString().isNotEmpty) {
        channelId.broadcast(ValueEventArgs(data["channelId"]));
      } else {
        channelId.broadcast(ValueEventArgs("Unregisted"));
      }
      if (data != null && data["appKey"].toString().isNotEmpty) {
        appKey.broadcast(ValueEventArgs(data["appKey"]));
      } else {
        appKey.broadcast(ValueEventArgs("No Available AppKey Data"));
      }
    }
  }
}

class ValueEventArgs extends EventArgs {
  String changedValue;
  ValueEventArgs(this.changedValue);
}

class ArrayListEventArgs extends EventArgs {
  List changedValue;

  ArrayListEventArgs(this.changedValue);
}

class BoolEventArgs extends EventArgs {
  bool changedValue;
  BoolEventArgs(this.changedValue);
}

class NumberEventArgs extends EventArgs {
  bool changedValue;
  NumberEventArgs(this.changedValue);
}
