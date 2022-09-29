import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_inbox/constants.dart';
import 'package:flutter_acoustic_mobile_push_inbox/flutter_acoustic_mobile_push_inbox.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/imageMessage/models/image_message_page.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/imageMessage/models/image_message.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/layouts/message_layout.dart';

class ImageMessagePreview extends State<ImageMessage> {
  var inbox = InboxMessageValue();
  var inboxNotificationPushCounter = 0;

  bool? isReadViewer;
  bool isExpired = false;
  bool isVisible = true;

  String tag = "Inbox";
  updateIsReadViewer(value) {
    setState(() {
      isReadViewer = value;
    });
  }

  dropDownMenuAction(String value) {
    if (value == "Read") {
      updateIsReadViewer(true);
    } else if (value == "Unread") {
      updateIsReadViewer(false);
    } else {
      setState(() {
        isVisible = false;
      });
    }
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
    if (isVisible) {
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
                        imageActionList: widget.action,
                      )),
            ).then((value) {
              if (value is String) {
                dropDownMenuAction(value);
              }
            });
            var inbox = InboxMessageValue();
            inbox.readInboxMessage(widget.messageId);
            updateIsReadViewer(true);
          } else {
            return;
          }
        }
      });

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
                            imageActionList: widget.action,
                          )),
                ).then((value) {
                  if (value is String) {
                    dropDownMenuAction(value);
                  }
                });
                var inbox = InboxMessageValue();
                inbox.readInboxMessage(widget.messageId);
                updateIsReadViewer(true);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isExpired
                      ? disableMessageBackgroundColor
                      : messageBackgroundColor,
                  border: const Border(
                      bottom: BorderSide(
                    color: Colors.grey,
                  )),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Message().previewHeader(
                        widget.messageDate,
                        widget.messageTitle,
                        widget.messageBody,
                        isExpired,
                        widget.isRead,
                        isReadViewer,
                        MediaQuery.of(context).size.width * .6,
                        avatar: widget.messageAvatar),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Message()
                          .image(widget.messageContent, widget.isExpired),
                    ),
                    Message().actionButtons(
                      widget.action[0].name,
                      widget.action[2].name,
                      widget.action[1].name,
                      widget.action,
                      widget.messageId,
                      isExpired: isExpired,
                    )
                  ],
                ),
              )));
    } else {
      return const SizedBox.shrink();
    }
  }
}
