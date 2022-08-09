import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/imageMessage/image_message_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../flutter_acoustic_mobile_push_inbox.dart';
import 'dart:developer' as dev;

class ImageMessagePageState extends State<ImageMessagePage> {
  String tag = "Inbox";
  @override
  Widget build(BuildContext context) {
    var inbox = InboxMessageValue();
    kebabMenu() {
      List<DropdownMenuItem<Object>> menuItems = [
        DropdownMenuItem(
          child: const Text("Read"),
          value: 'Read',
          onTap: () {
            dev.log('read', name: tag);
            Navigator.pop(context);
            inbox.readInboxMessage(widget.imageMessagePageId);
            widget.updateIsReadViewer(true);
          },
        ),
        DropdownMenuItem(
          child: const Text("Unread"),
          value: 'Unread',
          onTap: () {
            dev.log('unread', name: tag);
            Navigator.pop(context);
            inbox.unreadInboxMessage(widget.imageMessagePageId);
            widget.updateIsReadViewer(false);
          },
        ),
        DropdownMenuItem(
          child: const Text("Delete"),
          value: 'Delete',
          onTap: () {
            Navigator.pop(context);
            widget.imageMessagePageInboxDeleteMessage();
          },
        ),
      ];
      return DropdownButtonHideUnderline(
        child: DropdownButton(
          style: const TextStyle(fontSize: 12, color: Colors.black),
          icon: const Icon(Icons.more_vert),
          items: menuItems,
          onChanged: (x) {
            setState(() {});
          },
        ),
      );
    }

    buttonAction(int index) {
      String type = widget.imageActionList[index]["type"];
      if (type == "url" || type == "dial") {
        inbox.clickInboxAction(jsonEncode(widget.imageActionList[index]),
            widget.imageMessagePageId);

        String action = "";
        if (type == "dial") {
          action = "tel://";
        }
        launch(action + widget.imageActionList[index]["value"],
            forceSafariVC: false, forceWebView: false);
      } else {
        dev.log('unrecognized data value', name: tag);
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.imageMessagePageTitle,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[kebabMenu()],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: ListView(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: SizedBox(
                          child: Image.network(widget.imageMessagePageAvatar,
                              errorBuilder: (context, error, stackTrace) {
                            dev.log('Issue loading avatar image', name: tag);
                            return const Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(Icons.person));
                          }),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            widget.imageMessagePageTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    height: 20,
                    thickness: 0.5,
                    color: Colors.black,
                  ),
                  Text(widget.imageMessagePageBody),
                  Image.network(widget.imageMessagePageContent,
                      errorBuilder: (context, error, stackTrace) {
                    dev.log('Issue loading avatar image', name: tag);
                    return const Center(
                      child: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.image_not_supported_outlined)),
                    );
                  }),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          buttonAction(0);
                        },
                        child: Text(
                          widget.imageActionList[0]["name"].isEmpty
                              ? 'Left'
                              : widget.imageActionList[0]["name"],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          buttonAction(2);
                        },
                        child: Text(
                          widget.imageActionList[2]["name"].isEmpty
                              ? 'Center'
                              : widget.imageActionList[2]["name"],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          buttonAction(1);
                        },
                        child: Text(
                          widget.imageActionList[1]["name"].isEmpty
                              ? 'Right'
                              : widget.imageActionList[1]["name"],
                        ),
                      ),
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
