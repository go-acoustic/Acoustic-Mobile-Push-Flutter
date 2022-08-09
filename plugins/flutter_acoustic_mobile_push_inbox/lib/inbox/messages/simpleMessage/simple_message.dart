import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/simpleMessage/simple_message_state.dart';

class SimpleMessage extends StatefulWidget {
  final String messageTitle;
  final String messageBody;
  final String messageDate;
  final String messageContent;
  final String messageId;
  final bool isRead;
  final bool isExpired;
  final Function inboxDeleteMessage;
  final String? notificationId;
  final List<dynamic> action;

  const SimpleMessage({
    required this.messageTitle,
    required this.messageBody,
    required this.messageDate,
    required this.messageContent,
    required this.messageId,
    required this.inboxDeleteMessage,
    required this.isRead,
    required this.isExpired,
    this.notificationId,
    required this.action,
    Key? key,
  }) : super(key: key);

  @override
  State<SimpleMessage> createState() => SimpleMessageState();
}
