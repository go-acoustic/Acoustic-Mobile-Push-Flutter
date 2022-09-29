import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_inbox/flutter_acoustic_mobile_push_inbox.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/layouts/video_message_layout_design.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/videoMessage/models/video_message_page.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/layouts/message_layout.dart';
import 'package:video_player/video_player.dart';

class VideoMessagePageState extends State<VideoMessagePage> {
  late VideoPlayerController _videoController;
  String tag = "Inbox";

  @override
  void initState() {
    super.initState();
    _videoController =
        VideoPlayerController.network(widget.videoMessagePageContent)
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
          });
  }

  @override
  void dispose() {
    super.dispose();
    _videoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            setState(() {
              if (_videoController.value.isPlaying) {
                _videoController.pause();
              }
            });
            InboxMessageValue().readInboxMessage(widget.videoMessagePageId);
            Navigator.pop(context, true);
          },
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.videoMessagePageTitle,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          Message().kebabMenu(
            context,
            widget.videoMessagePageId,
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: ListView(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Message().header(
                      widget.videoMessagePageAvatar,
                      widget.videoMessagePageDate,
                      widget.videoMessagePageTitle),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    child: Text(widget.videoMessagePageBody),
                  ),
                  Container(
                    child: VideoLayout()
                        .videoMessageRender(_videoController, false),
                  ),
                  Message().actionButtons(
                      widget.videoActionList[0].name,
                      widget.videoActionList[2].name,
                      widget.videoActionList[1].name,
                      widget.videoActionList,
                      widget.videoMessagePageId)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
