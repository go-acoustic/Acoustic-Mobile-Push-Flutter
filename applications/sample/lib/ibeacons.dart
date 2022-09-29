import 'dart:async';
import 'dart:io';
import 'package:ca_mce_flutter_sdk_sample/location_request_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_beacon/beacon_permission.dart';
import 'package:flutter_acoustic_mobile_push_beacon/ibeacon/flutter_ibeacon_pay_load.dart';
import 'package:flutter_acoustic_mobile_push_location/flutter_acoustic_mobile_push_location.dart';
import 'package:flutter_acoustic_mobile_push_beacon/flutter_acoustic_mobile_push_beacon.dart';
import 'package:flutter_acoustic_mobile_push_location/location.dart';
import 'constants.dart';
import 'dart:developer' as dev;

class IBeacons extends StatefulWidget {
  const IBeacons({Key? key}) : super(key: key);

  @override
  State<IBeacons> createState() => _IBeaconsState();
}

class _IBeaconsState extends State<IBeacons> {
  List<IBeaconPayload> _beaconList = [];

  String beaconId = "";
  String status = "NO AVAILABLE STATUS";
  String tag = "IBeacons";
  String permissionStatus = "";

  bool wasPaused = false;
  bool initRun = true;
  bool showDialog = false;

  late LocationsPermission permission;
  Timer? timer;

  Future<void> locationPermission() async {
    try {
      permission = await Location().checkLocationPermission();

      dev.log('PERMISSION STATUS: $permission', name: tag);

      if (permission != LocationsPermission.always) {
        if (showDialog == false) {
          RequestDialog().showPermission(context);
          setState(() {
            showDialog = true;
          });
        }
      }

      await BeaconBluetooth().scanPermission().then((permission) {
        dev.log('BLUETOOTH_SCAN permission $permission', name: tag);
      });

      if (permission == LocationsPermission.always ||
          permission == LocationsPermission.whileInUse) {
        var module = IbeaconModuleValue();
        await module.sendLocationPermission().then((_) {
          reloadData();

          if (initRun) {
            if (Platform.isAndroid) {
              timer = Timer(const Duration(seconds: 2), (() => reloadData()));
            }
            setState(() {
              initRun = false;
            });
          }
        });
      }
    } catch (err) {
      return dev.log('$err', name: tag);
    }
  }

  // SDK Integration
  Future<void> getLocationPermission() async {
    var module = LocationModuleValue();
    module.checkLocationPermission();
    module.locationPermissionStatus.subscribe((args) async {
      var data = args!.changedValue;
      dev.log("data for permission status --> $data", name: tag);
      setState(() {
        if (data.isEmpty) {
          status = 'no available status';
        } else {
          status = data;
        }
      });
      await getBeaconLocations();
    });
  }

  Future<void> getBeaconLocations() async {
    var module = IbeaconModuleValue();
    module.getIBeaconLocations();
    module.beaconLocations.subscribe((args) {
      var data = args!.changedValue;
      dev.log("Items in beacon locations --> ${data.length}", name: tag);
      setState(() {
        _beaconList = data;
      });
    });

    module.uuidValue.subscribe((args) {
      var data = args!.changedValue;
      dev.log("uuid --> $data", name: tag);

      setState(() {
        beaconId = data;
      });
    });
  }

  // displays location permissions status based on result from checkLocationStatus
  Widget locationStatus() {
    try {
      if (status.isNotEmpty) {
        status = status.toUpperCase();
      } else {
        return const Text("");
      }

      if (status == 'DENIED' ||
          status == 'RESTRICTED' ||
          status == 'DISABLED') {
        return Text("${status[0]}${status.substring(1).toLowerCase()}",
            style: const TextStyle(color: Colors.red));
      } else if (status == 'DELAYED') {
        return const Text('Delayed (Touch to enable)',
            style: TextStyle(color: Colors.black));
      } else if (status == 'ALWAYS') {
        return const Text('Enabled', style: TextStyle(color: Colors.green));
      } else if (status == 'ENABLED') {
        return const Text('Enabled (When in use)',
            style: TextStyle(color: Colors.orange));
      } else if (status == 'NO AVAILABLE STATUS') {
        return const Text('Not Available');
      }
    } catch (err) {
      dev.log('ERROR: $err', name: tag);
      return const Text('Not Available');
    }

    return const Text("");
  }

  @override
  void initState() {
    super.initState();
    permission = LocationsPermission.notInitialized;
    locationPermission();
  }

  reloadData() {
    getLocationPermission();
    locationStatus();
  }

  @override
  void dispose() {
    super.dispose();

    if (timer != null) {
      timer!.cancel();
    }
  }

  buildBeaconsList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _beaconList.length,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            card(_beaconList[index].major.toString(), false,
                body: _beaconList[index].id),
          ],
        );
      },
    );
  }

  Widget card(String title, bool largeText, {String? body, Widget? status}) {
    return Container(
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
        horizontal: 30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: largeText ? 18 : 14,
            ),
          ),
          if (body != null) ...[body.isNotEmpty ? Text(body) : const Text("")],
          if (status != null) ...[status]
        ],
      ),
    );
  }

  Widget beaconHeader(String title) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 10, left: 20),
      child: Text(
        title,
        style: const TextStyle(
          color: labelColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: const Text(
          'iBeacons',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.sync,
              color: Colors.black,
            ),
            onPressed: () async {
              if (permission == LocationsPermission.denied) {
                locationPermission();
              } else if (permission == LocationsPermission.always ||
                  permission == LocationsPermission.whileInUse) {
                reloadData();
              }
            },
          )
        ],
      ),
      body: Container(
        height: double.infinity,
        decoration: appBackgroundGradient,
        child: SingleChildScrollView(
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                beaconHeader('iBEACON FEATURE'),
                card('UUID', true, body: beaconId),
                card('Status', true, status: locationStatus()),
                beaconHeader('iBEACON MAJOR REGIONS'),
                _beaconList.isNotEmpty
                    ? buildBeaconsList()
                    : const SafeArea(child: Text(""))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
