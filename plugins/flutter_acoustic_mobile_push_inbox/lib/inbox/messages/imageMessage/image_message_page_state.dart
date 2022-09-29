import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_inbox/flutter_acoustic_mobile_push_inbox.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/imageMessage/models/image_message_page.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/layouts/message_layout.dart';

class ImageMessagePageState extends State<ImageMessagePage> {
  String tag = "Inbox";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            InboxMessageValue().readInboxMessage(widget.imageMessagePageId);
            Navigator.pop(context, true);
          },
        ),
        title: Text(
          widget.imageMessagePageTitle,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          Message().kebabMenu(
            context,
            widget.imageMessagePageId,
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: ListView(
          children: [
            SafeArea(
              child: Column(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Message().header(
                          widget.imageMessagePageAvatar,
                          widget.imageMessagePageDate,
                          widget.imageMessagePageTitle),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 20),
                        child: Text(
                          widget.imageMessagePageBody,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Message().image(widget.imageMessagePageContent, false),
                      Message().actionButtons(
                        widget.imageActionList[0].name,
                        widget.imageActionList[2].name,
                        widget.imageActionList[1].name,
                        widget.imageActionList,
                        widget.imageMessagePageId,
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
