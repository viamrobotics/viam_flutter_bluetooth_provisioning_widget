part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class ScanningNetworksRepository {
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  List<BluetoothDevice> _uniqueDevices = [];
  final Set<String> _deviceIds = {};
  List<BluetoothDevice> get uniqueDevices => _uniqueDevices;
  set uniqueDevices(List<BluetoothDevice> devices) {
    _uniqueDevices = devices;
    _devicesController.add(_uniqueDevices);
  }

  final StreamController<List<BluetoothDevice>> _devicesController = StreamController<List<BluetoothDevice>>.broadcast();
  Stream<List<BluetoothDevice>> get devicesStream => _devicesController.stream;

  final StreamController<bool> _scanningController = StreamController<bool>.broadcast();
  Stream<bool> get scanningStream => _scanningController.stream;

  bool _isScanning = false;
  bool get isScanning => _isScanning;
  set isScanning(bool value) {
    _isScanning = value;
    _scanningController.add(_isScanning);
  }

  bool _isDisposed = false;

  void dispose() {
    _isDisposed = true;
    _devicesController.close();
    _scanningController.close();
    _stopScan();
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

  void scanNetworkAgain() {
    _stopScan();
    _deviceIds.clear();
    _uniqueDevices.clear();
    _devicesController.add(_uniqueDevices);
    _startScan();
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
    isScanning = true;
    final stream = await ViamBluetoothProvisioning.scanForPeripherals();
    _scanSubscription = stream.listen((device) {
      for (final result in device) {
        if (!_deviceIds.contains(result.device.remoteId.str)) {
          _deviceIds.add(result.device.remoteId.str);
          _uniqueDevices.add(result.device);
          _devicesController.add(_uniqueDevices);
        }
      }
    });
  }

  void _stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    if (!_isDisposed) {
      isScanning = false;
    }
  }
}
