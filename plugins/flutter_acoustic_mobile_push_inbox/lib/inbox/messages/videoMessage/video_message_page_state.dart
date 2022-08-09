import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/videoMessage/video_message_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'dart:developer' as dev;
import '../../../flutter_acoustic_mobile_push_inbox.dart';

class VideoMessagePageState extends State<VideoMessagePage> {
  late VideoPlayerController _videoController;
  String tag = "Inbox";

  Timer t = Timer(const Duration(milliseconds: 500), () {});
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
    if (_videoController.value.isPlaying) {
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
    if (!_videoController.value.isInitialized &&
        _videoController.value.hasError) {
      return const Center(child: Text("Error loading video"));
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: _videoController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
        FloatingActionButton(
          heroTag: null,
          backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
          elevation: 0,
          onPressed: () {
            setState(() {
              if (_videoController.value.isPlaying) {
                _videoController.pause();
              } else {
                _videoController.play();
              }
            });
          },
          // links the FAB to the _videoController so that it can change icons within the modalBottomSheet based on the state
          child: AnimatedBuilder(
            animation: _videoController,
            builder: (context, child) {
              return iconSequence();
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var inbox = InboxMessageValue();

    buttonAction(int index) {
      String type = widget.videoActionList[index]["type"];
      if (type == "url" || type == "dial") {
        inbox.clickInboxAction(jsonEncode(widget.videoActionList[index]),
            widget.videoMessagePageId);

        String action = "";
        if (type == "dial") {
          action = "tel://";
        }
        launch(action + widget.videoActionList[index]["value"],
            forceSafariVC: false, forceWebView: false);
      } else {
        dev.log('unrecognized data value', name: tag);
      }
    }

    kebabMenu() {
      List<DropdownMenuItem<Object>> menuItems = [
        DropdownMenuItem(
          child: const Text("Read"),
          value: 'Read',
          onTap: () {
            dev.log('read', name: tag);
            Navigator.pop(context);
            inbox.readInboxMessage(widget.videoMessagePageId);
            widget.updateIsReadViewer(true);
          },
        ),
        DropdownMenuItem(
          child: const Text("Unread"),
          value: 'Unread',
          onTap: () {
            dev.log('unread', name: tag);
            Navigator.pop(context);
            inbox.unreadInboxMessage(widget.videoMessagePageId);
            widget.updateIsReadViewer(false);
          },
        ),
        DropdownMenuItem(
          child: const Text("Delete"),
          value: 'Delete',
          onTap: () {
            Navigator.pop(context);
            widget.videoMessagePageInboxDeleteMessage();
          },
        ),
      ];
      return DropdownButtonHideUnderline(
        child: DropdownButton(
          style: const TextStyle(fontSize: 12, color: Colors.black),
          icon: const Icon(Icons.more_vert),
          items: menuItems,
          onChanged: (x) {
            setState(() {});
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            setState(() {
              if (_videoController.value.isPlaying) {
                _videoController.pause();
              }
            });
            Navigator.pop(context);
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
        actions: <Widget>[kebabMenu()],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: ListView(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: Image.network(widget.videoMessagePageAvatar,
                            height: 50,
                            width: 50,
                            color: Colors.white.withOpacity(1.0),
                            colorBlendMode: BlendMode.modulate,
                            errorBuilder: (context, error, stackTrace) {
                          dev.log('Issue loading avatar image', name: tag);
                          return const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(Icons.person));
                        }),
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            widget.videoMessagePageTitle,
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    height: 20,
                    thickness: 0.5,
                    color: Colors.black,
                  ),
                  Text(widget.videoMessagePageBody),
                  Container(
                    child: videoMessageRender(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          buttonAction(0);
                        },
                        child: Text(
                          widget.videoActionList[0]["name"].isEmpty
                              ? 'Left'
                              : widget.videoActionList[0]["name"],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          buttonAction(2);
                        },
                        child: Text(
                          widget.videoActionList[2]["name"].isEmpty
                              ? 'Center'
                              : widget.videoActionList[2]["name"],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          buttonAction(1);
                        },
                        child: Text(
                          widget.videoActionList[1]["name"].isEmpty
                              ? 'Right'
                              : widget.videoActionList[1]["name"],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
