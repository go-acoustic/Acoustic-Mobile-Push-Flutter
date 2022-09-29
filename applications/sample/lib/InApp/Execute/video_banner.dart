part of 'package:ca_mce_flutter_sdk_sample/in_app.dart';

extension VideoBanner on _InAppState {
  Future<void> inAppVideoTemplate() async {
    if (_templatesInAppData != null &&
        messageViewCounter() &&
        checkTemplateOrientation("video")) {
      try {
        if (_templatesInAppData.content?.action!.value != null) {
          _videoController =
              VideoPlayerController.network(_templatesInAppData.content!.video)
                ..addListener(() {
                  if (_videoController!.value.duration ==
                      _videoController!.value.position) {
                    Navigator.popUntil(context, ModalRoute.withName('/in-app'));
                  }
                })
                ..initialize().then((_) {
                  _videoController!.play();
                  showModalBottomSheet(
                    enableDrag: true,
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: const Color.fromRGBO(0, 0, 0, 0.2),
                    builder: (context) => videoTemplate(
                        _templatesInAppData.content!.title,
                        _templatesInAppData.content!.text,
                        _templatesInAppData.content!.video,
                        _templatesInAppData.content!.action!.value,
                        _templatesInAppData.id),
                  ).then((value) {
                    _videoController?.pause();
                  });

                  inApp.recordViewForInAppMessage(_templatesInAppData.id!);

                  videoSetState();
                });
        }
      } catch (err) {
        dev.log('Video banner has no available data.', name: tag);
        return;
      }
    }
  }

  videoRend() {
    try {
      _videoController = VideoPlayerController.network(
          _templatesInAppData.content!.video)
        ..addListener(() {
          final bool isPlaying = _videoController!.value.isPlaying;

          videoSetState(playingNow: isPlayingNow);

          videoSetState(playingNow: isPlayingNow, currentlyPlaying: isPlaying);
        })
        ..initialize().then((_) {
          videoSetState();
        });
    } catch (err) {
      dev.log('video load error: $err', name: tag);
    }
  }

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

  videoTemplate(title, message, video, url, templateId) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return DraggableScrollableSheet(
          initialChildSize: 1,
          builder: (_, controller) => BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.08),
                    child: InkWell(
                        onTap: () {
                          inApp.clickInApp(templateId);
                          inApp.deleteInApp(templateId);
                          clearBannerAndReload();
                          _videoController!.pause();

                          Navigator.popUntil(
                              context, ModalRoute.withName('/in-app'));

                          urlLauncher(url);
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).size.height *
                                      0.05),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _videoController!.pause();
                                      videoSetState();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Center(
                                    child: AspectRatio(
                                  aspectRatio:
                                      _videoController!.value.aspectRatio,
                                  child: VideoPlayer(_videoController!),
                                )),
                                if (_videoController!.value.isInitialized) ...[
                                  AspectRatio(
                                    aspectRatio:
                                        _videoController!.value.aspectRatio,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.transparent,
                                        onPrimary: Colors.white,
                                        shadowColor: Colors.transparent,
                                      ),
                                      onPressed: () {
                                        videoSetState(
                                            videoController: _videoController!);
                                      },
                                      child: AnimatedBuilder(
                                        animation: _videoController!,
                                        builder: (context, child) {
                                          return iconSequence();
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 50.0),
                              child: Column(
                                children: [
                                  Text(
                                    '$title',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  const Divider(
                                    color: Colors.white,
                                    height: 10,
                                  ),
                                  Text('$message',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      )),
                                ],
                              ),
                            )
                          ],
                        ))),
              ));
    }
    return Container(
      alignment: Alignment.topCenter,
      child: Stack(fit: StackFit.expand, children: [
        AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!))
      ]),
    );
  }
}
