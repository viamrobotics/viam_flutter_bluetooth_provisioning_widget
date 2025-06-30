part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class CheckingDeviceOnlineRepository {
  final Viam viam;
  final Robot robot;
  final BluetoothDevice device;

  CheckingDeviceOnlineRepository({
    required this.viam,
    required this.robot,
    required this.device,
  });

  Stream<DeviceOnlineState> get deviceOnlineStateStream => _stateController.stream;
  DeviceOnlineState get deviceOnlineState => _deviceOnlineState;

  final StreamController<DeviceOnlineState> _stateController = StreamController<DeviceOnlineState>.broadcast();
  DeviceOnlineState _deviceOnlineState = DeviceOnlineState.checking;
  Timer? _onlineTimer;

  List<String>? _startingErrors;

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
      _checkError();
      _checkOnline();
      _checkAgentStatus();
    });
  }

  Future<void> _checkError() async {
    _startingErrors ??= await device.readErrors();
    final errors = await device.readErrors();
    if (errors.length > _startingErrors!.length) {
      // a new error was appended to the error list, let's check if it's a new error
      debugPrint('Error connecting machine: ${errors.last}');
      _onlineTimer?.cancel();
      deviceOnlineState = DeviceOnlineState.errorConnecting;
      // fire and forget disconnect device
      if (device.isConnected) {
        device.disconnect();
      }
    }
  }

  Future<void> _checkAgentStatus() async {
    try {
      if (device.isConnected) {
        final status = await device.readStatus();
        if (status.isConnected && status.isConfigured && deviceOnlineState != DeviceOnlineState.success) {
          deviceOnlineState = DeviceOnlineState.agentConnected;
        }
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
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
