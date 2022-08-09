part of 'package:ca_mce_flutter_sdk_sample/in_app.dart';

extension AddCanned on _InAppState {
  Widget addCanned() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SafeArea(
          bottom: false,
          child: Container(
            padding: const EdgeInsets.only(top: 40, bottom: 10, left: 10),
            child: const Text(
              'ADD CANNED INAPP',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            dev.log("Submitting bottom banner data", name: tag);
            sendCannedInApp(bottomRule);
          },
          child: const InAppButtonContainer(
            buttonTitle: 'Bottom Banner Template',
          ),
        ),
        InkWell(
          onTap: () {
            dev.log("Submitting top banner data", name: tag);
            sendCannedInApp(topRule);
          },
          child: const InAppButtonContainer(
            buttonTitle: 'Top Banner Template',
          ),
        ),
        InkWell(
          onTap: () {
            dev.log("Submitting image banner data", name: tag);
            sendCannedInApp(imageRule);
          },
          child: const InAppButtonContainer(
            buttonTitle: 'Image Banner Template',
          ),
        ),
        InkWell(
          onTap: () {
            dev.log("Submitting video banner data", name: tag);
            sendCannedInApp(videoRule);
          },
          child: const InAppButtonContainer(
            buttonTitle: 'Video Banner Template',
          ),
        )
      ],
    );
  }
}
