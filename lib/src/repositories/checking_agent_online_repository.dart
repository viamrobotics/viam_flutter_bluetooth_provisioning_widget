part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class CheckingAgentOnlineRepository {
  final BluetoothDevice device;
  final Duration checkingInterval;

  Stream<bool> get agentOnlineStateStream => _agentOnlineController.stream;
  final StreamController<bool> _agentOnlineController = StreamController<bool>.broadcast();

  bool get agentOnline => _agentOnline;
  bool _agentOnline = false;
  set agentOnline(bool value) {
    _agentOnline = value;
    _agentOnlineController.add(value);
  }

  Timer? _onlineTimer;

  CheckingAgentOnlineRepository({required this.device, this.checkingInterval = const Duration(seconds: 5)});

  void dispose() {
    _onlineTimer?.cancel();
    _agentOnlineController.close();
  }

  void startChecking() {
    _onlineTimer = Timer.periodic(checkingInterval, (timer) {
      try {
        readAgentStatus();
      } catch (e) {
        debugPrint('Error reading agent status: $e');
      }
    });
  }

  Future<void> readAgentStatus() async {
    final status = await device.readStatus();
    if (status.isConnected) {
      _onlineTimer?.cancel();
    }
    debugPrint('Agent online status: ${status.isConnected}');
    agentOnline = status.isConnected;
  }
}
