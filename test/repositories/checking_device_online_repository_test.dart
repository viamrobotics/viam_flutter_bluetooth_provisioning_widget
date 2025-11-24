import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';
import 'package:mockito/mockito.dart';

import 'package:fixnum/fixnum.dart';
import '../mocks/generate_mocks.mocks.dart';

void main() {
  group('CheckingAgentOnlineRepository', () {
    late CheckingDeviceOnlineRepository repository;
    late MockBluetoothService service;

    late MockBluetoothDevice device;
    late MockBluetoothCharacteristic viamStatusCharacteristic;
    late MockViam viam;
    late MockRobot robot;
    late MockTimestamp timestamp;

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
      when(robot.id).thenReturn('robotId');
      timestamp = MockTimestamp();
      when(robot.lastAccess).thenReturn(timestamp);

      final appClient = MockAppClient();
      when(appClient.getRobot('robotId')).thenAnswer((_) async => robot);
      when(viam.appClient).thenReturn(appClient);

      repository = CheckingDeviceOnlineRepository(viam: viam, robot: robot, device: device);
    });

    tearDown(() {
      repository.dispose();
    });

    group('checking device online', () {
      test('start checking', () async {});
      test('is robot online: true', () async {
        when(timestamp.seconds).thenReturn(Int64(DateTime.now().millisecondsSinceEpoch ~/ 1000)); // now in seconds
        final online = await repository.isRobotOnline();
        expect(online, isTrue);
      });

      test('is robot online: false', () async {
        when(timestamp.seconds).thenReturn(Int64(1764014950)); // 11/24/25
        final online = await repository.isRobotOnline();
        expect(online, isFalse);
      });

      test('read agent errors', () async {});
    });
  });
}
