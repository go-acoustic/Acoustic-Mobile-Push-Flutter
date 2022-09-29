// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';
import 'package:ca_mce_flutter_sdk_sample/location_request_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_geofence/flutter_acoustic_mobile_push_geofence.dart';
import 'package:flutter_acoustic_mobile_push_geofence/geofence/flutter_geofence_pay_load.dart';
import 'package:flutter_acoustic_mobile_push_location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:developer' as dev;

class Geofences extends StatefulWidget {
  const Geofences({Key? key}) : super(key: key);

  @override
  State<Geofences> createState() => _GeofencesState();
}

class _GeofencesState extends State<Geofences> {
  List<GeofencePayload> _geofenceTestList = [];
  Map<CircleId, Circle> setCircles = <CircleId, Circle>{};
  var module = GeofencesValue();

  CurrentPosition position = Location().defaultPosition;

  String tag = "Geofence";
  bool loadInProgress = true;
  bool wasPaused = false;
  bool initRun = true;

  Timer? timer;

  bool showDialog = false;

  late LocationsPermission permission;

  Future<void> determinePosition() async {
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

    await Location().getcurrentLocation().then((currentPosition) {
      dev.log(
          'CURRENT POSITION: ${currentPosition.latitude}, ${currentPosition.longitude}',
          name: tag);
      setState(() {
        position = currentPosition;
      });
    });
  }

  Future<void> locationPermissions() async {
    try {
      await determinePosition().then((_) {
        onLocationsPermissionGranted();

        if (initRun) {
          if (Platform.isAndroid) {
            timer = Timer(
                const Duration(seconds: 2), (() => locationPermissions()));
          }
          setState(() {
            initRun = false;
          });
        }
      });
    } catch (err) {
      return dev.log('$err', name: tag);
    }
  }

  createGeofences() {
    for (var geofence in _geofenceTestList) {
      double geoLat = geofence.latitude;
      double geoLong = geofence.longitude;
      int geoRad = geofence.radius;
      String id = geofence.id;
      final CircleId circleId = CircleId(id);

      if (!setCircles.containsKey(circleId)) {
        dev.log('geoData: $id, $geoLat, $geoLong, $geoRad', name: tag);

        final Circle circle = Circle(
            circleId: circleId,
            center: LatLng(geoLat, geoLong),
            radius: geoRad.toDouble(),
            strokeWidth: 1,
            fillColor: const Color.fromRGBO(102, 51, 153, 0.4));

        setState(() {
          setCircles[circleId] = circle;
        });
      }
    }

    setState(() {
      loadInProgress = false;
    });
  }

  Future<void> getGeofence(latitude, longitude) async {
    module
        .geofencesNearCoordinate(GeofencePayload(latitude, longitude, 100000));
    module.geofenceLocations.subscribe((args) {
      setState(() {
        _geofenceTestList = args!.changedValue;
        dev.log('GEOFENCE DATA ITEMS: ${_geofenceTestList.length}', name: tag);
      });

      createGeofences();
    });
  }

  Future<void> onLocationsPermissionGranted() async {
    permission = await Location().checkLocationPermission().then((value) async {
      if (value == LocationsPermission.always ||
          value == LocationsPermission.whileInUse) {
        await module.sendLocationPermission().then((value) async {
          getGeofence(position.latitude, position.longitude);
        });
      }
      return value;
    });
  }

  permissionHandlerUI() {
    if (permission == LocationsPermission.deniedForever ||
        permission == LocationsPermission.denied) {
      return const Center(child: Text('Permission Status: Denied'));
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  @override
  void initState() {
    super.initState();
    loadInProgress = true;
    permission = LocationsPermission.notInitialized;
    locationPermissions();
  }

  @override
  void dispose() {
    super.dispose();

    if (timer != null) {
      timer!.cancel();
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
              if (permission == LocationsPermission.whileInUse ||
                  permission == LocationsPermission.always) {
                setState(() {
                  loadInProgress = true;
                });
                locationPermissions();
              }
            },
          )
        ],
      ),
      body: Container(
          child: loadInProgress
              ? permissionHandlerUI()
              : GoogleMap(
                  mapType: MapType.normal,
                  zoomControlsEnabled: true,
                  zoomGesturesEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(position.latitude, position.longitude),
                    zoom: 12,
                  ),
                  circles: Set<Circle>.of(setCircles.values),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                )),
    );
  }
}
