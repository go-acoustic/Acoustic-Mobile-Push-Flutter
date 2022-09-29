import 'dart:convert';
import 'dart:core';
import 'dart:developer' as dev;

class InBoxMessage {
  String inboxMessageId = "";
  String richContentId = "";
  String templateName = "";
  String attribution = "";
  String mailingId = "";
  int sendDate = 0;
  int expirationDate = 0;
  bool isDeleted = false;
  bool isRead = false;
  bool isExpired = false;
  Content? content;

  InBoxMessage(
      {required this.inboxMessageId,
      required this.richContentId,
      required this.templateName,
      required this.attribution,
      required this.mailingId,
      required this.sendDate,
      required this.expirationDate,
      required this.isDeleted,
      required this.isRead,
      required this.isExpired,
      required this.content});

  InBoxMessage.fromJson(Map<String, dynamic> json) {
    if (json["inboxMessageId"] != null) {
      inboxMessageId = json['inboxMessageId'];
    }

    if (json["richContentId"] != null) {
      richContentId = json['richContentId'];
    }

    if (json["templateName"] != null) {
      templateName = json['templateName'];
    }

    if (json["attribution"] != null) {
      attribution = json['attribution'];
    }

    if (json["mailingId"] != null) {
      mailingId = json['mailingId'];
    }

    if (json["sendDate"] != null) {
      sendDate = json['sendDate'];
    }

    if (json["expirationDate"] != null) {
      expirationDate = json['expirationDate'];
    }

    if (json["isDeleted"] != null) {
      isDeleted = json['isDeleted'];
    }

    if (json["isRead"] != null) {
      isRead = json['isRead'];
    }

    if (json["isExpired"] != null) {
      isExpired = json['isExpired'];
    }

    content =
        json['content'] != null ? Content.fromJson(json['content']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['inboxMessageId'] = inboxMessageId;
    data['richContentId'] = richContentId;
    data['templateName'] = templateName;
    data['attribution'] = attribution;
    data['mailingId'] = mailingId;
    data['sendDate'] = sendDate;
    data['expirationDate'] = expirationDate;
    data['isDeleted'] = isDeleted;
    data['isRead'] = isRead;
    data['isExpired'] = isExpired;
    if (content != null) {
      data['content'] = content!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return 'InBoxMessage{inboxMessageId: $inboxMessageId, '
        'richContentId: $richContentId, templateName: $templateName, '
        'attribution: $attribution, mailingId: $mailingId, '
        'sendDate: $sendDate, expirationDate: $expirationDate, '
        'isDeleted: $isDeleted, isRead: $isRead, isExpired: $isExpired, content: ${content.toString()}';
  }
}

class Content {
  String? contentVideo;
  String? contentImage;
  String? header;
  String? subHeader;
  String? headerImage;
  String? contentText;
  MessageDetails? messageDetails;
  MessagePreview? messagePreview;
  List<MessageActions>? actions;

  String tag = "Payload";
  Content(
      {this.contentVideo,
      this.contentImage,
      this.header,
      this.subHeader,
      this.headerImage,
      this.contentText,
      this.messageDetails,
      this.messagePreview,
      this.actions});

  Content.fromJson(Map<String, dynamic> json) {
    if (json["contentVideo"] != null) {
      contentVideo = json['contentVideo'];
    }
    if (json["contentImage"] != null) {
      contentImage = json['contentImage'];
    }
    if (json["header"] != null) {
      header = json['header'];
    }
    if (json["subHeader"] != null) {
      subHeader = json['subHeader'];
    }
    if (json["headerImage"] != null) {
      headerImage = json['headerImage'];
    }
    if (json["contentText"] != null) {
      contentText = json['contentText'];
    }

    bool needPatch = false;
    if (json['messageDetails'] != null) {
      if (json['actions'] != null) {
        try {
          actions = <MessageActions>[];

          for (final name in json['actions'].keys) {
            final actionsObject = json['actions'][name];
            actionsObject["id"] = name;

            actions!.add(MessageActions.fromJson(actionsObject));

            var actionData = jsonEncode(json['messageDetails']['richContent']);

            dynamic actionDataFixed;

            if (actionsObject['type'] == 'url') {
              needPatch = true;
            }

            actionDataFixed = actionData;

            var updatedActionData = jsonDecode(actionDataFixed);
            json['messageDetails']['richContent'] = updatedActionData;
            json['messageDetails'] = {'richContent': updatedActionData};

            messageDetails = MessageDetails.fromJson(json['messageDetails']);
          }
        } catch (err) {
          dev.log("Error from mapping: $err", name: tag);
        }
      } else {
        messageDetails = MessageDetails.fromJson(json['messageDetails']);
      }
    } else {
      messageDetails = null;
    }

    messagePreview = json['messagePreview'] != null
        ? MessagePreview.fromJson(json['messagePreview'])
        : null;

    if (json['actions'] != null && !needPatch) {
      actions = <MessageActions>[];
      json['actions'].forEach((v) {
        actions!.add(MessageActions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['contentVideo'] = contentVideo;
    data['contentImage'] = contentImage;
    data['header'] = header;
    data['subHeader'] = subHeader;
    data['headerImage'] = headerImage;
    data['contentText'] = contentText;
    if (messageDetails != null) {
      data['messageDetails'] = messageDetails!.toJson();
    }
    if (messagePreview != null) {
      data['messagePreview'] = messagePreview!.toJson();
    }
    if (actions != null) {
      data['actions'] = actions!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return 'Content{contentVideo: $contentVideo, contentImage: $contentImage, '
        'header: $header, subHeader: $subHeader, headerImage: $headerImage, '
        'contentText: $contentText, messageDetails: ${messageDetails.toString()}, '
        'messagePreview: ${messagePreview.toString()}, actions: ${actions.toString()}}';
  }
}

class MessageDetails {
  String richContent = "";

  MessageDetails({required this.richContent});

  MessageDetails.fromJson(Map<String, dynamic> json) {
    richContent = json['richContent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['richContent'] = richContent;
    return data;
  }

  @override
  String toString() {
    return 'MessageDetails{richContent: $richContent}';
  }
}

class MessagePreview {
  String subject = "";
  String previewContent = "";

  MessagePreview({required this.subject, required this.previewContent});

  MessagePreview.fromJson(Map<String, dynamic> json) {
    if (json["subject"] != null) {
      subject = json['subject'];
    }

    if (json["previewContent"] != null) {
      previewContent = json['previewContent'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subject'] = subject;
    data['previewContent'] = previewContent;
    return data;
  }

  @override
  String toString() {
    return 'MessagePreview{subject: $subject, previewContent: $previewContent}';
  }
}

class MessageActions {
  String name = "";
  String type = "";
  String value = "";
  String? id = "";

  MessageActions(
      {required this.name, required this.type, required this.value, this.id});

  MessageActions.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = json['type'];
    value = json['value'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = type;
    data['value'] = value;
    return data;
  }

  @override
  String toString() {
    return 'Actions{name: $name, value: $value}';
  }

  String toObjectString() {
    return '{name: $name, value: $value, type: $type}';
  }
}

class InBoxMessageModel {
  int messages = 0;
  int unread = 0;

  InBoxMessageModel(this.messages, this.unread);

  InBoxMessageModel.fromJson(Map<String, dynamic> json) {
    messages = json['messages'];
    unread = json['unread'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['messages'] = messages;
    data['unread'] = unread;
    return data;
  }

  @override
  String toString() {
    return 'InBoxMessageModel{messages: $messages, unread: $unread}';
  }
}
