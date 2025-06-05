part of '../../viam_flutter_provisioning_widget.dart';

class ConnectedBluetoothDeviceScreen extends StatefulWidget {
  const ConnectedBluetoothDeviceScreen({
    super.key,
    required this.handleWifiCredentials,
    required this.robot,
    required this.robotPart,
    required this.connectedDevice,
  });

  final void Function(String ssid, String? psk) handleWifiCredentials;
  final Robot robot;
  final RobotPart robotPart;
  final BluetoothDevice connectedDevice;

  @override
  State<ConnectedBluetoothDeviceScreen> createState() => _ConnectedBluetoothDeviceScreenState();
}

class _ConnectedBluetoothDeviceScreenState extends State<ConnectedBluetoothDeviceScreen> {
  List<WifiNetwork> _wifiNetworks = [];
  bool _isScanning = false;
  bool _showingDialog = false;

  @override
  void initState() {
    super.initState();
    _readNetworkList();
  }

  void _readNetworkList() async {
    setState(() {
      _isScanning = true;
    });
    await Future.delayed(const Duration(milliseconds: 500)); // delay to see "scanning" ui
    try {
      final wifiNetworks = await widget.connectedDevice.readNetworkList();
      setState(() {
        _wifiNetworks = wifiNetworks.sorted((a, b) => b.signalStrength.compareTo(a.signalStrength));
      });
    } catch (e) {
      if (mounted) {
        showErrorDialog(context, title: 'Failed to read network list');
      }
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _scanNetworkAgain() {
    setState(() {
      _wifiNetworks.clear();
    });
    _readNetworkList();
  }

  Future<void> _presentPasskeyDialog(WifiNetwork wifiNetwork) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool obscureText = false;
        TextEditingController passkeyController = TextEditingController();
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(wifiNetwork.ssid),
            content: TextFormField(
              autofocus: true,
              autocorrect: false,
              controller: passkeyController,
              obscureText: obscureText,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.black),
                  onPressed: () => setDialogState(() => obscureText = !obscureText),
                ),
              ),
              onChanged: (value) => setDialogState(() => passkeyController.text = value),
            ),
            actions: <Widget>[
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancel"),
              ),
              FilledButton(
                onPressed: passkeyController.text.isNotEmpty
                    ? () {
                        Navigator.of(dialogContext).pop();
                        widget.handleWifiCredentials(wifiNetwork.ssid, passkeyController.text);
                      }
                    : null,
                child: Text('Connect'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _notSeeingYourNetwork() async {
    setState(() {
      _showingDialog = true;
    });
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tips'),
          content: const Text(
            'Make sure that the network isn’t hidden and that your device is within range of your Wi-Fi router.\n\nPlease note that a 2.4GHz network is required.',
          ),
          actions: <Widget>[
            OutlinedButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _showingDialog = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  IconData _networkIcon(WifiNetwork wifiNetwork) {
    switch (wifiNetwork.signalStrength) {
      case <= 40:
        return Icons.wifi_1_bar;
      case <= 70:
        return Icons.wifi_2_bar;
      default:
        return Icons.wifi;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Choose your Wi-Fi', style: Theme.of(context).textTheme.titleLarge),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
          child: Text(
            'Choose the Wi-Fi network you’d like to use to connect your device.',
            style: Theme.of(context).textTheme.bodyLarge,
            maxLines: 2,
          ),
        ),
        _isScanning && _wifiNetworks.isEmpty
            ? Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemCount: 1,
                  itemBuilder: (context, _) {
                    return Card(
                      elevation: 0,
                      color: const Color(0xFFF5F7F8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const ScanningListTile(),
                    );
                  },
                ),
              )
            : Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemCount: _wifiNetworks.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: ListTile(
                        minVerticalPadding: 20,
                        leading: Icon(_networkIcon(_wifiNetworks[index]), color: const Color(0xFF8B949E), size: 20),
                        trailing: _wifiNetworks[index].isSecure ? Icon(Icons.lock_outline, color: const Color(0xFF8B949E), size: 20) : null,
                        horizontalTitleGap: 16,
                        title: Text(_wifiNetworks[index].ssid, style: Theme.of(context).textTheme.bodyLarge),
                        onTap: () {
                          if (_wifiNetworks[index].isSecure) {
                            _presentPasskeyDialog(_wifiNetworks[index]);
                          } else {
                            widget.handleWifiCredentials(_wifiNetworks[index].ssid, null);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
        if (!_showingDialog)
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _scanNetworkAgain,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Scan network again'),
                ),
                TextButton(
                  onPressed: _notSeeingYourNetwork,
                  child: const Text('Not seeing your network?'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
