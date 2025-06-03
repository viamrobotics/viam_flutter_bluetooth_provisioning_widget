part of '../../viam_flutter_provisioning_widget.dart';

class BluetoothScanningScreen extends StatefulWidget {
  final Function(BluetoothDevice) onDeviceSelected;

  const BluetoothScanningScreen({super.key, required this.onDeviceSelected});

  @override
  State<BluetoothScanningScreen> createState() => _BluetoothScanningScreenState();
}

class _BluetoothScanningScreenState extends State<BluetoothScanningScreen> {
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  final Set<String> _deviceIds = {};
  List<BluetoothDevice> _uniqueDevices = [];
  bool _isConnecting = false;
  bool _isScanning = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      // Need to explicitly request permissions on Android
      // iOS handles this automatically when you initialize bluetoothProvisioning
      _checkPermissions();
    } else {
      _initialize();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopScan(); // not called when moving forward in nav, stop scan when moving forward if we need to
    super.dispose();
  }

  void _checkPermissions() async {
    final scanStatus = await Permission.bluetoothScan.request();
    final connectStatus = await Permission.bluetoothConnect.request();
    if (scanStatus == PermissionStatus.granted && connectStatus == PermissionStatus.granted) {
      _initialize();
    }
  }

  void _initialize() async {
    await ViamBluetoothProvisioning.initialize(poweredOn: (poweredOn) {
      if (poweredOn) {
        _startScan();
      }
    });
  }

  void _startScan() async {
    setState(() {
      _isScanning = true;
    });
    final stream = await ViamBluetoothProvisioning.scanForPeripherals();
    _scanSubscription = stream.listen((device) {
      setState(() {
        for (final result in device) {
          if (!_deviceIds.contains(result.device.remoteId.str)) {
            _deviceIds.add(result.device.remoteId.str);
            _uniqueDevices.add(result.device);
          }
        }
        _uniqueDevices = _uniqueDevices;
      });
    });
  }

  void _stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    if (!_isDisposed) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _connect(BluetoothDevice device) async {
    setState(() {
      _isConnecting = true;
    });
    try {
      // await device.connect();
      widget.onDeviceSelected(device);
    } catch (e) {
      if (mounted) {
        showErrorDialog(context, title: 'Failed to connect to device', error: e.toString());
      }
    }
    setState(() {
      _isConnecting = false;
    });
  }

  void _scanNetworkAgain() {
    _stopScan();
    setState(() {
      _deviceIds.clear();
      _uniqueDevices.clear();
    });
    _startScan();
  }

  Future<void> _notSeeingDevice() async {
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
    return _isConnecting
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
              _isScanning && _uniqueDevices.isEmpty
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
                        itemCount: _uniqueDevices.length,
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
                                  _uniqueDevices[index].platformName.isNotEmpty == true ? _uniqueDevices[index].platformName : 'untitled',
                                  style: Theme.of(context).textTheme.bodyLarge),
                              onTap: () => _connect(_uniqueDevices[index]),
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
                      onPressed: _scanNetworkAgain,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Scan network again'),
                    ),
                    TextButton(
                      onPressed: _notSeeingDevice,
                      child: const Text('Not seeing your device?'),
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}
