part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class CheckingDeviceOnlineRepository {
  final Viam viam;
  final Robot robot;
  final BluetoothDevice device;

  CheckingDeviceOnlineRepository({required this.viam, required this.robot, required this.device});

  Stream<DeviceOnlineState> get deviceOnlineStateStream => _stateController.stream;
  DeviceOnlineState get deviceOnlineState => _deviceOnlineState;
  String? get errorMessage => _errorMessage;

  final StreamController<DeviceOnlineState> _stateController = StreamController<DeviceOnlineState>.broadcast();
  DeviceOnlineState _deviceOnlineState = DeviceOnlineState.checking;
  Timer? _onlineTimer;
  List<String>? _startingErrors;
  String? _errorMessage;

  set deviceOnlineState(DeviceOnlineState state) {
    if (_deviceOnlineState != state) {
      _deviceOnlineState = state;
      _stateController.add(state);
    }
  }

  void dispose() {
    _onlineTimer?.cancel();
    _stateController.close();
  }

  Future<void> startChecking() async {
    _onlineTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_deviceOnlineState == DeviceOnlineState.success) {
        timer.cancel();
        return;
      }
      _checkOnline();
      _checkAgentStatus();
    });
  }

  /// We want to read these sequentially for now, some errors observed trying to read ble characteristics in parallel
  Future<void> _checkAgentStatus() async {
    if (!device.isConnected) {
      return;
    }

    await _readAgentErrors();
    await _readAgentStatus();
  }

  Future<void> _readAgentErrors() async {
    try {
      if (_startingErrors == null) {
        _startingErrors = await device.readErrors();
        return; // nothing to compare, return
      }

      final newErrors = await device.readErrors();
      debugPrint('newErrors: $newErrors');
      if (newErrors.length > _startingErrors!.length) {
        // a new error was appended to the error list
        _onlineTimer?.cancel();
        deviceOnlineState = DeviceOnlineState.errorConnecting;
        _errorMessage = newErrors.last.capitalize();
        debugPrint('Error connecting machine: $_errorMessage');
      }
    } catch (e) {
      debugPrint('Error reading agent errors: $e');
    }
  }

  Future<void> _readAgentStatus() async {
    try {
      final status = await device.readStatus();
      if (status.isConnected && status.isConfigured && deviceOnlineState != DeviceOnlineState.success) {
        deviceOnlineState = DeviceOnlineState.agentConnected; // timer still allowed to run for the online check
      }
    } on Exception catch (e) {
      debugPrint('Error reading agent status: $e');
    }
  }

  Future<void> _checkOnline() async {
    final refreshedRobot = await viam.appClient.getRobot(robot.id);
    final seconds = refreshedRobot.lastAccess.seconds.toInt();
    final actual = DateTime.now().microsecondsSinceEpoch / Duration.microsecondsPerSecond;
    if ((actual - seconds) < 10) {
      _onlineTimer?.cancel();
      deviceOnlineState = DeviceOnlineState.success;
      // fire and forget disconnect device
      if (device.isConnected) {
        device.disconnect();
      }
    }
  }
}
