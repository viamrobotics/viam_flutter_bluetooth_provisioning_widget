# Viam Flutter Bluetooth Provisioning Example

This directory contains a complete example app that demonstrates how to use the Viam Flutter Bluetooth Provisioning Widget with two flows: `BluetoothProvisioningFlow` and `BluetoothTetheringFlow`.

## Quick Start

1. **Update the constants** in `lib/consts.dart` with your Viam credentials:

```dart
class Consts {
  static const String apiKeyId = 'your-api-key-id';
  static const String apiKey = 'your-api-key';
  static const String organizationId = 'your-organization-id';
  static const String locationId = 'your-location-id';
  static const String psk = 'viamsetup'; // if you specify a hotspot_password in viam-defaults.json this must match
}
```

2. **Run the app** on a physical device:

```bash
flutter run
```

## Requirements

- **Physical Device**: Must be run on a physical device (not a simulator)
- **viam-agent Version**: Machine must be running `0.20.0`+ for standard flow, `0.21.0`+ for tethering

## Running Flutter Integration Tests with Patrol on a Physical iOS Device

Running [Patrol](https://patrol.leancode.co/) integration tests on a physical iOS device
requires code signing via Fastlane Match.

### First-time setup

1. Install Fastlane:

   ```bash
   brew install fastlane
   ```

2. Fetch the signing credentials:

   ```bash
   cd ios
   fastlane certs
   ```

   This downloads the provisioning profile and certificate from the
   [viam-ios-certs](https://github.com/viamrobotics/viam-ios-certs) repo
   and configures the RunnerUITests target for manual signing.

### Run the test

```bash
patrol test -t patrol_test/ble_provisioning_flow_test.dart --release
```

### Admin: Creating or renewing profiles

If profiles have expired or a new signing target is needed:

```bash
cd ios
fastlane setup_certs
```

This creates new certificates/profiles on the Apple Developer Portal and
pushes them to the certs repo.