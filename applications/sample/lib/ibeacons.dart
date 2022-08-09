import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_geofence/flutter_acoustic_mobile_push_geofence.dart';
import 'package:flutter_acoustic_mobile_push_location/flutter_acoustic_mobile_push_location.dart';
import 'package:flutter_acoustic_mobile_push_beacon/flutter_acoustic_mobile_push_beacon.dart';
import 'package:permission_handler/permission_handler.dart';
import 'constants.dart';
import 'dart:developer' as dev;
import 'package:geolocator/geolocator.dart' as geo;
import 'dart:io' show Platform;
import 'package:app_settings/app_settings.dart';

class IBeacons extends StatefulWidget {
  const IBeacons({Key? key}) : super(key: key);

  @override
  State<IBeacons> createState() => _IBeaconsState();
}

class _IBeaconsState extends State<IBeacons> with WidgetsBindingObserver {
  List _beaconList = [];

  dynamic beaconId;
  dynamic status = "NO AVAILABLE STATUS";

  String tag = "IBeacons";
  String permissionStatus = "";

  geo.Position? position;
  late geo.LocationPermission permission;

  Future<void> initLocationPermissions() async {
    try {
      position = await _determinePosition().then((value) {
        getLocation();
        getBeaconLocations();
        bluetoothScanPermission();
        return value;
      });
    } catch (err) {
      return dev.log('$err loaction permissions denied', name: tag);
    }
  }

  Future<void> getLocation() async {
    var module = GeofencesValue();
    await module.sendLocationPermission();

    await getLocationPermission();

    dev.log('CURRENT POSITION: ${position?.latitude}, ${position?.longitude}',
        name: tag);
  }

  Future<geo.Position> _determinePosition() async {
    bool serviceEnabled;

    serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await geo.Geolocator.checkPermission();

    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        setState(() {
          permissionStatus = "denied";
        });
        return Future.error('Location permissions are denied');
      } else if (permission == geo.LocationPermission.deniedForever) {
        setState(() {
          status = "DENIED";
        });
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
    }

    if (permission == geo.LocationPermission.whileInUse ||
        permission == geo.LocationPermission.always) {
      setState(() {
        permissionStatus = "";
      });
    }

    dev.log('PERMISSION STATUS: $permission', name: tag);

    if (permission == geo.LocationPermission.whileInUse ||
        permission == geo.LocationPermission.deniedForever) {
      showPermissionDialog();
    }

    return await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high);
  }

  showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String platformText =
            'select the "Allow all the time" option in the permissions menu.';

        if (Platform.isIOS) {
          platformText = 'select the "Always" option in the Location menu.';
        }
        return AlertDialog(
          title: const Text('Permission Required'),
          content: Text(
              'This app requires your permission to access location information in the background. This is used to detect geofences while the app is in the background. To grant this permission, $platformText'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Grant Permission'),
            ),
          ],
        );
      },
    ).then((exit) {
      if (exit != null && exit) {
        if (Platform.isIOS) {
          AppSettings.openAppSettings();
        } else {
          geo.Geolocator.requestPermission();
        }
      }
    });
  }

  Future bluetoothScanPermission() async {
    final bluetoothScan = await Permission.bluetoothScan.status;
    // ignore: unrelated_type_equality_checks, unused_local_variable
    bool isBluetoothScanOn = bluetoothScan == ServiceStatus.enabled;
    final bluetoothStatus = await Permission.bluetoothScan.request();

    if (bluetoothStatus == PermissionStatus.granted) {
      dev.log('BLUETOOTH_SCAN permission granted', name: tag);
    } else if (bluetoothStatus == PermissionStatus.denied) {
      dev.log('BLUETOOTH_SCAN permission denied', name: tag);
    } else if (bluetoothStatus == PermissionStatus.permanentlyDenied) {
      dev.log('BLUETOOTH_SCAN permission permanently denied', name: tag);
    }
  }

  // SDK Integration
  Future<void> getLocationPermission() async {
    var module = LocationModuleValue();
    module.checkLocationPermission();
    module.locationPermissionStatus.subscribe((args) {
      var data = args!.changedValue;
      dev.log("data for permission status --> $data", name: tag);
      setState(() {
        if (data.isEmpty) {
          status = 'no available status';
        } else {
          status = data;
        }
      });
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
  locationStatus() {
    try {
      if (status != null) {
        status = status.toUpperCase();
      } else {
        return const Text("");
      }

      if (status == 'DENIED') {
        return const Text('Denied', style: TextStyle(color: Colors.red));
      } else if (status == 'DELAYED') {
        return const Text('Delayed (Touch to enable)',
            style: TextStyle(color: Colors.black));
      } else if (status == 'ALWAYS') {
        return const Text('Enabled', style: TextStyle(color: Colors.green));
      } else if (status == 'RESTRICTED') {
        return const Text('Restricted', style: TextStyle(color: Colors.red));
      } else if (status == 'ENABLED') {
        return const Text('Enabled (When in use)',
            style: TextStyle(color: Colors.orange));
      } else if (status == 'DISABLED') {
        return const Text('Disabled', style: TextStyle(color: Colors.red));
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
    initLocationPermissions();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      permission = await geo.Geolocator.checkPermission();

      if (permission == geo.LocationPermission.always) {
        reloadData();
      }
    }
  }

  reloadData() {
    getLocationPermission();
    getBeaconLocations();
    locationStatus();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  buildBeaconsList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _beaconList.length,
      itemBuilder: (context, index) {
        var major = _beaconList[index].major;
        var regionId = _beaconList[index].id;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      major != null ? '$major' : '',
                      style: const TextStyle(
                        color: beaconListTitleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      regionId != null ? '$regionId' : '',
                      style: const TextStyle(
                        color: beaconListSubTitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color labelColor = Colors.white;

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
              if (permission == geo.LocationPermission.whileInUse) {
                showPermissionDialog();
              } else if (permission == geo.LocationPermission.denied) {
                initLocationPermissions();
              } else if (permission == geo.LocationPermission.always) {
                reloadData();
              }
            },
          )
        ],
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(
                bottom: false,
                child: Container(
                  padding: const EdgeInsets.only(top: 50, bottom: 10, left: 20),
                  child: Text(
                    'iBEACON FEATURE',
                    style: TextStyle(
                      color: labelColor,
                    ),
                  ),
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
                      'UUID',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    (beaconId != null && beaconId != "")
                        ? Text('$beaconId')
                        : const Text('Not Available'),
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
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    locationStatus(),
                  ],
                ),
              ),
              SafeArea(
                bottom: false,
                child: Container(
                  padding: const EdgeInsets.only(top: 50, bottom: 10, left: 20),
                  child: Text(
                    'iBEACON MAJOR REGIONS',
                    style: TextStyle(
                      color: labelColor,
                    ),
                  ),
                ),
              ),
              _beaconList.isNotEmpty
                  ? buildBeaconsList()
                  : const SafeArea(child: Text(""))
            ],
          ),
        ),
      ),
    );
  }
}
