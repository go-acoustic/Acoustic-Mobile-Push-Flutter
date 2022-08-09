import 'dart:async';
import 'dart:convert';
import 'package:event/event.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acoustic_mobile_push_inapp/flutter_in_app_pay_load.dart';
import 'package:flutter_acoustic_mobile_push/flutter_acoustic_sdk_push.dart';
import 'dart:developer' as dev;

class FlutterAcousticMobilePushInapp {
  static const MethodChannel _channel =
      MethodChannel('flutter_acoustic_mobile_push_inapp');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String?> sendCannedInAppContent(
      InAppMessage eventPayLoad) async {
    final String? version = await _channel.invokeMethod(
        'cannedInAppContent', eventPayLoad.createBundle());
    return version;
  }
}

class InAppModelEventArgs extends EventArgs {
  InAppMessage inAppMessage;
  InAppModelEventArgs(this.inAppMessage);
}

class InAppMessageValue {
  final hasInAppMessage = Event<BoolEventArgs>();
  final inAppMessage = Event<InAppModelEventArgs>();

  String tag = "InApp";

  Future<void> getInAppList() async {
    const MethodChannel('flutter_acoustic_mobile_push_inapp')
        .invokeMethod('getSync');
    const MethodChannel('flutter_acoustic_mobile_push_inapp')
        .setMethodCallHandler((methodCall) async {
      if (methodCall.method == "NoInAppMessage") {
        hasInAppMessage.broadcast(BoolEventArgs(false));
      } else if (methodCall.method == "InAppMessage") {
        var response = methodCall.arguments.toString();

        if (response.isEmpty) {
          hasInAppMessage.broadcast(BoolEventArgs(false));
        } else {
          var listJson = jsonDecode(response);
          dev.log("From response ${listJson.toString()}", name: tag);

          InAppMessage lists = InAppMessage.fromJson(listJson);
          dev.log("InAppMessage has new items from response", name: tag);

          inAppMessage.broadcast(InAppModelEventArgs(lists));
        }
      }
    });
  }

  getInAppMessage(List<String> rules) {
    const MethodChannel('flutter_acoustic_mobile_push_inapp')
        .invokeMethod('getInAppMessageTemplate', rules);
  }

  getInAppMessageTemplateBottom(List<String> templateName) async {
    return await const MethodChannel('flutter_acoustic_mobile_push_inapp')
        .invokeMethod('getInAppMessageTemplate', ['bottomBanner']);
  }

  // records message and sends "message opened" when banner button is clicked and banner is shown
  void recordViewForInAppMessage(String inAppMessageId) async {
    const MethodChannel('flutter_acoustic_mobile_push_inapp')
        .invokeMethod('recordViewForInAppMessage', inAppMessageId);
  }

  // records message and sends "message opened" when url on banner is clicked
  void clickInApp(String inAppMessageId) async {
    const MethodChannel('flutter_acoustic_mobile_push_inapp')
        .invokeMethod('clickInApp', inAppMessageId);
  }

  // This sets the in app message’s view count to max views and removes the message from storage
  void deleteInApp(String inAppMessageId) async {
    const MethodChannel('flutter_acoustic_mobile_push_inapp')
        .invokeMethod('deleteInApp', inAppMessageId);
  }
}
