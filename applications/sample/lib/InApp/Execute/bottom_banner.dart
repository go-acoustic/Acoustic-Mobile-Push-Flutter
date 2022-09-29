part of 'package:ca_mce_flutter_sdk_sample/in_app.dart';

extension BottomBanner on _InAppState {
  bottomBan(text, bgColor, bgImage, url, templateId, durationSeconds) {
    double screenWidth = MediaQuery.of(context).size.width / 1.25;
    double leftoverWidth = MediaQuery.of(context).size.width - screenWidth;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: durationSeconds),
        elevation: 2,
        backgroundColor: const Color.fromRGBO(14, 114, 101, 1),
        padding: const EdgeInsets.all(0),
        content: Stack(
          fit: StackFit.loose,
          clipBehavior: Clip.hardEdge,
          children: [
            Row(
              children: [
                InkWell(
                    child: Container(
                      width: screenWidth,
                      height: 50,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            alignment: const Alignment(-.2, 0),
                            image: bgImage != null
                                ? NetworkImage('$bgImage')
                                : const NetworkImage(''),
                            fit: BoxFit.cover),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 250,
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
                      ScaffoldMessenger.of(context).clearSnackBars();
                      urlLauncher(url);
                    }),
                TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white,
                      minimumSize: Size(leftoverWidth, 50),
                      padding: const EdgeInsets.all(0),
                      backgroundColor: Colors.blue),
                  onPressed: () {
                    ScaffoldMessenger.of(context).clearSnackBars();
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  inAppBottomTemplate() {
    ScaffoldMessenger.of(context).clearSnackBars();

    if (messageViewCounter() && checkTemplateOrientation("bottomBanner")) {
      try {
        dev.log("Create Bottom Banner", name: tag);

        bottomBan(
            _templatesInAppData.content!.text,
            _templatesInAppData.content!.color,
            _templatesInAppData.content!.mainImage,
            _templatesInAppData.content!.action!.value,
            _templatesInAppData.id,
            _templatesInAppData.content!.duration);
        inApp.recordViewForInAppMessage(_templatesInAppData.id!);
      } catch (err) {
        dev.log('Bottom banner has no available data.', name: tag);
      }
    }
  }
}
