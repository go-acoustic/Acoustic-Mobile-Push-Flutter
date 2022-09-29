import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_inbox/constants.dart';
import 'package:flutter_acoustic_mobile_push_inbox/flutter_acoustic_mobile_push_inbox.dart';
import 'package:flutter_acoustic_mobile_push_inbox/flutter_inbox_pay_load.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/imageMessage/models/image_message.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/simpleMessage/models/simple_message.dart';
import 'package:intl/intl.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/videoMessage/models/video_message.dart';
import 'dart:developer' as dev;

class Inbox extends StatefulWidget {
  final String? messageNotificationId;
  static List<InBoxMessage> messages = [];

  const Inbox({Key? key, this.messageNotificationId}) : super(key: key);

  @override
  State<Inbox> createState() => InboxState();
}

class InboxState extends State<Inbox> {
  bool inboxMessages = false;

  String notificationAlert = "alert";
  String tag = "Inbox";

  readJsonMessagesSdk() {
    try {
      var inbox = InboxMessageValue();
      inbox.getInboxListMessage();
      inbox.syncInBoxMessages();
      inbox.inBoxList.subscribe((args) {
        var data = args!.inboxMessage;
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

  Timer buildInboxTimer = Timer(const Duration(milliseconds: 500), () {});
  // creates a small delay only on the initial load so the message data can be loaded in prior to the inbox being generated

  buildInboxDelayed() async {
    buildInboxTimer =
        Timer(const Duration(milliseconds: 2500), () => readJsonMessagesSdk());
  }

  noInboxMessages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: const Text(
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
        shrinkWrap: true,
        itemCount: Inbox.messages.length,
        itemBuilder: (context, index) {
          // variables that pull the json data after it has been decoded
          // converting date to proper formatting
          var timeStamp = Inbox.messages[index].sendDate;
          var convertedStamp = DateTime.fromMillisecondsSinceEpoch(timeStamp);
          var formattedDate = DateFormat('MM-dd-yyyy').format(convertedStamp);
          var date = formattedDate.toString();

          var messageType = Inbox.messages[index].templateName;
          var messageId = Inbox.messages[index].inboxMessageId;
          var isRead = Inbox.messages[index].isRead;
          var isExpired = Inbox.messages[index].isExpired;

          // for simple message
          if (messageType == 'default') {
            return SimpleMessage(
              messageTitle:
                  Inbox.messages[index].content!.messagePreview!.subject,
              messageBody:
                  Inbox.messages[index].content!.messagePreview!.previewContent,
              messageDate: date,
              messageContent:
                  Inbox.messages[index].content!.messageDetails!.richContent,
              messageId: messageId,
              isRead: isRead,
              isExpired: isExpired,
              notificationId: widget.messageNotificationId,
              action: Inbox.messages[index].content!.actions ?? [],
            );
          }

          // for image message
          else if (messageType == 'post' &&
              Inbox.messages[index].content?.contentImage != null) {
            try {
              return ImageMessage(
                messageTitle: Inbox.messages[index].content!.header!,
                messageSubtitle: Inbox.messages[index].content!.subHeader!,
                messageBody: Inbox.messages[index].content!.contentText!,
                messageDate: date,
                messageAvatar: Inbox.messages[index].content!.headerImage!,
                messageContent: Inbox.messages[index].content!.contentImage!,
                messageId: messageId,
                isRead: isRead,
                isExpired: isExpired,
                notificationId: widget.messageNotificationId,
                action: Inbox.messages[index].content!.actions!,
              );
            } catch (err) {
              dev.log("Error with image message: $err", name: tag);
            }
          }

          // for video message
          else if (messageType == 'post' &&
              Inbox.messages[index].content!.contentVideo != null) {
            try {
              return VideoMessage(
                messageTitle: Inbox.messages[index].content!.header!,
                messageSubtitle: Inbox.messages[index].content!.subHeader!,
                messageBody: Inbox.messages[index].content!.contentText!,
                messageDate: date,
                messageAvatar: Inbox.messages[index].content!.headerImage!,
                messageContent: Inbox.messages[index].content!.contentVideo!,
                messageId: messageId,
                isRead: isRead,
                isExpired: isExpired,
                notificationId: widget.messageNotificationId,
                action: Inbox.messages[index].content!.actions!,
              );
            } catch (err) {
              dev.log("Error with video message: $err", name: tag);
            }
          }

          return const Text('unknown message type');
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
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Inbox',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.sync,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      const Inbox(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
          )
        ],
      ),
      body: Container(
          decoration: appBackgroundGradient, child: buildInboxMessages()),
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
