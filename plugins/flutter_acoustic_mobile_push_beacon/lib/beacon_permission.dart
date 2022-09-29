import 'package:permission_handler/permission_handler.dart';

enum StatusPermission {
  /// The user denied access to the requested feature.
  denied,

  /// The user granted access to the requested feature.
  granted,

  /// The OS denied access to the requested feature. The user cannot change
  /// this app's status, possibly due to active restrictions such as parental
  /// controls being in place.
  /// *Only supported on iOS.*
  restricted,

  ///User has authorized this application for limited access.
  /// *Only supported on iOS (iOS14+).*
  limited,

  /// Permission to the requested feature is permanently denied, the permission
  /// dialog will not be shown when requesting this permission. The user may
  /// still change the permission status in the settings.
  /// *Only supported on Android.*
  permanentlyDenied,
}

class BeaconBluetooth {
  Future<StatusPermission> scanPermission() async {
    final bluetoothStatus = await Permission.bluetoothScan.request();

    if (bluetoothStatus == PermissionStatus.denied) {
      return StatusPermission.denied;
    } else if (bluetoothStatus == PermissionStatus.granted) {
      return StatusPermission.granted;
    } else if (bluetoothStatus == PermissionStatus.restricted) {
      return StatusPermission.restricted;
    } else if (bluetoothStatus == PermissionStatus.limited) {
      return StatusPermission.limited;
    } else {
      return StatusPermission.permanentlyDenied;
    }
  }
}
