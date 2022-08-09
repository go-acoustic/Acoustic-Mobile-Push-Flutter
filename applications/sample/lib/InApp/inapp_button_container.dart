import 'package:ca_mce_flutter_sdk_sample/constants.dart';
import 'package:flutter/material.dart';

class InAppButtonContainer extends StatelessWidget {
  const InAppButtonContainer({
    required this.buttonTitle,
    Key? key,
  }) : super(key: key);

  final String buttonTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: borderColor,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: SafeArea(
        bottom: false,
        child: Text(
          buttonTitle,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
