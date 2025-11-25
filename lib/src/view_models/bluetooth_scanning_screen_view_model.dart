part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class BluetoothScanningScreenViewModel extends ChangeNotifier {
  final Function(BluetoothDevice) onDeviceSelected;
  final String title;
  final String scanCtaText;
  final String notSeeingDeviceCtaText;
  final String tipsDialogTitle;
  final String tipsDialogSubtitle;
  final String tipsDialogCtaText;

  final ScanBluetoothDevicesRepository _scanBluetoothDevicesRepository;
  final ConnectBluetoothDeviceRepository _connectBluetoothDeviceRepository;

  List<BluetoothDevice> _uniqueDevices = [];
  List<BluetoothDevice> get uniqueDevices => _uniqueDevices;
  set uniqueDevices(List<BluetoothDevice> devices) {
    if (listEquals(_uniqueDevices, devices)) return;
    _uniqueDevices = devices;
    notifyListeners();
  }

  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;
  set isConnecting(bool value) {
    if (isConnecting == value) return;
    _isConnecting = value;
    notifyListeners();
  }

  bool _isScanning = false;
  bool get isScanning => _isScanning;
  set isScanning(bool value) {
    if (isScanning == value) return;
    _isScanning = value;
    notifyListeners();
  }

  StreamSubscription<List<BluetoothDevice>>? _devicesSubscription;
  StreamSubscription<bool>? _scanningSubscription;

  BluetoothScanningScreenViewModel({
    required this.onDeviceSelected,
    required ScanBluetoothDevicesRepository scanBluetoothDevicesRepository,
    required ConnectBluetoothDeviceRepository connectBluetoothDeviceRepository,
    required this.title,
    required this.scanCtaText,
    required this.notSeeingDeviceCtaText,
    required this.tipsDialogTitle,
    required this.tipsDialogSubtitle,
    required this.tipsDialogCtaText,
  })  : _scanBluetoothDevicesRepository = scanBluetoothDevicesRepository,
        _connectBluetoothDeviceRepository = connectBluetoothDeviceRepository {
    _devicesSubscription = _scanBluetoothDevicesRepository.uniqueDevicesStream.listen((value) {
      uniqueDevices = value;
    });
    _scanningSubscription = _scanBluetoothDevicesRepository.scanningStream.listen((value) {
      isScanning = value;
    });
  }

  @override
  void dispose() {
    _devicesSubscription?.cancel();
    _scanningSubscription?.cancel();
    _scanBluetoothDevicesRepository.dispose();
    super.dispose();
  }

  Future<void> startScanning() async {
    await _scanBluetoothDevicesRepository.start();
  }

  Future<bool> connect(BuildContext? context, BluetoothDevice device) async {
    try {
      isConnecting = true;
      await _connectBluetoothDeviceRepository.connect(device);
      onDeviceSelected(device);
      return true;
    } catch (e) {
      debugPrint('Failed to connect to device: ${e.toString()}');
      if (context != null && context.mounted == true) {
        await _showErrorDialog(context, title: 'Error', error: 'Failed to connect to device');
      }
      return false;
    } finally {
      isConnecting = false;
    }
  }

  Future<void> scanDevicesAgain() async {
    uniqueDevices = [];
    await _scanBluetoothDevicesRepository.startScan();
  }
}
