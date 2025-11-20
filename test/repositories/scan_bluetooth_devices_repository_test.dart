import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/generate_mocks.mocks.dart';

void main() {
  group('ScanBluetoothDevicesRepository', () {
    late ScanBluetoothDevicesRepository repository;
    late MockBluetoothService service;
    late MockRobotPart mainRobotPart;
    late MockRobot robot;

    // late MockBluetoothDevice device;
    // late MockBluetoothCharacteristic viamStatusCharacteristic;
    // late MockBluetoothCharacteristic partIdCharacteristic;
    // late MockBluetoothCharacteristic partSecretCharacteristic;
    // late MockBluetoothCharacteristic appAddressCharacteristic;
    // late MockBluetoothCharacteristic ssidCharacteristic;
    // late MockBluetoothCharacteristic pskCharacteristic;
    // late MockBluetoothCharacteristic exitProvisioningCharacteristic;
    // late MockBluetoothCharacteristic networkListCharacteristic;
    // late MockBluetoothCharacteristic fragmentIdCharacteristic;
    // late MockBluetoothCharacteristic agentVersionCharacteristic;

    setUp(() {
      repository = ScanBluetoothDevicesRepository();
      service = MockBluetoothService();
      when(service.uuid).thenReturn(Guid.fromString(ViamBluetoothUUIDs.serviceUUID));

      mainRobotPart = MockRobotPart();
      when(mainRobotPart.id).thenReturn('partId');
      when(mainRobotPart.secret).thenReturn('secret');

      robot = MockRobot();
      when(robot.id).thenReturn('robotId');
      when(robot.name).thenReturn('robotName');
    });

    group('start scan', () {
      test('connects successfully when no device connected', () async {
        final mockScanningStream = StreamController<List<ScanResult>>();
        final mockViamBluetoothProvisioning = MockViamBluetoothProvisioning();
        // TODO: need to change this class to have non-static method so can override
        when(mockViamBluetoothProvisioning.scanForPeripherals()).thenAnswer((_) async => mockScanningStream.stream);
        await repository.startScan();

        final mockDevice = MockBluetoothDevice();
        when(mockDevice.remoteId).thenReturn(DeviceIdentifier('test_device'));

        mockScanningStream.add([
          ScanResult(
            device: mockDevice,
            advertisementData: AdvertisementData(
              advName: 'test',
              txPowerLevel: 0,
              appearance: 0,
              connectable: true,
              manufacturerData: {},
              serviceData: {},
              serviceUuids: [],
            ),
            rssi: 0,
            timeStamp: DateTime.now(),
          )
        ]);

        repository.uniqueDevicesStream.listen((value) {
          expect(value, [mockDevice]);
        });
      });
    });

    group('scan devices again', () {
      test('connects successfully when no device connected', () async {});
    });

    group('stop scan', () {
      test('connects successfully when no device connected', () async {});
    });
  });
}
