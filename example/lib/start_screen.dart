import 'package:flutter/material.dart';

import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';

import 'reconnect_machines_screen.dart';
import 'provision_new_machine_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  void _goToNewMachineFlow(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ProvisionNewRobotScreen(),
    ));
  }

  void _goToReconnectMachinesFlow(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ReconnectRobotsScreen(),
    ));
  }

  void _goToTetheringNewMachineFlow(BuildContext context) {
    // TODO: APP-8807 go to created tethering flow once new screens are ready
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => InternetYesNoScreen(
        handleYesTapped: () {},
        handleNoTapped: () {},
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Provisioning'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () => _goToNewMachineFlow(context),
              child: const Text('New Machine Flow'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _goToReconnectMachinesFlow(context),
              child: const Text('Reconnect Machines'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _goToTetheringNewMachineFlow(context),
              child: const Text('Tethering New Machine Flow'),
            ),
          ],
        ),
      ),
    );
  }
}
