part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class ConnectBluetoothDeviceRepository {
  BluetoothDevice? get connectedDevice => _connectedDevice;
  BluetoothDevice? _connectedDevice;

  Future<void> connect(BluetoothDevice newDevice) async {
    if (newDevice.isConnected) {
      _connectedDevice = newDevice;
      return;
    }

    // disconnect previous device
    if (_connectedDevice?.isConnected == true) {
      await _connectedDevice!.disconnect(androidDelay: 2000);
    }

    const maxAttempts = 3;
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        await newDevice.connect();
        _connectedDevice = newDevice;
        debugPrint('connected to device on attempt $attempt');
        return;
      } catch (e) {
        if (attempt < maxAttempts) {
          await Future.delayed(Duration(seconds: 2));
          debugPrint('failed to connect to device on attempt $attempt, retrying, error: $e');
        } else {
          debugPrint('failed to connect to device after $maxAttempts attempts, stopping, error: $e');
          rethrow;
        }
      }
    }
  }

  Future<void> reconnect() async {
    if (_connectedDevice?.isConnected == false && _connectedDevice != null) {
      await connect(_connectedDevice!);
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
    if (_connectedDevice == null || _connectedDevice?.isConnected == false) {
      throw Exception('No connected device');
    }

    final status = await _connectedDevice!.readStatus();
    // don't overwrite existing machine, hotspot provisioning also does this check
    if (!status.isConfigured) {
      await _connectedDevice!.writeRobotPartConfig(
        partId: mainRobotPart.id,
        secret: mainRobotPart.secret,
        apiKey: null,
        psk: psk,
      );
    }
    if (ssid != null) {
      await _connectedDevice!.writeNetworkConfig(ssid: ssid, pw: password, psk: psk);
    }
    if (fragmentOverride) {
      final fragmentIdToWrite = fragmentId ?? await _connectedDevice!.readFragmentId();
      if (fragmentIdToWrite.isNotEmpty) {
        await _fragmentOverride(viam, fragmentIdToWrite, mainRobotPart, robot);
      }
    }
    await _connectedDevice!.exitProvisioning(psk: psk);
  }

  Future<List<WifiNetwork>> readNetworkList() async {
    if (_connectedDevice == null || _connectedDevice?.isConnected == false) {
      throw Exception('No connected device');
    }

    final wifiNetworks = await _connectedDevice!.readNetworkList();
    return wifiNetworks.sorted((a, b) => b.signalStrength.compareTo(a.signalStrength));
  }

  /// Version check to compare against a specified minimum version
  /// If we can't read the version, it's also in a version below what we support
  Future<bool> isAgentVersionBelowMinimum(String minimumVersion) async {
    if (_connectedDevice == null || _connectedDevice?.isConnected == false) {
      throw Exception('No connected device');
    }

    try {
      final agentVersion = await _connectedDevice!.readAgentVersion();
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
    if (_connectedDevice == null) {
      throw Exception('No connected device');
    }
    if (_connectedDevice!.isConnected) {
      await _connectedDevice!.connect();
    }

    await _connectedDevice!.unlockPairing(psk: psk);
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
