part of '../../viam_flutter_provisioning_widget.dart';

class BluetoothProvisioningFlowViewModel extends ChangeNotifier {
  BluetoothProvisioningFlowViewModel({required this.viam, required this.robot, required this.mainRobotPart});

  final Viam viam;
  final Robot robot;
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
  }
}
