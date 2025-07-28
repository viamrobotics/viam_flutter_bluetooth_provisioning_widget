part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class CheckDeviceAgentOnlineScreenViewModel extends ChangeNotifier {
  final VoidCallback handleOnline;

  bool get agentOnline => _agentOnline;
  set agentOnline(bool state) {
    if (_agentOnline != state) {
      _agentOnline = state;
      notifyListeners();
    }
  }

  final CheckingAgentOnlineRepository _checkingAgentOnlineRepository;
  bool _agentOnline;
  StreamSubscription<bool>? _agentOnlineSubscription;

  CheckDeviceAgentOnlineScreenViewModel({
    required this.handleOnline,
    required CheckingAgentOnlineRepository checkingAgentOnlineRepository,
  })  : _checkingAgentOnlineRepository = checkingAgentOnlineRepository,
        _agentOnline = checkingAgentOnlineRepository.agentOnline;

  @override
  void dispose() {
    _agentOnlineSubscription?.cancel();
    _checkingAgentOnlineRepository.dispose();
    super.dispose();
  }

  void startChecking() {
    _checkingAgentOnlineRepository.startChecking();
    _agentOnlineSubscription = _checkingAgentOnlineRepository.agentOnlineStateStream.listen((state) {
      _agentOnline = state;
      if (_agentOnline) {
        handleOnline();
      }
    });
  }
}
