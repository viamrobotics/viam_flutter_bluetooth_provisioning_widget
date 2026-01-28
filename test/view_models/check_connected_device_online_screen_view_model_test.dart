import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/generate_mocks.mocks.dart';

void main() {
  group('CheckConnectedDeviceOnlineScreenViewModel', () {
    late CheckConnectedDeviceOnlineScreenViewModel viewModel;
    late MockConnectBluetoothDeviceRepository mockConnectBluetoothDeviceRepository;
    late MockCheckingDeviceOnlineRepository mockCheckingDeviceOnlineRepository;
    late StreamController<DeviceOnlineState> deviceOnlineStream;
    late StreamController<String> errorMessageStream;

    setUp(() {
      mockConnectBluetoothDeviceRepository = MockConnectBluetoothDeviceRepository();

      deviceOnlineStream = StreamController<DeviceOnlineState>.broadcast();
      mockCheckingDeviceOnlineRepository = MockCheckingDeviceOnlineRepository();
      when(mockCheckingDeviceOnlineRepository.deviceOnlineStateStream).thenAnswer((_) => deviceOnlineStream.stream);
      when(mockCheckingDeviceOnlineRepository.deviceOnlineState).thenReturn(DeviceOnlineState.idle);

      errorMessageStream = StreamController<String>.broadcast();
      when(mockCheckingDeviceOnlineRepository.errorMessageStream).thenAnswer((_) => errorMessageStream.stream);

      viewModel = CheckConnectedDeviceOnlineScreenViewModel(
        successTitle: 'successTitle',
        successSubtitle: 'successSubtitle',
        successCta: 'successCta',
        checkingDeviceOnlineRepository: mockCheckingDeviceOnlineRepository,
        connectBluetoothDeviceRepository: mockConnectBluetoothDeviceRepository,
      );
    });

    tearDown(() {
      viewModel.dispose();
    });
    test('reconnect', () async {
      final device = MockBluetoothDevice();
      when(mockConnectBluetoothDeviceRepository.connectedDevice).thenReturn(device);
      when(device.isConnected).thenReturn(false);

      await viewModel.reconnect();

      verify(mockConnectBluetoothDeviceRepository.reconnect()).called(1);
      expect(mockConnectBluetoothDeviceRepository.connectedDevice, isNotNull);
    });

    test('start checking', () async {
      viewModel.startChecking();
      verify(mockCheckingDeviceOnlineRepository.startChecking()).called(1);
    });

    test('listen to device online state stream', () async {
      deviceOnlineStream.add(DeviceOnlineState.success);
      await pumpEventQueue();
      expect(viewModel.deviceOnlineState, DeviceOnlineState.success);
    });

    test('listen to error message stream', () async {
      errorMessageStream.add('error message');
      await pumpEventQueue();
      expect(viewModel.errorMessage, 'error message');
    });
  });
}
