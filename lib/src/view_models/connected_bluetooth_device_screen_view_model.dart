part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class ConnectedBluetoothDeviceScreenViewModel extends ChangeNotifier {
  final void Function(String ssid, String? psk) handleWifiCredentials;
  final String title;
  final String subtitle;
  final String scanCtaText;
  final String notSeeingDeviceCtaText;
  final String tipsDialogTitle;
  final String tipsDialogSubtitle;
  final String tipsDialogCtaText;

  List<WifiNetwork> _wifiNetworks = [];
  List<WifiNetwork> get wifiNetworks => _wifiNetworks;
  set wifiNetworks(List<WifiNetwork> networks) {
    if (listEquals(_wifiNetworks, networks)) return;
    _wifiNetworks = networks;
    notifyListeners();
  }

  bool _isLoadingNetworks = false;
  bool get isLoadingNetworks => _isLoadingNetworks;
  set isLoadingNetworks(bool value) {
    if (_isLoadingNetworks == value) return;
    _isLoadingNetworks = value;
    notifyListeners();
  }

  final ConnectBluetoothDeviceRepository _connectBluetoothDeviceRepository;

  ConnectedBluetoothDeviceScreenViewModel({
    required this.handleWifiCredentials,
    required ConnectBluetoothDeviceRepository connectBluetoothDeviceRepository,
    required this.title,
    required this.subtitle,
    required this.scanCtaText,
    required this.notSeeingDeviceCtaText,
    required this.tipsDialogTitle,
    required this.tipsDialogSubtitle,
    required this.tipsDialogCtaText,
  }) : _connectBluetoothDeviceRepository = connectBluetoothDeviceRepository;

  Future<void> readNetworkList(BuildContext? context) async {
    try {
      isLoadingNetworks = true;
      wifiNetworks.clear();
      await Future.delayed(const Duration(milliseconds: 500)); // delay to see "scanning" ui
      wifiNetworks = await _connectBluetoothDeviceRepository.readNetworkList();
    } catch (e) {
      debugPrint('Failed to read network list: ${e.toString()}');
      if (context != null && context.mounted == true) {
        _showErrorDialog(context, title: 'Error', error: 'Failed to read network list');
      }
    } finally {
      isLoadingNetworks = false;
    }
  }
}
