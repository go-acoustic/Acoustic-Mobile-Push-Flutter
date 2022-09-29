import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acoustic_mobile_push/user_attribute/flutter_attribute_pay_load.dart';
import 'package:flutter_acoustic_mobile_push/flutter_acoustic_sdk_push.dart';
import 'package:intl/intl.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'constants.dart';
import 'dart:developer' as dev;

class SendUserAttributes extends StatefulWidget {
  const SendUserAttributes({Key? key}) : super(key: key);

  @override
  State<SendUserAttributes> createState() => _SendUserAttributesState();
}

class _SendUserAttributesState extends State<SendUserAttributes> {
  String _keyNameField = "";
  String _valueStringField = "";
  String dateTime = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String currentTime = DateTime.now().toString();
  String tag = "SendUserAttributes";

  int _valueNumberField = 0;
  int valueType = 0;
  int operationType = 0;

  bool isSwitched = false;

  DateTime setDateTime = DateTime.now();

  Timer? timer;
  var valueStringController = TextEditingController();

  Widget _buildKeyName() {
    return TextFormField(
        decoration: const InputDecoration(
          border: InputBorder.none,
          labelText: 'optional',
        ),
        onChanged: (String? value) {
          setState(() {
            _keyNameField = value!;
          });
        });
  }

  Widget _buildValueString() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: TextFormField(
          controller: valueStringController,
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
          onChanged: (String? value) {
            setState(() {
              _valueStringField = value!;
            });
          }),
    );
  }

  Widget _buildValueNumber() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: TextFormField(
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        onSaved: (String? value) {
          if (value != null && value.isNotEmpty) {
            setState(() {
              _valueNumberField = int.parse(value);
            });
          }
        },
      ),
    );
  }

  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
      });
    } else {
      setState(() {
        isSwitched = false;
      });
    }
  }

  String userAttributeStatus = 'No Status Yet';

  List<dynamic> createAttributePayload() {
    var keyValue = _keyNameField;
    if (keyValue.isEmpty) {
      keyValue = "key";
    }
    List<dynamic> attributePayload = [];

    String value = "";

    if (valueType == 0) {
      attributePayload.add(DateAttribute(keyValue, setDateTime));
    } else if (valueType == 1) {
      value = _valueStringField;
      attributePayload.add(StringAttribute(keyValue, _valueStringField));
    } else if (valueType == 2) {
      value = isSwitched.toString();
      attributePayload.add(BooleanAttribute(keyValue, isSwitched));
    } else if (valueType == 3) {
      value = _valueNumberField.toString();
      attributePayload.add(NumberAttribute(keyValue, _valueNumberField));
    }

    setState(() {
      userAttributeStatus = "Queued Update key: $keyValue Value: $value";
    });

    timer = Timer(const Duration(seconds: 2), () {
      setState(() {
        userAttributeStatus = "Sent Update key: $keyValue Value: $value";
      });
    });

    return attributePayload;
  }

  sendAttribute() {
    _attributeFormKey.currentState?.save();
    dev.log('registering update', name: tag);

    FlutterAcousticSdkPush.updateUserAttributes(createAttributePayload());
  }

  deleteAttribute() {
    var keyValue = _keyNameField;
    if (keyValue.isEmpty) {
      keyValue = "key";
    }
    _attributeFormKey.currentState?.save();
    dev.log('registering delete', name: tag);

    FlutterAcousticSdkPush.deleteUserAttributes([keyValue]);

    setState(() {
      userAttributeStatus = "Queued Delete $keyValue";
    });

    timer = Timer(const Duration(seconds: 2), () {
      setState(() {
        userAttributeStatus = "Sent Delete $keyValue";
      });
    });
  }

  final GlobalKey<FormState> _attributeFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    changeValues() {
      if (valueType == 0) {
        return TextButton(
          onPressed: () => pickDateAndTime(context),
          child: Text(
            dateTime,
            style: const TextStyle(color: Colors.cyan),
          ),
        );
      } else if (valueType == 1) {
        return _buildValueString();
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
        return _buildValueNumber();
      }
    }

    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            'Send User Attributes',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
        ),
        body: Container(
          height: double.infinity,
          decoration: appBackgroundGradient,
          child: SingleChildScrollView(
            child: Form(
              key: _attributeFormKey,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 20, top: 20),
                      child: const Text(
                        'Key Name',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: _buildKeyName(),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.only(left: 20, top: 20, bottom: 10),
                      child: const Text(
                        'Value',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Column(
                      children: [
                        Center(
                          child: ToggleSwitch(
                            minWidth: 175,
                            minHeight: 40.0,
                            activeFgColor: Colors.white,
                            activeBgColor: const [Colors.cyan, colorLightGreen],
                            inactiveBgColor: Colors.white,
                            inactiveFgColor: Colors.cyan,
                            initialLabelIndex: valueType,
                            totalSwitches: 4,
                            labels: const [
                              'date',
                              'string',
                              'boolean',
                              'number'
                            ],
                            onToggle: (index) {
                              if (index != null) {
                                setState(() {
                                  valueType = index;
                                });
                              }
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(20),
                          child: changeValues(),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 60),
                      padding:
                          const EdgeInsets.only(left: 20, top: 20, bottom: 10),
                      child: const Text(
                        'Operation',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Center(
                      child: ToggleSwitch(
                        minWidth: 290.0,
                        minHeight: 40.0,
                        activeFgColor: Colors.white,
                        activeBgColor: const [Colors.cyan, colorLightGreen],
                        inactiveBgColor: Colors.white,
                        inactiveFgColor: Colors.cyan,
                        initialLabelIndex: operationType,
                        totalSwitches: 2,
                        labels: const ['Update', 'Delete'],
                        onToggle: (index) {
                          if (index != null) {
                            setState(() {
                              operationType = index;
                            });
                          }
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 20, top: 25),
                      child: InkWell(
                        onTap: () {
                          if (operationType == 0) {
                            sendAttribute();
                          } else {
                            deleteAttribute();
                          }
                        },
                        child: const Text(
                          'Send Attribute',
                          style: TextStyle(
                            color: Colors.cyan,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.only(left: 20, top: 50, bottom: 10),
                      child: const Text(
                        'Status',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        left: 20,
                      ),
                      child: Text(userAttributeStatus,
                          style: const TextStyle(color: Colors.white)),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 30, horizontal: 20),
                          child: const Text(
                            'Note: The key name and value type above must match a column in your WCA database in order to propogate',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
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

  @override
  void dispose() {
    super.dispose();

    if (timer != null) {
      timer!.cancel();
    }
  }
}
