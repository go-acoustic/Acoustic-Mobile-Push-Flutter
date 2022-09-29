import 'dart:ui';
import 'package:ca_mce_flutter_sdk_sample/InApp/inapp_button_container.dart';
import 'package:ca_mce_flutter_sdk_sample/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_acoustic_mobile_push_inapp/flutter_acoustic_mobile_push_inapp.dart';
import 'package:flutter_acoustic_mobile_push_inapp/flutter_in_app_pay_load.dart'
    as inapp_pay_load;
import 'package:flutter_acoustic_mobile_push_inapp/flutter_in_app_pay_load.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/layouts/message_layout.dart';
import 'package:video_player/video_player.dart';
import 'dart:developer' as dev;

part 'package:ca_mce_flutter_sdk_sample/InApp/Execute/banner_data.dart';
part 'package:ca_mce_flutter_sdk_sample/InApp/Execute/bottom_banner.dart';
part 'package:ca_mce_flutter_sdk_sample/InApp/Execute/top_banner.dart';
part 'package:ca_mce_flutter_sdk_sample/InApp/Execute/video_banner.dart';
part 'package:ca_mce_flutter_sdk_sample/InApp/Execute/image_banner.dart';
part 'package:ca_mce_flutter_sdk_sample/InApp/Execute/next_banner.dart';
part 'package:ca_mce_flutter_sdk_sample/InApp/inapp_add_canned.dart';
part 'package:ca_mce_flutter_sdk_sample/InApp/inapp_execute.dart';

class InApp extends StatefulWidget {
  const InApp({Key? key}) : super(key: key);

  @override
  State<InApp> createState() => _InAppState();
}

class _InAppState extends State<InApp> {
  String? videoBanUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

  VideoPlayerController? _videoController;
  Icon videoButton = const Icon(Icons.pause);
  int timesViewed = 0;
  bool isPlayingNow = false;
  bool hasStartedNow = false;
  bool isPausedNow = false;
  bool shouldSyncNow = false;
  dynamic t;
  Timer? timer;
  Timer? videoTimer;
  String tag = "InApp";

  var pauseIcon = const Visibility(
    child: Icon(
      Icons.pause,
      color: Color.fromRGBO(255, 255, 255, 0.4),
      size: 50,
    ),
    visible: true,
  );
  dynamic data;
  var templateIndex = 0;
  dynamic _templatesInAppData;
  var counter = 0;

  var bottomRule = inapp_pay_load.InAppMessage(
    rules: <String>["bottomBanner", "all"],
    maxViews: 5,
    template: "default",
    content: inapp_pay_load.TemplateContent(
        orientation: "bottom",
        action: inapp_pay_load.Action(
            type: "url", value: "http://www.acoustic.com"),
        text: "Bottom Banner Template Text",
        duration: 5,
        mainImage:
            "https://thumbs.dreamstime.com/b/sunset-beach-sunrays-133301221.jpg",
        icon: "note",
        color: "#0077FF",
        foreground: "#000000"),
    expirationDate:
        DateTime.now().add(const Duration(days: 1)).toIso8601String(),
    triggerDate:
        DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
  );

  var topRule = inapp_pay_load.InAppMessage(
    rules: <String>["topBanner", "all"],
    maxViews: 5,
    template: "default",
    content: inapp_pay_load.TemplateContent(
        orientation: "top",
        action: inapp_pay_load.Action(
            type: "url", value: "http://www.acoustic.com"),
        text: "Top Banner Template Text",
        duration: 5,
        mainImage:
            "https://thumbs.dreamstime.com/b/sunset-beach-sunrays-133301221.jpg",
        icon: "note",
        color: "#0077FF",
        foreground: "#000000"),
    expirationDate:
        DateTime.now().add(const Duration(days: 1)).toIso8601String(),
    triggerDate:
        DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
  );

  var imageRule = inapp_pay_load.InAppMessage(
    rules: <String>["image", "all"],
    maxViews: 5,
    template: "image",
    content: inapp_pay_load.TemplateContent(
      image: "https://cdn3.dpmag.com/2020/09/9-14-Autumn-Sunset-A.jpg",
      action:
          inapp_pay_load.Action(type: "url", value: "http://www.acoustic.com"),
      title: "This is an Image title",
      text: "Image Banner Template Text",
      duration: 5,
    ),
    expirationDate:
        DateTime.now().add(const Duration(days: 1)).toIso8601String(),
    triggerDate:
        DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
  );

  var videoRule = inapp_pay_load.InAppMessage(
    rules: <String>["video", "all"],
    maxViews: 5,
    template: "video",
    content: inapp_pay_load.TemplateContent(
      video:
          "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
      action:
          inapp_pay_load.Action(type: "url", value: "http://www.acoustic.com"),
      title: "This is a Video title",
      text: "Video Banner Template Text",
    ),
    expirationDate:
        DateTime.now().add(const Duration(days: 1)).toIso8601String(),
    triggerDate:
        DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
  );

  var inApp = InAppMessageValue();

  getUpdatedInAppMessageList() {
    dev.log('Refreshing Data...', name: tag);

    inApp.inAppMessage.subscribe((args) {
      var data = args!.inAppMessage;
      setState(() {
        _templatesInAppData = data;

        dev.log('InApp Data: $_templatesInAppData', name: tag);
        shouldSyncNow = false;
      });
    });
    if (_templatesInAppData == null) {
      shouldSyncNow = true;
    }
  }

  @override
  void initState() {
    super.initState();
    inApp.getInAppList();
    getInAppMessages(["all"]);
    getUpdatedInAppMessageList();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  urlLauncher(url) async {
    await Message().launchAction(url);
  }

  clearBannerAndReload() {
    _templatesInAppData?.numViews = _templatesInAppData?.maxViews;
    inApp.getInAppList();
    getInAppMessages(["all"]);
    getUpdatedInAppMessageList();
  }

  bool messageViewCounter() {
    if (_templatesInAppData?.numViews != null &&
        _templatesInAppData?.maxViews != null) {
      var templateNumViews = _templatesInAppData!.numViews;
      var templateMaxViews = _templatesInAppData!.maxViews;

      if (templateNumViews >= (templateMaxViews - 1)) {
        setState(() {
          dev.log("Data cleared", name: tag);
          _templatesInAppData = null;
          shouldSyncNow = true;
        });
        return false;
      }
    }
    return true;
  }

  bool checkTemplateOrientation(String banner) {
    if (_templatesInAppData?.rules != null) {
      if (_templatesInAppData?.rules.contains(banner)) {
        return true;
      }
    }
    return false;
  }

  Future<void> callback() async {
    inApp.inAppMessage.subscribe((args) {
      var data = args!.inAppMessage;
      setState(() {
        _templatesInAppData = data;
      });
    });
  }

  videoSetState(
      {bool? playingNow,
      bool? currentlyPlaying,
      VideoPlayerController? videoController}) {
    if (playingNow != null) {
      if (playingNow && currentlyPlaying == null) {
        setState(() {
          hasStartedNow = true;
          isPausedNow = false;
        });
      } else if (currentlyPlaying != null) {
        if (currentlyPlaying != playingNow) {
          setState(() {
            isPlayingNow = currentlyPlaying;
            if (hasStartedNow && !isPlayingNow) {
              isPausedNow = true;
            }
          });
        }
      }
    }

    if (videoController != null) {
      setState(() {
        if (videoController.value.isPlaying) {
          _videoController!.pause();
        } else {
          _videoController!.play();
        }
      });
    }
    if (playingNow == null &&
        currentlyPlaying == null &&
        videoController == null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: const Text(
          'InApp Messages',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              Navigator.of(context).pop();
            }),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.sync,
              color: Colors.black,
            ),
            onPressed: () {
              if (shouldSyncNow) {
                inApp.getInAppList();
                getInAppMessages(["all"]);
                getUpdatedInAppMessageList();
              } else {
                dev.log("Unable to sync as there are items in the queue",
                    name: tag);
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: appBackgroundGradient,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [execute(), addCanned()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _videoController?.dispose();
    _templatesInAppData = null;
    if (t != null) {
      t.cancel();
    }
    if (timer != null) {
      timer!.cancel();
    }
    if (videoTimer != null) {
      videoTimer!.cancel();
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
