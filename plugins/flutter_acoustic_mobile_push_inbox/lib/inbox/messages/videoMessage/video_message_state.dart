// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_inbox/constants.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/videoMessage/video_message_page.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/videoMessage/video_message.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'dart:developer' as dev;

import '../../../flutter_acoustic_mobile_push_inbox.dart';

class VideoMessageState extends State<VideoMessage> {
  var inbox = InboxMessageValue();
  bool isReadViewer = true;
  bool isExpired = false;

  String tag = "Inbox";

  updateIsReadViewer(value) {
    setState(() {
      isReadViewer = value;
    });
  }

  VideoPlayerController? _videoController;

  Timer t = Timer(Duration(milliseconds: 500), () {});
  var pauseIcon = const Visibility(
    child: Icon(
      Icons.pause,
      color: Color.fromRGBO(255, 255, 255, 0.4),
      size: 50,
    ),
    visible: true,
  );

  @override
  void initState() {
    super.initState();

    setState(() {
      isExpired = widget.isExpired;
    });

    _videoController = VideoPlayerController.network(
      widget.messageContent.isNotEmpty
          ? widget.messageContent
          // meant to be a fail-safe
          : 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    )..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    if (t.isActive) {
      t.cancel();
    }
  }

  // hides Pause Icon via "visible" property - delayed so it shows the pause icon first before hiding it immediately after
  pauseIconHide() {
    return t = Timer(const Duration(milliseconds: 50), () {
      pauseIcon = const Visibility(
        child: Icon(
          Icons.pause,
          color: Color.fromRGBO(255, 255, 255, 0.4),
          size: 50,
        ),
        visible: false,
      );
    });
  }

  // shows Pause Icon
  pauseIconShow() {
    pauseIcon = const Visibility(
      child: Icon(
        Icons.pause,
        color: Color.fromRGBO(255, 255, 255, 0.4),
        size: 50,
      ),
      visible: true,
    );
  }

  // if video is playing, shows pause icon briefly before hiding it - if not playing, returns pause icon to visible state and shows play icon
  iconSequence() {
    if (_videoController!.value.isPlaying) {
      pauseIconHide();
      return pauseIcon;
    } else {
      pauseIconShow();
      return const Icon(
        Icons.play_arrow,
        color: Color.fromRGBO(255, 255, 255, 0.4),
        size: 50,
      );
    }
  }

  videoMessageRender() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: _videoController!.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                )
              : _videoController!.value.hasError
                  ? Text("Error loading video")
                  : const Center(child: CircularProgressIndicator()),
        ),
        FloatingActionButton(
          heroTag: null,
          elevation: 0,
          backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
          onPressed: () {
            if (!isExpired) {
              setState(() {
                if (_videoController!.value.isPlaying) {
                  _videoController!.pause();
                } else {
                  _videoController!.play();
                }
              });
            }
          },
          // links the FAB to the _videoController so that it can change icons within the modalBottomSheet based on the state
          child: AnimatedBuilder(
            animation: _videoController!,
            builder: (context, child) {
              return iconSequence();
            },
          ),
        ),
        if (isExpired) ...[
          Center(
            child: _videoController!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: Container(
                      color: isExpired
                          ? Colors.white.withOpacity(0.5)
                          : Colors.white.withOpacity(1.0),
                    ))
                : const Center(child: CircularProgressIndicator()),
          ),
        ]
      ],
    );
  }

  var inboxNotificationPushCounter = 0;

  @override
  Widget build(BuildContext context) {
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
                      videoMessagePageInboxDeleteMessage:
                          widget.inboxDeleteMessage,
                      updateIsReadViewer: updateIsReadViewer,
                      videoActionList: widget.action,
                    )),
          );
          var inbox = InboxMessageValue();
          inbox.readInboxMessage(widget.messageId);
          updateIsReadViewer(true);
        } else {
          return;
        }
      }
    });

    buttonAction(int index) {
      String type = widget.action[index]["type"];
      if (type == "url" || type == "dial") {
        inbox.clickInboxAction(
            jsonEncode(widget.action[index]), widget.messageId);

        String action = "";
        if (type == "dial") {
          action = "tel://";
        }
        launch(action + widget.action[index]["value"],
            forceSafariVC: false, forceWebView: false);
      } else {
        dev.log('unrecognized data value', name: tag);
      }
    }

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
                      videoMessagePageInboxDeleteMessage:
                          widget.inboxDeleteMessage,
                      updateIsReadViewer: updateIsReadViewer,
                      videoActionList: widget.action,
                    )),
          );
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
            border: Border.all(
              width: 0.25,
              color: Colors.grey,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(widget.messageDate,
                      style: TextStyle(
                          color: isExpired
                              ? disableTextMessageBackgroundColor
                              : Colors.cyan))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: Image.network(widget.messageAvatar,
                            height: 50,
                            width: 50,
                            color: isExpired
                                ? Colors.white.withOpacity(0.5)
                                : Colors.white.withOpacity(1.0),
                            colorBlendMode: BlendMode.modulate,
                            errorBuilder: (context, error, stackTrace) {
                          dev.log('Issue loading avatar image', name: tag);
                          return const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(Icons.person));
                        }),
                      ),
                      SizedBox(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * .6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.messageTitle,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isExpired
                                      ? disableTextMessageBackgroundColor
                                      : messageTitleColor,
                                  fontWeight: widget.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                widget.messageSubtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: const TextStyle(
                                  color: messageBodyColor,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_forward_ios_sharp,
                        color: isExpired
                            ? disableTextMessageBackgroundColor
                            : Colors.black,
                      ),
                    ],
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: videoMessageRender(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  isExpired
                      ? Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Text(
                            widget.action[0]["name"].isEmpty
                                ? 'Left'
                                : widget.action[0]["name"],
                            style: TextStyle(
                                color: disableTextMessageBackgroundColor),
                          ),
                        )
                      : TextButton(
                          onPressed: () {
                            buttonAction(0);
                          },
                          child: Text(
                            widget.action[0]["name"].isEmpty
                                ? 'Left'
                                : widget.action[0]["name"],
                          ),
                        ),
                  isExpired
                      ? Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Text(
                            widget.action[2]["name"].isEmpty
                                ? 'Center'
                                : widget.action[2]["name"],
                            style: TextStyle(
                                color: disableTextMessageBackgroundColor),
                          ),
                        )
                      : TextButton(
                          onPressed: () {
                            buttonAction(2);
                          },
                          child: Text(
                            widget.action[2]["name"].isEmpty
                                ? 'Center'
                                : widget.action[2]["name"],
                          ),
                        ),
                  isExpired
                      ? Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Text(
                            widget.action[1]["name"].isEmpty
                                ? 'Right'
                                : widget.action[1]["name"],
                            style: TextStyle(
                                color: disableTextMessageBackgroundColor),
                          ),
                        )
                      : TextButton(
                          onPressed: () {
                            buttonAction(1);
                          },
                          child: Text(
                            widget.action[1]["name"].isEmpty
                                ? 'Right'
                                : widget.action[1]["name"],
                          ),
                        ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
