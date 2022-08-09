part of 'package:ca_mce_flutter_sdk_sample/in_app.dart';

extension Execute on _InAppState {
  Widget execute() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 40, bottom: 10, left: 10),
          child: const SafeArea(
            bottom: false,
            child: Text(
              'EXECUTE INAPP',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            getInAppMessages(["bottomBanner"]).then((value) {
              timer = Timer(const Duration(milliseconds: 75), () {
                inAppBottomTemplate();
              });
            });
          },
          child: const InAppButtonContainer(
            buttonTitle: 'Bottom Banner Template',
          ),
        ),
        InkWell(
          onTap: () {
            getInAppMessages(["topBanner"]).then((_) {
              timer = Timer(const Duration(milliseconds: 75), () {
                inAppTopTemplate();
              });
            });
          },
          child: const InAppButtonContainer(
            buttonTitle: 'Top Banner Template',
          ),
        ),
        InkWell(
          onTap: () {
            getInAppMessages(["image"]).then((_) {
              timer = Timer(const Duration(milliseconds: 75), () {
                createImageBanner();
              });
            });
          },
          child: const InAppButtonContainer(
            buttonTitle: 'Image Banner Template',
          ),
        ),
        InkWell(
          onTap: () {
            getInAppMessages(["video"]).then((_) {
              timer = Timer(const Duration(milliseconds: 75), () {
                inAppVideoTemplate();
              });
            });
          },
          child: const InAppButtonContainer(
            buttonTitle: 'Video Banner Template',
          ),
        ),
        InkWell(
          onTap: () {
            getInAppMessages(["all"]).then((_) {
              timer = Timer(const Duration(milliseconds: 75), () {
                createNextBanner();
              });
            });
          },
          child: const InAppButtonContainer(
            buttonTitle: 'Next Banner Template',
          ),
        ),
      ],
    );
  }
}
