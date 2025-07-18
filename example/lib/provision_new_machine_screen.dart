import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';

import 'consts.dart';
import 'utils.dart';

class ProvisionNewRobotScreen extends StatefulWidget {
  const ProvisionNewRobotScreen({super.key});

  @override
  State<ProvisionNewRobotScreen> createState() => _ProvisionNewRobotScreenState();
}

class _ProvisionNewRobotScreenState extends State<ProvisionNewRobotScreen> {
  String? _robotName;
  bool _isLoading = false;
  String? _errorString;

  Future<void> _createRobot() async {
    setState(() {
      _isLoading = true;
      _errorString = null;
    });
    try {
      final viam = await Viam.withApiKey(Consts.apiKeyId, Consts.apiKey);
      final (robot, mainPart) = await Utils.createRobot(viam);
      setState(() {
        _robotName = robot.name;
      });
      await Future.delayed(const Duration(seconds: 3)); // delay is intentional, so you can see the robot name
      if (mounted) {
        _goToBluetoothProvisioningFlow(context, viam, robot, mainPart);
      }
    } catch (e) {
      debugPrint('Error creating robot: ${e.toString()}');
      setState(() {
        _errorString = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
        _robotName = null;
      });
    }
  }

  void _goToBluetoothProvisioningFlow(BuildContext context, Viam viam, Robot robot, RobotPart mainPart) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChangeNotifierProvider(
        create: (context) => BluetoothProvisioningFlowViewModel(
          viam: viam,
          robot: robot,
          isNewMachine: true,
          mainRobotPart: mainPart,
          psk: Consts.psk,
          fragmentId: null,
          connectBluetoothDeviceRepository: ConnectBluetoothDeviceRepository(),
        ),
        builder: (context, child) => BluetoothProvisioningFlow(onSuccess: () {
          Navigator.of(context).pop();
        }, handleAgentConfigured: () {
          Navigator.of(context).pop();
        }, existingMachineExit: () {
          Navigator.of(context).pop();
        }, nonexistentMachineExit: () {
          Navigator.of(context).pop();
        }, agentMinimumVersionExit: () {
          Navigator.of(context).pop();
        }),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Provisioning'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_robotName != null) Text('Provisioning machine named: $_robotName'),
            if (_robotName != null) const SizedBox(height: 16),
            Center(
              child: FilledButton(
                onPressed: _createRobot,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator.adaptive(backgroundColor: Colors.white),
                      )
                    : const Text('Start Flow'),
              ),
            ),
            if (_errorString != null) const SizedBox(height: 16),
            if (_errorString != null) Text(_errorString!),
          ],
        ),
      ),
    );
  }
}
