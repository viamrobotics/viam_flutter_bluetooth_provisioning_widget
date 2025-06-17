part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class BluetoothScanningScreenViewModel extends ChangeNotifier {
  BluetoothScanningScreenViewModel({required this.onDeviceSelected});

  final Function(BluetoothDevice) onDeviceSelected;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  List<BluetoothDevice> _uniqueDevices = [];
  List<BluetoothDevice> get uniqueDevices => _uniqueDevices;
  set uniqueDevices(List<BluetoothDevice> devices) {
    _uniqueDevices = devices;
    notifyListeners();
  }

  final Set<String> _deviceIds = {};

  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;
  set isConnecting(bool value) {
    _isConnecting = value;
    notifyListeners();
  }

  bool _isScanning = false;
  bool get isScanning => _isScanning;
  set isScanning(bool value) {
    _isScanning = value;
    notifyListeners();
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _stopScan();
    super.dispose();
  }

  void start() {
    if (Platform.isAndroid) {
      // Need to explicitly request permissions on Android
      // iOS handles this automatically when you initialize bluetoothProvisioning
      _checkPermissions();
    } else {
      _initialize();
    }
  }

  void _checkPermissions() async {
    final scanStatus = await Permission.bluetoothScan.request();
    final connectStatus = await Permission.bluetoothConnect.request();
    final locationStatus = await Permission.locationWhenInUse.request();
    if (scanStatus == PermissionStatus.granted && connectStatus == PermissionStatus.granted && locationStatus == PermissionStatus.granted) {
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
    _isScanning = true;
    final stream = await ViamBluetoothProvisioning.scanForPeripherals();
    _scanSubscription = stream.listen((device) {
      for (final result in device) {
        if (!_deviceIds.contains(result.device.remoteId.str)) {
          _deviceIds.add(result.device.remoteId.str);
          _uniqueDevices.add(result.device);
        }
      }
      uniqueDevices = _uniqueDevices;
    });
  }

  void _stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    if (!_isDisposed) {
      isScanning = false;
    }
  }

  Future<void> connect(BluetoothDevice device) async {
    isConnecting = true;
    await device.connect();
    onDeviceSelected(device);
    isConnecting = false;
  }

  void scanNetworkAgain() {
    _stopScan();
    _deviceIds.clear();
    _uniqueDevices.clear();
    _startScan();
  }
}
