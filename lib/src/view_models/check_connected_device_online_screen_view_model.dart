part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class CheckConnectedDeviceOnlineScreenViewModel extends ChangeNotifier {
  final VoidCallback handleSuccess;

  /// agent has indicated the machine is online and has machine credentials
  /// though it may not be online in app.viam.com yet
  final VoidCallback handleAgentConfigured;

  final VoidCallback handleError;
  final Robot robot;
  final String successTitle;
  final String successSubtitle;
  final String successCta;
  String? get errorMessage => _checkingDeviceOnlineRepository.errorMessage;

  DeviceOnlineState get deviceOnlineState => _deviceOnlineState;
  set deviceOnlineState(DeviceOnlineState state) {
    if (_deviceOnlineState != state) {
      _deviceOnlineState = state;
      notifyListeners();
    }
  }

  final CheckingDeviceOnlineRepository _checkingDeviceOnlineRepository;
  final ConnectBluetoothDeviceRepository _connectBluetoothDeviceRepository;
  DeviceOnlineState _deviceOnlineState;
  StreamSubscription<DeviceOnlineState>? _deviceOnlineSubscription;

  CheckConnectedDeviceOnlineScreenViewModel({
    required this.handleSuccess,
    required this.handleAgentConfigured,
    required this.handleError,
    required this.successTitle,
    required this.successSubtitle,
    required this.successCta,
    required this.robot,
    required CheckingDeviceOnlineRepository checkingDeviceOnlineRepository,
    required ConnectBluetoothDeviceRepository connectBluetoothDeviceRepository,
  })  : _checkingDeviceOnlineRepository = checkingDeviceOnlineRepository,
        _connectBluetoothDeviceRepository = connectBluetoothDeviceRepository,
        _deviceOnlineState = checkingDeviceOnlineRepository.deviceOnlineState;

  @override
  void dispose() {
    _deviceOnlineSubscription?.cancel();
    _checkingDeviceOnlineRepository.dispose();
    super.dispose();
  }

  Future<void> reconnect() async {
    await _connectBluetoothDeviceRepository.reconnect();
  }

  void startChecking() {
    _checkingDeviceOnlineRepository.startChecking();
    _deviceOnlineSubscription = _checkingDeviceOnlineRepository.deviceOnlineStateStream.listen((state) {
      deviceOnlineState = state;
    });
  }
}
