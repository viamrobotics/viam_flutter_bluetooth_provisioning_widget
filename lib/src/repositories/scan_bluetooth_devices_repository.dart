part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class ScanBluetoothDevicesRepository {
  List<BluetoothDevice> _uniqueDevices = [];
  List<BluetoothDevice> get uniqueDevices => _uniqueDevices;
  set uniqueDevices(List<BluetoothDevice> devices) {
    _uniqueDevices = devices;
    _uniqueDevicesController.add(_uniqueDevices);
  }

  Stream<List<BluetoothDevice>> get uniqueDevicesStream => _uniqueDevicesController.stream;
  final StreamController<List<BluetoothDevice>> _uniqueDevicesController = StreamController<List<BluetoothDevice>>.broadcast();

  Stream<bool> get scanningStream => _scanningController.stream;
  final StreamController<bool> _scanningController = StreamController<bool>.broadcast();
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  bool _isScanning = false;
  bool get isScanning => _isScanning;
  set isScanning(bool value) {
    if (isScanning == value) return;
    _isScanning = value;
    _scanningController.add(_isScanning);
  }

  bool _isDisposed = false;
  final Set<String> _deviceIds = {};

  void dispose() {
    _isDisposed = true;
    _uniqueDevicesController.close();
    _scanningController.close();
    _scanSubscription?.cancel();
    stopScan();
  }

  void start() {
    if (Platform.isAndroid) {
      // Need to explicitly request permissions on Android
      // iOS handles this automatically when you initialize bluetoothProvisioning
      _checkPermissions();
    } else {
      initialize();
    }
  }

  Future<void> initialize() async {
    await ViamBluetoothProvisioning.initialize(poweredOn: (poweredOn) {
      if (poweredOn) {
        startScan();
      }
    });
  }

  Future<void> startScan() async {
    isScanning = true;
    final stream = await ViamBluetoothProvisioning.scanForPeripherals();
    _scanSubscription = stream.listen((device) {
      for (final result in device) {
        if (!_deviceIds.contains(result.device.remoteId.str)) {
          _deviceIds.add(result.device.remoteId.str);
          uniqueDevices.add(result.device);
        }
      }
    });
  }

  void scanDevicesAgain() {
    stopScan();
    _deviceIds.clear();
    uniqueDevices = [];
    startScan();
  }

  void stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    if (!_isDisposed) {
      isScanning = false;
    }
  }

  Future<void> _checkPermissions() async {
    final scanStatus = await Permission.bluetoothScan.request();
    final connectStatus = await Permission.bluetoothConnect.request();
    final locationStatus = await Permission.locationWhenInUse.request();
    if (scanStatus == PermissionStatus.granted && connectStatus == PermissionStatus.granted && locationStatus == PermissionStatus.granted) {
      initialize();
    }
  }
}
