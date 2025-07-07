part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class ConnectedBluetoothDeviceScreenViewModel extends ChangeNotifier {
  final void Function(String ssid, String? psk) handleWifiCredentials;

  List<WifiNetwork> _wifiNetworks = [];
  List<WifiNetwork> get wifiNetworks => _wifiNetworks;
  set wifiNetworks(List<WifiNetwork> networks) {
    _wifiNetworks = networks;
    notifyListeners();
  }

  bool _isLoadingNetworks = false;
  bool get isLoadingNetworks => _isLoadingNetworks;
  set isLoadingNetworks(bool value) {
    _isLoadingNetworks = value;
    notifyListeners();
  }

  final ConnectBluetoothDeviceRepository _connectBluetoothDeviceRepository;

  ConnectedBluetoothDeviceScreenViewModel({
    required this.handleWifiCredentials,
    required ConnectBluetoothDeviceRepository connectBluetoothDeviceRepository,
  }) : _connectBluetoothDeviceRepository = connectBluetoothDeviceRepository;

  Future<void> readNetworkList() async {
    wifiNetworks.clear();
    isLoadingNetworks = true;
    await Future.delayed(const Duration(milliseconds: 500)); // delay to see "scanning" ui
    wifiNetworks = await _connectBluetoothDeviceRepository.readNetworkList();
    isLoadingNetworks = false;
  }
}
