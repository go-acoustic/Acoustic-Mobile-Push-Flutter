import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/videoMessage/video_message_page_state.dart';

class VideoMessagePage extends StatefulWidget {
  final String videoMessagePageTitle;
  final String videoMessagePageBody;
  final String videoMessagePageDate;
  final String videoMessagePageAvatar;
  final String videoMessagePageContent;
  final String videoMessagePageId;
  final Function videoMessagePageInboxDeleteMessage;
  final Function(bool) updateIsReadViewer;
  final List<dynamic> videoActionList;

  const VideoMessagePage(
      {required this.videoMessagePageTitle,
      required this.videoMessagePageBody,
      required this.videoMessagePageDate,
      required this.videoMessagePageAvatar,
      required this.videoMessagePageContent,
      required this.videoMessagePageId,
      required this.videoMessagePageInboxDeleteMessage,
      required this.updateIsReadViewer,
      required this.videoActionList,
      Key? key})
      : super(key: key);

  @override
  VideoMessagePageState createState() => VideoMessagePageState();
}
