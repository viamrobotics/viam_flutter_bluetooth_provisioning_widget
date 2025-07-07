part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class BluetoothProvisioningFlowViewModel extends ChangeNotifier {
  BluetoothProvisioningFlowViewModel({
    required this.viam,
    required this.robot,
    required this.isNewMachine,
    required this.connectBluetoothDeviceRepository,
    required mainRobotPart,
    required String psk,
  })  : _mainRobotPart = mainRobotPart,
        _psk = psk;
  final Viam viam;
  final Robot robot;
  final bool isNewMachine;
  final ConnectBluetoothDeviceRepository connectBluetoothDeviceRepository;

  final RobotPart _mainRobotPart;
  final String _psk;
  BluetoothDevice? get device => connectBluetoothDeviceRepository.device;

  Future<void> writeConfig({required String ssid, required String? password}) async {
    await connectBluetoothDeviceRepository.writeConfig(
      ssid: ssid,
      password: password,
      mainRobotPart: _mainRobotPart,
      psk: _psk,
    );
  }
}
