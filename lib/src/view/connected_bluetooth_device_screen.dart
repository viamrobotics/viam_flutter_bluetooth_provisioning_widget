part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class ConnectedBluetoothDeviceScreen extends StatefulWidget {
  const ConnectedBluetoothDeviceScreen({super.key});

  @override
  State<ConnectedBluetoothDeviceScreen> createState() => _ConnectedBluetoothDeviceScreenState();
}

class _ConnectedBluetoothDeviceScreenState extends State<ConnectedBluetoothDeviceScreen> {
  bool _showingDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _readNetworkList();
    });
  }

  // would be in view model, but want to handle error and show dialog w/ the context
  Future<void> _readNetworkList() async {
    try {
      await Provider.of<ConnectedBluetoothDeviceScreenViewModel>(context, listen: false).readNetworkList();
    } catch (e) {
      if (mounted) {
        showErrorDialog(context, title: 'Error reading network list', error: e.toString());
      }
    }
  }

  Future<void> _presentPasskeyDialog(WifiNetwork wifiNetwork, ConnectedBluetoothDeviceScreenViewModel viewModel) async {
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
                        viewModel.handleWifiCredentials(wifiNetwork.ssid, passkeyController.text);
                        Navigator.of(dialogContext).pop();
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
            'Make sure that the network isn\'t hidden and that your device is within range of your Wi-Fi router.\n\nPlease note that a 2.4GHz network is required.',
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
    return Consumer<ConnectedBluetoothDeviceScreenViewModel>(
      builder: (context, viewModel, child) {
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
                'Choose the Wi-Fi network you\'d like to use to connect your device.',
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 2,
              ),
            ),
            viewModel.isLoadingNetworks && viewModel.wifiNetworks.isEmpty
                ? Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemCount: 1,
                      itemBuilder: (context, _) {
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
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
                      itemCount: viewModel.wifiNetworks.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: ListTile(
                            minVerticalPadding: 20,
                            leading: Icon(_networkIcon(viewModel.wifiNetworks[index]), color: const Color(0xFF8B949E), size: 20),
                            trailing: viewModel.wifiNetworks[index].isSecure
                                ? Icon(Icons.lock_outline, color: const Color(0xFF8B949E), size: 20)
                                : null,
                            horizontalTitleGap: 16,
                            title: Text(viewModel.wifiNetworks[index].ssid, style: Theme.of(context).textTheme.bodyLarge),
                            onTap: () {
                              if (viewModel.wifiNetworks[index].isSecure) {
                                _presentPasskeyDialog(viewModel.wifiNetworks[index], viewModel);
                              } else {
                                viewModel.handleWifiCredentials(viewModel.wifiNetworks[index].ssid, null);
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
                      onPressed: _readNetworkList,
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
      },
    );
  }
}
