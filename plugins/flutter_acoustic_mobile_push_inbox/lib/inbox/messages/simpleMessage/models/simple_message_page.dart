import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_inbox/flutter_inbox_pay_load.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/simpleMessage/simple_message_page_state.dart';

class SimpleMessagePage extends StatefulWidget {
  final String simpleMessagePageTitle;
  final String simpleMessagePageBody;
  final String simpleMessagePageDate;
  final String simpleMessagePageContent;
  final String simpleMessagePageId;
  final List<MessageActions> simpleActionList;

  const SimpleMessagePage(
      {required this.simpleMessagePageTitle,
      required this.simpleMessagePageBody,
      required this.simpleMessagePageDate,
      required this.simpleMessagePageContent,
      required this.simpleMessagePageId,
      required this.simpleActionList,
      Key? key})
      : super(key: key);

  @override
  SimpleMessagePageState createState() => SimpleMessagePageState();
}
