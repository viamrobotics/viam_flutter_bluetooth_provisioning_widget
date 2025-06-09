part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class ConnectedBluetoothDeviceScreenViewModel extends ChangeNotifier {
  final void Function(String ssid, String? psk) handleWifiCredentials;

  final BluetoothDevice connectedDevice;

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

  ConnectedBluetoothDeviceScreenViewModel({required this.handleWifiCredentials, required this.connectedDevice});

  Future<void> readNetworkList() async {
    this.wifiNetworks.clear();
    isLoadingNetworks = true;
    await Future.delayed(const Duration(milliseconds: 500)); // delay to see "scanning" ui
    final wifiNetworks = await connectedDevice.readNetworkList();
    this.wifiNetworks = wifiNetworks.sorted((a, b) => b.signalStrength.compareTo(a.signalStrength));
    isLoadingNetworks = false;
  }
}
