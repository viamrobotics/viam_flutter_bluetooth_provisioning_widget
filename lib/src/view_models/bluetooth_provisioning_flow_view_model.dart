part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class BluetoothProvisioningFlowViewModel extends ChangeNotifier {
  BluetoothProvisioningFlowViewModel({
    required this.viam,
    required this.robot,
    required this.isNewMachine,
    required this.connectBluetoothDeviceRepository,
    required mainRobotPart,
    required String psk,
    required this.fragmentId,
    this.agentMinimumVersion,
  })  : _mainRobotPart = mainRobotPart,
        _psk = psk;
  final Viam viam;
  final Robot robot;
  final bool isNewMachine;
  final ConnectBluetoothDeviceRepository connectBluetoothDeviceRepository;
  final String? agentMinimumVersion;

  /// if not specified, the fragmentId read from the connected device will be used instead
  final String? fragmentId;

  final RobotPart _mainRobotPart;
  final String _psk;
  BluetoothDevice? get device => connectBluetoothDeviceRepository.device;

  Future<void> writeConfig({required String ssid, required String? password}) async {
    await connectBluetoothDeviceRepository.writeConfig(
      viam: viam,
      robot: robot,
      ssid: ssid,
      password: password,
      mainRobotPart: _mainRobotPart,
      psk: _psk,
      fragmentId: fragmentId,
    );
  }

  Future<bool> agentVersionBelowMinimum() async {
    if (agentMinimumVersion != null) {
      return await connectBluetoothDeviceRepository.isAgentVersionBelowMinimum(agentMinimumVersion!);
    }
    return false;
  }
}
