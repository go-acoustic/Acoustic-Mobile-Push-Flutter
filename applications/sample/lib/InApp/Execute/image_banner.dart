part of 'package:ca_mce_flutter_sdk_sample/in_app.dart';

extension ImageBanner on _InAppState {
  createImageBanner() {
    if (_templatesInAppData != null &&
        messageViewCounter() &&
        checkTemplateOrientation("image")) {
      bool isOpen;
      try {
        isOpen = true;
        dev.log("Create Image Banner", name: tag);

        if (_templatesInAppData.content?.action!.value != null) {
          showModalBottomSheet(
            enableDrag: true,
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            backgroundColor: const Color.fromRGBO(0, 0, 0, 0.2),
            builder: (context) => ImageTemplate(
              _templatesInAppData.content!.title,
              _templatesInAppData.content!.text,
              _templatesInAppData.content!.image,
              _templatesInAppData.content!.action!.value,
              _templatesInAppData.id,
            ),
          ).then((_) => isOpen = false);

          t = Timer(Duration(seconds: _templatesInAppData.content!.duration),
              () {
            if (isOpen == true) {
              Navigator.pop(context);
            }
          });
        }
        inApp.recordViewForInAppMessage(_templatesInAppData.id!);
      } catch (err) {
        dev.log('Image banner has no available data.', name: tag);

        return;
      }
    }
  }

  // update in next patch
  // ignore: non_constant_identifier_names
  ImageTemplate(title, message, image, url, templateId) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return DraggableScrollableSheet(
        initialChildSize: 1,
        builder: (_, controller) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            padding: const EdgeInsets.only(top: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      inApp.clickInApp(templateId);
                      inApp.deleteInApp(templateId);
                      clearBannerAndReload();

                      Navigator.popUntil(
                          context, ModalRoute.withName('/in-app'));

                      urlLauncher(url);
                    },
                    child: Image.network(
                      '$image',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: Column(
                    children: [
                      Text(
                        '$title',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      const Divider(
                        color: Colors.white,
                        height: 10,
                      ),
                      SizedBox(
                        height: 125,
                        child: ListView(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                '$message',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Container(
      alignment: Alignment.topCenter,
      child: Stack(fit: StackFit.expand, children: [
        InkWell(
          onTap: () {
            inApp.clickInApp(templateId);
            inApp.deleteInApp(templateId);
            clearBannerAndReload();

            Navigator.popUntil(context, ModalRoute.withName('/in-app'));

            urlLauncher(url);
          },
          child: Image.network(
            '$image',
            fit: BoxFit.fitWidth,
          ),
        ),
      ]),
    );
  }
}
