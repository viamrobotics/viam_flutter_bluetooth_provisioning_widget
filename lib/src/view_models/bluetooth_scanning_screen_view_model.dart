part of '../../viam_flutter_provisioning_widget.dart';

class BluetoothScanningScreenViewModel extends ChangeNotifier {
  BluetoothScanningScreenViewModel({required this.onDeviceSelected}) {
    start();
  }

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

  // better name
  void start() {
    if (Platform.isAndroid) {
      // Need to explicitly request permissions on Android
      // iOS handles this automatically when you initialize bluetoothProvisioning
      checkPermissions();
    } else {
      initialize();
    }
  }

  // PERMISSION REPO
  void checkPermissions() async {
    final scanStatus = await Permission.bluetoothScan.request();
    final connectStatus = await Permission.bluetoothConnect.request();
    if (scanStatus == PermissionStatus.granted && connectStatus == PermissionStatus.granted) {
      initialize();
    }
  }

  // maybe put elsewhere
  void initialize() async {
    await ViamBluetoothProvisioning.initialize(poweredOn: (poweredOn) {
      if (poweredOn) {
        startScan();
      }
    });
  }

  // TODO: STREAM/MOVE INTO BLUETOOTH REPO!
  void startScan() async {
    _isScanning = true;
    final stream = await ViamBluetoothProvisioning.scanForPeripherals();
    _scanSubscription = stream.listen((device) {
      for (final result in device) {
        if (!_deviceIds.contains(result.device.remoteId.str)) {
          _deviceIds.add(result.device.remoteId.str);
          _uniqueDevices.add(result.device);
        }
      }
      uniqueDevices = _uniqueDevices; // heh..?
    });
  }

  void _stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    if (!_isDisposed) {
      _isScanning = false;
    }
  }

  Future<void> connect(BluetoothDevice device) async {
    _isConnecting = true;
    await device.connect();
    onDeviceSelected(device);
    _isConnecting = false;
  }

  void scanNetworkAgain() {
    _stopScan();
    _deviceIds.clear();
    _uniqueDevices.clear();
    startScan();
  }
}
