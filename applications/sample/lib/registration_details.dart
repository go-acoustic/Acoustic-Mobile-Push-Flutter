import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push/flutter_acoustic_sdk_push.dart';
import 'dart:developer' as dev;

class RegistrationDetails extends StatefulWidget {
  const RegistrationDetails({Key? key}) : super(key: key);

  @override
  State<RegistrationDetails> createState() => _RegistrationDetailsState();
}

// credentials constructor
class Credentials {
  String? appKey;
  String userId;
  String channelId;
  String registration;

  Credentials(this.appKey, this.userId, this.channelId, this.registration);
}

class _RegistrationDetailsState extends State<RegistrationDetails> {
  var _userId = "";
  var _channelId = "";
  var _appKey = "";
  String tag = "registrationDetails";

  Future<void> getDataFromSDK() async {
    var value = RegisiterValue();
    value.getRegisterValue();
    value.userId.subscribe((args) {
      var data = args!.changedValue;
      setState(() {
        _userId = data;
        dev.log('userId: ' + _userId, name: tag);
      });
    });

    value.channelId.subscribe((args) {
      var data = args!.changedValue;
      setState(() {
        _channelId = data;
        dev.log('channelId: ' + _channelId, name: tag);
      });
    });

    value.appKey.subscribe((args) {
      var data = args!.changedValue;
      setState(() {
        _appKey = data;
        dev.log('appKey: ' + _appKey, name: tag);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getDataFromSDK();
  }

  // update in next patch
  // ignore: annotate_overrides
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Registration',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(
                bottom: false,
                child: Container(
                  child: const Text(
                    'CREDENTIALS',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 50, bottom: 10, left: 20),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      width: 1,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'User Id',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(_userId),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      width: 1,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Channel ID',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(_channelId),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'App Key',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(_appKey),
                  ],
                ),
              ),
              SafeArea(
                bottom: false,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: const Text(
                    'User ID and Channel ID only known after registration. The registration process could take several minutes, If you have issues with registering a device make sure you have the correct certificate and appKey',
                    style: TextStyle(color: Colors.white),
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
