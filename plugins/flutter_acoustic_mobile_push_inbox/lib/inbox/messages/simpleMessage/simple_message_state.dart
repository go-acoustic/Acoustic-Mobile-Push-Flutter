import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/simpleMessage/simple_message_page.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/simpleMessage/simple_message.dart';
import '../../../constants.dart';
import '../../../flutter_acoustic_mobile_push_inbox.dart';

class SimpleMessageState extends State<SimpleMessage> {
  var inboxNotificationPushCounter = 0;
  bool isReadViewer = true;
  bool isExpired = false;

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
                  builder: (context) => SimpleMessagePage(
                        simpleMessagePageTitle: widget.messageTitle,
                        simpleMessagePageBody: widget.messageBody,
                        simpleMessagePageDate: widget.messageDate,
                        simpleMessagePageContent: widget.messageContent,
                        simpleMessagePageId: widget.messageId,
                        simpleMessagePageInboxDeleteMessage:
                            widget.inboxDeleteMessage,
                        simpleActionList: widget.action,
                        updateIsReadViewer: updateIsReadViewer,
                      )));
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
                builder: (context) => SimpleMessagePage(
                      simpleMessagePageTitle: widget.messageTitle,
                      simpleMessagePageBody: widget.messageBody,
                      simpleMessagePageDate: widget.messageDate,
                      simpleMessagePageContent: widget.messageContent,
                      simpleMessagePageId: widget.messageId,
                      simpleMessagePageInboxDeleteMessage:
                          widget.inboxDeleteMessage,
                      simpleActionList: widget.action,
                      updateIsReadViewer: updateIsReadViewer,
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
                              : Colors.cyan)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                          widget.messageBody,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: const TextStyle(
                            color: messageBodyColor,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_forward_ios_sharp,
                        color: isExpired
                            ? disableTextMessageBackgroundColor
                            : Colors.black,
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
