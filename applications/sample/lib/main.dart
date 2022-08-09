import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_acoustic_mobile_push_inbox/flutter_acoustic_mobile_push_inbox.dart';
import 'home_screen.dart';
import 'registration_details.dart';
import 'in_app.dart';
import 'custom_actions.dart';
import 'send_test_events.dart';
import 'send_user_attributes.dart';
import 'geofences.dart';
import 'ibeacons.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'home-screen',
      routes: {
        'home-screen': (context) => const HomeScreen(),
        '/registration-details': (context) => const RegistrationDetails(),
        '/inbox': (context) => Inbox(),
        '/in-app': (context) => const InApp(),
        '/custom-actions': (context) => const CustomActions(),
        '/send-test-events': (context) => const SendTestEvents(),
        '/send-user-attributes': (context) => const SendUserAttributes(),
        '/geofences': (context) => const Geofences(),
        '/ibeacons': (context) => const IBeacons()
      },
    );
  }
}
