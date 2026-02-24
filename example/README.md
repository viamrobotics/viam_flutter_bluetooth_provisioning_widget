# Viam Flutter Bluetooth Provisioning Example

This directory contains a complete example app that demonstrates how to use the Viam Flutter Bluetooth Provisioning Widget with two flows: `BluetoothProvisioningFlow` and `BluetoothTetheringFlow`.

## Quick Start

1. **Set up your environment** — create a `.env` file in this directory with your Viam credentials (see `.env.example` for reference):

```
API_KEY_ID=your-api-key-id
API_KEY=your-api-key
ORG_ID=your-organization-id
LOCATION_ID=your-location-id
PSK=viamsetup
```

See `.env.example` for additional fields needed when running integration tests.

2. **Run the app** on a physical device:

```bash
flutter run
```

## Requirements

- **Physical Device**: Must be run on a physical device (not a simulator)
- **viam-agent Version**: Machine must be running `0.20.0`+ for standard flow, `0.21.0`+ for tethering

## BLE Provisioning Integration Tests

Both approaches below require additional fields in your `.env` file — see `.env.example` for the full list.

### Automated (recommended)

Fill in all sections of your `.env` file (including Wi-Fi credentials, device, and platform), then run from anywhere:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/viamrobotics/viam_flutter_bluetooth_provisioning_widget/main/example/ble_test.sh) /path/to/.env
```

Or if you already have the repo cloned:

```bash
bash ble_test.sh .env
```

### Manual

Make sure `WIFI_SSID` and `WIFI_PASSWORD` are filled in your `.env`, then:

1. Install [Patrol CLI](https://patrol.leancode.co/):

```bash
flutter pub global activate patrol_cli
```

2. **iOS only** — install Fastlane and fetch signing credentials (see [Patrol test README](patrol_test/README.md) for more details):

```bash
brew install fastlane
cd ios && fastlane certs
```

3. Run the test from the `example/` directory:

**Android:**
```bash
patrol test -t patrol_test/ble_provisioning_flow_test.dart --verbose
```

**iOS:**
```bash
patrol test -t patrol_test/ble_provisioning_flow_test.dart --release --verbose
```