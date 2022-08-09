// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:event/event.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/videoMessage/video_message.dart';
import 'flutter_inbox_pay_load.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'inbox/messages/imageMessage/image_message.dart';
import 'inbox/messages/simpleMessage/simple_message.dart';
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
    // update in next patch
    // ignore: unused_local_variable
    final Future? response =
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
            // dev.log("Error from decoding Json $err", name: tag);
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

// inbox begin

class Inbox extends StatefulWidget {
  final String? messageNotificationId;
  static List messages = [];
  // inbox shouldn't be const for this case as other values are being passed through
  // update in next patch
  // ignore: prefer_const_constructors_in_immutables
  Inbox({Key? key, this.messageNotificationId}) : super(key: key);

  @override
  State<Inbox> createState() => InboxState();
}

class InboxState extends State<Inbox> {
  bool inboxMessages = false;

  String notificationAlert = "alert";
  String tag = "Inbox";

  // creates empty array for messages to be stored in

  // fetch sdk data
  //var inbox = InboxMessageValue();

  readJsonMessagesSdk() {
    try {
      var inbox = InboxMessageValue();
      inbox.getInboxListMessage();
      inbox.syncInBoxMessages();
      inbox.inBoxList.subscribe((args) {
        var data = args!.inboxMessage;
        for (var i = 0; i < data.length; i++) {
          // update in next patch
          // ignore: unused_local_variable
          var box = data[i];
        }
        setState(() {
          Inbox.messages = data;
          inboxMessages = true;
          Inbox.messages = Inbox.messages.reversed.toList();
        });
      });
    } catch (err) {
      dev.log('$err', name: tag);
    }
  }

  Timer buildInboxTimer = Timer(Duration(milliseconds: 500), () {});
  // creates a small delay only on the initial load so the message data can be loaded in prior to the inbox being generated

  buildInboxDelayed() async {
    buildInboxTimer =
        Timer(Duration(milliseconds: 2500), () => readJsonMessagesSdk());
  }

  noInboxMessages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(20),
          child: Text(
            'No Inbox Messages - Press the Refresh button at the top right corner to load messages. If messages exist, they will be loaded',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    readJsonMessagesSdk();
    buildInboxDelayed();
    super.initState();
  }

  var inboxReloadCounter = 0;

  checkIsExpired() {
    for (int i = 0; i < Inbox.messages.length; ++i) {
      setState(() {
        Inbox.messages[i].isExpired = Inbox.messages[i].isExpired;
      });
    }
  }

  // builds message list or shows "No Messages"
  buildInboxMessages() {
    if (Inbox.messages.isNotEmpty) {
      checkIsExpired();
      return ListView.builder(
        itemCount: Inbox.messages.length,
        itemBuilder: (context, index) {
          // variables that pull the json data after it has been decoded
          // converting date to proper formatting
          var timeStamp = Inbox.messages[index].sendDate;
          var convertedStamp = DateTime.fromMillisecondsSinceEpoch(timeStamp);
          var formattedDate = DateFormat('MM-dd-yyyy').format(convertedStamp);
          // sendDate
          var date = formattedDate.toString();

          var messageType = Inbox.messages[index].templateName;

          var messageId = Inbox.messages[index].inboxMessageId;

          var isRead = Inbox.messages[index].isRead;
          var isExpired = Inbox.messages[index].isExpired;

          // update in next patch
          // ignore: prefer_function_declarations_over_variables
          var inboxDeleteMessage = () {
            InboxMessageValue().deleteMessage(messageId);
            readJsonMessagesSdk();
          };

          // for simple message
          if (messageType == 'default') {
            var simpleMessageTitle =
                Inbox.messages[index].content.messagePreview.subject;
            var simpleMessageText =
                Inbox.messages[index].content.messagePreview.previewContent;
            var simpleMessageContent =
                Inbox.messages[index].content.messageDetails.richContent;
            List<dynamic> setAction = [];

            if (Inbox.messages[index].content.actions != null) {
              for (int i = 0;
                  i < Inbox.messages[index].content.actions.length;
                  ++i) {
                setAction.add({
                  'name': Inbox.messages[index].content.actions[i].name,
                  'value': Inbox.messages[index].content.actions[i].value,
                  'type': Inbox.messages[index].content.actions[i].type,
                  'id': Inbox.messages[index].content.actions[i].id
                });
              }
            }

            return SimpleMessage(
              messageTitle: simpleMessageTitle,
              messageBody: simpleMessageText,
              messageDate: date,
              messageContent: simpleMessageContent,
              messageId: messageId,
              inboxDeleteMessage: inboxDeleteMessage,
              isRead: isRead,
              isExpired: isExpired,
              notificationId: widget.messageNotificationId,
              action: setAction,
            );

            // for image message
          } else if (messageType == 'post' &&
              Inbox.messages[index].content.contentImage != null) {
            try {
              var mediaMessageTitle = Inbox.messages[index].content.header;
              var mediaMessageSubtitle =
                  Inbox.messages[index].content.subHeader;
              var mediaMessageText = Inbox.messages[index].content.contentText;
              var avatar = Inbox.messages[index].content.headerImage;
              var content = Inbox.messages[index].content.contentImage;

              List<dynamic> setAction = [];

              if (Inbox.messages[index].content.actions != null) {
                for (int i = 0;
                    i < Inbox.messages[index].content.actions.length;
                    ++i) {
                  setAction.add({
                    'name': Inbox.messages[index].content.actions[i].name,
                    'value': Inbox.messages[index].content.actions[i].value,
                    'type': Inbox.messages[index].content.actions[i].type,
                  });
                }
              }

              return ImageMessage(
                messageTitle: mediaMessageTitle,
                messageSubtitle: mediaMessageSubtitle,
                messageBody: mediaMessageText,
                messageDate: date,
                messageAvatar: avatar,
                messageContent: content,
                messageId: messageId,
                inboxDeleteMessage: inboxDeleteMessage,
                isRead: isRead,
                isExpired: isExpired,
                notificationId: widget.messageNotificationId,
                action: setAction,
              );
            } catch (err) {
              dev.log("Error with image message: $err", name: tag);
            }
            // left

            // for video message
          } else if (messageType == 'post' &&
              Inbox.messages[index].content.contentVideo != null) {
            try {
              var mediaMessageTitle = Inbox.messages[index].content.header;
              var mediaMessageSubtitle =
                  Inbox.messages[index].content.subHeader;
              var mediaMessageText = Inbox.messages[index].content.contentText;
              var avatar = Inbox.messages[index].content.headerImage;
              var content = Inbox.messages[index].content.contentVideo;

              List<dynamic> setAction = [];

              if (Inbox.messages[index].content.actions != null) {
                for (int i = 0;
                    i < Inbox.messages[index].content.actions.length;
                    ++i) {
                  setAction.add({
                    'name': Inbox.messages[index].content.actions[i].name,
                    'value': Inbox.messages[index].content.actions[i].value,
                    'type': Inbox.messages[index].content.actions[i].type,
                  });
                }
              }

              return VideoMessage(
                messageTitle: mediaMessageTitle,
                messageSubtitle: mediaMessageSubtitle,
                messageBody: mediaMessageText,
                messageDate: date,
                messageAvatar: avatar,
                messageContent: content,
                messageId: messageId,
                inboxDeleteMessage: inboxDeleteMessage,
                isRead: isRead,
                isExpired: isExpired,
                notificationId: widget.messageNotificationId,
                action: setAction,
              );
            } catch (err) {
              dev.log("Error with video message: $err", name: tag);
            }
          }
          return Text('unknown message type');
        },
      );
    } else {
      if (Inbox.messages.isEmpty) {
        return noInboxMessages();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'Inbox',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.sync,
              color: Colors.black,
            ),
            onPressed: () {
              // pulls down messages along with any updated

              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => Inbox(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
          )
        ],
      ),
      body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment(0.8, 0.4),
              colors: <Color>[
                Color.fromRGBO(22, 57, 77, 1),
                Color.fromRGBO(14, 114, 101, 1),
              ],
            ),
          ),
          child: buildInboxMessages()),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (buildInboxTimer.isActive) {
      buildInboxTimer.cancel();
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
