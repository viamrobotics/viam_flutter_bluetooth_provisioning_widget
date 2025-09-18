part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class BluetoothProvisioningFlowViewModel extends ChangeNotifier {
  BluetoothProvisioningFlowViewModel({
    required this.viam,
    required this.robot,
    required this.isNewMachine,
    required this.connectBluetoothDeviceRepository,
    required this.checkingDeviceOnlineRepository,
    required mainRobotPart,
    required String psk,
    required this.fragmentId,
    this.agentMinimumVersion = '0.20.0',
    this.copy = const BluetoothProvisioningFlowCopy(),
    required this.onSuccess,
    required this.existingMachineExit,
    required this.nonexistentMachineExit,
    required this.agentMinimumVersionExit,
  })  : _mainRobotPart = mainRobotPart,
        _psk = psk,
        _isConfigured = !isNewMachine,
        _deviceOnlineState = checkingDeviceOnlineRepository.deviceOnlineState {
    _deviceOnlineSubscription = checkingDeviceOnlineRepository.deviceOnlineStateStream.listen((state) {
      deviceOnlineState = state;
    });
  }

  final Viam viam;
  final Robot robot;
  final bool isNewMachine;
  final ConnectBluetoothDeviceRepository connectBluetoothDeviceRepository;
  final CheckingDeviceOnlineRepository checkingDeviceOnlineRepository;
  final String agentMinimumVersion;
  final BluetoothProvisioningFlowCopy copy;

  /// if not specified, the fragmentId read from the connected device will be used instead
  final String? fragmentId;
  BluetoothDevice? get device => connectBluetoothDeviceRepository.device;

  final RobotPart _mainRobotPart;
  final String _psk;

  /// based on isNewMachine initially, but can be determined by reading the device status
  bool get isConfigured => _isConfigured;
  bool _isConfigured;
  set isConfigured(bool value) {
    _isConfigured = value;
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  bool _isLoading = false;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  DeviceOnlineState get deviceOnlineState => _deviceOnlineState;
  DeviceOnlineState _deviceOnlineState;
  StreamSubscription<DeviceOnlineState>? _deviceOnlineSubscription; // ignore: unused_field
  set deviceOnlineState(DeviceOnlineState state) {
    if (_deviceOnlineState != state) {
      _deviceOnlineState = state;
      notifyListeners();
    }
  }

  final VoidCallback onSuccess;

  final VoidCallback existingMachineExit;
  final VoidCallback nonexistentMachineExit;

  /// called when the connected machine's agent version is lower (or we can't read it) compared to the agentMinimumVersion in the view model
  final VoidCallback agentMinimumVersionExit;

  Future<void> writeConfig({required String? ssid, required String? password}) async {
    await connectBluetoothDeviceRepository.writeConfig(
      viam: viam,
      robot: robot,
      ssid: ssid,
      password: password,
      mainRobotPart: _mainRobotPart,
      psk: _psk,
      fragmentId: fragmentId,
      fragmentOverride: isNewMachine,
    );
  }

  Future<bool> agentVersionBelowMinimum() async {
    return await connectBluetoothDeviceRepository.isAgentVersionBelowMinimum(agentMinimumVersion);
  }

  Future<bool> isDeviceConnectionValid(BuildContext context, BluetoothDevice device) async {
    try {
      isLoading = true;
      // agent minimum check
      if (await agentVersionBelowMinimum() && context.mounted) {
        // disconnect the device to avoid any `pairing request` dialogs.
        device.disconnect();
        _agentMinimumVersionDialog(context);
        return false;
      }
      // status check
      final status = await device.readStatus();
      isConfigured = status.isConfigured;
      if (isNewMachine && status.isConfigured && context.mounted) {
        _avoidOverwritingExistingMachineDialog(context);
        return false;
      } else if (!isNewMachine && !status.isConfigured && context.mounted) {
        _reconnectingNonexistingMachineDialog(context);
        return false;
      }
      checkingDeviceOnlineRepository.device = device;
      return true;
    } catch (e) {
      debugPrint('Error reading device status: $e');
      return false; // could be valid, but undetermined without reading status
    } finally {
      isLoading = false;
    }
  }

  Future<bool> onWifiCredentials(BuildContext context, String? ssid, String? password) async {
    try {
      isLoading = true;
      await writeConfig(ssid: ssid, password: password);
      return true;
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, title: 'Failed to write config', error: e.toString());
      }
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<bool> unlockBluetoothPairing(BuildContext context) async {
    try {
      isLoading = true;
      await device?.unlockPairing(psk: _psk);
      debugPrint('unlocked pairing');
      await device?.disconnect();
      debugPrint('disconnected from device');
      return true;
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, title: 'Failed to unlock pairing', error: e.toString());
      }
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<void> _avoidOverwritingExistingMachineDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(copy.existingMachineDialogTitle),
          content: Text(
            copy.existingMachineDialogSubtitle,
          ),
          actions: <Widget>[
            OutlinedButton(
              child: Text(copy.existingMachineDialogCta),
              onPressed: () {
                Navigator.pop(context);
                existingMachineExit();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _agentMinimumVersionDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(copy.agentIncompatibleDialogTitle),
          content: Text(copy.agentIncompatibleDialogSubtitle),
          actions: <Widget>[
            OutlinedButton(
              child: Text(copy.agentIncompatibleDialogCta),
              onPressed: () {
                Navigator.pop(context);
                agentMinimumVersionExit();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _reconnectingNonexistingMachineDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(copy.machineNotFoundDialogTitle),
          content: Text(copy.machineNotFoundDialogSubtitle),
          actions: <Widget>[
            OutlinedButton(
              child: Text(copy.machineNotFoundDialogCta),
              onPressed: () {
                Navigator.pop(context);
                nonexistentMachineExit();
              },
            ),
          ],
        );
      },
    );
  }
}
