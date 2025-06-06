part of '../../viam_flutter_provisioning_widget.dart';

class ConnectedBluetoothDeviceScreenViewModel extends ChangeNotifier {
  final void Function(String ssid, String? psk) handleWifiCredentials;

  final BluetoothDevice connectedDevice;

  List<WifiNetwork> _wifiNetworks = [];
  List<WifiNetwork> get wifiNetworks => _wifiNetworks;
  set wifiNetworks(List<WifiNetwork> networks) {
    _wifiNetworks = networks;
    notifyListeners();
  }

  bool _isScanning = false;
  bool get isScanning => _isScanning;
  set isScanning(bool value) {
    _isScanning = value;
    notifyListeners();
  }

  ConnectedBluetoothDeviceScreenViewModel({required this.handleWifiCredentials, required this.connectedDevice}) {
    readNetworkList();
  }

  void readNetworkList() async {
    isScanning = true;
    await Future.delayed(const Duration(milliseconds: 500)); // delay to see "scanning" ui
    try {
      final wifiNetworks = await connectedDevice.readNetworkList();
      this.wifiNetworks = wifiNetworks.sorted((a, b) => b.signalStrength.compareTo(a.signalStrength));
    } catch (e) {
      throw Exception('Failed to read network list');
    } finally {
      _isScanning = false;
    }
  }

  void scanNetworkAgain() {
    wifiNetworks.clear();
    readNetworkList();
  }
}
