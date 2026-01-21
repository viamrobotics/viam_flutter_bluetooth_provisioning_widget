import 'dart:math';

import 'package:flutter/material.dart';
import 'package:viam_sdk/protos/app/app.dart';
import 'package:viam_sdk/viam_sdk.dart';

import 'consts.dart';

class Utils {
  static Future<(Robot robot, RobotPart mainPart)> createRobot(Viam viam) async {
    final location = await viam.appClient.createLocation(Consts.organizationId, 'test-location-${Random().nextInt(1000)}');
    final String robotName = "tester-${Random().nextInt(1000)}";
    final robotId = await viam.appClient.newMachine(robotName, location.id);
    debugPrint('created robot: $robotName, at location: ${location.name}');
    final robot = await viam.appClient.getRobot(robotId);
    final mainPart = (await viam.appClient.listRobotParts(robotId)).firstWhere((element) => element.mainPart);
    return (robot, mainPart);
  }
}
