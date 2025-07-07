part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class BluetoothScanningScreenViewModel extends ChangeNotifier {
  BluetoothScanningScreenViewModel({
    required this.onDeviceSelected,
    required ScanBluetoothDevicesRepository scanBluetoothDevicesRepository,
    required ConnectedBluetoothDeviceRepository connectedBluetoothDeviceRepository,
  })  : _scanBluetoothDevicesRepository = scanBluetoothDevicesRepository,
        _connectedBluetoothDeviceRepository = connectedBluetoothDeviceRepository {
    _devicesSubscription = _scanBluetoothDevicesRepository.devicesStream.listen((devices) {
      uniqueDevices = devices;
    });
    _scanningSubscription = _scanBluetoothDevicesRepository.scanningStream.listen((scanning) {
      isScanning = scanning;
    });
  }

  final Function(BluetoothDevice) onDeviceSelected;

  final ScanBluetoothDevicesRepository _scanBluetoothDevicesRepository;
  final ConnectedBluetoothDeviceRepository _connectedBluetoothDeviceRepository;
  List<BluetoothDevice> _uniqueDevices = [];
  List<BluetoothDevice> get uniqueDevices => _uniqueDevices;
  set uniqueDevices(List<BluetoothDevice> devices) {
    _uniqueDevices = devices;
    notifyListeners();
  }

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

  StreamSubscription<List<BluetoothDevice>>? _devicesSubscription;
  StreamSubscription<bool>? _scanningSubscription;

  @override
  void dispose() {
    _devicesSubscription?.cancel();
    _scanningSubscription?.cancel();
    _scanBluetoothDevicesRepository.dispose();
    super.dispose();
  }

  void startScanning() {
    _scanBluetoothDevicesRepository.start();
  }

  Future<void> connect(BluetoothDevice device) async {
    isConnecting = true;
    await _connectedBluetoothDeviceRepository.connect(device);
    onDeviceSelected(device);
    isConnecting = false;
  }

  void scanDevicesAgain() {
    _scanBluetoothDevicesRepository.scanDevicesAgain();
  }
}
