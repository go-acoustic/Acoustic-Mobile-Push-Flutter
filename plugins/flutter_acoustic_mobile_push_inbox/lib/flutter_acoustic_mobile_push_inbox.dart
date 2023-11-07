import 'dart:async';
import 'dart:convert';
import 'package:event/event.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acoustic_mobile_push_inbox/flutter_inbox_pay_load.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/inbox_messages.dart';
import 'dart:developer' as dev;

class FlutterAcousticMobilePushInbox {
  static const MethodChannel _channel =
      MethodChannel('flutter_acoustic_mobile_push_inbox');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

class InboxMessageValue {
  final inBoxList = Event<InboxMessageEventArgs>();
  final syncInBoxMessage = Event<BoolEventArgs>();
  final inBoxMessages = Event<InBoxModelEventArgs>();

  String tag = "Inbox";
  Future<void> syncInBoxMessages() async {
    await getInboxListMessage();
    const MethodChannel('flutter_acoustic_mobile_push_inbox')
        .invokeMethod('syncInboxMessage');
  }

  Future<void> getInboxListMessage() async {
    const MethodChannel('flutter_acoustic_mobile_push_inbox')
        .setMethodCallHandler((methodCall) async {
      if (methodCall.method == "InboxMessages") {
        dev.log("inbox -> ${methodCall.arguments.toString()}", name: tag);

        var response = methodCall.arguments.toString();
        if (response.isEmpty) {
          dev.log('empty response', name: tag);
          inBoxList.broadcast(InboxMessageEventArgs(List.empty()));
        } else {
          try {
            var listJson = jsonDecode(response) as List;
            dev.log(response, name: tag);

            List<InBoxMessage> lists =
                listJson.map((list) => InBoxMessage.fromJson(list)).toList();
            inBoxList.broadcast(InboxMessageEventArgs(lists));
            dev.log("inbox messages count ${lists.length}", name: tag);
          } catch (err) {
            dev.log("Error from decoding Json $err", name: tag);
          }
        }
      } else if (methodCall.method == "InBoxMessageCount") {
        var response = methodCall.arguments.toString();
        if (response.isEmpty) {
          inBoxMessages.broadcast(InBoxModelEventArgs(InBoxMessageModel(0, 0)));
        } else {
          var model = jsonDecode(response) as InBoxMessageModel;
          inBoxMessages.broadcast(InBoxModelEventArgs(model));
        }
      }
    });
  }

  void deleteMessage(String id) async {
    const MethodChannel('flutter_acoustic_mobile_push_inbox')
        .invokeMethod('deleteInboxMessage', id)
        .then((value) {
      for (var i = 0; i < Inbox.messages.length; ++i) {
        if (Inbox.messages[i].inboxMessageId == id) {
          Inbox.messages.removeAt(i);
        }
      }
    });
  }

  void readInboxMessage(String id) async {
    const MethodChannel('flutter_acoustic_mobile_push_inbox')
        .invokeMethod('readInboxMessage', id);
  }

  void unreadInboxMessage(String id) async {
    const MethodChannel('flutter_acoustic_mobile_push_inbox')
        .invokeMethod('unreadInboxMessage', id);
  }

  void getInboxMessageCount() async {
    const MethodChannel('flutter_acoustic_mobile_push_inbox')
        .invokeMethod('readInboxMessage');
  }

  void clickInboxAction(String action, String id) async {
    const MethodChannel('flutter_acoustic_mobile_push_inbox').invokeMethod(
        'clickInboxAction', {'action': action, 'inboxMessageId': id});
  }
}

class InboxMessageEventArgs extends EventArgs {
  List<InBoxMessage> inboxMessage;
  InboxMessageEventArgs(this.inboxMessage);
}

class BoolEventArgs extends EventArgs {
  bool changedValue;
  BoolEventArgs(this.changedValue);
}

class InBoxModelEventArgs extends EventArgs {
  InBoxMessageModel changedValue;
  InBoxModelEventArgs(this.changedValue);
}
