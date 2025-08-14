import 'package:flutter_test/flutter_test.dart';

import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';

void main() {
  group('ConnectBluetoothDeviceRepository', () {
    late ConnectBluetoothDeviceRepository repository;

    setUp(() {
      repository = ConnectBluetoothDeviceRepository();
    });

    tearDown(() {
      repository.dispose();
    });

    group('isVersionLower', () {
      test('should return false when current version is higher than minimum', () {
        expect(repository.isVersionLower(currentVersionStr: '1.2.0', minimumVersionStr: '1.1.0'), false);
        expect(repository.isVersionLower(currentVersionStr: '2.0.0', minimumVersionStr: '1.9.9'), false);
        expect(repository.isVersionLower(currentVersionStr: '0.20.4', minimumVersionStr: '0.19.0'), false);
        expect(repository.isVersionLower(currentVersionStr: '0.0.2', minimumVersionStr: '0.0.1'), false);
        expect(repository.isVersionLower(currentVersionStr: '1.20', minimumVersionStr: '1.18.5'), false);
        expect(repository.isVersionLower(currentVersionStr: '0.2', minimumVersionStr: '0.1'), false);
      });

      test('should return true when current version is lower than minimum', () {
        expect(repository.isVersionLower(currentVersionStr: '1.1.0', minimumVersionStr: '1.2.0'), true);
        expect(repository.isVersionLower(currentVersionStr: '1.9.9', minimumVersionStr: '2.0.0'), true);
        expect(repository.isVersionLower(currentVersionStr: '0.19.0', minimumVersionStr: '0.20.4'), true);
        expect(repository.isVersionLower(currentVersionStr: '0.0.1', minimumVersionStr: '0.0.2'), true);
        expect(repository.isVersionLower(currentVersionStr: '1.18.5', minimumVersionStr: '1.20'), true);
        expect(repository.isVersionLower(currentVersionStr: '0.1', minimumVersionStr: '0.2'), true);
      });

      test('should handle pre-release versions correctly', () {
        expect(repository.isVersionLower(currentVersionStr: '0.20.4-release', minimumVersionStr: '0.19.0'), false);
        expect(repository.isVersionLower(currentVersionStr: 'custom', minimumVersionStr: '0.20.4'), false); // custom beats any version
      });

      test('should return false when versions are equal', () {
        expect(repository.isVersionLower(currentVersionStr: '1.2.0', minimumVersionStr: '1.2.0'), false);
        expect(repository.isVersionLower(currentVersionStr: '0.20.4-release', minimumVersionStr: '0.20.4'), false);
        expect(repository.isVersionLower(currentVersionStr: '0.20.4', minimumVersionStr: '0.20.4'), false);
      });
    });
  });
}
