part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class CheckingDeviceOnlineRepository {
  final Viam viam;
  final Robot robot;
  BluetoothDevice? device;

  CheckingDeviceOnlineRepository({
    required this.viam,
    required this.robot,
    required this.device,
  });

  Stream<DeviceOnlineState> get deviceOnlineStateStream => _stateController.stream;
  DeviceOnlineState get deviceOnlineState => _deviceOnlineState;
  String? get errorMessage => _errorMessage;

  final StreamController<DeviceOnlineState> _stateController = StreamController<DeviceOnlineState>.broadcast();
  DeviceOnlineState _deviceOnlineState = DeviceOnlineState.idle;
  Timer? _onlineTimer;
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

  void startChecking() {
    deviceOnlineState = DeviceOnlineState.checking;
    _onlineTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_deviceOnlineState == DeviceOnlineState.success) {
        timer.cancel();
        return;
      }
      _checkOnline();
      if (device != null && device?.isConnected == true) {
        _readAgentErrors(device!);
      }
    });
  }

  Future<void> _readAgentErrors(BluetoothDevice device) async {
    try {
      // when bleService comes back online, if these errors comes back as not empty we have an error to handle
      // this should return an array with 1 value once it's readable (bleService comes back online)
      final errors = await device.readErrors();
      if (errors.isNotEmpty) {
        _onlineTimer?.cancel();
        deviceOnlineState = DeviceOnlineState.errorConnecting;
        _errorMessage = errors.last;
        debugPrint('Error connecting machine: $_errorMessage');
      }
    } catch (e) {
      debugPrint('Error reading agent errors: $e');
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
      if (device?.isConnected == true) {
        device?.disconnect();
      }
    }
  }
}
