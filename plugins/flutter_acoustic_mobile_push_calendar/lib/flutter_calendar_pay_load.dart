import 'dart:core';

class CalendarPayload {
  Payload payload;

  CalendarPayload(this.payload);

  Map<String, dynamic> createBundle() {
    Map<String, dynamic> data = {};
    // plugin not currently in use
    // ignore: unnecessary_null_comparison
    if (payload != null) {
      data["action"] = payload.createBundle();
    }

    return data;
  }
}

class Payload {
  String? starts;
  String? ends;
  String? title;
  String? description;
  String? date;
  String? time;
  String? timezone;
  bool interactive = false;

  Payload();

  Map<String, dynamic> createBundle() {
    Map<String, dynamic> data = {};
    if (starts != null) {
      data["startDate"] = starts;
    }

    if (ends != null) {
      data["endDate"] = ends;
    }

    if (title != null) {
      data["title"] = title;
    }

    if (description != null) {
      data["description"] = description;
    }

    if (date != null) {
      data["date"] = date;
    }

    if (time != null) {
      data["time"] = time;
    }

    if (timezone != null) {
      data["timezone"] = timezone;
    }

    data["interactive"] = interactive;

    return data;
  }
}
