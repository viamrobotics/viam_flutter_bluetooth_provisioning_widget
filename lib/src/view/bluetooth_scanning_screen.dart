part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class BluetoothScanningScreen extends StatefulWidget {
  const BluetoothScanningScreen({super.key});

  @override
  State<BluetoothScanningScreen> createState() => _BluetoothScanningScreenState();
}

class _BluetoothScanningScreenState extends State<BluetoothScanningScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BluetoothScanningScreenViewModel>().startScanning();
    });
  }

  Future<void> _notSeeingDevice(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tips'),
          content: const Text(
            'If the device isn\'t showing up, ensure Bluetooth is on and that the device is plugged in and turned on.\n\nYou may also need to change your phone\'s Bluetooth settings to allow it to connect to new devices.',
          ),
          actions: <Widget>[
            OutlinedButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothScanningScreenViewModel>(
      builder: (context, viewModel, child) {
        return viewModel.isConnecting
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 24),
                    Text('Connecting...'),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.titleLarge,
                        children: [
                          TextSpan(text: 'Choose your '),
                          TextSpan(
                            text: 'Device Name',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ),
                  viewModel.isScanning && viewModel.uniqueDevices.isEmpty
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
                            itemCount: viewModel.uniqueDevices.length,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                child: ListTile(
                                  minVerticalPadding: 20,
                                  leading: Icon(Icons.bluetooth, color: const Color(0xFF8B949E), size: 20),
                                  horizontalTitleGap: 16,
                                  title: Text(
                                      viewModel.uniqueDevices[index].platformName.isNotEmpty == true
                                          ? viewModel.uniqueDevices[index].platformName
                                          : 'untitled',
                                      style: Theme.of(context).textTheme.bodyLarge),
                                  onTap: () => viewModel.connect(viewModel.uniqueDevices[index]),
                                ),
                              );
                            },
                          ),
                        ),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: viewModel.scanDevicesAgain,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Scan network again'),
                        ),
                        TextButton(
                          onPressed: () => _notSeeingDevice(context),
                          child: const Text('Not seeing your device?'),
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
