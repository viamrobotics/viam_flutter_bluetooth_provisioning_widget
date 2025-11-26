part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class ConnectBluetoothDeviceRepository {
  BluetoothDevice? get device => _device;
  BluetoothDevice? _device;

  Future<void> connect(BluetoothDevice device) async {
    if (device.isConnected) {
      _device = device;
      return;
    }
    await device.connect();
    _device = device;
  }

  Future<void> reconnect() async {
    if (_device?.isConnected == false && _device != null) {
      await connect(_device!);
      debugPrint('reconnected to device');
    }
  }

  Future<void> writeConfig({
    required Viam viam,
    required Robot robot,
    required RobotPart mainRobotPart,
    required String? ssid,
    required String? password,
    required String psk,
    required String? fragmentId,
    required bool fragmentOverride,
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
    if (ssid != null) {
      await _device!.writeNetworkConfig(ssid: ssid, pw: password, psk: psk);
    }
    if (fragmentOverride) {
      final fragmentIdToWrite = fragmentId ?? await _device!.readFragmentId();
      if (fragmentIdToWrite.isNotEmpty) {
        await _fragmentOverride(viam, fragmentIdToWrite, mainRobotPart, robot);
      }
    }
    await _device!.exitProvisioning(psk: psk);
  }

  Future<List<WifiNetwork>> readNetworkList() async {
    if (_device == null || _device?.isConnected == false) {
      throw Exception('No connected device');
    }

    final wifiNetworks = await _device!.readNetworkList();
    return wifiNetworks.sorted((a, b) => b.signalStrength.compareTo(a.signalStrength));
  }

  /// Version check to compare against a specified minimum version
  /// If we can't read the version, it's also in a version below what we support
  Future<bool> isAgentVersionBelowMinimum(String minimumVersion) async {
    if (_device == null || _device?.isConnected == false) {
      throw Exception('No connected device');
    }

    try {
      final agentVersion = await _device!.readAgentVersion();
      return isVersionLower(currentVersionStr: agentVersion, minimumVersionStr: minimumVersion);
    } catch (e) {
      debugPrint('Error reading agent version: $e');
      return true;
    }
  }

  bool isVersionLower({required String currentVersionStr, required String minimumVersionStr}) {
    // extract version numbers using regex (e.g., "0.20.4-release" -> "0.20.4")
    final versionRegex = RegExp(r'^(\d+\.\d+\.\d+)');
    String cleanCurrentVersion = versionRegex.firstMatch(currentVersionStr)?.group(1) ?? currentVersionStr;
    String cleanMinimumVersion = versionRegex.firstMatch(minimumVersionStr)?.group(1) ?? minimumVersionStr;
    List<int> currentIntList = cleanCurrentVersion.split('.').map(int.tryParse).whereType<int>().toList();
    List<int> minimumIntList = cleanMinimumVersion.split('.').map(int.tryParse).whereType<int>().toList();

    if (currentIntList.isEmpty) {
      return false; // no numbers, allow 'custom' pre-release versions to be higher than minimum
    }
    // not using the factory constructor because it can't parse 1.20 properly, so we'll convert that to 1.20.0
    final currentVersion = Version(
      currentIntList.elementAtOrNull(0) ?? 0,
      currentIntList.elementAtOrNull(1) ?? 0,
      currentIntList.elementAtOrNull(2) ?? 0,
    );
    final minimumVersion = Version(
      minimumIntList.elementAtOrNull(0) ?? 0,
      minimumIntList.elementAtOrNull(1) ?? 0,
      minimumIntList.elementAtOrNull(2) ?? 0,
    );
    return currentVersion < minimumVersion;
  }

  Future<void> unlockPairing({required String psk}) async {
    if (_device == null) {
      throw Exception('No connected device');
    }
    if (_device!.isConnected) {
      await _device!.connect();
    }
    
    await _device!.unlockPairing(psk: psk);
  }

  Future<void> _fragmentOverride(Viam viam, String fragmentId, RobotPart robotPart, Robot robot) async {
    Map<String, dynamic> config = {
      "fragments": [
        {
          "id": fragmentId,
        }
      ]
    };
    await viam.appClient.updateRobotPart(robotPart.id, robot.name, config);
  }
}
