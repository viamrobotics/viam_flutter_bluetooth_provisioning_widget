import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/generate_mocks.mocks.dart';

void main() {
  group('CheckingAgentOnlineRepository', () {
    late CheckingDeviceOnlineRepository repository;
    late MockBluetoothService service;

    late MockBluetoothDevice device;
    late MockBluetoothCharacteristic viamStatusCharacteristic;
    late MockViam viam;
    late MockRobot robot;

    setUp(() {
      device = MockBluetoothDevice();
      when(device.discoverServices(
        subscribeToServicesChanged: true,
        timeout: 15,
      )).thenAnswer((_) async => <BluetoothService>[service]);

      service = MockBluetoothService();
      when(service.uuid).thenReturn(Guid.fromString(ViamBluetoothUUIDs.serviceUUID));

      viamStatusCharacteristic = MockBluetoothCharacteristic();
      when(viamStatusCharacteristic.uuid).thenReturn(Guid.fromString(ViamBluetoothUUIDs.statusUUID));

      when(service.characteristics).thenReturn(<BluetoothCharacteristic>[viamStatusCharacteristic]);

      viam = MockViam();
      robot = MockRobot();

      repository = CheckingDeviceOnlineRepository(viam: viam, robot: robot, device: device);
    });

    tearDown(() {
      repository.dispose();
    });

    group('checking device online', () {
      test('first', () async {});
    });
  });
}
