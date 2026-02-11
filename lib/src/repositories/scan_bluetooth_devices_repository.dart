part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class ScanBluetoothDevicesRepository {
  final ViamBluetoothProvisioning viamBluetoothProvisioning;

  Stream<List<BluetoothDevice>> get uniqueDevicesStream => _uniqueDevicesController.stream;
  final StreamController<List<BluetoothDevice>> _uniqueDevicesController = StreamController<List<BluetoothDevice>>.broadcast();
  final List<BluetoothDevice> _uniqueDevices = [];

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

  final Set<String> _deviceIds = {};

  ScanBluetoothDevicesRepository({required this.viamBluetoothProvisioning});

  void dispose() {
    _uniqueDevicesController.close();
    _scanningController.close();
    _scanSubscription?.cancel();
    _scanSubscription = null;
    _uniqueDevices.clear();
    _deviceIds.clear();
  }

  Future<void> initialize() async {
    viamBluetoothProvisioning.initialize(poweredOn: (poweredOn) async {
      if (poweredOn) {
        await startScan();
      }
    });
  }

  Future<void> startScan() async {
    isScanning = true;
    _deviceIds.clear();
    _uniqueDevices.clear();

    final stream = await viamBluetoothProvisioning.scanForPeripherals();
    _scanSubscription = stream.listen((scanResults) {
      for (final result in scanResults) {
        if (!_deviceIds.contains(result.device.remoteId.str)) {
          _deviceIds.add(result.device.remoteId.str);
          _uniqueDevices.add(result.device);
        }
      }
      _uniqueDevicesController.add(List.from(_uniqueDevices));
    });
  }
}
