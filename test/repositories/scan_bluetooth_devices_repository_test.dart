import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/generate_mocks.mocks.dart';

void main() {
  group('ScanBluetoothDevicesRepository', () {
    late ScanBluetoothDevicesRepository repository;
    late MockViamBluetoothProvisioning mockViamBluetoothProvisioning;
    late MockBluetoothService service;
    late MockRobotPart mainRobotPart;
    late MockRobot robot;

    late MockBluetoothDevice mockDevice1;
    late MockBluetoothDevice mockDevice2;

    late ScanResult mockScanResult1;
    late ScanResult mockScanResult2;

    setUp(() {
      mockViamBluetoothProvisioning = MockViamBluetoothProvisioning();
      repository = ScanBluetoothDevicesRepository(viamBluetoothProvisioning: mockViamBluetoothProvisioning);
      service = MockBluetoothService();
      when(service.uuid).thenReturn(Guid.fromString(ViamBluetoothUUIDs.serviceUUID));

      mainRobotPart = MockRobotPart();
      when(mainRobotPart.id).thenReturn('partId');
      when(mainRobotPart.secret).thenReturn('secret');

      robot = MockRobot();
      when(robot.id).thenReturn('robotId');
      when(robot.name).thenReturn('robotName');

      mockDevice1 = MockBluetoothDevice();
      when(mockDevice1.remoteId).thenReturn(DeviceIdentifier('test_device_1'));
      mockDevice2 = MockBluetoothDevice();
      when(mockDevice2.remoteId).thenReturn(DeviceIdentifier('test_device_2'));

      mockScanResult1 = ScanResult(
        device: mockDevice1,
        advertisementData: AdvertisementData(
          advName: 'adv1',
          txPowerLevel: 0,
          appearance: 0,
          connectable: true,
          manufacturerData: {},
          serviceData: {},
          serviceUuids: [],
        ),
        rssi: 0,
        timeStamp: DateTime.now(),
      );
      mockScanResult2 = ScanResult(
        device: mockDevice2,
        advertisementData: AdvertisementData(
          advName: 'adv2',
          txPowerLevel: 0,
          appearance: 0,
          connectable: true,
          manufacturerData: {},
          serviceData: {},
          serviceUuids: [],
        ),
        rssi: 0,
        timeStamp: DateTime.now(),
      );
    });

    tearDown(() {
      repository.dispose();
    });

    group('scanning', () {
      test('start scanning', () async {
        final mockScanningStream = StreamController<List<ScanResult>>();
        when(mockViamBluetoothProvisioning.scanForPeripherals()).thenAnswer((_) => Future.value(mockScanningStream.stream));

        final completer = Completer<void>();
        repository.uniqueDevicesStream.listen((value) {
          expect(value, [mockDevice1, mockDevice2]);
          completer.complete();
        });

        await repository.startScan();
        expect(repository.isScanning, true);

        mockScanningStream.add([mockScanResult1, mockScanResult2]);

        await completer.future;
      });
    });
  });
}
