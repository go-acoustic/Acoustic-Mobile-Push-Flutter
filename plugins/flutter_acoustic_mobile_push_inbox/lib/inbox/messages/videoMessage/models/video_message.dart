import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_inbox/flutter_inbox_pay_load.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/videoMessage/video_message_preview.dart';

class VideoMessage extends StatefulWidget {
  final String messageTitle;
  final String messageSubtitle;
  final String messageBody;
  final String messageDate;
  final String messageAvatar;
  final String messageContent;
  final String messageId;
  final bool isRead;
  final bool isExpired;
  final String? notificationId;
  final List<MessageActions> action;

  const VideoMessage({
    required this.messageTitle,
    required this.messageSubtitle,
    required this.messageBody,
    required this.messageDate,
    required this.messageAvatar,
    required this.messageContent,
    required this.messageId,
    required this.isRead,
    required this.isExpired,
    this.notificationId,
    required this.action,
    Key? key,
  }) : super(key: key);

  @override
  State<VideoMessage> createState() => VideoMessagePreview();
}
