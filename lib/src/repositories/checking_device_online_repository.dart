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

  Stream<DeviceOnlineState> get deviceOnlineStateStream => _deviceOnlineStateController.stream;
  final StreamController<DeviceOnlineState> _deviceOnlineStateController = StreamController<DeviceOnlineState>.broadcast();

  Stream<String> get errorMessageStream => _errorMessageController.stream;
  final StreamController<String> _errorMessageController = StreamController<String>.broadcast();

  Timer? _onlineTimer;

  void dispose() {
    _onlineTimer?.cancel();
    _deviceOnlineStateController.close();
    _errorMessageController.close();
  }

  void startChecking() {
    _deviceOnlineStateController.add(DeviceOnlineState.checking);
    _onlineTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final online = await isRobotOnline();
      if (online) {
        timer.cancel();
        _deviceOnlineStateController.add(DeviceOnlineState.success);
        if (device?.isConnected == true) device?.disconnect();
      } else if (device != null && device?.isConnected == true) {
        final error = await readAgentError(device!);
        if (error != null) {
          timer.cancel();
          _deviceOnlineStateController.add(DeviceOnlineState.errorConnecting);
          _errorMessageController.add(error);
        }
      }
    });
  }

  Future<bool> isRobotOnline() async {
    final refreshedRobot = await viam.appClient.getRobot(robot.id);
    final seconds = refreshedRobot.lastAccess.seconds.toInt();
    final actual = DateTime.now().microsecondsSinceEpoch / Duration.microsecondsPerSecond;
    return ((actual - seconds) < 10);
  }

  /// when bleService comes back online, if these errors comes back as not empty we have an error to handle
  /// this should return an array with 1 value once it's readable (bleService comes back online)
  Future<String?> readAgentError(BluetoothDevice device) async {
    try {
      final errors = await device.readErrors();
      if (errors.isNotEmpty) {
        return errors.last;
      }
      return null;
    } catch (e) {
      debugPrint('Error reading agent errors: ${e.toString()}');
      return null;
    }
  }
}
