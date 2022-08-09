import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_inbox/constants.dart';
import 'package:flutter_acoustic_mobile_push_inbox/flutter_acoustic_mobile_push_inbox.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/imageMessage/image_message_page.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/imageMessage/image_message.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as dev;

class ImageMessageState extends State<ImageMessage> {
  var inbox = InboxMessageValue();
  var inboxNotificationPushCounter = 0;

  bool isReadViewer = true;
  bool isExpired = false;

  String tag = "Inbox";
  updateIsReadViewer(value) {
    setState(() {
      isReadViewer = value;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isExpired = widget.isExpired;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 50), () async {
      if ((widget.notificationId != null) &&
          (widget.notificationId == widget.messageId)) {
        if (inboxNotificationPushCounter == 0) {
          setState(() {
            inboxNotificationPushCounter = inboxNotificationPushCounter + 1;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImageMessagePage(
                      imageMessagePageTitle: widget.messageTitle,
                      imageMessagePageBody: widget.messageBody,
                      imageMessagePageDate: widget.messageDate,
                      imageMessagePageAvatar: widget.messageAvatar,
                      imageMessagePageContent: widget.messageContent,
                      imageMessagePageId: widget.messageId,
                      imageMessagePageInboxDeleteMessage:
                          widget.inboxDeleteMessage,
                      updateIsReadViewer: updateIsReadViewer,
                      imageActionList: widget.action,
                    )),
          );
          var inbox = InboxMessageValue();
          inbox.readInboxMessage(widget.messageId);
          updateIsReadViewer(true);
        } else {
          return;
        }
      }
    });

    buttonAction(int index) {
      String type = widget.action[index]["type"];
      if (type == "url" || type == "dial") {
        inbox.clickInboxAction(
            jsonEncode(widget.action[index]), widget.messageId);
        String action = "";
        if (type == "dial") {
          action = "tel://";
        }
        launch(action + widget.action[index]["value"],
            forceSafariVC: false, forceWebView: false);
      } else {
        dev.log('unrecognized data value', name: tag);
      }
    }

    return SafeArea(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImageMessagePage(
                      imageMessagePageTitle: widget.messageTitle,
                      imageMessagePageBody: widget.messageBody,
                      imageMessagePageDate: widget.messageDate,
                      imageMessagePageAvatar: widget.messageAvatar,
                      imageMessagePageContent: widget.messageContent,
                      imageMessagePageId: widget.messageId,
                      imageMessagePageInboxDeleteMessage:
                          widget.inboxDeleteMessage,
                      updateIsReadViewer: updateIsReadViewer,
                      imageActionList: widget.action,
                    )),
          );
          var inbox = InboxMessageValue();
          inbox.readInboxMessage(widget.messageId);
          updateIsReadViewer(true);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isExpired
                ? disableMessageBackgroundColor
                : messageBackgroundColor,
            border: Border.all(
              width: 0.25,
              color: Colors.grey,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(widget.messageDate,
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
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.network(widget.messageAvatar,
                              color: isExpired
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.white.withOpacity(1.0),
                              colorBlendMode: BlendMode.modulate,
                              errorBuilder: (context, error, stackTrace) {
                            dev.log('Issue loading avatar image', name: tag);
                            return const Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(Icons.person));
                          }),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.messageTitle,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isExpired
                                    ? disableTextMessageBackgroundColor
                                    : messageTitleColor,
                                fontWeight: (widget.isRead && isReadViewer)
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              widget.messageSubtitle,
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
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: Image.network(widget.messageContent,
                    fit: BoxFit.contain,
                    color: isExpired
                        ? Colors.white.withOpacity(0.5)
                        : Colors.white.withOpacity(1.0),
                    colorBlendMode: BlendMode.modulate,
                    errorBuilder: (context, error, stackTrace) {
                  dev.log('Issue loading avatar image', name: tag);
                  return const Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Icon(Icons.image_not_supported_outlined));
                }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  isExpired
                      ? Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Text(
                            widget.action[0]["name"].isEmpty
                                ? 'Left'
                                : widget.action[0]["name"],
                            style: const TextStyle(
                                color: disableTextMessageBackgroundColor),
                          ),
                        )
                      : TextButton(
                          onPressed: () {
                            buttonAction(0);
                          },
                          child: Text(
                            widget.action[0]["name"].isEmpty
                                ? 'Left'
                                : widget.action[0]["name"],
                          ),
                        ),
                  isExpired
                      ? Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Text(
                            widget.action[2]["name"].isEmpty
                                ? 'Center'
                                : widget.action[2]["name"],
                            style: const TextStyle(
                                color: disableTextMessageBackgroundColor),
                          ),
                        )
                      : TextButton(
                          onPressed: () {
                            buttonAction(2);
                          },
                          child: Text(
                            widget.action[2]["name"].isEmpty
                                ? 'Center'
                                : widget.action[2]["name"],
                          ),
                        ),
                  isExpired
                      ? Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Text(
                            widget.action[1]["name"].isEmpty
                                ? 'Right'
                                : widget.action[1]["name"],
                            style: const TextStyle(
                                color: disableTextMessageBackgroundColor),
                          ),
                        )
                      : TextButton(
                          onPressed: () {
                            buttonAction(1);
                          },
                          child: Text(
                            widget.action[1]["name"].isEmpty
                                ? 'Right'
                                : widget.action[1]["name"],
                          ),
                        ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
