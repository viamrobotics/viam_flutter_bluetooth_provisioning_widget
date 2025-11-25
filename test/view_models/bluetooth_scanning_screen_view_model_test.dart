import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/generate_mocks.mocks.dart';

void main() {
  group('BluetoothScanningScreenViewModel', () {
    late BluetoothScanningScreenViewModel viewModel;
    late MockViamBluetoothProvisioning mockViamBluetoothProvisioning;
    late MockBluetoothDevice mockDevice1;
    late MockBluetoothDevice mockDevice2;
    late ScanResult mockScanResult1;
    late ScanResult mockScanResult2;

    setUp(() {
      mockViamBluetoothProvisioning = MockViamBluetoothProvisioning();
      viewModel = BluetoothScanningScreenViewModel(
        onDeviceSelected: (device) {},
        scanBluetoothDevicesRepository: ScanBluetoothDevicesRepository(viamBluetoothProvisioning: mockViamBluetoothProvisioning),
        connectBluetoothDeviceRepository: ConnectBluetoothDeviceRepository(),
        title: 'title',
        scanCtaText: 'scanCtaText',
        notSeeingDeviceCtaText: 'notSeeingDeviceCtaText',
        tipsDialogTitle: 'tipsDialogTitle',
        tipsDialogSubtitle: 'tipsDialogSubtitle',
        tipsDialogCtaText: 'tipsDialogCtaText',
      );

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
      viewModel.dispose();
    });

    test('start scanning', () async {
      final mockScanningStream = StreamController<List<ScanResult>>();
      when(mockViamBluetoothProvisioning.scanForPeripherals()).thenAnswer((_) => Future.value(mockScanningStream.stream));

      when(mockViamBluetoothProvisioning.initialize(poweredOn: anyNamed('poweredOn'))).thenAnswer((invocation) {
        final poweredOnCallback = invocation.namedArguments[#poweredOn] as dynamic Function(bool)?;
        if (poweredOnCallback != null) {
          poweredOnCallback(true);
        }
      });
      await viewModel.startScanning();
      expect(viewModel.isScanning, true);
      mockScanningStream.add([mockScanResult1, mockScanResult2]);
      await Future.delayed(const Duration(seconds: 1)); // TODO: FAKE ASYNC
      expect(viewModel.uniqueDevices, [mockDevice1, mockDevice2]);
    });

    // connect

    // scan again
  });
}
