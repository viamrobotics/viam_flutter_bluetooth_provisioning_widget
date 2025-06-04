import 'package:flutter/material.dart';
import 'package:viam_flutter_provisioning_widget/viam_flutter_provisioning_widget.dart';
import 'package:viam_sdk/protos/app/app.dart';
import 'package:viam_sdk/viam_sdk.dart';

// TODO: This can end up in library as part of https://viam.atlassian.net/browse/APP-8323
class BluetoothProvisioningFlowViewModel extends ChangeNotifier {
  BluetoothProvisioningFlowViewModel({required this.viam, required this.robot, required this.mainRobotPart});

  final Viam viam; // TODO: maybe keeping
  final Robot robot; // TODO: for testing, we'll start with it
  final RobotPart mainRobotPart;

  BluetoothDevice? _connectedDevice;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  set connectedDevice(BluetoothDevice? device) {
    _connectedDevice = device;
    notifyListeners();
  }

  Future<void> writeConfig({required String ssid, required String? psk}) async {
    if (_connectedDevice == null) {
      throw Exception('No connected device');
    }

    final status = await _connectedDevice!.readStatus();
    // don't overwrite existing machine, hotspot provisioning also does this check
    if (!status.isConfigured) {
      await _connectedDevice!.writeRobotPartConfig(
        partId: mainRobotPart.id,
        secret: mainRobotPart.secret,
      );
    }
    await _connectedDevice!.writeNetworkConfig(ssid: ssid, pw: psk);
    // can safely disconnect after writing config
    await _connectedDevice!.disconnect();
  }
}
