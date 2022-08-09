import 'dart:core';
import 'package:flutter_acoustic_mobile_push/user_attribute/flutter_attribute_pay_load.dart';
import 'package:intl/intl.dart';

class EventPayLoad {
  String? type;
  String? name;
  DateTime? timestamp;
  String? mailingId;
  String? attribution;
  bool? isImmediate;
  List<dynamic>? attributes;

  EventPayLoad();

  Map<String, dynamic> createBundle() {
    Map<String, dynamic> data = {};

    if (type != null) {
      data['type'] = type;
    }
    if (name != null) {
      data['name'] = name;
    }
    if (timestamp != null) {
      data['timestamp'] =
          (DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(timestamp!))
              .toString();
    }
    if (attribution != null) {
      data['attribution'] = attribution;
    }
    if (mailingId != null) {
      data['mailingId'] = mailingId;
    }
    if (attributes != null) {
      List<dynamic> setAttributes = [];

      for (Object attribute in attributes!) {
        if (attribute is StringAttribute) {
          StringAttribute stringAttribute = attribute;
          setAttributes.add(stringAttribute.createBundle());
        } else if (attribute is NumberAttribute) {
          NumberAttribute numberAttribute = attribute;
          setAttributes.add(numberAttribute.createBundle());
        } else if (attribute is BooleanAttribute) {
          BooleanAttribute booleanAttribute = attribute;
          setAttributes.add(booleanAttribute.createBundle());
        } else if (attribute is DateAttribute) {
          DateAttribute dateAttribute = attribute;
          setAttributes.add(dateAttribute.createBundle());
        }
      }

      data['attributes'] = setAttributes;
    }
    data['immediate'] = isImmediate;
    return data;
  }
}

class DeleteEventPayLoad {
  String key = "";

  DeleteEventPayLoad(this.key);

  Map<String, dynamic> createBundle() {
    Map<String, dynamic> data = {};
    data["key"] = key;

    return data;
  }
}
