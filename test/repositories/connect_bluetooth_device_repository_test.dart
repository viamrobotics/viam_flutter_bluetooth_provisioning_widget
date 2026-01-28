import 'package:flutter_test/flutter_test.dart';

import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/generate_mocks.mocks.dart';

void main() {
  group('ConnectBluetoothDeviceRepository', () {
    late ConnectBluetoothDeviceRepository repository;
    late MockBluetoothService service;
    late MockRobotPart mainRobotPart;
    late MockRobot robot;

    late MockBluetoothDevice device;
    late MockBluetoothCharacteristic viamStatusCharacteristic;
    late MockBluetoothCharacteristic partIdCharacteristic;
    late MockBluetoothCharacteristic partSecretCharacteristic;
    late MockBluetoothCharacteristic appAddressCharacteristic;
    late MockBluetoothCharacteristic ssidCharacteristic;
    late MockBluetoothCharacteristic pskCharacteristic;
    late MockBluetoothCharacteristic exitProvisioningCharacteristic;
    late MockBluetoothCharacteristic networkListCharacteristic;
    late MockBluetoothCharacteristic fragmentIdCharacteristic;
    late MockBluetoothCharacteristic agentVersionCharacteristic;

    final mockPublicKeyBytes = [
      0x30, 0x82, 0x01, 0x22, // SEQUENCE, 290 bytes
      0x30, 0x0D, // SEQUENCE, 13 bytes
      0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01, // RSA OID
      0x05, 0x00, // NULL
      0x03, 0x82, 0x01, 0x0F, 0x00, // BIT STRING, 271 bytes
      0x30, 0x82, 0x01, 0x0A, // SEQUENCE, 266 bytes
      // Modulus (2048-bit = 256 bytes)
      0x02, 0x82, 0x01, 0x01, 0x00, // INTEGER, 257 bytes
      0xC5, 0xAB, 0xF5, 0x3E, 0x8C, 0x2D, 0x91, 0x47,
      0xB9, 0x7A, 0x3F, 0xE8, 0x52, 0x1B, 0xC3, 0x6D,
      0x8A, 0x9F, 0x45, 0x23, 0x67, 0x89, 0xAB, 0xCD,
      0xEF, 0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE,
      0xF0, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77,
      0x88, 0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF,
      0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF,
      0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10,
      0xA1, 0xB2, 0xC3, 0xD4, 0xE5, 0xF6, 0x07, 0x18,
      0x29, 0x3A, 0x4B, 0x5C, 0x6D, 0x7E, 0x8F, 0x90,
      0x1A, 0x2B, 0x3C, 0x4D, 0x5E, 0x6F, 0x70, 0x81,
      0x92, 0xA3, 0xB4, 0xC5, 0xD6, 0xE7, 0xF8, 0x09,
      0x1B, 0x2C, 0x3D, 0x4E, 0x5F, 0x60, 0x71, 0x82,
      0x93, 0xA4, 0xB5, 0xC6, 0xD7, 0xE8, 0xF9, 0x0A,
      0x2B, 0x3C, 0x4D, 0x5E, 0x6F, 0x70, 0x81, 0x92,
      0xA3, 0xB4, 0xC5, 0xD6, 0xE7, 0xF8, 0x09, 0x1A,
      0x2B, 0x3C, 0x4D, 0x5E, 0x6F, 0x70, 0x81, 0x92,
      0xA3, 0xB4, 0xC5, 0xD6, 0xE7, 0xF8, 0x09, 0x1A,
      0x2B, 0x3C, 0x4D, 0x5E, 0x6F, 0x70, 0x81, 0x92,
      0xA3, 0xB4, 0xC5, 0xD6, 0xE7, 0xF8, 0x09, 0x1A,
      0x2B, 0x3C, 0x4D, 0x5E, 0x6F, 0x70, 0x81, 0x92,
      0xA3, 0xB4, 0xC5, 0xD6, 0xE7, 0xF8, 0x09, 0x1A,
      0x2B, 0x3C, 0x4D, 0x5E, 0x6F, 0x70, 0x81, 0x92,
      0xA3, 0xB4, 0xC5, 0xD6, 0xE7, 0xF8, 0x09, 0x1A,
      0x2B, 0x3C, 0x4D, 0x5E, 0x6F, 0x70, 0x81, 0x92,
      0xA3, 0xB4, 0xC5, 0xD6, 0xE7, 0xF8, 0x09, 0x1A,
      0x2B, 0x3C, 0x4D, 0x5E, 0x6F, 0x70, 0x81, 0x92,
      0xA3, 0xB4, 0xC5, 0xD6, 0xE7, 0xF8, 0x09, 0x1A,
      0x2B, 0x3C, 0x4D, 0x5E, 0x6F, 0x70, 0x81, 0x92,
      0xA3, 0xB4, 0xC5, 0xD6, 0xE7, 0xF8, 0x09, 0x1A,
      0x2B, 0x3C, 0x4D, 0x5E, 0x6F, 0x70, 0x81, 0x92,
      0xA3, 0xB4, 0xC5, 0xD6, 0xE7, 0xF8, 0x09, 0x1A,
      // Exponent (typically 65537 = 0x010001, 3 bytes)
      0x02, 0x03, // INTEGER, 3 bytes
      0x01, 0x00, 0x01
    ];

    /// Example byte array representing 3 WiFi networks:
    /// 1. "HomeWiFi" - Secure, Signal Strength: 90
    /// 2. "PublicWiFi" - Insecure, Signal Strength: 50
    /// 3. "OfficeNetwork" - Secure, Signal Strength: 25
    ///
    /// Format per network:
    /// - Byte 0: metadata (bit 7 = secure flag, bits 0-6 = signal strength 0-127)
    /// - Bytes 1-N: SSID as UTF-8 bytes
    /// - Byte N+1: null terminator (0x00)
    final exampleNetworkBytes = [
      // Network 1: "HomeWiFi" - secure (0x80), signal 90 (0x5A) -> 0xDA
      0xDA, // metadata: secure + signal strength 90
      0x48, 0x6F, 0x6D, 0x65, 0x57, 0x69, 0x46, 0x69, // "HomeWiFi" in UTF-8
      0x00, // null terminator

      // Network 2: "PublicWiFi" - insecure (0x00), signal 50 (0x32) -> 0x32
      0x32, // metadata: insecure + signal strength 50
      0x50, 0x75, 0x62, 0x6C, 0x69, 0x63, 0x57, 0x69, 0x46, 0x69, // "PublicWiFi" in UTF-8
      0x00, // null terminator

      // Network 3: "OfficeNetwork" - secure (0x80), signal 25 (0x19) -> 0x99
      0x99, // metadata: secure + signal strength 25
      0x4F, 0x66, 0x66, 0x69, 0x63, 0x65, 0x4E, 0x65, 0x74, 0x77, 0x6F, 0x72, 0x6B, // "OfficeNetwork" in UTF-8
      0x00, // null terminator
    ];

    setUp(() {
      repository = ConnectBluetoothDeviceRepository();
      service = MockBluetoothService();
      when(service.uuid).thenReturn(Guid.fromString(ViamBluetoothUUIDs.serviceUUID));

      device = MockBluetoothDevice();
      when(device.connect()).thenAnswer((_) async => {});
      when(device.discoverServices(
        subscribeToServicesChanged: true,
        timeout: 15,
      )).thenAnswer((_) async => <BluetoothService>[service]);

      viamStatusCharacteristic = MockBluetoothCharacteristic();
      when(viamStatusCharacteristic.uuid).thenReturn(Guid.fromString(ViamBluetoothUUIDs.statusUUID));

      final viamCryptoCharacteristic = MockBluetoothCharacteristic();
      when(viamCryptoCharacteristic.uuid).thenReturn(Guid.fromString(ViamBluetoothUUIDs.cryptoUUID));
      when(viamCryptoCharacteristic.read()).thenAnswer((_) async => mockPublicKeyBytes);

      partIdCharacteristic = MockBluetoothCharacteristic();
      when(partIdCharacteristic.uuid).thenReturn(Guid.fromString(ViamBluetoothUUIDs.robotPartUUID));
      when(partIdCharacteristic.write(any)).thenAnswer((_) async => {});

      partSecretCharacteristic = MockBluetoothCharacteristic();
      when(partSecretCharacteristic.uuid).thenReturn(Guid.fromString(ViamBluetoothUUIDs.robotPartSecretUUID));
      when(partSecretCharacteristic.write(any)).thenAnswer((_) async => {});

      appAddressCharacteristic = MockBluetoothCharacteristic();
      when(appAddressCharacteristic.uuid).thenReturn(Guid.fromString(ViamBluetoothUUIDs.appAddressUUID));
      when(appAddressCharacteristic.write(any)).thenAnswer((_) async => {});

      ssidCharacteristic = MockBluetoothCharacteristic();
      when(ssidCharacteristic.uuid).thenReturn(Guid.fromString(ViamBluetoothUUIDs.ssidUUID));
      when(ssidCharacteristic.read()).thenAnswer((_) async => [0, 0, 0, 0]);

      pskCharacteristic = MockBluetoothCharacteristic();
      when(pskCharacteristic.uuid).thenReturn(Guid.fromString(ViamBluetoothUUIDs.pskUUID));
      when(pskCharacteristic.write(any)).thenAnswer((_) async => {});

      exitProvisioningCharacteristic = MockBluetoothCharacteristic();
      when(exitProvisioningCharacteristic.uuid).thenReturn(Guid.fromString(ViamBluetoothUUIDs.exitProvisioningUUID));
      when(exitProvisioningCharacteristic.write(any)).thenAnswer((_) async => {});

      networkListCharacteristic = MockBluetoothCharacteristic();
      when(networkListCharacteristic.uuid).thenReturn(Guid.fromString(ViamBluetoothUUIDs.availableWiFiNetworksUUID));
      when(networkListCharacteristic.read()).thenAnswer((_) async => exampleNetworkBytes);

      fragmentIdCharacteristic = MockBluetoothCharacteristic();
      when(fragmentIdCharacteristic.uuid).thenReturn(Guid.fromString(ViamBluetoothUUIDs.fragmentUUID));
      // abcd123
      when(fragmentIdCharacteristic.read()).thenAnswer((_) async => [0x61, 0x62, 0x63, 0x64, 0x31, 0x32, 0x33]);

      agentVersionCharacteristic = MockBluetoothCharacteristic();
      when(agentVersionCharacteristic.uuid).thenReturn(Guid.fromString(ViamBluetoothUUIDs.agentVersionUUID));

      when(service.characteristics).thenReturn(<BluetoothCharacteristic>[
        viamStatusCharacteristic,
        viamCryptoCharacteristic,
        partIdCharacteristic,
        partSecretCharacteristic,
        appAddressCharacteristic,
        ssidCharacteristic,
        pskCharacteristic,
        exitProvisioningCharacteristic,
        networkListCharacteristic,
        fragmentIdCharacteristic,
        agentVersionCharacteristic,
      ]);

      mainRobotPart = MockRobotPart();
      when(mainRobotPart.id).thenReturn('partId');
      when(mainRobotPart.secret).thenReturn('secret');

      robot = MockRobot();
      when(robot.id).thenReturn('robotId');
      when(robot.name).thenReturn('robotName');
    });

    group('connect', () {
      test('connects successfully when no device connected', () async {
        when(device.isConnected).thenReturn(false);

        expect(repository.connectedDevice, isNull);
        await repository.connect(device);
        expect(repository.connectedDevice, equals(device));
      });
    });

    group('write config', () {
      test('write config to connected device with no fragment override', () async {
        when(device.isConnected).thenReturn(true);
        await repository.connect(device);
        when(viamStatusCharacteristic.read()).thenAnswer((_) async => [0]); // not configured, not online

        await repository.writeConfig(
          viam: MockViam(),
          robot: robot,
          mainRobotPart: mainRobotPart,
          ssid: 'ssid',
          password: 'password',
          psk: 'viamsetup',
          fragmentId: null,
          fragmentOverride: false,
        );

        verify(partIdCharacteristic.write(any)).called(1);
        verify(partSecretCharacteristic.write(any)).called(1);
        verify(appAddressCharacteristic.write(any)).called(1);

        verify(ssidCharacteristic.write(any)).called(1);
        verify(pskCharacteristic.write(any)).called(1);

        verify(exitProvisioningCharacteristic.write(any)).called(1);
      });
    });

    test('don\'t overwrite existing machine', () async {
      when(device.isConnected).thenReturn(true);
      await repository.connect(device);

      when(viamStatusCharacteristic.read()).thenAnswer((_) async => [1]); // configured, not online

      await repository.writeConfig(
        viam: MockViam(),
        robot: robot,
        mainRobotPart: mainRobotPart,
        ssid: 'ssid',
        password: 'password',
        psk: 'viamsetup',
        fragmentId: null,
        fragmentOverride: false,
      );

      verifyNever(partIdCharacteristic.write(any));
      verifyNever(partSecretCharacteristic.write(any));
      verifyNever(appAddressCharacteristic.write(any));

      verify(ssidCharacteristic.write(any)).called(1);
      verify(pskCharacteristic.write(any)).called(1);

      verify(exitProvisioningCharacteristic.write(any)).called(1);
    });

    test('don\'t write network credentials with null ssid', () async {
      when(device.isConnected).thenReturn(true);
      await repository.connect(device);

      when(viamStatusCharacteristic.read()).thenAnswer((_) async => [0]); // not configured, not online

      await repository.writeConfig(
        viam: MockViam(),
        robot: robot,
        mainRobotPart: mainRobotPart,
        ssid: null,
        password: 'password',
        psk: 'viamsetup',
        fragmentId: null,
        fragmentOverride: false,
      );

      verify(partIdCharacteristic.write(any)).called(1);
      verify(partSecretCharacteristic.write(any)).called(1);
      verify(appAddressCharacteristic.write(any)).called(1);

      verifyNever(ssidCharacteristic.write(any));
      verifyNever(pskCharacteristic.write(any));

      verify(exitProvisioningCharacteristic.write(any)).called(1);
    });

    test('throws when not no device connected', () async {
      try {
        await repository.writeConfig(
          viam: MockViam(),
          robot: robot,
          mainRobotPart: mainRobotPart,
          ssid: 'ssid',
          password: 'password',
          psk: 'viamsetup',
          fragmentId: null,
          fragmentOverride: false,
        );
      } catch (e) {
        expect(e.toString(), equals('Exception: No connected device'));
      }
    });

    test('fragment override written', () async {
      when(device.isConnected).thenReturn(true);
      await repository.connect(device);
      when(viamStatusCharacteristic.read()).thenAnswer((_) async => [0]); // not configured, not online

      final viam = MockViam();
      final appClient = MockAppClient();
      when(viam.appClient).thenReturn(appClient);
      when(appClient.updateRobotPart(any, any, any)).thenAnswer((_) async => mainRobotPart);

      await repository.writeConfig(
        viam: viam,
        robot: robot,
        mainRobotPart: mainRobotPart,
        ssid: 'ssid',
        password: 'password',
        psk: 'viamsetup',
        fragmentId: null,
        fragmentOverride: true,
      );

      verify(partIdCharacteristic.write(any)).called(1);
      verify(partSecretCharacteristic.write(any)).called(1);
      verify(appAddressCharacteristic.write(any)).called(1);

      verify(ssidCharacteristic.write(any)).called(1);
      verify(pskCharacteristic.write(any)).called(1);

      verify(exitProvisioningCharacteristic.write(any)).called(1);

      verify(appClient.updateRobotPart(any, any, any)).called(1);
    });

    group('readNetworkList', () {
      test('should read network list successfully', () async {
        when(device.isConnected).thenReturn(true);
        await repository.connect(device);

        final networList = await repository.readNetworkList();
        expect(networList.length, equals(3));
        expect(networList[0].ssid, equals('HomeWiFi'));
        expect(networList[0].signalStrength, equals(90));
        expect(networList[0].isSecure, equals(true));
        expect(networList[1].ssid, equals('PublicWiFi'));
        expect(networList[1].signalStrength, equals(50));
        expect(networList[1].isSecure, equals(false));
        expect(networList[2].ssid, equals('OfficeNetwork'));
        expect(networList[2].signalStrength, equals(25));
        expect(networList[2].isSecure, equals(true));
      });
    });

    group('isAgentVersionBelowMinimum', () {
      test('should return true when agent version is lower than minimum', () async {
        when(device.isConnected).thenReturn(true);
        await repository.connect(device);

        // 0.19.0
        when(agentVersionCharacteristic.read()).thenAnswer((_) async => [0x30, 0x2E, 0x31, 0x39, 0x2E, 0x30]);

        final isBelowMinimum = await repository.isAgentVersionBelowMinimum('0.20.0');
        expect(isBelowMinimum, equals(true));
      });

      test('should return false when agent version is higher than minimum', () async {
        when(device.isConnected).thenReturn(true);
        await repository.connect(device);

        // 0.21.0
        when(agentVersionCharacteristic.read()).thenAnswer((_) async => [0x30, 0x2E, 0x32, 0x31, 0x2E, 0x30]);

        final isBelowMinimum = await repository.isAgentVersionBelowMinimum('0.20.0');
        expect(isBelowMinimum, equals(false));
      });
    });

    group('isVersionLower', () {
      test('should return false when current version is higher than minimum', () {
        expect(repository.isVersionLower(currentVersionStr: '1.2.0', minimumVersionStr: '1.1.0'), false);
        expect(repository.isVersionLower(currentVersionStr: '2.0.0', minimumVersionStr: '1.9.9'), false);
        expect(repository.isVersionLower(currentVersionStr: '0.20.4', minimumVersionStr: '0.19.0'), false);
        expect(repository.isVersionLower(currentVersionStr: '0.0.2', minimumVersionStr: '0.0.1'), false);
        expect(repository.isVersionLower(currentVersionStr: '1.20', minimumVersionStr: '1.18.5'), false);
        expect(repository.isVersionLower(currentVersionStr: '0.2', minimumVersionStr: '0.1'), false);
      });

      test('should return true when current version is lower than minimum', () {
        expect(repository.isVersionLower(currentVersionStr: '1.1.0', minimumVersionStr: '1.2.0'), true);
        expect(repository.isVersionLower(currentVersionStr: '1.9.9', minimumVersionStr: '2.0.0'), true);
        expect(repository.isVersionLower(currentVersionStr: '0.19.0', minimumVersionStr: '0.20.4'), true);
        expect(repository.isVersionLower(currentVersionStr: '0.0.1', minimumVersionStr: '0.0.2'), true);
        expect(repository.isVersionLower(currentVersionStr: '1.18.5', minimumVersionStr: '1.20'), true);
        expect(repository.isVersionLower(currentVersionStr: '0.1', minimumVersionStr: '0.2'), true);
      });

      test('should handle pre-release versions correctly', () {
        expect(repository.isVersionLower(currentVersionStr: '0.20.4-release', minimumVersionStr: '0.19.0'), false);
        expect(repository.isVersionLower(currentVersionStr: 'custom', minimumVersionStr: '0.20.4'), false); // custom beats any version
      });

      test('should return false when versions are equal', () {
        expect(repository.isVersionLower(currentVersionStr: '1.2.0', minimumVersionStr: '1.2.0'), false);
        expect(repository.isVersionLower(currentVersionStr: '0.20.4-release', minimumVersionStr: '0.20.4'), false);
        expect(repository.isVersionLower(currentVersionStr: '0.20.4', minimumVersionStr: '0.20.4'), false);
      });
    });
  });
}
