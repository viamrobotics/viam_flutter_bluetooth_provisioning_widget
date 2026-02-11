import 'dart:io';

import 'package:flutter/material.dart';

import 'reconnect_machines_screen.dart';
import 'provision_new_machine_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  void _goToNewMachineFlow(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ProvisionNewMachineScreen(),
    ));
  }

  void _goToReconnectMachinesFlow(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ReconnectRobotsScreen(),
    ));
  }

  Future<bool> _hasBluetoothPermissions() async {
    if (Platform.isAndroid) {
      final scanStatus = await Permission.bluetoothScan.request();
      final connectStatus = await Permission.bluetoothConnect.request();
      final locationStatus = await Permission.locationWhenInUse.request();

      return (scanStatus == PermissionStatus.granted &&
          connectStatus == PermissionStatus.granted &&
          locationStatus == PermissionStatus.granted);
    } else {
      // iOS will ask for permissions when try to start scanning
      // but you can also change this to ask before entering the flow
      return true;
    }
  }

  Future<void> _showPermissionsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text('Please grant the required permissions to continue.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
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
              key: ValueKey('new-machine-flow'),
              onPressed: () async {
                final hasPermissions = await _hasBluetoothPermissions();
                if (!context.mounted) return;
                if (hasPermissions) {
                  _goToNewMachineFlow(context);
                } else {
                  await _showPermissionsDialog(context);
                }
              },
              child: const Text('New Machine Flow'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: ValueKey('reconnect-flow'),
              onPressed: () async {
                final hasPermissions = await _hasBluetoothPermissions();
                if (!context.mounted) return;
                if (hasPermissions) {
                  _goToReconnectMachinesFlow(context);
                } else {
                  await _showPermissionsDialog(context);
                }
              },
              child: const Text('Reconnect Machines'),
            ),
          ],
        ),
      ),
    );
  }
}
