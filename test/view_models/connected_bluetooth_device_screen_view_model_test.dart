import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/generate_mocks.mocks.dart';

void main() {
  group('ConnectedBluetoothDeviceScreenViewModel', () {
    late ConnectedBluetoothDeviceScreenViewModel viewModel;
    late MockConnectBluetoothDeviceRepository mockConnectBluetoothDeviceRepository;

    setUp(() {
      mockConnectBluetoothDeviceRepository = MockConnectBluetoothDeviceRepository();
      viewModel = ConnectedBluetoothDeviceScreenViewModel(
        connectBluetoothDeviceRepository: mockConnectBluetoothDeviceRepository,
        title: 'title',
        subtitle: 'subtitle',
        scanCtaText: 'scanCtaText',
        notSeeingDeviceCtaText: 'notSeeingDeviceCtaText',
        tipsDialogTitle: 'tipsDialogTitle',
        tipsDialogSubtitle: 'tipsDialogSubtitle',
        tipsDialogCtaText: 'tipsDialogCtaText',
      );
    });

    tearDown(() {
      viewModel.dispose();
    });
    test('read network list', () async {
      when(mockConnectBluetoothDeviceRepository.readNetworkList()).thenAnswer((_) => Future.value([
            WifiNetwork(ssid: 'ssid', signalStrength: 100, isSecure: true),
            WifiNetwork(ssid: 'ssid2', signalStrength: 50, isSecure: false),
          ]));
      await viewModel.readNetworkList(null);

      expect(viewModel.wifiNetworks[0].ssid, equals('ssid'));
      expect(viewModel.wifiNetworks[0].signalStrength, equals(100));
      expect(viewModel.wifiNetworks[0].isSecure, equals(true));
      expect(viewModel.wifiNetworks[1].ssid, equals('ssid2'));
      expect(viewModel.wifiNetworks[1].signalStrength, equals(50));
      expect(viewModel.wifiNetworks[1].isSecure, equals(false));
      expect(viewModel.isLoadingNetworks, false);
    });
    test('read network list failure', () async {
      when(mockConnectBluetoothDeviceRepository.readNetworkList()).thenAnswer((_) => Future.error('error'));
      await viewModel.readNetworkList(null);

      expect(viewModel.isLoadingNetworks, false);
      expect(viewModel.wifiNetworks, []);
      verify(mockConnectBluetoothDeviceRepository.readNetworkList()).called(1);
    });
  });
}
