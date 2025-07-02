part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class BluetoothProvisioningFlowViewModel extends ChangeNotifier {
  BluetoothProvisioningFlowViewModel({
    required this.viam,
    required this.robot,
    required mainRobotPart,
    required String psk,
  })  : _mainRobotPart = mainRobotPart,
        _psk = psk;

  final Viam viam;
  final Robot robot;
  final RobotPart _mainRobotPart;
  final String _psk;

  BluetoothDevice? _connectedDevice;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  set connectedDevice(BluetoothDevice? device) {
    _connectedDevice = device;
    notifyListeners();
  }

  Future<void> writeConfig({required String ssid, required String? password}) async {
    if (_connectedDevice == null) {
      throw Exception('No connected device');
    }

    final status = await _connectedDevice!.readStatus();
    // don't overwrite existing machine, hotspot provisioning also does this check
    if (!status.isConfigured) {
      await _connectedDevice!.writeRobotPartConfig(
        partId: _mainRobotPart.id,
        secret: _mainRobotPart.secret,
        psk: _psk,
      );
    }
    await _connectedDevice!.writeNetworkConfig(ssid: ssid, pw: password, psk: _psk);
    await _connectedDevice!.exitProvisioning(psk: _psk);
  }
}
