import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:viam_sdk/viam_sdk.dart';
// ignore: depend_on_referenced_packages
import 'package:viam_sdk/protos/app/app.dart';

import 'bluetooth_provisioning_flow.dart';
import 'view_model.dart';
import 'consts.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  Viam? _viam;
  Robot? _robot;
  RobotPart? _mainPart;

  @override
  void initState() {
    super.initState();
    _initViam();
  }

  void _goToIntroScreenOne(BuildContext context, Viam viam, Robot robot, RobotPart mainPart) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChangeNotifierProvider(
        create: (context) => BluetoothProvisioningFlowViewModel(
          viam: viam,
          robot: robot,
          mainRobotPart: mainPart,
        ),
        builder: (context, child) => BluetoothProvisioningFlow(),
      ),
    ));
  }

  Future<void> _initViam() async {
    try {
      _viam = await Viam.withApiKey(Consts.apiKeyId, Consts.apiKey);
      _createRobot(_viam!);
    } catch (e) {
      debugPrint('Error initializing Viam: $e');
    }
  }

  Future<void> _createRobot(Viam viam) async {
    final location = await viam.appClient.createLocation(Consts.organizationId, 'test-location-${Random().nextInt(1000)}');
    final String robotName = "tester-${Random().nextInt(1000)}";
    debugPrint('robotName: $robotName, locationId: ${location.name}');
    final robotId = await viam.appClient.newMachine(robotName, location.id);
    _robot = await viam.appClient.getRobot(robotId);
    _mainPart = (await viam.appClient.listRobotParts(robotId)).firstWhere((element) => element.mainPart);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Provisioning'),
      ),
      body: Center(
        child: FilledButton(
          onPressed: () => _goToIntroScreenOne(
            context,
            _viam!,
            _robot!,
            _mainPart!,
          ),
          child: const Text('Start Flow'),
        ),
      ),
    );
  }
}
