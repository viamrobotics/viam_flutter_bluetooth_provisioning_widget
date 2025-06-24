part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class CheckingDeviceOnlineRepository {
  final Viam viam;
  final Robot robot;
  final BluetoothDevice connectedDevice;

  /// Stream that emits whenever the device online state changes
  Stream<DeviceOnlineState> get deviceOnlineStateStream => _stateController.stream;
  DeviceOnlineState get deviceOnlineState => _deviceOnlineState;

  final StreamController<DeviceOnlineState> _stateController = StreamController<DeviceOnlineState>.broadcast();
  DeviceOnlineState _deviceOnlineState = DeviceOnlineState.checking;
  Timer? _onlineTimer;

  set deviceOnlineState(DeviceOnlineState state) {
    _deviceOnlineState = state;
    _stateController.add(state);
  }

  CheckingDeviceOnlineRepository({
    required this.connectedDevice,
    required this.viam,
    required this.robot,
  }) {
    _initTimer();
  }

  void dispose() {
    _onlineTimer?.cancel();
    _stateController.close();
  }

  void _initTimer() {
    _onlineTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkOnline();
      _checkAgentStatus();
    });
  }

  Future<void> _checkAgentStatus() async {
    try {
      final status = await connectedDevice.readStatus();
      if (status.isConnected && status.isConfigured && deviceOnlineState != DeviceOnlineState.success) {
        deviceOnlineState = DeviceOnlineState.agentConnected;
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  void _checkOnline() async {
    final refreshedRobot = await viam.appClient.getRobot(robot.id);
    final seconds = refreshedRobot.lastAccess.seconds.toInt();
    final actual = DateTime.now().microsecondsSinceEpoch / Duration.microsecondsPerSecond;
    if ((actual - seconds) < 10) {
      deviceOnlineState = DeviceOnlineState.success;
      _onlineTimer?.cancel();
    }
  }
}
