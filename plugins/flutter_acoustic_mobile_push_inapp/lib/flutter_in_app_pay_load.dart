import 'dart:core';

class InAppMessage {
  String? id = "";
  String? contentId = "";
  String? attribution = "";
  String? mailingId = "";
  String? triggerDate = "";
  String? expirationDate = "";
  List<String>? rules = [];
  int? maxViews = 0;
  int views = 0;
  int numViews = 0;
  String? template = "";
  TemplateContent? content;

  InAppMessage({
    this.id,
    this.contentId,
    this.attribution,
    this.mailingId,
    this.triggerDate,
    this.expirationDate,
    this.rules,
    this.maxViews,
    this.views = 0,
    this.numViews = 0,
    this.template,
    this.content,
  });

  InAppMessage.fromJson(Map<String, dynamic> json) {
    if (json['rules'] != null) {
      if (json['rules'] is String) {
        String rulesFromJson = json['rules'];
        rulesFromJson = rulesFromJson.substring(1, rulesFromJson.length - 1);
        rules = rulesFromJson.split(", ");
      } else {
        for (String rule in json['rules']) {
          rules?.add(rule);
        }
      }
    }
    if (json['numViews'] != null) {
      numViews = json['numViews'];
    }
    if (json['maxViews'] != null) {
      maxViews = json['maxViews'];
    }

    if (json['templateContent'] != null) {
      content =
          json['content'] = TemplateContent.fromJson(json['templateContent']);
    }

    if (json['inAppMessageId'] != null) {
      id = json['inAppMessageId'];
    }
    if (json['templateName'] != null) {
      template = json['templateName'];
    }
  }

  @override
  String toString() {
    return 'InAppMessage{id: $id, '
        'contentId: $contentId, '
        'attribution: $attribution, mailingId: $mailingId, '
        'triggerDate: $triggerDate, expirationDate: $expirationDate, '
        'rules: $rules, '
        'maxViews: $maxViews, views: $views, numViews: $numViews, '
        'template: $template, content: ${content.toString()},';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['contentId'] = contentId;
    data['attribution'] = attribution;
    data['mailingId'] = mailingId;
    data['triggerDate'] = triggerDate;
    data['expirationDate'] = expirationDate;
    data['rules'] = rules;
    data['maxViews'] = maxViews;
    data['numViews'] = numViews;
    data['views'] = views;
    data['template'] = template;
    if (content != null) {
      data['content'] = content!.toJson();
    }
    return data;
  }

  Map<String, dynamic> toJsonTest() => {
        'id': id,
        'contentId': contentId,
        'attribution': attribution,
        'mailingId': mailingId,
        'triggerDate': triggerDate,
        'expirationDate': expirationDate,
        'rules': rules,
        'maxViews': maxViews,
        'numViews': numViews,
        'views': views,
        'template': template,
        'templateContent': content!.toJsonTest(),
      };

  createBundle() {
    Map<String, dynamic> data = {};

    // Top and Bottom
    if (content?.orientation != null &&
        (content?.orientation == "top" || content?.orientation == "bottom")) {
      data['rules'] = rules;
      data['maxViews'] = maxViews;
      data['template'] = template;
      if (content != null) {
        data['content'] = content?.createBannerBundle();
      }
      data['triggerDate'] = triggerDate;
      data['expirationDate'] = expirationDate;

      return data;
    }

    //Image
    if (template == "image") {
      data['rules'] = rules;
      data['maxViews'] = maxViews;
      data['template'] = template;
      if (content != null) {
        data['content'] = content?.createImageBundle();
      }
      data['triggerDate'] = triggerDate;
      data['expirationDate'] = expirationDate;
      return data;
    }

    // Video
    if (template == "video") {
      data['rules'] = rules;
      data['maxViews'] = maxViews;
      data['template'] = template;
      if (content != null) {
        data['content'] = content?.createVideoBundle();
      }
      data['triggerDate'] = triggerDate;
      data['expirationDate'] = expirationDate;
      return data;
    }
  }
}

class TemplateContent {
  String? mainImage = "";
  String? image = "";
  String text = "";
  String? color = "";
  String? icon = "";
  String? title = "";
  String? orientation;
  String? video;
  Action? action;
  int? duration = 20;
  String? foreground = "";

  TemplateContent(
      {this.mainImage,
      this.image,
      required this.text,
      this.color,
      this.icon,
      this.title,
      this.orientation,
      this.video,
      this.action,
      this.duration,
      this.foreground});

  createBannerBundle() {
    Map<String, dynamic> data = {};
    data['orientation'] = orientation;
    data['action'] = action?.createBundle();
    data['text'] = text;
    data['duration'] = duration;
    data['mainImage'] = mainImage;
    data['icon'] = icon;
    data['color'] = color;
    data['foreground'] = foreground;

    return data;
  }

  createImageBundle() {
    Map<String, dynamic> data = {};
    data['title'] = title;
    data['text'] = text;
    data['image'] = image;
    data['duration'] = duration;
    data['action'] = action?.createBundle();

    return data;
  }

  createVideoBundle() {
    Map<String, dynamic> data = {};
    data['title'] = title;
    data['text'] = text;
    data['video'] = video;
    data['action'] = action?.createBundle();

    return data;
  }

  createBundle() {
    Map<String, dynamic> data = {};

    data['mainImage'] = mainImage;
    data['image'] = image;
    data['text'] = text;
    data['color'] = color;
    data['icon'] = icon;
    data['title'] = title;
    data['orientation'] = orientation;
    data['video'] = video;
    data['action'] = action?.createBundle();

    return data;
  }

  TemplateContent.fromJson(Map<String, dynamic> json) {
    if (json['color'] != null) {
      color = json['color'];
    }
    if (json['text'] != null) {
      text = json['text'];
    }
    if (json['title'] != null) {
      title = json['title'];
    }
    if (json['duration'] != null && json['duration'] != "null") {
      if (json['duration'] is String) {
        duration = int.parse(json['duration']);
      } else {
        duration = json['duration'];
      }
    }
    if (json['foreground'] != null) {
      foreground = json['foreground'];
    }
    if (json['orientation'] != null) {
      orientation = json['orientation'];
    }
    if (json['icon'] != null) {
      icon = json['icon'];
    }
    if (json['mainImage'] != null) {
      mainImage = json['mainImage'];
    }
    if (json['image'] != null) {
      image = json['image'];
    }
    if (json['video'] != null) {
      video = json['video'];
    }
    if (json['action'] != null) {
      action = Action.fromJson(json['action']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mainImage'] = mainImage;
    data['image'] = image;
    data['text'] = text;
    data['color'] = color;
    data['title'] = title;
    data['video'] = video;
    data['icon'] = icon;
    if (orientation != null) {
      data['orientation'] = action;
    }
    if (action != null) {
      data['action'] = action!.toJson();
    }
    return data;
  }

  Map<String, dynamic> toJsonTest() => {
        'mainImage': mainImage,
        'image': image,
        'text': text,
        'color': color,
        'title': title,
        'video': video,
        'icon': icon,
        'orientation': orientation,
        'action': action!.toJsonTest()
      };

  @override
  String toString() {
    return 'TemplateContent{mainImage: $mainImage, image: $image, text: $text, color: $color, icon: $icon, orientation: $orientation, title: $title, video: $video, action: ${action.toString()}}';
  }

  String toJsonString() {
    return 'TemplateContent{mainImage: $mainImage, image: $image, text: $text, color: $color, icon: $icon, orientation: $orientation, title: $title, video: $video, action: ${action.toString()}}';
  }
}

class Action {
  String type = "";
  String value = "";

  Action({required this.type, required this.value});

  createBundle() {
    Map<String, dynamic> data = {};

    data['type'] = type;
    data['value'] = value;

    return data;
  }

  Action.fromJson(Map<String, dynamic> json) {
    if (json['type'] != null) {
      type = json['type'];
    }
    if (json['value'] != null) {
      value = json['value'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['value'] = value;
    return data;
  }

  Map<String, dynamic> toJsonTest() => {'type': type, 'value': value};

  @override
  String toString() {
    return 'Action{type: $type, value: $value}';
  }
}
