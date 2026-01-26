part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class BluetoothScanningScreenViewModel extends ChangeNotifier {
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

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    if (isLoading == value) return;
    _isLoading = value;
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

  Future<void> stopScanning() async {
    if (FlutterBluePlus.isScanningNow) {
      try {
        await FlutterBluePlus.stopScan();
        // Give the Android BLE stack time to fully stop scanning (not great, but needed)
        // Other functions we rely on (like disconnect) have a built-in Android delay of 2s
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        debugPrint('Failed to stop scanning: ${e.toString()}');
      }
    }
  }

  Future<bool> connect(BuildContext? context, BluetoothDevice device) async {
    try {
      await _connectBluetoothDeviceRepository.connect(device);
      return true;
    } catch (e) {
      debugPrint('Failed to connect to device: ${e.toString()}');
      if (context != null && context.mounted == true) {
        await _showErrorDialog(context, title: 'Error', error: 'Failed to connect to device');
      }
      return false;
    }
  }

  Future<void> scanDevicesAgain() async {
    uniqueDevices = [];
    await _scanBluetoothDevicesRepository.startScan();
  }

  String deviceName(BluetoothDevice device) {
    if (device.advName.isNotEmpty) {
      return device.advName; // name advertised during scanning, won't be stale during scanning if device was renamed
    } else if (device.platformName.isNotEmpty) {
      return device.platformName; // name persisted between app restarts, can be stale (but a better fallback than 'untitled')
    } else {
      return 'untitled';
    }
  }
}
