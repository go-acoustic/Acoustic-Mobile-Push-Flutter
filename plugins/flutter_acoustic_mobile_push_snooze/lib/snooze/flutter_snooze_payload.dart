import 'dart:core';

class SnoozePayload {
  MinuteValue? value;
  ApsValue? apsValue;
  int mailingId = 0;

  Map<String, dynamic> createBundle() {
    Map<String, dynamic> data = {};

    if (value != null) {
      data['action'] = value!.toJson();
    }
    if (apsValue != null) {
      data['payload'] = apsValue!.toJson();
    }
    data['mailingId'] = mailingId;

    return data;
  }
}

class MinuteValue {
  int minutes = 0;

  MinuteValue({required this.minutes});

  MinuteValue.fromJson(Map<String, dynamic> json) {
    minutes = json['minutes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = minutes;
    return data;
  }

  Map<String, dynamic> toJsonTest() => {'minutes': minutes};
}

class ApsValue {
  String? category = "";
  String? sound = "";
  int badge = 0;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category'] = category;
    data['sound'] = sound;
    data['badge'] = badge;
    return data;
  }
}
