import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/generate_mocks.mocks.dart';

void main() {
  group('CheckingAgentOnlineRepository', () {
    late CheckingAgentOnlineRepository repository;
    late MockBluetoothService service;

    late MockBluetoothDevice device;
    late MockBluetoothCharacteristic viamStatusCharacteristic;

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

      repository = CheckingAgentOnlineRepository(device: device, checkingInterval: const Duration(milliseconds: 5));
    });

    tearDown(() {
      repository.dispose();
    });

    group('checking agent online', () {
      test('read online status', () async {
        when(viamStatusCharacteristic.read()).thenAnswer((_) async => [2]); // online, no machine creds

        final completer = Completer<void>();
        repository.agentOnlineStateStream.listen((value) {
          expect(value, true);
          completer.complete();
        });

        await repository.readAgentStatus();
        await completer.future;
      });

      test('read online status with timer', () async {
        when(viamStatusCharacteristic.read()).thenAnswer((_) async => [2]); // online, no machine creds

        final completer = Completer<void>();
        repository.agentOnlineStateStream.listen((value) {
          expect(value, true);
          completer.complete();
        });

        repository.startChecking();
        await completer.future;
      });

      test('error reading online status', () async {
        when(viamStatusCharacteristic.read()).thenThrow(Exception('Error reading online status'));

        try {
          await repository.readAgentStatus();
        } on Exception catch (e) {
          expect(e.toString(), 'Exception: Error reading online status');
        }
      });

      test('error reading online status: device not set', () async {
        repository = CheckingAgentOnlineRepository(device: null);
        try {
          await repository.readAgentStatus();
        } on Exception catch (e) {
          expect(e.toString(), 'Exception: Device is not set');
        }
      });
    });
  });
}
