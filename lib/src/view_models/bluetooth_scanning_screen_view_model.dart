part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class BluetoothScanningScreenViewModel extends ChangeNotifier {
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

  Future<void> connect(BuildContext context, BluetoothDevice device) async {
    try {
      isConnecting = true;
      await _connectBluetoothDeviceRepository.connect(device);
      onDeviceSelected(device);
    } catch (e) {
      debugPrint('error connecting to device: ${e.toString()}');
      if (context.mounted) {
        debugPrint('Failed to connect to device: ${e.toString()}');
        _showErrorDialog(context, title: 'Error', error: 'Failed to connect to device');
      }
    } finally {
      isConnecting = false;
    }
  }

  void scanDevicesAgain() {
    _scanBluetoothDevicesRepository.scanDevicesAgain();
  }
}
