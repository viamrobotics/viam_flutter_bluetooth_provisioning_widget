part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class ConnectedBluetoothDeviceRepository {
  BluetoothDevice? get connectedDevice => _connectedDevice;
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
  BluetoothDevice? _connectedDevice;

  void dispose() {
    if (_connectedDevice?.isConnected ?? false) {
      _connectedDevice?.disconnect();
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
    if (_connectedDevice == null) {
      throw Exception('No connected device');
    }

    final status = await _connectedDevice!.readStatus();
    // don't overwrite existing machine, hotspot provisioning also does this check
    if (!status.isConfigured) {
      await _connectedDevice!.writeRobotPartConfig(
        partId: mainRobotPart.id,
        secret: mainRobotPart.secret,
        psk: psk,
      );
    }
    await _connectedDevice!.writeNetworkConfig(ssid: ssid, pw: password, psk: psk);
    await _connectedDevice!.exitProvisioning(psk: psk);
  }

  Future<List<WifiNetwork>> readNetworkList() async {
    if (_connectedDevice == null) {
      throw Exception('No connected device');
    }

    final wifiNetworks = await _connectedDevice!.readNetworkList();
    return wifiNetworks.sorted((a, b) => b.signalStrength.compareTo(a.signalStrength));
  }

  void _successfullyConnected(BluetoothDevice device) {
    _connectionStateSubscription = device.connectionState.listen((state) {
      bluetoothConnectionState = state;
      if (state == BluetoothConnectionState.disconnected) {
        _connectedDevice = null;
      }
    });
    _connectedDevice = device;
  }
}
