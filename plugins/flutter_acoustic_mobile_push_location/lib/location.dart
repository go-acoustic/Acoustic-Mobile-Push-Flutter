import 'package:flutter_acoustic_mobile_push_location/flutter_acoustic_mobile_push_location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_settings/app_settings.dart';
import 'dart:io' show Platform;

/// Represent the possible location permissions.
enum LocationsPermission {
  /// Permission to access the device's location is denied, the App should try
  /// to request permission using the `Geolocator.requestPermission()` method.
  denied,

  /// Permission to access the device's location is permenantly denied. When
  /// requestiong permissions the permission dialog will not been shown until
  /// the user updates the permission in the App settings.
  deniedForever,

  /// Permission to access the device's location is allowed only while
  /// the App is in use.
  whileInUse,

  /// Permission to access the device's location is allowed even when the
  /// App is running in the background.
  always,

  /// Permission status is cannot be determined. This permission is only
  /// returned by the `Geolocator.checkPermission()` method on the web platform
  /// for browsers that do not implement the Permission API (see https://developer.mozilla.org/en-US/docs/Web/API/Permissions_API).
  unableToDetermine,

  /// Permission status has not yet initialized
  /// To be used when using late variable
  notInitialized
}

class CurrentPosition {
  /// The latitude of this position in degrees normalized to the interval -90.0
  /// to +90.0 (both inclusive).
  final double latitude;

  /// The longitude of the position in degrees normalized to the interval -180
  /// (exclusive) to +180 (inclusive).
  final double longitude;

  /// The time at which this position was determined.
  final DateTime? timestamp;

  /// The altitude of the device in meters.
  ///
  /// The altitude is not available on all devices. In these cases the returned
  /// value is 0.0.
  final double altitude;

  /// The estimated horizontal accuracy of the position in meters.
  ///
  /// The accuracy is not available on all devices. In these cases the value is
  /// 0.0.
  final double accuracy;

  /// The heading in which the device is traveling in degrees.
  ///
  /// The heading is not available on all devices. In these cases the value is
  /// 0.0.
  final double heading;

  /// The floor specifies the floor of the building on which the device is
  /// located.
  ///
  /// The floor property is only available on iOS and only when the information
  /// is available. In all other cases this value will be null.
  final int? floor;

  /// The speed at which the devices is traveling in meters per second over
  /// ground.
  ///
  /// The speed is not available on all devices. In these cases the value is
  /// 0.0.
  final double speed;

  /// The estimated speed accuracy of this position, in meters per second.
  ///
  /// The speedAccuracy is not available on all devices. In these cases the
  /// value is 0.0.
  final double speedAccuracy;

  /// Will be true on Android (starting from API lvl 18) when the location came
  /// from the mocked provider.
  ///
  /// On iOS this value will always be false.
  final bool isMocked;
  const CurrentPosition({
    required this.longitude,
    required this.latitude,
    required this.timestamp,
    required this.accuracy,
    required this.altitude,
    required this.heading,
    required this.speed,
    required this.speedAccuracy,
    this.floor,
    this.isMocked = false,
  });
}

class Location {
  var accuracy = LocationAccuracy.reduced;
  CurrentPosition defaultPosition = CurrentPosition(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);

  Future<LocationsPermission> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      return LocationsPermission.denied;
    } else if (permission == LocationPermission.deniedForever) {
      return LocationsPermission.deniedForever;
    } else if (permission == LocationPermission.whileInUse) {
      return LocationsPermission.whileInUse;
    } else if (permission == LocationPermission.always) {
      return LocationsPermission.always;
    }
    return LocationsPermission.unableToDetermine;
  }

  setLocationAccuracy() async {
    if (Platform.isIOS) {
      var module = LocationModuleValue();
      double data = await module.getLocationAccuracy();
      if (data == 3000.0) {
        accuracy = LocationAccuracy.lowest;
      } else if (data == 1000.0) {
        accuracy = LocationAccuracy.low;
      } else if (data == 100.0) {
        accuracy = LocationAccuracy.medium;
      } else if (data == 10.0) {
        accuracy = LocationAccuracy.high;
      } else if (data == -1) {
        accuracy = LocationAccuracy.best;
      }
    } else {
      accuracy = LocationAccuracy.best;
    }
  }

  Future<int> getLocationRadius() async {
    var module = LocationModuleValue();
    int data = await module.getLocationSearchRadius();
    return data;
  }

  Future<CurrentPosition> getcurrentLocation() async {
    await setLocationAccuracy();

    Position position =
        await Geolocator.getCurrentPosition(desiredAccuracy: accuracy);
    CurrentPosition currentPosition = CurrentPosition(
        longitude: position.longitude,
        latitude: position.latitude,
        timestamp: position.timestamp,
        accuracy: position.accuracy,
        altitude: position.altitude,
        heading: position.heading,
        speed: position.speed,
        speedAccuracy: position.speedAccuracy);
    return currentPosition;
  }

  requestDevicePermission(bool exit) {
    if (exit) {
      if (Platform.isIOS) {
        AppSettings.openAppSettings();
      } else {
        Geolocator.requestPermission();
      }
    }
  }
}
