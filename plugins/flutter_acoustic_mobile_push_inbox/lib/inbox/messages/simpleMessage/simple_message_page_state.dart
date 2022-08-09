import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/simpleMessage/simple_message_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import '../../../flutter_acoustic_mobile_push_inbox.dart';
import 'dart:developer' as dev;

class SimpleMessagePageState extends State<SimpleMessagePage> {
  late WebViewPlusController controller;

  dynamic url;
  String tag = "Inbox";

  // function below uses default viewport to render properly sized html content for mobile devices, otherwise it will default to webview size
  void loadLocalHtml() async {
    url = Uri.dataFromString(
      """<!DOCTYPE html>
    <html>
      <head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
      ${widget.simpleMessagePageContent}
    </html>""",
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString();

    controller.loadUrl(url);
  }

  deleteMessage() {
    var inbox = InboxMessageValue();
    inbox.deleteMessage(widget.simpleMessagePageId);
    Navigator.pop(context);
  }

  NavigationDecision linkLauncher(NavigationRequest request) {
    var inbox = InboxMessageValue();
    int counter = -1;
    for (int i = 0; i < widget.simpleActionList.length; ++i) {
      if (request.url == "actionid:" + widget.simpleActionList[i]["id"]) {
        counter = i;
        break;
      }
    }

    try {
      if (Platform.isAndroid) {
        if (widget.simpleActionList[counter]["value"]
            .toString()
            .contains("http")) {
          launch(widget.simpleActionList[counter]["value"]);
        } else {
          launch("tel:${widget.simpleActionList[counter]["value"]}");
        }
        inbox.clickInboxAction(jsonEncode(widget.simpleActionList[counter]),
            widget.simpleMessagePageId);

        return NavigationDecision.prevent;
      } else if (Platform.isIOS) {
        if (widget.simpleActionList[counter]["value"]
            .toString()
            .contains("http")) {
          launch(widget.simpleActionList[counter]["value"],
              forceSafariVC: false, forceWebView: false);
        } else {
          launch("tel:${widget.simpleActionList[counter]["value"]}");
        }
      }
    } catch (err) {
      dev.log("$err", name: tag);
    }
    try {
      return NavigationDecision.navigate;
    } catch (err) {
      return NavigationDecision.prevent;
    }
  }

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
            inbox.readInboxMessage(widget.simpleMessagePageId);
            widget.updateIsReadViewer(true);
          },
        ),
        DropdownMenuItem(
          child: const Text("Unread"),
          value: 'Unread',
          onTap: () {
            dev.log('unread', name: tag);
            Navigator.pop(context);
            inbox.unreadInboxMessage(widget.simpleMessagePageId);
            widget.updateIsReadViewer(false);
          },
        ),
        DropdownMenuItem(
          child: const Text("Delete"),
          value: 'Delete',
          onTap: () {
            Navigator.pop(context);
            widget.simpleMessagePageInboxDeleteMessage();
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.simpleMessagePageTitle,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[kebabMenu()],
      ),
      // update in next patch
      // ignore: avoid_unnecessary_containers
      body: Container(
        child: WebViewPlus(
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (controller) {
            this.controller = controller;

            loadLocalHtml();
          },
          navigationDelegate: linkLauncher,
        ),
      ),
    );
  }
}
