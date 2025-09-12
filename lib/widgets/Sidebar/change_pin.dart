import 'package:flutter/material.dart';
import 'package:mywallet/screens/Pin/pin.dart';

class ChangePinPage extends StatelessWidget {
  const ChangePinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PinScreen(mode: PinMode.change, hasPin: true);
  }
}
