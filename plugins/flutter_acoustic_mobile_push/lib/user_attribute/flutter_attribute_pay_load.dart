import 'dart:core';
import 'package:intl/intl.dart';

class AttributePayLoad {
  List payload = [];

  AttributePayLoad(this.payload);

  List<dynamic> createBundle() {
    List<dynamic> data = [];

    for (Object attribute in payload) {
      if (attribute is StringAttribute) {
        StringAttribute stringAttribute = attribute;
        data.add(stringAttribute.createBundle());
      } else if (attribute is NumberAttribute) {
        NumberAttribute numberAttribute = attribute;
        data.add(numberAttribute.createBundle());
      } else if (attribute is BooleanAttribute) {
        BooleanAttribute booleanAttribute = attribute;
        data.add(booleanAttribute.createBundle());
      } else if (attribute is DateAttribute) {
        DateAttribute dateAttribute = attribute;
        data.add(dateAttribute.createBundle());
      }
    }

    return data;
  }
}

class CustomActionPayLoad {
  String? type;
  String? value;
  String key = "key";

  CustomActionPayLoad();

  Map<String, dynamic> createBundle() {
    Map<String, dynamic> data = {};

    if (type != null) {
      data['type'] = type;
    }

    if (value != null) {
      data['value'] = value;
    }

    data['key'] = key;

    return data;
  }
}

class StringAttribute {
  String type = "string";
  String value = "";
  String key = "";

  StringAttribute(this.key, this.value);

  Map<String, dynamic> createBundle() {
    Map<String, dynamic> data = {};

    data['type'] = type;

    data['value'] = value;

    data['key'] = key;

    return data;
  }
}

class NumberAttribute {
  String type = "number";
  int value = 0;
  String key = "";

  NumberAttribute(this.key, this.value);

  Map<String, dynamic> createBundle() {
    Map<String, dynamic> data = {};

    data['type'] = type;

    data['value'] = value;

    data['key'] = key;

    return data;
  }
}

class BooleanAttribute {
  String type = "boolean";
  bool value = false;
  String key = "";

  BooleanAttribute(this.key, this.value);

  Map<String, dynamic> createBundle() {
    Map<String, dynamic> data = {};

    data['type'] = type;

    data['value'] = value;

    data['key'] = key;

    return data;
  }
}

class DateAttribute {
  String type = "date";
  DateTime value = DateTime.now();

  String key = "";

  DateAttribute(this.key, this.value);

  Map<String, dynamic> createBundle() {
    Map<String, dynamic> data = {};

    data['type'] = type;

    data['value'] = (DateFormat('yyyy-MM-dd').format(value)).toString();

    data['key'] = key;

    return data;
  }
}

class DeleteAttributePayLoad {
  List payload = [];

  DeleteAttributePayLoad(this.payload);

  List<dynamic> createBundle() {
    List<dynamic> data = [];
    Map<String, dynamic> map = {};

    for (String attributeKey in payload) {
      map['key'] = attributeKey;
      data.add(map);
    }

    return data;
  }
}
