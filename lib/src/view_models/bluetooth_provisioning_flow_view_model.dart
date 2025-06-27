part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class BluetoothProvisioningFlowViewModel extends ChangeNotifier {
  BluetoothProvisioningFlowViewModel({required this.viam, required this.robot, required mainRobotPart}) : _mainRobotPart = mainRobotPart;

  final Viam viam;
  final Robot robot;
  final RobotPart _mainRobotPart;

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
        partId: _mainRobotPart.id,
        secret: _mainRobotPart.secret,
      );
    }
    await _connectedDevice!.writeNetworkConfig(ssid: ssid, pw: psk);
    await _connectedDevice!.exitProvisioning();
  }
}
