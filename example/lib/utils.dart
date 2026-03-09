import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';

class Utils {
  static Future<(Robot robot, RobotPart mainPart)> createRobot(Viam viam) async {
    final String robotName = "ble-provisioning-${Random().nextInt(1000)}";
    final robotId = await viam.appClient.newMachine(robotName, dotenv.env['LOCATION_ID']!);
    debugPrint('created robot: $robotName');
    final robot = await viam.appClient.getRobot(robotId);
    final mainPart = (await viam.appClient.listRobotParts(robotId)).firstWhere((element) => element.mainPart);
    return (robot, mainPart);
  }
}
