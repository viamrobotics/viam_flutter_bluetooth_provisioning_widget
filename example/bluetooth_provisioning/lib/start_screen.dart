import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bluetooth_provisioning_flow.dart';
import 'view_model.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  void _goToIntroScreenOne(BuildContext context) async {
    // Navigator.of(context).push(MaterialPageRoute(
    //   builder: (context) => ChangeNotifierProvider(
    //     create: (context) => BluetoothProvisioningFlowViewModel(
    //       viam: AuthService.authenticatedViam,
    //       robot: Robot(id: ''),
    //       mainRobotPart: RobotPart(id: ''),
    //     ),
    //     builder: (context, child) => BluetoothProvisioningFlow(),
    //   ),
    // ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Provisioning'),
      ),
      body: Center(
        child: FilledButton(
          onPressed: () => _goToIntroScreenOne(context),
          child: const Text('Start Flow'),
        ),
      ),
    );
  }

  // TODO: add the api key stuff.. from hotspot example
}
