part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class CheckingAgentOnlineRepository {
  final BluetoothDevice device;

  CheckingAgentOnlineRepository({required this.device});

  Stream<bool> get agentOnlineStateStream => _stateController.stream;
  bool get agentOnline => _agentOnline;

  final StreamController<bool> _stateController = StreamController<bool>.broadcast();
  bool _agentOnline = false;

  Timer? _onlineTimer;

  set agentOnline(bool state) {
    if (_agentOnline != state) {
      _agentOnline = state;
      _stateController.add(state);
    }
  }

  void dispose() {
    _onlineTimer?.cancel();
    _stateController.close();
  }

  void startChecking() {
    _onlineTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_agentOnline) {
        timer.cancel();
        return;
      }
      _readAgentStatus();
    });
  }

  Future<void> _readAgentStatus() async {
    try {
      final status = await device.readStatus();
      debugPrint('status isConnected: ${status.isConnected}');
      agentOnline = status.isConnected;
    } on Exception catch (e) {
      debugPrint('Error reading agent status: $e');
    }
  }
}
