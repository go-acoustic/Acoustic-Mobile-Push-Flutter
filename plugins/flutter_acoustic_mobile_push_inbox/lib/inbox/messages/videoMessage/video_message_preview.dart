import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_inbox/constants.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/layouts/video_message_layout_design.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/videoMessage/models/video_message_page.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/videoMessage/models/video_message.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/layouts/message_layout.dart';
import 'package:video_player/video_player.dart';
import '../../../flutter_acoustic_mobile_push_inbox.dart';

class VideoMessagePreview extends State<VideoMessage> {
  var inbox = InboxMessageValue();
  bool? isReadViewer;
  bool isExpired = false;
  bool isVisible = true;

  String tag = "Inbox";

  updateIsReadViewer(value) {
    setState(() {
      isReadViewer = value;
    });
  }

  dropDownMenuAction(String value) {
    if (value == "Read") {
      updateIsReadViewer(true);
    } else if (value == "Unread") {
      updateIsReadViewer(false);
    } else {
      setState(() {
        isVisible = false;
      });
    }
  }

  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();

    setState(() {
      isExpired = widget.isExpired;
    });

    _videoController = VideoPlayerController.networkUrl(
      widget.messageContent.isNotEmpty
          ? Uri.parse(widget.messageContent)
          // meant to be a fail-safe
          : Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
    )..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _videoController!.dispose();
  }

  var inboxNotificationPushCounter = 0;

  @override
  Widget build(BuildContext context) {
    if (isVisible) {
      Future.delayed(const Duration(milliseconds: 50), () async {
        if ((widget.notificationId != null) &&
            (widget.notificationId == widget.messageId)) {
          if (inboxNotificationPushCounter == 0) {
            setState(() {
              inboxNotificationPushCounter = inboxNotificationPushCounter + 1;
            });

            setState(() {
              if (_videoController!.value.isPlaying) {
                _videoController!.pause();
              }
            });

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VideoMessagePage(
                        videoMessagePageTitle: widget.messageTitle,
                        videoMessagePageBody: widget.messageBody,
                        videoMessagePageDate: widget.messageDate,
                        videoMessagePageAvatar: widget.messageAvatar,
                        videoMessagePageContent: widget.messageContent,
                        videoMessagePageId: widget.messageId,
                        videoActionList: widget.action,
                      )),
            ).then((value) {
              if (value is String) {
                dropDownMenuAction(value);
              }
            });
            var inbox = InboxMessageValue();
            inbox.readInboxMessage(widget.messageId);
            updateIsReadViewer(true);
          } else {
            return;
          }
        }
      });

      return SafeArea(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VideoMessagePage(
                        videoMessagePageTitle: widget.messageTitle,
                        videoMessagePageBody: widget.messageBody,
                        videoMessagePageDate: widget.messageDate,
                        videoMessagePageAvatar: widget.messageAvatar,
                        videoMessagePageContent: widget.messageContent,
                        videoMessagePageId: widget.messageId,
                        videoActionList: widget.action,
                      )),
            ).then((value) {
              if (value is String) {
                dropDownMenuAction(value);
              }
            });
            var inbox = InboxMessageValue();
            inbox.readInboxMessage(widget.messageId);
            updateIsReadViewer(true);

            setState(() {
              if (_videoController!.value.isPlaying) {
                _videoController!.pause();
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isExpired
                  ? disableMessageBackgroundColor
                  : messageBackgroundColor,
              border: const Border(
                  bottom: BorderSide(
                color: Colors.grey,
              )),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Message().previewHeader(
                    widget.messageDate,
                    widget.messageTitle,
                    widget.messageBody,
                    isExpired,
                    widget.isRead,
                    isReadViewer,
                    MediaQuery.of(context).size.width * .6,
                    avatar: widget.messageAvatar),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: VideoLayout()
                      .videoMessageRender(_videoController!, isExpired),
                ),
                Message().actionButtons(
                  widget.action[0].name,
                  widget.action[2].name,
                  widget.action[1].name,
                  widget.action,
                  widget.messageId,
                  isExpired: isExpired,
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
