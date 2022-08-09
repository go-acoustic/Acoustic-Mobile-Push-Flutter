import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/imageMessage/image_message_page_state.dart';

class ImageMessagePage extends StatefulWidget {
  final String imageMessagePageTitle;
  final String imageMessagePageBody;
  final String imageMessagePageDate;
  final String imageMessagePageAvatar;
  final String imageMessagePageContent;
  final String imageMessagePageId;
  final Function imageMessagePageInboxDeleteMessage;

  final Function(bool) updateIsReadViewer;
  final List<dynamic> imageActionList;

  const ImageMessagePage(
      {required this.imageMessagePageTitle,
      required this.imageMessagePageBody,
      required this.imageMessagePageDate,
      required this.imageMessagePageAvatar,
      required this.imageMessagePageContent,
      required this.imageMessagePageId,
      required this.imageMessagePageInboxDeleteMessage,
      required this.updateIsReadViewer,
      required this.imageActionList,
      Key? key})
      : super(key: key);

  @override
  ImageMessagePageState createState() => ImageMessagePageState();
}
