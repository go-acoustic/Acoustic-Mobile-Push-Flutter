import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push/flutter_acoustic_sdk_push.dart';
import 'package:flutter_acoustic_mobile_push/user_attribute/flutter_attribute_pay_load.dart';
import 'constants.dart';
import 'dart:developer' as dev;
import 'dart:io' show Platform;

class CustomActions extends StatefulWidget {
  const CustomActions({Key? key}) : super(key: key);

  @override
  State<CustomActions> createState() => _CustomActionsState();
}

class _CustomActionsState extends State<CustomActions> {
  String _customActionType = "";
  String _customActionValue = "";
  String tag = "customActions";

  Widget _buildTextFormField(String action) {
    return TextFormField(
        decoration: const InputDecoration(
          border: InputBorder.none,
          labelText: 'optional',
        ),
        onSaved: (String? value) {
          setState(() {
            if (action == "type") {
              _customActionType = value!;
            } else if (action == "value") {
              _customActionValue = value!;
            }
          });
        });
  }

  Text registerTextWidget = const Text('');
  Text textWidget = const Text('');

  String statusValue = 'No Status Yet';
  var value = CustomActionValue();

  Future<void> registerCustomAction(String actionType) async {
    value.registerCustomAction(actionType);

    value.regisiteredEvent.subscribe((args) {
      var data = args!.changedValue;
      setState(() {
        if (statusValue != data) {
          dev.log(data, name: tag);
          statusValue = data;
        }
      });
    });
  }

  Future<void> registerCustomActionAndValue(
      CustomActionPayLoad eventObject) async {
    value.registerCustomActionAndValue(eventObject);

    value.regisiteredValueEvent.subscribe((args) {
      var data = args!.changedValue;
      setState(() {
        if (statusValue != data) {
          dev.log(data, name: tag);
          statusValue = data;
        } else {}
      });
    });
  }

  Future<void> unregisterCustomAction(String actionType) async {
    value.unregisterCustomAction(actionType);

    value.unregisiteredEvent.subscribe((args) {
      var data = args!.changedValue;

      setState(() {
        if (statusValue != data) {
          dev.log(data, name: tag);
          statusValue = data;
        }
      });
    });
  }

  register() {
    _formKey.currentState?.save();

    if (_customActionType.isEmpty) {
      return Text(statusValue, style: const TextStyle(color: labelColor));
    } else {
      registerCustomAction(_customActionType);
    }
  }

  registerWithValue() {
    _formKey.currentState?.save();

    CustomActionPayLoad customActionPayLoad = CustomActionPayLoad();
    customActionPayLoad.type = _customActionType;
    customActionPayLoad.value = _customActionValue;

    registerCustomActionAndValue(customActionPayLoad);
  }

  unregister() {
    _formKey.currentState?.save();
    unregisterCustomAction(_customActionType);
  }

  Widget actionTitle(String text) {
    return Container(
      padding: const EdgeInsets.only(left: 20, top: 20),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget inkWellText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.cyan,
        fontSize: 15,
      ),
    );
  }

  // update in next patch
  // ignore: non_constant_identifier_names
  Widget textFieldSetup(Widget TextFormField) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
      child: TextFormField,
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Custom Action',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
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
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      actionTitle('Custom Action Type'),
                      textFieldSetup(_buildTextFormField("type")),
                      actionTitle('Register Custom Action'),
                      Container(
                        padding: const EdgeInsets.only(left: 20, top: 5),
                        child: InkWell(
                            onTap: () => register(),
                            child: inkWellText(
                                'Register Custom Action With Type')),
                      ),
                      actionTitle('Unregister Custom Action'),
                      Container(
                        padding: const EdgeInsets.only(left: 20, top: 5),
                        child: InkWell(
                            onTap: () => unregister(),
                            child: inkWellText(
                                'Unregister Custom Action With Type')),
                      ),
                      if (Platform.isIOS) ...[
                        actionTitle('Custom Action Value'),
                        textFieldSetup(_buildTextFormField("value")),
                        actionTitle('Send'),
                        Container(
                          padding: const EdgeInsets.only(left: 20, top: 5),
                          child: InkWell(
                              onTap: () => registerWithValue(),
                              child: inkWellText(
                                  'Send Custom Action with Type and Value')),
                        ),
                        actionTitle('Status:'),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                          ),
                          child: Text(statusValue,
                              style: const TextStyle(color: labelColor)),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
