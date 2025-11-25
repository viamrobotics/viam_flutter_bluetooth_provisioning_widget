import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/generate_mocks.mocks.dart';

void main() {
  group('BluetoothScanningScreenViewModel', () {
    late BluetoothScanningScreenViewModel viewModel;
    late MockViamBluetoothProvisioning mockViamBluetoothProvisioning;
    late MockConnectBluetoothDeviceRepository mockConnectBluetoothDeviceRepository;
    late MockBluetoothDevice mockDevice1;
    late MockBluetoothDevice mockDevice2;
    late ScanResult mockScanResult1;
    late ScanResult mockScanResult2;

    setUp(() {
      mockViamBluetoothProvisioning = MockViamBluetoothProvisioning();
      mockConnectBluetoothDeviceRepository = MockConnectBluetoothDeviceRepository();
      viewModel = BluetoothScanningScreenViewModel(
        scanBluetoothDevicesRepository: ScanBluetoothDevicesRepository(viamBluetoothProvisioning: mockViamBluetoothProvisioning),
        connectBluetoothDeviceRepository: mockConnectBluetoothDeviceRepository,
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
    group('scanning', () {
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
        expect(viewModel.uniqueDevices, []);

        mockScanningStream.add([mockScanResult1, mockScanResult2]);
        await pumpEventQueue();
        expect(viewModel.uniqueDevices, [mockDevice1, mockDevice2]);
      });

      test('scan devices again', () async {
        final mockScanningStream = StreamController<List<ScanResult>>();
        when(mockViamBluetoothProvisioning.scanForPeripherals()).thenAnswer((_) => Future.value(mockScanningStream.stream));

        when(mockViamBluetoothProvisioning.initialize(poweredOn: anyNamed('poweredOn'))).thenAnswer((invocation) {
          final poweredOnCallback = invocation.namedArguments[#poweredOn] as dynamic Function(bool)?;
          if (poweredOnCallback != null) {
            poweredOnCallback(true);
          }
        });
        await viewModel.scanDevicesAgain();
        expect(viewModel.isScanning, true);
        expect(viewModel.uniqueDevices, []);

        mockScanningStream.add([mockScanResult1, mockScanResult2]);
        await pumpEventQueue();
        expect(viewModel.uniqueDevices, [mockDevice1, mockDevice2]);
      });
    });

    group('connecting', () {
      test('success', () async {
        when(mockConnectBluetoothDeviceRepository.connect(mockDevice1)).thenAnswer((_) => Future.value());
        final result = await viewModel.connect(null, mockDevice1);
        expect(result, true);
        expect(viewModel.isConnecting, false);
        verify(mockConnectBluetoothDeviceRepository.connect(mockDevice1)).called(1);
      });

      test('failure', () async {
        when(mockConnectBluetoothDeviceRepository.connect(mockDevice1)).thenAnswer((_) => Future.error('error'));
        final result = await viewModel.connect(null, mockDevice1);
        expect(result, false);
        expect(viewModel.isConnecting, false);
        verify(mockConnectBluetoothDeviceRepository.connect(mockDevice1)).called(1);
      });
    });
  });
}
