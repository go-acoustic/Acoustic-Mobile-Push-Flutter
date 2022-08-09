part of 'package:ca_mce_flutter_sdk_sample/in_app.dart';

extension TopBanner on _InAppState {
  topBan(text, bgColor, bgImage, url, templateId, secondsDuration) {
    double bannerHeight = 52;
    double screenWidth = MediaQuery.of(context).size.width / 1.25;

    timer = Timer(Duration(seconds: secondsDuration), (() {
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    }));

    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        leadingPadding: const EdgeInsets.all(0),
        padding: const EdgeInsets.all(0),
        overflowAlignment: OverflowBarAlignment.start,
        backgroundColor: Colors.blue,
        content: Stack(
          fit: StackFit.loose,
          clipBehavior: Clip.hardEdge,
          children: [
            InkWell(
              child: Container(
                width: screenWidth,
                height: bannerHeight,
                padding: const EdgeInsets.all(0),
                margin: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  image: DecorationImage(
                      alignment: const Alignment(0, 0),
                      image: bgImage != null
                          ? NetworkImage('$bgImage')
                          : const NetworkImage(''),
                      fit: BoxFit.cover),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 245,
                      child: Text(
                        text == null ? '' : '$text',
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                inApp.clickInApp(templateId);
                inApp.deleteInApp(templateId);
                clearBannerAndReload();
                ScaffoldMessenger.of(context).clearMaterialBanners();
                if (timer != null) {
                  timer!.cancel();
                }

                urlLauncher(url);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (timer != null) {
                timer!.cancel();
              }

              ScaffoldMessenger.of(context).clearMaterialBanners();
            },
            child: const Icon(
              Icons.close,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  inAppTopTemplate() {
    var inApp = InAppMessageValue();

    if (_templatesInAppData != null &&
        messageViewCounter() &&
        checkTemplateOrientation("topBanner")) {
      try {
        dev.log("Create Top Banner", name: tag);
        ScaffoldMessenger.of(context).clearMaterialBanners();
        if (timer != null) {
          timer!.cancel();
        }

        topBan(
            _templatesInAppData.content!.text,
            _templatesInAppData.content!.color,
            _templatesInAppData.content!.mainImage,
            _templatesInAppData.content!.action!.value,
            _templatesInAppData.id,
            _templatesInAppData!.content.duration);

        inApp.recordViewForInAppMessage(_templatesInAppData.id!);
      } catch (err) {
        dev.log('Top banner has no available data.', name: tag);
        return;
      }
    }
  }
}
