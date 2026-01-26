import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/generate_mocks.mocks.dart';

void main() {
  group('CheckAgentOnlineScreenViewModel', () {
    late CheckAgentOnlineScreenViewModel viewModel;
    late MockCheckingAgentOnlineRepository mockCheckingAgentOnlineRepository;
    late StreamController<bool> agentOnlineStream;
    late MockConnectBluetoothDeviceRepository mockConnectBluetoothDeviceRepository;
    setUp(() {
      mockConnectBluetoothDeviceRepository = MockConnectBluetoothDeviceRepository();

      agentOnlineStream = StreamController<bool>.broadcast();
      mockCheckingAgentOnlineRepository = MockCheckingAgentOnlineRepository();
      when(mockCheckingAgentOnlineRepository.agentOnlineStateStream).thenAnswer((_) => agentOnlineStream.stream);
      when(mockCheckingAgentOnlineRepository.agentOnline).thenReturn(false);

      viewModel = CheckAgentOnlineScreenViewModel(
        successTitle: 'successTitle',
        successSubtitle: 'successSubtitle',
        checkingAgentOnlineRepository: mockCheckingAgentOnlineRepository,
        connectBluetoothDeviceRepository: mockConnectBluetoothDeviceRepository,
      );
    });

    tearDown(() {
      viewModel.dispose();
    });
    test('reconnect', () async {
      final device = MockBluetoothDevice();
      when(mockConnectBluetoothDeviceRepository.currentDevice).thenReturn(device);
      when(device.isConnected).thenReturn(false);

      await viewModel.reconnect();

      verify(mockConnectBluetoothDeviceRepository.reconnect()).called(1);
      expect(mockConnectBluetoothDeviceRepository.currentDevice, isNotNull);
    });

    test('start checking', () async {
      viewModel.startChecking();
      verify(mockCheckingAgentOnlineRepository.startChecking()).called(1);
    });

    test('listen to agent online state stream', () async {
      agentOnlineStream.add(true);
      await pumpEventQueue();
      expect(viewModel.agentOnline, true);
    });
  });
}
