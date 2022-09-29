import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_location/location.dart';

class RequestDialog {
  showPermission(context) {
    showDialog(
      context: context,
      useRootNavigator: false,
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
      if (exit != null) {
        Location().requestDevicePermission(exit);
      }
    });
  }
}
