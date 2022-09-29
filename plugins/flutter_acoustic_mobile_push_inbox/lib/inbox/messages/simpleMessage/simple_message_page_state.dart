import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_inbox/flutter_acoustic_mobile_push_inbox.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/simpleMessage/models/simple_message_page.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/layouts/message_layout.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

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

  Future<NavigationDecision> linkLauncher(NavigationRequest request) async {
    int counter = -1;
    for (int i = 0; i < widget.simpleActionList.length; ++i) {
      if (request.url == "actionid:" + widget.simpleActionList[i].id!) {
        counter = i;
        await Message().launchAction(widget.simpleActionList[counter].value);
        break;
      }
    }

    if (Platform.isAndroid) {
      return NavigationDecision.prevent;
    } else {
      return NavigationDecision.navigate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            InboxMessageValue().readInboxMessage(widget.simpleMessagePageId);
            Navigator.pop(context, true);
          },
        ),
        title: Text(
          widget.simpleMessagePageTitle,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          Message().kebabMenu(
            context,
            widget.simpleMessagePageId,
          )
        ],
      ),
      body: WebViewPlus(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) {
          this.controller = controller;

          loadLocalHtml();
        },
        navigationDelegate: linkLauncher,
      ),
    );
  }
}
