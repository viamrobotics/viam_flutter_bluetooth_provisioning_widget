part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class CheckConnectedDeviceOnlineScreenViewModel extends ChangeNotifier {
  final VoidCallback handleSuccess;
  final VoidCallback handleError;
  final Robot robot;
  final String successTitle;
  final String successSubtitle;
  final String successCta;

  String? get errorMessage => _errorMessage;
  String? _errorMessage;
  set errorMessage(String? value) {
    if (_errorMessage != value) {
      _errorMessage = value;
      notifyListeners();
    }
  }

  DeviceOnlineState get deviceOnlineState => _deviceOnlineState;
  DeviceOnlineState _deviceOnlineState = DeviceOnlineState.idle;
  set deviceOnlineState(DeviceOnlineState state) {
    print("DEVICEONLINESTATE IN VM: $state");
    if (_deviceOnlineState != state) {
      _deviceOnlineState = state;
      notifyListeners();
      print("DEVICEONLINESTATE IN VIEW MODEL AFTER NOTIFY: $state");
    }
  }

  final CheckingDeviceOnlineRepository _checkingDeviceOnlineRepository;
  final ConnectBluetoothDeviceRepository _connectBluetoothDeviceRepository;
  StreamSubscription<DeviceOnlineState>? _deviceOnlineSubscription;
  StreamSubscription<String>? _errorMessageSubscription;

  CheckConnectedDeviceOnlineScreenViewModel({
    required this.handleSuccess,
    required this.handleError,
    required this.successTitle,
    required this.successSubtitle,
    required this.successCta,
    required this.robot,
    required CheckingDeviceOnlineRepository checkingDeviceOnlineRepository,
    required ConnectBluetoothDeviceRepository connectBluetoothDeviceRepository,
  })  : _checkingDeviceOnlineRepository = checkingDeviceOnlineRepository,
        _connectBluetoothDeviceRepository = connectBluetoothDeviceRepository;

  @override
  void dispose() {
    _deviceOnlineSubscription?.cancel();
    _errorMessageSubscription?.cancel();
    // don't dispose the repository - it's shared with the parent view model
    super.dispose();
  }

  Future<void> reconnect() async {
    await _connectBluetoothDeviceRepository.reconnect();
  }

  void startChecking() {
    _deviceOnlineSubscription = _checkingDeviceOnlineRepository.deviceOnlineStateStream.listen((state) {
      deviceOnlineState = state;
    });
    _errorMessageSubscription = _checkingDeviceOnlineRepository.errorMessageStream.listen((message) {
      errorMessage = message;
    });
    _checkingDeviceOnlineRepository.startChecking();
  }
}
