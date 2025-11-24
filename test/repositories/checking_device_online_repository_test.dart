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
    late MockBluetoothCharacteristic errorsCharacteristic;
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

      errorsCharacteristic = MockBluetoothCharacteristic();
      when(errorsCharacteristic.uuid).thenReturn(Guid.fromString(ViamBluetoothUUIDs.errorsUUID));

      when(service.characteristics).thenReturn(<BluetoothCharacteristic>[
        viamStatusCharacteristic,
        errorsCharacteristic,
      ]);

      viam = MockViam();
      robot = MockRobot();
      when(robot.id).thenReturn('robotId');
      timestamp = MockTimestamp();
      when(robot.lastAccess).thenReturn(timestamp);

      final appClient = MockAppClient();
      when(appClient.getRobot('robotId')).thenAnswer((_) async => robot);
      when(viam.appClient).thenReturn(appClient);

      repository = CheckingDeviceOnlineRepository(
        viam: viam,
        robot: robot,
        device: device,
        interval: const Duration(milliseconds: 5),
      );
    });

    tearDown(() {
      repository.dispose();
    });

    group('checking device online', () {
      test('start checking: comes online', () async {
        when(errorsCharacteristic.read()).thenAnswer((_) async => []); // empty errors
        when(timestamp.seconds).thenReturn(Int64(DateTime.now().millisecondsSinceEpoch ~/ 1000)); // now in seconds
        when(device.isConnected).thenReturn(true);

        repository.startChecking();
        final completer = Completer<void>();
        repository.deviceOnlineStateStream.listen((value) {
          expect(value, DeviceOnlineState.success);
          completer.complete();
        });

        await completer.future;
      });

      test('start checking: error offline', () async {
        when(errorsCharacteristic.read()).thenAnswer((_) async => [0x41, 0x42, 0x43]); // "ABC"
        when(timestamp.seconds).thenReturn(Int64(1764014950)); // 11/24/25 ~3pm EST
        when(device.isConnected).thenReturn(true);

        repository.startChecking();
        final completer1 = Completer<void>();
        repository.deviceOnlineStateStream.listen((value) {
          expect(value, DeviceOnlineState.errorConnecting);
          completer1.complete();
        });

        final completer2 = Completer<void>();
        repository.errorMessageStream.listen((value) {
          expect(value, equals('ABC'));
          completer2.complete();
        });

        await completer1.future;
        await completer2.future;
      });
      test('is robot online: true', () async {
        when(timestamp.seconds).thenReturn(Int64(DateTime.now().millisecondsSinceEpoch ~/ 1000)); // now in seconds
        final online = await repository.isRobotOnline();
        expect(online, isTrue);
      });

      test('is robot online: false', () async {
        when(timestamp.seconds).thenReturn(Int64(1764014950)); // 11/24/25 ~3pm EST
        final online = await repository.isRobotOnline();
        expect(online, isFalse);
      });

      test('read agent errors', () async {
        when(errorsCharacteristic.read()).thenAnswer((_) async => [0x41, 0x42, 0x43]); // "ABC"
        final error = await repository.readAgentError(device);
        expect(error, equals('ABC'));
      });
    });
  });
}
