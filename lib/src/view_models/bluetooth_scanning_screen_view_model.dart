part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class BluetoothScanningScreenViewModel extends ChangeNotifier {
  BluetoothScanningScreenViewModel({required this.onDeviceSelected, required ScanningNetworksRepository scanningNetworksRepository})
      : _scanningNetworksRepository = scanningNetworksRepository {
    _setupStreamListeners();
  }

  final Function(BluetoothDevice) onDeviceSelected;

  final ScanningNetworksRepository _scanningNetworksRepository;
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

  void _setupStreamListeners() {
    _scanningNetworksRepository.devicesStream.listen((devices) {
      uniqueDevices = devices;
    });
    _scanningNetworksRepository.scanningStream.listen((scanning) {
      isScanning = scanning;
    });
  }

  @override
  void dispose() {
    _scanningNetworksRepository.dispose();
    super.dispose();
  }

  void start() {
    _scanningNetworksRepository.start();
  }

  Future<void> connect(BluetoothDevice device) async {
    isConnecting = true;
    await device.connect();
    onDeviceSelected(device);
    isConnecting = false;
  }

  void scanNetworkAgain() {
    _scanningNetworksRepository.scanNetworkAgain();
  }
}
