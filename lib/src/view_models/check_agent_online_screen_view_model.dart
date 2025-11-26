part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class CheckAgentOnlineScreenViewModel extends ChangeNotifier {
  final String successTitle;
  final String successSubtitle;

  bool get agentOnline => _agentOnline;
  set agentOnline(bool state) {
    if (_agentOnline != state) {
      _agentOnline = state;
      notifyListeners();
    }
  }

  final CheckingAgentOnlineRepository _checkingAgentOnlineRepository;
  final ConnectBluetoothDeviceRepository _connectBluetoothDeviceRepository;
  bool _agentOnline;
  StreamSubscription<bool>? _agentOnlineSubscription;

  CheckAgentOnlineScreenViewModel({
    required this.successTitle,
    required this.successSubtitle,
    required CheckingAgentOnlineRepository checkingAgentOnlineRepository,
    required ConnectBluetoothDeviceRepository connectBluetoothDeviceRepository,
  })  : _checkingAgentOnlineRepository = checkingAgentOnlineRepository,
        _connectBluetoothDeviceRepository = connectBluetoothDeviceRepository,
        _agentOnline = checkingAgentOnlineRepository.agentOnline {
    _agentOnlineSubscription = _checkingAgentOnlineRepository.agentOnlineStateStream.listen((state) {
      agentOnline = state;
    });
  }

  @override
  void dispose() {
    _agentOnlineSubscription?.cancel();
    _checkingAgentOnlineRepository.dispose();
    // don't dispose the connect repository - it's shared with the parent view model
    super.dispose();
  }

  Future<void> reconnect() async {
    await _connectBluetoothDeviceRepository.reconnect();
  }

  void startChecking() {
    _checkingAgentOnlineRepository.startChecking();
  }
}
