part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class CheckConnectedDeviceOnlineScreenViewModel extends ChangeNotifier {
  final VoidCallback handleSuccess;
  final BluetoothDevice connectedDevice;
  final Viam viam;
  final Robot robot;
  Timer? _onlineTimer;

  DeviceOnlineState _deviceOnlineState = DeviceOnlineState.checking;
  DeviceOnlineState get deviceOnlineState => _deviceOnlineState;
  set deviceOnlineState(DeviceOnlineState state) {
    _deviceOnlineState = state;
    notifyListeners();
  }

  CheckConnectedDeviceOnlineScreenViewModel({
    required this.handleSuccess,
    required this.connectedDevice,
    required this.viam,
    required this.robot,
  }) {
    _initTimers();
  }

  @override
  void dispose() {
    _onlineTimer?.cancel();
    super.dispose();
  }

  // TODO: REPO this and below
  void _initTimers() {
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
