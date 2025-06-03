part of '../../viam_flutter_provisioning_widget.dart';

class ConnectedBluetoothDeviceScreen extends StatefulWidget {
  const ConnectedBluetoothDeviceScreen({
    super.key,
    required this.handleGoToNameDeviceScreen,
    required this.robot,
    required this.robotPart,
    required this.connectedDevice,
  });

  final void Function(String ssid, String? psk) handleGoToNameDeviceScreen;
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
        bool obscureText = true;
        TextEditingController passkeyController = TextEditingController();
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(wifiNetwork.ssid),
            content: TextFormField(
              autofocus: true,
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
                        // TODO: Re-provisioning logic add back
                        widget.handleGoToNameDeviceScreen(wifiNetwork.ssid, passkeyController.text);
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
          title: const Text('Find your hotspot name'),
          content: _buildDialogContent(),
          actions: <Widget>[
            OutlinedButton(
              child: const Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogContent() {
    final textTheme = Theme.of(context).textTheme.bodyLarge;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your hotspot name is the same as your phone's name.",
          style: textTheme,
        ),
        const SizedBox(height: 16),
        if (Platform.isIOS) ...[
          RichText(
            text: TextSpan(style: textTheme, children: [
              const TextSpan(text: "If you aren't sure what your phone's name is, you can find it on your "),
              TextSpan(text: "Personal Hotspot", style: textTheme!.copyWith(fontStyle: FontStyle.italic)),
              const TextSpan(text: " settings page:"),
            ]),
          ),
          const SizedBox(height: 8),
          Image.asset('images/ios_find_hotspot_name.png'),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(style: textTheme, children: [
              const TextSpan(text: "You can also find it by going to "),
              TextSpan(text: "Settings > General > About", style: textTheme.copyWith(fontStyle: FontStyle.italic)),
              const TextSpan(text: ":"),
            ]),
          ),
          const SizedBox(height: 8),
          Image.asset('images/ios_hotspot_name.png'),
        ] else ...[
          RichText(
            text: TextSpan(style: textTheme, children: [
              const TextSpan(text: "If you aren't sure what your phone's name is, you can find it in"),
              TextSpan(text: " Settings > About phone", style: textTheme!.copyWith(fontStyle: FontStyle.italic)),
              const TextSpan(text: ":"),
            ]),
          ),
          const SizedBox(height: 16),
          Image.asset('images/android_about_phone.png'),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(style: textTheme, children: [
              const TextSpan(text: "Tap "),
              TextSpan(text: "About phone. ", style: textTheme.copyWith(fontStyle: FontStyle.italic)),
              const TextSpan(text: "Your device's name should be at the top of the page:"),
            ]),
          ),
          const SizedBox(height: 16),
          Image.asset('images/android_device_name.png'),
        ]
      ],
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
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFBFC),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
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
                            trailing:
                                _wifiNetworks[index].isSecure ? Icon(Icons.lock_outline, color: const Color(0xFF8B949E), size: 20) : null,
                            horizontalTitleGap: 16,
                            title: Text(_wifiNetworks[index].ssid, style: Theme.of(context).textTheme.bodyLarge),
                            onTap: () {
                              if (_wifiNetworks[index].isSecure) {
                                _presentPasskeyDialog(_wifiNetworks[index]);
                              } else {
                                widget.handleGoToNameDeviceScreen(_wifiNetworks[index].ssid, null);
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
        ),
      ),
    );
  }
}
