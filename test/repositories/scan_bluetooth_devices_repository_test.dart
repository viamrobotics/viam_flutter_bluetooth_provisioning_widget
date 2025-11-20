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
    });

    tearDown(() {
      repository.dispose();
    });

    group('start scan', () {
      test('scan returns', () async {
        final mockScanningStream = StreamController<List<ScanResult>>();
        when(mockViamBluetoothProvisioning.scanForPeripherals()).thenAnswer((_) => Future.value(mockScanningStream.stream));
        await repository.startScan();
        expect(repository.isScanning, true);

        final mockDevice = MockBluetoothDevice();
        when(mockDevice.remoteId).thenReturn(DeviceIdentifier('test_device'));

        final completer = Completer<void>();
        repository.uniqueDevicesStream.listen((value) {
          expect(value, [mockDevice]);
          completer.complete();
        });

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

        await completer.future;
      });
    });

    // group('scan devices again', () {
    //   test('connects successfully when no device connected', () async {});
    // });

    // group('stop scan', () {
    //   test('connects successfully when no device connected', () async {});
    // });
  });
}
