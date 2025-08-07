part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class CheckAgentOnlineScreenViewModel extends ChangeNotifier {
  final VoidCallback handleOnline;
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
    required this.handleOnline,
    required this.successTitle,
    required this.successSubtitle,
    required CheckingAgentOnlineRepository checkingAgentOnlineRepository,
    required ConnectBluetoothDeviceRepository connectBluetoothDeviceRepository,
  })  : _checkingAgentOnlineRepository = checkingAgentOnlineRepository,
        _connectBluetoothDeviceRepository = connectBluetoothDeviceRepository,
        _agentOnline = checkingAgentOnlineRepository.agentOnline;

  @override
  void dispose() {
    _agentOnlineSubscription?.cancel();
    _checkingAgentOnlineRepository.dispose();
    super.dispose();
  }

  void reconnect() {
    _connectBluetoothDeviceRepository.reconnect();
  }

  void startChecking() {
    _checkingAgentOnlineRepository.startChecking();
    _agentOnlineSubscription = _checkingAgentOnlineRepository.agentOnlineStateStream.listen((state) {
      agentOnline = state;
      if (agentOnline) {
        handleOnline();
      }
    });
  }
}
