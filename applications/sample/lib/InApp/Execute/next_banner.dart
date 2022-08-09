part of 'package:ca_mce_flutter_sdk_sample/in_app.dart';

extension NextBanner on _InAppState {
  createNextBanner() {
    try {
      var templateType = _templatesInAppData?.template;

      if (_templatesInAppData != null &&
          templateType == 'default' &&
          _templatesInAppData?.rules.contains("topBanner")) {
        inAppTopTemplate();
      } else if (_templatesInAppData != null &&
          templateType == 'default' &&
          _templatesInAppData?.rules.contains("bottomBanner")) {
        inAppBottomTemplate();
      } else if (_templatesInAppData != null &&
          _templatesInAppData?.rules.contains("image")) {
        createImageBanner();
      } else if (_templatesInAppData != null &&
          _templatesInAppData?.rules.contains("video")) {
        inAppVideoTemplate();
      }
    } catch (err) {
      dev.log('Ran out of queued list items', name: tag);
      dev.log('$err', name: tag);
    }
  }
}
