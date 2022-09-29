import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/inbox_messages.dart';
import 'package:video_player/video_player.dart';

class VideoLayout extends InboxState {
  var pauseIcon = const Visibility(
    child: Icon(
      Icons.pause,
      color: Color.fromRGBO(255, 255, 255, 0.4),
      size: 50,
    ),
    visible: true,
  );

  // hides Pause Icon via "visible" property - delayed so it shows the pause icon first before hiding it immediately after
  pauseIconHide() {
    return Timer(const Duration(milliseconds: 50), () {
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
  iconSequence(VideoPlayerController _videoController) {
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

  Widget videoIconBuilder(VideoPlayerController _videoController) {
    return AnimatedBuilder(
      animation: _videoController,
      builder: (context, child) {
        return iconSequence(_videoController);
      },
    );
  }

  videoMessageRender(VideoPlayerController _videoController, bool isExpired) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: _videoController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                )
              : _videoController.value.hasError
                  ? const Text("Error loading video")
                  : const Center(child: CircularProgressIndicator()),
        ),
        FloatingActionButton(
            heroTag: null,
            elevation: 0,
            backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
            onPressed: () {
              if (!isExpired) {
                if (_videoController.value.isPlaying) {
                  _videoController.pause();
                } else {
                  _videoController.play();
                }
              }
            },
            // links the FAB to the _videoController so that it can change icons within the modalBottomSheet based on the state
            child: videoIconBuilder(_videoController)),
        if (isExpired) ...[
          Center(
            child: _videoController.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
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
}
