part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class CheckConnectedDeviceOnlineScreenViewModel extends ChangeNotifier {
  final VoidCallback handleSuccess;
  final CheckingDeviceOnlineRepository _checkingDeviceOnlineRepository;
  final Robot robot;

  DeviceOnlineState _deviceOnlineState;
  DeviceOnlineState get deviceOnlineState => _deviceOnlineState;
  set deviceOnlineState(DeviceOnlineState state) {
    if (_deviceOnlineState != state) {
      _deviceOnlineState = state;
      notifyListeners();
    }
  }

  CheckConnectedDeviceOnlineScreenViewModel({
    required this.handleSuccess,
    required this.robot,
    required CheckingDeviceOnlineRepository checkingDeviceOnlineRepository,
  })  : _checkingDeviceOnlineRepository = checkingDeviceOnlineRepository,
        _deviceOnlineState = checkingDeviceOnlineRepository.deviceOnlineState {
    _startListening();
  }

  @override
  void dispose() {
    _checkingDeviceOnlineRepository.dispose();
    super.dispose();
  }

  void _startListening() {
    _checkingDeviceOnlineRepository.deviceOnlineStateStream.listen((state) {
      deviceOnlineState = state;
    });
  }
}
