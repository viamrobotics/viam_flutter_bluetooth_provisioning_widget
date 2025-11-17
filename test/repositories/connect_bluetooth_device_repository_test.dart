import 'package:flutter_test/flutter_test.dart';

import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/generate_mocks.mocks.dart';

void main() {
  group('ConnectBluetoothDeviceRepository', () {
    late ConnectBluetoothDeviceRepository repository;
    late MockBluetoothService service;
    late MockRobotPart mainRobotPart;
    late MockBluetoothCharacteristic viamStatusCharacteristic;
    late MockBluetoothCharacteristic partIdCharacteristic;
    late MockBluetoothCharacteristic partSecretCharacteristic;
    late MockBluetoothCharacteristic appAddressCharacteristic;
    late MockBluetoothCharacteristic ssidCharacteristic;
    late MockBluetoothCharacteristic pskCharacteristic;
    late MockBluetoothCharacteristic exitProvisioningCharacteristic;

    setUp(() {
      repository = ConnectBluetoothDeviceRepository();
      service = MockBluetoothService();
      when(service.uuid).thenReturn(Guid.fromString(ViamBluetoothUUIDs.serviceUUID));

      viamStatusCharacteristic = MockBluetoothCharacteristic();
      when(viamStatusCharacteristic.uuid).thenReturn(Guid.fromString(ViamBluetoothUUIDs.statusUUID));

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

      when(service.characteristics).thenReturn(<BluetoothCharacteristic>[
        viamStatusCharacteristic,
        viamCryptoCharacteristic,
        partIdCharacteristic,
        partSecretCharacteristic,
        appAddressCharacteristic,
        ssidCharacteristic,
        pskCharacteristic,
        exitProvisioningCharacteristic,
      ]);

      mainRobotPart = MockRobotPart();
      when(mainRobotPart.id).thenReturn('partId');
      when(mainRobotPart.secret).thenReturn('secret');
    });

    group('connect', () {
      test('connects successfully when no device connected', () async {
        final device = MockBluetoothDevice();

        when(device.isConnected).thenReturn(false);
        when(device.connect()).thenAnswer((_) async => {});

        expect(repository.device, isNull);
        await repository.connect(device);
        expect(repository.device, equals(device));
      });
    });

    group('write config', () {
      test('write config to connected device with no fragment override', () async {
        final device = MockBluetoothDevice();

        when(device.isConnected).thenReturn(true);
        when(device.connect()).thenAnswer((_) async => {});
        await repository.connect(device);
        when(viamStatusCharacteristic.read()).thenAnswer((_) async => [0]); // not configured, not online

        when(device.discoverServices(
          subscribeToServicesChanged: true,
          timeout: 15,
        )).thenAnswer((_) async => <BluetoothService>[service]);

        await repository.writeConfig(
          viam: MockViam(),
          robot: MockRobot(),
          mainRobotPart: mainRobotPart,
          ssid: 'ssid',
          password: 'password',
          psk: 'viamsetup',
          fragmentId: 'fragmentId',
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
      final device = MockBluetoothDevice();

      when(device.isConnected).thenReturn(true);
      when(device.connect()).thenAnswer((_) async => {});
      await repository.connect(device);

      when(device.discoverServices(
        subscribeToServicesChanged: true,
        timeout: 15,
      )).thenAnswer((_) async => <BluetoothService>[service]);

      when(viamStatusCharacteristic.read()).thenAnswer((_) async => [1]); // configured, not online

      await repository.writeConfig(
        viam: MockViam(),
        robot: MockRobot(),
        mainRobotPart: mainRobotPart,
        ssid: 'ssid',
        password: 'password',
        psk: 'viamsetup',
        fragmentId: 'fragmentId',
        fragmentOverride: false,
      );

      verifyNever(partIdCharacteristic.write(any));
      verifyNever(partSecretCharacteristic.write(any));
      verifyNever(appAddressCharacteristic.write(any));

      verify(ssidCharacteristic.write(any)).called(1);
      verify(pskCharacteristic.write(any)).called(1);

      verify(exitProvisioningCharacteristic.write(any)).called(1);
    });

    // TODO: throws when not device not connected
    // TODO: don't overwrite existing machine
    // TODO: not writing w/ out ssid?
    // TODO: fragment override test

    // TODO: readNetworkList

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
