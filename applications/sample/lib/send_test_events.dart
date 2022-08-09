import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acoustic_mobile_push/event/flutter_event_pay_load.dart';
import 'package:flutter_acoustic_mobile_push/flutter_acoustic_sdk_push.dart';
import 'package:flutter_acoustic_mobile_push/user_attribute/flutter_attribute_pay_load.dart';
import 'package:intl/intl.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'dart:developer' as dev;

class SendTestEvents extends StatefulWidget {
  const SendTestEvents({Key? key}) : super(key: key);

  @override
  State<SendTestEvents> createState() => _SendTestEventsState();
}

enum EventType { sdk, custom }

extension EventTypeExtention on EventType {
  String get name {
    switch (this) {
      case EventType.sdk:
        return 'sdk';
      case EventType.custom:
        return 'custom';
      default:
        return "";
    }
  }
}

class _SendTestEventsState extends State<SendTestEvents> {
  int eventType = EventType.sdk.index;
  int type = 0;
  int valueType = 0;
  int nameTypeApp = 0;
  int nameTypeAction = 0;
  int nameTypeGeo = 0;
  int nameTypeIBeacon = 0;
  int eventSubType = 0;
  dynamic _customEventName;
  dynamic _customEventAttribution = "";
  dynamic _customEventMailingId;
  String _customEventAttributeName = "";

  String tag = "SendTestEvents";

  bool isSwitched = false;
  var textValue = 'False';

  int _valueNumberField = 0;
  dynamic _valueStringField;

  dynamic dateAndTime;
  String dateTime = DateFormat('yyyy-MM-dd').format(DateTime.now());
  DateTime setDateTime = DateTime.now();
  late TimeOfDay time;
  late DateTime date;

  var valueStringFieldController = TextEditingController();
  var customEventAttributeNameController = TextEditingController();
  var valueNumberFieldController = TextEditingController();
  var customEventAttributionController = TextEditingController();
  var customEventMailingIdController = TextEditingController();

  setEvent(index) {
    setState(() {
      eventType = index;

      resetValues();
      clearControllers();
    });
  }

  clearControllers() {
    setState(() {
      customEventAttributeNameController.clear();
      _customEventAttributeName = "";

      valueNumberFieldController.clear();
      _valueNumberField = 0;

      customEventAttributionController.clear();
      _customEventAttribution = "";

      customEventMailingIdController.clear();
      _customEventMailingId = "";

      valueStringFieldController.clear();
      _valueStringField = "";
    });
  }

  resetValues() {
    setResult(0);
    setValue(0);
    setSubType(0);
    setNameTypeApp(0);
  }

  setResult(index) {
    setState(() {
      type = index;
      clearControllers();
    });

    if (index == 0) {
      setNameTypeApp(index);
    }
    if (index == 1) {
      setSubType(0);
      setNameTypeAction(0);
    }
    if (index == 3) {
      setNameTypeGeo(0);
    }
    if (index == 4) {
      setNameTypeIBeacon(0);
    }
  }

  setValue(index) {
    setState(() {
      valueType = index;
    });
    clearControllers();
  }

  setSubType(index) {
    setState(() {
      eventSubType = index;
    });
  }

  setNameTypeApp(index) {
    setState(() {
      nameTypeApp = index;
    });
  }

  setNameTypeAction(index) {
    setState(() {
      nameTypeAction = index;
    });
  }

  setNameTypeGeo(index) {
    setState(() {
      nameTypeGeo = index;
    });
  }

  _setValues(index) {
    setState(() {
      valueType = index;
    });
  }

  setNameTypeIBeacon(index) {
    setState(() {
      nameTypeIBeacon = index;
    });
  }

  bool isDisabled() {
    if (eventType == 0) {
      return false;
    }

    if (eventType == 1) {
      if (type == 0 && nameTypeApp != 1) {
        return true;
      }

      if (type == 1 && (nameTypeAction == 1)) {
        if (nameTypeAction == 1) {
          return true;
        }
      }

      if ((type == 3 && nameTypeGeo == 1) ||
          (type == 4 && nameTypeIBeacon == 1)) {
        return true;
      }
    }

    return false;
  }

  int lockToggleNum() {
    if (eventType == 0) {
      return 0;
    }
    if (eventType == 1) {
      if (type == 0 && !isDisabled()) {
        setState(() {
          customEventAttributeNameController.text = "sessionLenght";
          _customEventAttributeName = customEventAttributeNameController.text;
        });
      }
      if (type == 0 && nameTypeApp != 1) {
        _setValues(3);
        return 3;
      }

      if (type == 1) {
        if (nameTypeAction == 0 || nameTypeAction == 3) {
          if (nameTypeAction == 0) {
            setState(() {
              customEventAttributeNameController.text = "url";
              _customEventAttributeName =
                  customEventAttributeNameController.text;
            });
          } else {
            setState(() {
              customEventAttributeNameController.text = "richContentId";
              _customEventAttributeName =
                  customEventAttributeNameController.text;
            });
          }

          _setValues(1);
          return 1;
        } else if (nameTypeAction == 2) {
          setState(() {
            customEventAttributeNameController.text = "phoneNumber";
            _customEventAttributeName = customEventAttributeNameController.text;
          });
          _setValues(3);
          return 3;
        }
      }

      if (type == 2) {
        if (!isDisabled()) {
          setState(() {
            customEventAttributeNameController.text = "inboxMessageId";
            _customEventAttributeName = customEventAttributeNameController.text;
          });
          _setValues(1);
        }
        return 1;
      }

      if (type == 3) {
        if (!isDisabled()) {
          if (nameTypeGeo == 0) {
            setState(() {
              customEventAttributeNameController.text = "reason";
              valueStringFieldController.text = "not_enabled";
              _customEventAttributeName =
                  customEventAttributeNameController.text;
            });
          } else if (nameTypeGeo == 2 || nameTypeGeo == 3) {
            setState(() {
              customEventAttributeNameController.text = "locationId";
              _customEventAttributeName =
                  customEventAttributeNameController.text;
            });
          }

          _setValues(1);
        }
        return 1;
      }

      if (type == 4) {
        if (!isDisabled()) {
          if (nameTypeIBeacon == 0) {
            setState(() {
              customEventAttributeNameController.text = "reason";
              valueStringFieldController.text = "not_enabled";
              _customEventAttributeName =
                  customEventAttributeNameController.text;
            });
          } else if (nameTypeIBeacon == 2 || nameTypeIBeacon == 3) {
            setState(() {
              customEventAttributeNameController.text = "locationId";
              _customEventAttributeName =
                  customEventAttributeNameController.text;
            });
          }

          _setValues(1);
        }

        return 1;
      }
    }
    return valueType;
  }

  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
        textValue = 'Switch True';
      });
    } else {
      setState(() {
        isSwitched = false;
        textValue = 'Switch False';
      });
    }
  }

  Widget customTypeButton(String text) {
    return SizedBox(
      height: 40,
      width: (MediaQuery.of(context).size.width) / 1.3,
      child: TextButton(
          child: Text(text),
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 5),
            primary: Colors.white,
            textStyle: const TextStyle(fontSize: 20, color: Colors.white),
            backgroundColor: Colors.cyan,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          )),
    );
  }

  Widget _buildNameDetails() {
    return TextFormField(
      decoration: const InputDecoration(
        hintText: "required",
        border: InputBorder.none,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      onSaved: (String? value) {
        setState(() {
          _customEventName = value!;
        });
      },
    );
  }

  Widget _buildAttributionDetails() {
    return TextFormField(
      controller: customEventAttributionController,
      decoration: const InputDecoration(
        hintText: "optional",
        border: InputBorder.none,
      ),
      onSaved: (String? value) {
        if (value!.isNotEmpty) {
          setState(() {
            _customEventAttribution = value;
          });
        }
      },
    );
  }

  Widget _buildMailingIdDetails() {
    return TextFormField(
      controller: customEventMailingIdController,
      decoration: const InputDecoration(
        hintText: "optional",
        border: InputBorder.none,
      ),
      onSaved: (String? value) {
        setState(() {
          _customEventMailingId = value!;
        });
      },
    );
  }

  Widget _buildEventAttributeNameDetails() {
    return TextFormField(
      controller: customEventAttributeNameController,
      enabled: !isDisabled(),
      decoration: const InputDecoration(
        hintText: "optional",
        border: InputBorder.none,
      ),
      onSaved: (String? value) {
        setState(() {
          _customEventAttributeName = value!;
        });
      },
    );
  }

  String eventStatusValue = 'No Status Yet';
  dynamic timer;

  List<dynamic> createAttributePayload() {
    List<dynamic> attributePayload = [];

    if (valueType == 0) {
      attributePayload
          .add(DateAttribute(_customEventAttributeName, setDateTime));
    } else if (valueType == 1) {
      attributePayload
          .add(StringAttribute(_customEventAttributeName, _valueStringField));
    } else if (valueType == 2) {
      attributePayload
          .add(BooleanAttribute(_customEventAttributeName, isSwitched));
    } else if (valueType == 3) {
      attributePayload
          .add(NumberAttribute(_customEventAttributeName, _valueNumberField));
    }

    return attributePayload;
  }

  sendCustomEvent() {
    if (!_testEventsFormKey.currentState!.validate()) {
      dev.log('Name has not been set', name: tag);

      return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Name value required'),
          content: const Text(
              'Please enter a value for the Name field under Event Details'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }

    _testEventsFormKey.currentState?.save();

    setState(() {
      eventStatusValue =
          'Queued Event with name: $_customEventName, type: custom';
    });

    timer = Timer(const Duration(seconds: 2), () {
      setState(() {
        eventStatusValue = "Sent events: $_customEventName, type: custom";
      });
    });

    EventPayLoad eventPayLoad = EventPayLoad();
    eventPayLoad.type = "custom";
    eventPayLoad.name = _customEventName;
    eventPayLoad.timestamp = DateTime.now();

    if (_customEventAttribution != null) {
      eventPayLoad.attribution = _customEventAttribution;
    }

    if (_customEventMailingId != null) {
      eventPayLoad.mailingId = _customEventMailingId;
    }

    eventPayLoad.attributes = createAttributePayload();
    eventPayLoad.isImmediate = true;

    dev.log('Send Event', name: tag);
    dev.log(eventPayLoad.createBundle().toString(), name: tag);

    FlutterAcousticSdkPush.sendEvent(eventPayLoad);
  }

  sendSdkEvent() {
    String typeResult = "";
    String nameResult = "";
    _testEventsFormKey.currentState?.save();

    switch (type) {
      case 0:
        typeResult = 'Application';
        switch (nameTypeApp) {
          case 0:
            nameResult = 'sessionStarted';
            break;
          case 1:
            nameResult = 'sessionEnded';
            break;
          case 2:
            nameResult = 'uiPushEnabled';
            break;
          case 3:
            nameResult = 'uiPushDisable';
        }
        break;
      case 1:
        switch (eventSubType) {
          case 0:
            typeResult = 'simpleNotification';
            break;
          case 1:
            typeResult = 'InboxSource';
            break;
          case 2:
            typeResult = 'inAppSource';
        }
        switch (nameTypeAction) {
          case 0:
            nameResult = 'UrlClicked';
            break;
          case 1:
            nameResult = 'appOpe';
            break;
          case 2:
            nameResult = 'phoneNu';
            break;
          case 3:
            nameResult = 'inboxMe';
        }
        break;
      case 2:
        typeResult = 'Inbox';
        nameResult = 'messageOpened';
        break;
      case 3:
        typeResult = 'geofence';
        switch (nameTypeGeo) {
          case 0:
            nameResult = 'disabled';
            break;
          case 1:
            nameResult = 'enabled';
            break;
          case 2:
            nameResult = 'enter';
            break;
          case 3:
            nameResult = 'exit';
        }
        break;
      case 4:
        typeResult = 'ibeacon';
        switch (nameTypeIBeacon) {
          case 0:
            nameResult = 'disabled';
            break;
          case 1:
            nameResult = 'enabled';
            break;
          case 2:
            nameResult = 'enter';
            break;
          case 3:
            nameResult = 'exit';
        }
    }

    EventPayLoad eventPayLoad = EventPayLoad();
    eventPayLoad.type = typeResult;
    eventPayLoad.name = nameResult;
    eventPayLoad.timestamp = DateTime.now();

    if (_customEventAttribution != null) {
      eventPayLoad.attribution = _customEventAttribution;
    }
    if (_customEventMailingId != null) {
      eventPayLoad.mailingId = _customEventMailingId;
    }
    if (!isDisabled()) {
      eventPayLoad.attributes = createAttributePayload();
    }

    dev.log('Send SDK Event', name: tag);
    dev.log(eventPayLoad.createBundle().toString(), name: tag);

    FlutterAcousticSdkPush.sendEvent(eventPayLoad);
  }

  @override
  void dispose() {
    super.dispose();
    if (timer != null) {
      timer.cancel();
    }
  }

  final GlobalKey<FormState> _testEventsFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    Color labelColor = Colors.white;
    Color colorLightGreen = const Color.fromRGBO(36, 189, 138, 0.5);

    changeEvent() {
      if (eventType == 1) {
        return ToggleSwitch(
          minWidth: 145,
          fontSize: 13,
          activeFgColor: Colors.white,
          activeBgColor: [Colors.cyan, colorLightGreen],
          inactiveBgColor: Colors.white,
          inactiveFgColor: Colors.cyan,
          initialLabelIndex: type,
          totalSwitches: 5,
          labels: const ['app', 'action', 'inbox', 'geofence', 'ibeacon'],
          onToggle: (index) {
            setResult(index);
          },
        );
      }
    }

    Widget changeType() {
      if (eventType == 0) {
        return customTypeButton('Custom');
      } else {
        if (type == 0) {
          return customTypeButton('Application');
        } else if (type == 1) {
          return ToggleSwitch(
            minWidth: (MediaQuery.of(context).size.width) / 3.9,
            fontSize: 13,
            activeFgColor: Colors.white,
            activeBgColor: [Colors.cyan, colorLightGreen],
            inactiveBgColor: Colors.white,
            inactiveFgColor: Colors.cyan,
            initialLabelIndex: eventSubType,
            totalSwitches: 3,
            labels: const ['simpleNotification', 'InboxSource', 'inAppSource'],
            onToggle: (index) {
              setSubType(index);
            },
          );
        } else if (type == 2) {
          return customTypeButton("Inbox");
        } else if (type == 3) {
          return customTypeButton('geofence');
        } else if (type == 4) {
          return customTypeButton('ibeacon');
        }
      }

      return const Text("");
    }

    Widget changeName() {
      if (eventType == 0) {
        return Container(
          width: (MediaQuery.of(context).size.width) / 1.3,
          margin: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
            color: Colors.white,
          ),
          child: _buildNameDetails(),
        );
      } else {
        if (type == 0) {
          return ToggleSwitch(
            fontSize: 13,
            minWidth: (MediaQuery.of(context).size.width) / 5.2,
            activeFgColor: Colors.white,
            activeBgColor: [Colors.cyan, colorLightGreen],
            inactiveBgColor: Colors.white,
            inactiveFgColor: Colors.cyan,
            initialLabelIndex: nameTypeApp,
            totalSwitches: 4,
            labels: const [
              'sessionStarted',
              'sessionEnded',
              'uiPushEnabled',
              'uiPushDisable'
            ],
            onToggle: (index) {
              if (index == 1) {
                _setValues(3);
              }

              setNameTypeApp(index);
            },
          );
        } else if (type == 1) {
          return ToggleSwitch(
            minWidth: (MediaQuery.of(context).size.width) / 5.5,
            minHeight: 40.0,
            fontSize: 13,
            activeFgColor: Colors.white,
            activeBgColor: [Colors.cyan, colorLightGreen],
            inactiveBgColor: Colors.white,
            inactiveFgColor: Colors.cyan,
            initialLabelIndex: nameTypeAction,
            totalSwitches: 4,
            labels: const ['UrlClicked', 'appOpe', 'phoneNu', 'inboxMe'],
            onToggle: (index) {
              setNameTypeAction(index);
            },
          );
        } else if (type == 2) {
          return SizedBox(
            height: 40,
            width: (MediaQuery.of(context).size.width) / 1.3,
            child: TextButton(
                child: const Text('messageOpened'),
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  primary: Colors.white,
                  textStyle: const TextStyle(fontSize: 20, color: Colors.white),
                  backgroundColor: Colors.cyan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                )),
          );
        } else if (type == 3) {
          return ToggleSwitch(
            minWidth: (MediaQuery.of(context).size.width) / 5.3,
            minHeight: 40.0,
            fontSize: 13,
            activeFgColor: Colors.white,
            activeBgColor: [Colors.cyan, colorLightGreen],
            inactiveBgColor: Colors.white,
            inactiveFgColor: Colors.cyan,
            initialLabelIndex: nameTypeGeo,
            totalSwitches: 4,
            labels: const ['disabled', 'enabled', 'enter', 'exit'],
            onToggle: (index) {
              setNameTypeGeo(index);
            },
          );
        } else if (type == 4) {
          return ToggleSwitch(
            minWidth: (MediaQuery.of(context).size.width) / 5.3,
            minHeight: 40.0,
            fontSize: 13,
            activeFgColor: Colors.white,
            activeBgColor: [Colors.cyan, colorLightGreen],
            inactiveBgColor: Colors.white,
            inactiveFgColor: Colors.cyan,
            initialLabelIndex: nameTypeIBeacon,
            totalSwitches: 4,
            labels: const ['disabled', 'enabled', 'enter', 'exit'],
            onToggle: (index) {
              setNameTypeIBeacon(index);
            },
          );
        }
      }
      return const Text("");
    }

    _changeValue() {
      if (isDisabled()) {
        return const Text("");
      }

      if (valueType == 0) {
        return TextButton(
          onPressed: () {
            if (!isDisabled()) {
              pickDateAndTime(context);
            }
          },
          child: Text(
            isDisabled() ? "" : dateTime,
            style: const TextStyle(color: Colors.cyan),
          ),
        );
      } else if (valueType == 1) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: TextFormField(
              controller: valueStringFieldController,
              decoration: const InputDecoration(
                hintText: "",
                border: InputBorder.none,
              ),
              onSaved: (String? value) {
                setState(() {
                  _valueStringField = value!;
                });
              }),
        );
      } else if (valueType == 2) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'False',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            Transform.scale(
              scale: 1.25,
              child: Switch(
                onChanged: toggleSwitch,
                value: isSwitched,
                activeColor: const Color.fromRGBO(29, 247, 168, 1),
                activeTrackColor: const Color.fromRGBO(29, 247, 168, 0.25),
                inactiveThumbColor: const Color.fromRGBO(19, 23, 61, 1),
                inactiveTrackColor: const Color.fromRGBO(19, 23, 61, 0.25),
              ),
            ),
            const Text(
              'True',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ],
        );
      } else if (valueType == 3) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: TextFormField(
            decoration: const InputDecoration(
              hintText: "",
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
            onSaved: (String? value) {
              if (value!.isNotEmpty) {
                setState(() {
                  _valueNumberField = int.parse(value);
                });
              }
            },
          ),
        );
      }
    }

    List<String>? valueToggleList = ['date', 'string', 'boolean', 'number'];
    Widget regularValueToggle() {
      return ToggleSwitch(
        fontSize: 13,
        minWidth: 75.7,
        activeFgColor: Colors.white,
        activeBgColor: [Colors.cyan, colorLightGreen],
        inactiveBgColor: Colors.white,
        inactiveFgColor: Colors.cyan,
        initialLabelIndex: valueType,
        totalSwitches: valueToggleList.length,
        labels: valueToggleList,
        onToggle: (index) {
          _setValues(index);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Send Events',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment(0.8, 0.4),
            colors: <Color>[
              Color.fromRGBO(22, 57, 77, 1),
              Color.fromRGBO(14, 114, 101, 1),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Form(
                key: _testEventsFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          child: ToggleSwitch(
                            minWidth: 295.0,
                            minHeight: 40.0,
                            activeFgColor: Colors.white,
                            activeBgColor: [Colors.cyan, colorLightGreen],
                            inactiveBgColor: Colors.white,
                            inactiveFgColor: Colors.cyan,
                            initialLabelIndex: eventType,
                            totalSwitches: 2,
                            labels: const [
                              'Send Custom Event',
                              'Simulate SDK Event'
                            ],
                            onToggle: (index) {
                              setEvent(index);
                              setState(() {
                                valueType = 0;
                              });
                            },
                          ),
                        ),
                        Container(
                          child: changeEvent(),
                        ),
                      ],
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'Event Details',
                            style: TextStyle(
                                color: labelColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'Type',
                            style: TextStyle(
                              color: labelColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        changeType(),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 25),
                          child: Text(
                            'Name',
                            style: TextStyle(
                              color: labelColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        changeName(),
                      ],
                    ),

                    //END OF NAME SECTION

                    //START OF ATTRIBUTION SECTION //
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Attribution',
                            style: TextStyle(
                              color: labelColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x26000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child: _buildAttributionDetails(),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Mailing Id',
                            style: TextStyle(
                              color: labelColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x26000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child: _buildMailingIdDetails(),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'Event Attribute',
                            style: TextStyle(
                                color: labelColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'Name',
                              style: TextStyle(
                                color: isDisabled() ? Colors.grey : labelColor,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x26000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                              color: isDisabled() ? Colors.grey : Colors.white,
                            ),
                            child: _buildEventAttributeNameDetails(),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Value',
                          style: TextStyle(
                            color: isDisabled() ? Colors.grey : labelColor,
                            fontSize: 15,
                          ),
                        ),
                        eventType == 0
                            ? regularValueToggle()
                            : ToggleSwitch(
                                fontSize: 13,
                                minWidth: 75.7,
                                dividerColor:
                                    isDisabled() ? Colors.grey : Colors.white,
                                activeFgColor:
                                    isDisabled() ? Colors.grey : Colors.white,
                                activeBgColor: isDisabled()
                                    ? [Colors.grey]
                                    : [Colors.cyan, colorLightGreen],
                                inactiveBgColor:
                                    isDisabled() ? Colors.grey : Colors.white,
                                inactiveFgColor:
                                    isDisabled() ? Colors.grey : Colors.cyan,
                                initialLabelIndex: lockToggleNum(),
                                changeOnTap: false,
                                totalSwitches: 4,
                                labels: const [
                                  'date',
                                  'string',
                                  'boolean',
                                  'number'
                                ],
                              ),
                      ],
                    ),

                    if (!isDisabled()) ...[
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 30),
                              child: const Text(''),
                            ),
                          ),
                          Expanded(
                            flex: 6,
                            child: Container(
                              child: _changeValue(),
                            ),
                          ),
                        ],
                      ),
                    ],

                    Container(
                      padding: isDisabled()
                          ? const EdgeInsets.only(top: 15)
                          : const EdgeInsets.only(top: 0),
                      child: InkWell(
                        onTap: () {
                          if (eventType == 0) {
                            sendCustomEvent();
                          } else {
                            sendSdkEvent();
                          }
                        },
                        child: const Text(
                          'Send Event',
                          style: TextStyle(color: Colors.cyan, fontSize: 18),
                        ),
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      child: Text(
                        'Status',
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      eventStatusValue,
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future pickDateAndTime(BuildContext context) async {
    DateTime? date = await pickDate(context);
    if (date == null) return;

    setState(() {
      setDateTime = date;
      dateTime = DateFormat('yyyy-MM-dd').format(setDateTime);
    });
  }

  Future<DateTime?> pickDate(BuildContext context) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    return newDate;
  }
}
