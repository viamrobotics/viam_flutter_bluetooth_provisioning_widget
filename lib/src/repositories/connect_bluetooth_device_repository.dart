part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class ConnectBluetoothDeviceRepository {
  BluetoothDevice? get device => _device;
  Stream<BluetoothConnectionState?> get bluetoothConnectionStateStream => _stateController.stream;
  BluetoothConnectionState? get bluetoothConnectionState => _bluetoothConnectionState;
  set bluetoothConnectionState(BluetoothConnectionState? state) {
    if (_bluetoothConnectionState != state) {
      _bluetoothConnectionState = state;
      _stateController.add(state);
    }
  }

  final StreamController<BluetoothConnectionState?> _stateController = StreamController<BluetoothConnectionState>.broadcast();
  BluetoothConnectionState? _bluetoothConnectionState;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  BluetoothDevice? _device;

  void dispose() {
    if (_device?.isConnected ?? false) {
      _device?.disconnect();
    }
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
    _stateController.close();
  }

  Future<void> connect(BluetoothDevice device) async {
    if (device.isConnected) {
      _successfullyConnected(device);
      return;
    }
    await device.connect();
    _successfullyConnected(device);
  }

  Future<void> writeConfig({
    required String ssid,
    required String? password,
    required RobotPart mainRobotPart,
    required String psk,
  }) async {
    if (_device == null || _device?.isConnected == false) {
      throw Exception('No connected device');
    }

    final status = await _device!.readStatus();
    // don't overwrite existing machine, hotspot provisioning also does this check
    if (!status.isConfigured) {
      await _device!.writeRobotPartConfig(
        partId: mainRobotPart.id,
        secret: mainRobotPart.secret,
        psk: psk,
      );
    }
    await _device!.writeNetworkConfig(ssid: ssid, pw: password, psk: psk);
    await _device!.exitProvisioning(psk: psk);
  }

  Future<List<WifiNetwork>> readNetworkList() async {
    if (_device == null || _device?.isConnected == false) {
      throw Exception('No connected device');
    }

    final wifiNetworks = await _device!.readNetworkList();
    return wifiNetworks.sorted((a, b) => b.signalStrength.compareTo(a.signalStrength));
  }

  void _successfullyConnected(BluetoothDevice device) {
    _connectionStateSubscription = device.connectionState.listen((state) {
      bluetoothConnectionState = state;
      if (state == BluetoothConnectionState.disconnected) {
        _device = null;
      }
    });
    _device = device;
  }
}
