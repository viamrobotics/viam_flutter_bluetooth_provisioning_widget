import 'package:flutter_test/flutter_test.dart';

import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/generate_mocks.mocks.dart';

void main() {
  group('ConnectBluetoothDeviceRepository', () {
    late ConnectBluetoothDeviceRepository repository;

    setUp(() {
      repository = ConnectBluetoothDeviceRepository();
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
      // TODO: throws when not device not connected
      // TODO: don't overwrite existing machine
      // TODO: not writing w/ out ssid?
      // TODO: fragment override test
      test('write config to connected device with no fragment override', () async {
        final device = MockBluetoothDevice();

        when(device.isConnected).thenReturn(true);
        when(device.connect()).thenAnswer((_) async => {});
        // OR make it so can init the repo w/ device
        await repository.connect(device);

        when(device.readStatus()).thenAnswer((_) async => (isConfigured: false, isConnected: true));
        when(device.writeRobotPartConfig(partId: 'partId', secret: 'secret', psk: 'viamsetup')).thenAnswer((_) async => {});
        when(device.writeNetworkConfig(ssid: 'ssid', pw: 'password', psk: 'psk')).thenAnswer((_) async => {});
        when(device.exitProvisioning(psk: 'viamsetup')).thenAnswer((_) async => {});

        await repository.writeConfig(
          viam: MockViam(),
          robot: MockRobot(),
          mainRobotPart: MockRobotPart(),
          ssid: 'ssid',
          password: 'password',
          psk: 'viamsetup',
          fragmentId: 'fragmentId',
          fragmentOverride: false,
        );

        verify(device.exitProvisioning(psk: 'viamsetup')).called(1);

        //   if (_device == null || _device?.isConnected == false) {
        //     throw Exception('No connected device');
        //   }

        //   final status = await _device!.readStatus();
        //   // don't overwrite existing machine, hotspot provisioning also does this check
        //   if (!status.isConfigured) {
        //     await _device!.writeRobotPartConfig(
        //       partId: mainRobotPart.id,
        //       secret: mainRobotPart.secret,
        //       psk: psk,
        //     );
        //   }
        //   if (ssid != null) {
        //     await _device!.writeNetworkConfig(ssid: ssid, pw: password, psk: psk);
        //   }
        //   if (fragmentOverride) {
        //     final fragmentIdToWrite = fragmentId ?? await _device!.readFragmentId();
        //     if (fragmentIdToWrite.isNotEmpty) {
        //       await _fragmentOverride(viam, fragmentIdToWrite, mainRobotPart, robot);
        //     }
        //   }
        //   await _device!.exitProvisioning(psk: psk);
        // }
      });
    });

    // readNetworkList

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
