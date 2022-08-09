part of 'package:ca_mce_flutter_sdk_sample/in_app.dart';

extension BannerData on _InAppState {
  Future<void> getInAppMessages(List<String> rules) async {
    for (String ruleName in rules) {
      inApp.getInAppMessage([ruleName]);
    }
  }

  sendCannedInApp(InAppMessage eventPayLoad) {
    FlutterAcousticMobilePushInapp.sendCannedInAppContent(eventPayLoad);
  }
}
