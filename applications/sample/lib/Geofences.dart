// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_geofence/flutter_acoustic_mobile_push_geofence.dart';
import 'package:flutter_acoustic_mobile_push_geofence/geofence/flutter_geofence_pay_load.dart';
import 'package:flutter_acoustic_mobile_push_location/flutter_acoustic_mobile_push_location.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as dev;
import 'dart:io' show Platform;
import 'package:app_settings/app_settings.dart';

class Geofences extends StatefulWidget {
  const Geofences({Key? key}) : super(key: key);

  @override
  State<Geofences> createState() => _GeofencesState();
}

class _GeofencesState extends State<Geofences> with WidgetsBindingObserver {
  var uuid = const Uuid();
  var module = GeofencesValue();

  geo.Position position = geo.Position(
      longitude: 37.33233141,
      latitude: -122.0312186,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0);

  String tag = "Geofence";
  String permissionStatus = "";
  Timer? timer;
  bool initRun = true;
  bool loadInProgress = true;

  List _geofenceTestList = [];
  Set<Circle> geofenceCirclesList = {};

  // ignore: unused_field
  late LatLng _lastMapPosition;
  late geo.LocationPermission permission;

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
          permissionStatus = "deniedForever";
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

  Future<void> initLocationPermissions() async {
    try {
      geo.Position getPosition = await _determinePosition();

      setState(() {
        position = getPosition;
      });
      dev.log('CURRENT POSITION: ${position.latitude}, ${position.longitude}',
          name: tag);

      if (permission == geo.LocationPermission.always) {
        geofenceDataSetup();
      }
    } catch (err) {
      return dev.log('$err loaction permissions denied', name: tag);
    }
  }

  Future<void> getLocationPermission() async {
    var module = LocationModuleValue();
    module.checkLocationPermission();
    module.locationPermissionStatus.subscribe((args) {
      var data = args!.changedValue;
      dev.log("data --> $data", name: tag);
    });
  }

  createGeofences() {
    for (var i = 0; i < _geofenceTestList.length; i++) {
      var geoLat = _geofenceTestList[i].latitude;
      var geoLong = _geofenceTestList[i].longitude;
      var geoRad = _geofenceTestList[i].radius;

      dev.log('geoData: $i $geoLat, $geoLong, $geoRad', name: tag);

      geofenceCirclesList.add(Circle(
        circleId: CircleId(
          uuid.v4().toString(),
        ),
        center: LatLng(geoLat, geoLong),
        radius: geoRad.toDouble(),
        strokeWidth: 1,
        fillColor: const Color.fromRGBO(102, 51, 153, 0.4),
      ));
    }
    setState(() {
      loadInProgress = false;
      initRun = false;
    });
  }

  Future<void> testGeofence(latitude, longitude) async {
    dev.log('COORDS: $latitude, $longitude', name: tag);

    module
        .geofencesNearCoordinate(GeofencePayload(latitude, longitude, 100000));
    module.geofenceLocations.subscribe((args) {
      var data = args!.changedValue;
      setState(() {
        _geofenceTestList = data;
        dev.log('GEOFENCE DATA ITEMS: ${_geofenceTestList.length}', name: tag);
      });

      if (initRun) {
        timer = Timer(
          const Duration(seconds: 1),
          () {
            initLocationPermissions().then((value) => createGeofences());

            setState(() {
              initRun = false;
            });
          },
        );
      } else {
        createGeofences();
      }
    });
  }

  geofenceDataSetup() async {
    permission = await geo.Geolocator.checkPermission().then((value) async {
      if (value == geo.LocationPermission.always) {
        await module.sendLocationPermission().then((value) async {
          await getLocationPermission().then((value) {
            testGeofence(position.latitude, position.longitude);
          });
        });
      }

      return value;
    });
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  permissionHandlerUI() {
    if (permissionStatus == "deniedForever" || permissionStatus == "denied") {
      return const Center(child: Text('Permission Status: Denied'));
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadInProgress = true;
    initLocationPermissions();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      geofenceDataSetup();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);

    if (timer != null) {
      timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: const Text(
          'Geofences',
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
            onPressed: () {
              if (permission == geo.LocationPermission.whileInUse) {
                showPermissionDialog();
              }

              setState(() {
                loadInProgress = true;
              });
              initLocationPermissions();
            },
          )
        ],
      ),
      body: Container(
          child: loadInProgress
              ? permissionHandlerUI()
              : GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(position.latitude, position.longitude),
                    zoom: 12,
                  ),
                  circles: geofenceCirclesList,
                  onCameraMove: _onCameraMove,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                )),
    );
  }
}
