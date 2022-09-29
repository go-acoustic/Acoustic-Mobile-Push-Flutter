import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_inbox/constants.dart';
import 'package:flutter_acoustic_mobile_push_inbox/flutter_acoustic_mobile_push_inbox.dart';
import 'package:flutter_acoustic_mobile_push_inbox/flutter_inbox_pay_load.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/inbox_messages.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as dev;

class Message extends InboxState {
  Widget previewHeader(String date, String title, String subtitle,
      bool isExpired, bool isRead, bool? isReadViewer, double messageTextWidth,
      {String avatar = ""}) {
    String tag = "MessageHeader";

    boldText() {
      if (isReadViewer != null) {
        if (isReadViewer) {
          return FontWeight.normal;
        }
        return FontWeight.bold;
      }

      if (isRead) {
        return FontWeight.normal;
      }

      return FontWeight.bold;
    }

    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(date,
              style: TextStyle(
                  color: isExpired
                      ? disableTextMessageBackgroundColor
                      : Colors.cyan),
              textAlign: TextAlign.right),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (avatar.isNotEmpty) ...[
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: avatar.contains(".mp4")
                        ? const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(Icons.person))
                        : CachedNetworkImage(
                            imageUrl: avatar,
                            color: isExpired
                                ? Colors.white.withOpacity(0.5)
                                : Colors.white.withOpacity(1.0),
                            colorBlendMode: BlendMode.modulate,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, error, stackTrace) {
                              dev.log('Issue loading avatar image: $error',
                                  name: tag);
                              return const Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(Icons.person));
                            }),
                  ),
                ),
              ],
              SizedBox(
                width: messageTextWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isExpired
                            ? disableTextMessageBackgroundColor
                            : messageTitleColor,
                        fontWeight: boldText(),
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(
                        color: isExpired
                            ? disableTextMessageBackgroundColor
                            : messageBodyColor,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.arrow_forward_ios_sharp,
                  color: isExpired
                      ? disableTextMessageBackgroundColor
                      : Colors.black),
            ],
          ),
        ],
      )
    ]);
  }

  Widget header(String avatar, String date, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: SizedBox(
                child: avatar.contains(".mp4")
                    ? const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(Icons.person))
                    : CachedNetworkImage(
                        imageUrl: avatar,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                CircularProgressIndicator(
                                    value: downloadProgress.progress),
                        errorWidget: (context, error, stackTrace) {
                          dev.log('Issue loading avatar image: $error',
                              name: tag);
                          return const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(Icons.person));
                        }),
              ),
            ),
            Text(date,
                style: const TextStyle(color: Colors.cyan),
                textAlign: TextAlign.right),
          ],
        ),
        Container(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            title,
            textAlign: TextAlign.left,
            overflow: TextOverflow.clip,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        const Divider(
          height: 20,
          thickness: 0.5,
          color: Colors.black,
        ),
      ],
    );
  }

  Widget image(String url, bool isExpired) {
    return CachedNetworkImage(
      color: isExpired
          ? Colors.white.withOpacity(0.5)
          : Colors.white.withOpacity(1.0),
      colorBlendMode: BlendMode.modulate,
      imageUrl: url,
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          CircularProgressIndicator(value: downloadProgress.progress),
      errorWidget: (context, error, stackTrace) {
        dev.log('Issue loading image: $error', name: tag);
        return const Center(
          child: Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.image_not_supported_outlined)),
        );
      },
    );
  }

  launchAction(String actionValue) async {
    try {
      if (actionValue.contains("http")) {
        var index = actionValue.indexOf("//");
        String link = actionValue.substring(index);
        final Uri launchUri = Uri(
          scheme: 'https',
          path: link,
        );
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        final Uri launchUri = Uri(
          scheme: 'tel',
          path: actionValue,
        );
        await launchUrl(launchUri);
      }
    } catch (err) {
      dev.log("$err", name: tag);
    }
  }

  Widget actionButtons(String leftButtonName, String centerButtonName,
      String rightButtonName, List<MessageActions> action, String messageId,
      {bool isExpired = false}) {
    var inbox = InboxMessageValue();

    buttonAction(int index) async {
      String type = action[index].type;
      if (type == "url" || type == "dial") {
        inbox.clickInboxAction(jsonEncode(action[index]), messageId);

        await launchAction(action[index].value);
      } else {
        dev.log('unrecognized data value', name: tag);
      }
    }

    return Row(children: [
      Expanded(
        flex: 1,
        child: TextButton(
          onPressed: isExpired
              ? null
              : () {
                  buttonAction(0);
                },
          child: Text(
            leftButtonName.isEmpty ? 'Left' : leftButtonName,
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: TextButton(
          onPressed: isExpired
              ? null
              : () {
                  buttonAction(2);
                },
          child: Text(
            centerButtonName.isEmpty ? 'Center' : centerButtonName,
          ),
        ),
      ),
      Expanded(
        child: TextButton(
          onPressed: isExpired
              ? null
              : () {
                  buttonAction(1);
                },
          child: Text(
            rightButtonName.isEmpty ? 'Right' : rightButtonName,
          ),
        ),
      )
    ]);
  }

  Widget kebabMenu(context, String id) {
    var inbox = InboxMessageValue();
    List<DropdownMenuItem<Object>> menuItems = [
      DropdownMenuItem(
        child: const Text("Read"),
        value: 'Read',
        onTap: () {
          dev.log('message read', name: tag);
          inbox.readInboxMessage(id);
        },
      ),
      DropdownMenuItem(
        child: const Text("Unread"),
        value: 'Unread',
        onTap: () {
          dev.log('message unread', name: tag);
          inbox.unreadInboxMessage(id);
        },
      ),
      DropdownMenuItem(
        child: const Text("Delete"),
        value: 'Delete',
        onTap: () {
          dev.log('message delete', name: tag);
          InboxMessageValue().deleteMessage(id);
        },
      ),
    ];
    return DropdownButtonHideUnderline(
      child: DropdownButton(
        style: const TextStyle(fontSize: 12, color: Colors.black),
        icon: const Icon(Icons.more_vert),
        items: menuItems,
        onChanged: (value) {
          Navigator.pop(context, value.toString());
        },
      ),
    );
  }
}
