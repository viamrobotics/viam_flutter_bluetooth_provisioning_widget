import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:viam_sdk/viam_sdk.dart';
// ignore: depend_on_referenced_packages
import 'package:viam_sdk/protos/app/app.dart';
import 'package:viam_flutter_provisioning_widget/viam_flutter_provisioning_widget.dart';

import 'consts.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  String? _robotName;
  bool _isLoading = false;

  Future<void> _createRobot() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final viam = await Viam.withApiKey(Consts.apiKeyId, Consts.apiKey);
      final location = await viam.appClient.createLocation(Consts.organizationId, 'test-location-${Random().nextInt(1000)}');
      final String robotName = "tester-${Random().nextInt(1000)}";
      setState(() {
        _robotName = robotName;
      });
      debugPrint('robotName: $robotName, locationId: ${location.name}');
      final robotId = await viam.appClient.newMachine(robotName, location.id);
      final robot = await viam.appClient.getRobot(robotId);
      final mainPart = (await viam.appClient.listRobotParts(robotId)).firstWhere((element) => element.mainPart);
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        _goToBluetoothProvisioningFlow(context, viam, robot, mainPart);
      }
    } catch (e) {
      debugPrint('Error initializing Viam: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _robotName = null;
      });
    }
  }

  void _goToBluetoothProvisioningFlow(BuildContext context, Viam viam, Robot robot, RobotPart mainPart) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChangeNotifierProvider(
        create: (context) => BluetoothProvisioningFlowViewModel(
          viam: viam,
          robot: robot,
          mainRobotPart: mainPart,
        ),
        builder: (context, child) => BluetoothProvisioningFlow(onSuccess: () {
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_robotName != null) Text('Provisioning machine named: $_robotName'),
            if (_robotName != null) const SizedBox(height: 16),
            FilledButton(
              onPressed: _createRobot,
              child: _isLoading ? const CircularProgressIndicator.adaptive(backgroundColor: Colors.white) : const Text('Start Flow'),
            ),
          ],
        ),
      ),
    );
  }
}
