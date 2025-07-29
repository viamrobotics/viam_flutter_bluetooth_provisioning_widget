part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class BluetoothScanningScreen extends StatefulWidget {
  const BluetoothScanningScreen({super.key, required this.viewModel});

  final BluetoothScanningScreenViewModel viewModel;

  @override
  State<BluetoothScanningScreen> createState() => _BluetoothScanningScreenState();
}

class _BluetoothScanningScreenState extends State<BluetoothScanningScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.startScanning();
  }

  Future<void> _notSeeingDevice(BuildContext context, String title, String subtitle, String ctaText) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(subtitle),
          actions: <Widget>[
            OutlinedButton(
              child: Text(ctaText),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return widget.viewModel.isConnecting
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
                    child: Text(widget.viewModel.title, style: Theme.of(context).textTheme.titleLarge),
                  ),
                  widget.viewModel.isScanning && widget.viewModel.uniqueDevices.isEmpty
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
                            itemCount: widget.viewModel.uniqueDevices.length,
                            itemBuilder: (ctx, index) {
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
                                      widget.viewModel.uniqueDevices[index].platformName.isNotEmpty == true
                                          ? widget.viewModel.uniqueDevices[index].platformName
                                          : 'untitled',
                                      style: Theme.of(context).textTheme.bodyLarge),
                                  onTap: () => widget.viewModel.connect(context, widget.viewModel.uniqueDevices[index]),
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
                          onPressed: widget.viewModel.scanDevicesAgain,
                          icon: const Icon(Icons.refresh),
                          label: Text(widget.viewModel.scanCtaText),
                        ),
                        TextButton(
                          onPressed: () => _notSeeingDevice(
                            context,
                            widget.viewModel.tipsDialogTitle,
                            widget.viewModel.tipsDialogSubtitle,
                            widget.viewModel.tipsDialogCtaText,
                          ),
                          child: Text(widget.viewModel.notSeeingDeviceCtaText),
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
