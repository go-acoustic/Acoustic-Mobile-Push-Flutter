import 'package:ca_mce_flutter_sdk_sample/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acoustic_mobile_push_inbox/inbox/messages/inbox_messages.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    runInboxMessageAction() {
      Future<void> getInboxMessageAction() async {
        const MethodChannel('flutter_acoustic_mobile_push_inbox')
            .invokeMethod('registerInboxComponent');

        const MethodChannel('flutter_acoustic_mobile_push_inbox_receiver')
            .setMethodCallHandler((methodCall) async {
          methodCall.method;
          if (methodCall.method == "inboxMessageNotification") {
            Navigator.of(context).popUntil((route) => route.isFirst);
            String notificationResponseId = methodCall.arguments.toString();
            Navigator.push(
                context,
                MaterialPageRoute(
                    settings: const RouteSettings(name: '/inbox'),
                    builder: (context) => Inbox(
                          messageNotificationId: notificationResponseId,
                        )));
          }
        });
      }

      getInboxMessageAction();
      return;
    }

    runInboxMessageAction();

    mainNav() {
      return ListView(
        children: const [
          MainNavWidget(
              backOutButton: '/registration-details',
              mainButtonTitle: 'Registration Details'),
          MainNavWidget(backOutButton: '/inbox', mainButtonTitle: 'Inbox'),
          MainNavWidget(backOutButton: '/in-app', mainButtonTitle: 'InApp'),
          MainNavWidget(
              backOutButton: '/custom-actions',
              mainButtonTitle: 'Custom Actions'),
          MainNavWidget(
              backOutButton: '/send-test-events',
              mainButtonTitle: 'Send Test Events'),
          MainNavWidget(
              backOutButton: '/send-user-attributes',
              mainButtonTitle: 'Send User Attributes'),
          MainNavWidget(
              backOutButton: '/geofences', mainButtonTitle: 'Geofences'),
          MainNavWidget(backOutButton: '/ibeacons', mainButtonTitle: 'iBeacons')
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Sample App',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: appBackgroundGradient,
            height: (MediaQuery.of(context).orientation == Orientation.portrait)
                ? 250
                : 100,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'acoustic',
                    style: TextStyle(
                      fontSize: 37,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Campaign',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(19, 23, 61, 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: mainNav()),
        ],
      ),
    );
  }
}

class MainNavWidget extends StatelessWidget {
  const MainNavWidget(
      {required this.backOutButton, required this.mainButtonTitle, Key? key})
      : super(key: key);

  final String backOutButton;
  final String mainButtonTitle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed((context), backOutButton);
      },
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: Color.fromRGBO(19, 23, 61, 0.5),
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mainButtonTitle,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color.fromRGBO(19, 23, 61, 1),
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
