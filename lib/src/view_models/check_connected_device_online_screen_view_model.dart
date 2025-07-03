part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class CheckConnectedDeviceOnlineScreenViewModel extends ChangeNotifier {
  final VoidCallback handleSuccess;

  /// agent has indicated the machine is online and has machine credentials
  /// though it's still not online in app.viam.com
  final VoidCallback handleAgentConfigured
  
  final VoidCallback handleError;
  final Robot robot;
  String? get errorMessage => _checkingDeviceOnlineRepository.errorMessage;

  DeviceOnlineState get deviceOnlineState => _deviceOnlineState;
  set deviceOnlineState(DeviceOnlineState state) {
    if (_deviceOnlineState != state) {
      _deviceOnlineState = state;
      notifyListeners();
    }
  }

  final CheckingDeviceOnlineRepository _checkingDeviceOnlineRepository;
  DeviceOnlineState _deviceOnlineState;
  StreamSubscription<DeviceOnlineState>? _deviceOnlineSubscription;

  CheckConnectedDeviceOnlineScreenViewModel({
    required this.handleSuccess,
    required this.handleAgentConfigured,
    required this.handleError,
    required this.robot,
    required CheckingDeviceOnlineRepository checkingDeviceOnlineRepository,
  })  : _checkingDeviceOnlineRepository = checkingDeviceOnlineRepository,
        _deviceOnlineState = checkingDeviceOnlineRepository.deviceOnlineState;

  @override
  void dispose() {
    _deviceOnlineSubscription?.cancel();
    _checkingDeviceOnlineRepository.dispose();
    super.dispose();
  }

  void startChecking() {
    _checkingDeviceOnlineRepository.startChecking();
    _deviceOnlineSubscription = _checkingDeviceOnlineRepository.deviceOnlineStateStream.listen((state) {
      deviceOnlineState = state;
    });
  }
}
