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
  bool _agentOnline;
  StreamSubscription<bool>? _agentOnlineSubscription;

  CheckAgentOnlineScreenViewModel({
    required this.handleOnline,
    required this.successTitle,
    required this.successSubtitle,
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
      agentOnline = state;
      if (agentOnline) {
        handleOnline();
      }
    });
  }
}
