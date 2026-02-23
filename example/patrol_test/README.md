# BLE Provisioning Integration Tests

This directory contains [Patrol](https://patrol.leancode.co/) integration tests
that exercise the full BLE provisioning flow end-to-end on a physical device.
Patrol extends Flutter's integration test framework with native automation so the
tests can tap through system dialogs (Bluetooth permissions, Local Network
access, etc.).

## Prerequisites

- A physical mobile device connected to your computer
- A Raspberry Pi (or other device) in provisioning mode
- [Flutter](https://docs.flutter.dev/get-started/install)
- [Patrol CLI](https://patrol.leancode.co/documentation/getting-started):
  `flutter pub global activate patrol_cli`
- Xcode (iOS) or Android Studio (Android)
- **iOS only:** Access to the [viamrobotics/viam-ios-certs](https://github.com/viamrobotics/viam-ios-certs) repo and the **Match passphrase** (see [iOS Code Signing](#ios-code-signing-with-fastlane-match))

## Running the Tests Manually
1) Before running, fill in your Viam credentials in [`lib/consts.dart`](../lib/consts.dart).

2) Update the Wi-Fi credentials in
`patrol_test/ble_provisioning_flow_test.dart`:
   ```dart
      const String testWifiSsid = 'YOUR_WIFI_SSID';
      const String testWifiPassword = 'YOUR_WIFI_PASSWORD';
   ```

All commands below are run from the `example/` directory.

### Android

```bash
patrol test -t patrol_test/ble_provisioning_flow_test.dart --verbose
```

No special signing or build mode is required on Android. Debug mode (the
default) works fine.

### iOS

iOS requires **release mode** and **manual code signing** because Patrol's
native test runner must be signed to deploy to a physical device.

```bash
patrol test -t patrol_test/ble_provisioning_flow_test.dart --release --verbose
```

#### iOS Code Signing with Fastlane Match

We use [Fastlane Match](https://docs.fastlane.tools/actions/match/) to manage
iOS signing certificates and provisioning profiles. Match stores them in a
private Git repo so any team member can fetch the same credentials.

**The certs repo:**
[viamrobotics/viam-ios-certs](https://github.com/viamrobotics/viam-ios-certs)
(private). This repo holds the encrypted signing certificates and provisioning
profiles. You need repo access and the **Match passphrase** to decrypt them.

Ask a team member for the Match passphrase if you don't have it. It is
required as the `MATCH_PASSWORD` environment variable (or Fastlane will prompt
you interactively).

**First-time setup:**

1. Install Fastlane:

   ```bash
   brew install fastlane
   ```

2. Fetch the signing credentials:

   ```bash
   cd ios
   fastlane certs
   ```

   This runs the `certs` lane, which downloads the provisioning profile and
   certificate from the viam-ios-certs repo and configures the
   `RunnerUITests` target for manual signing.

**Fastlane lanes:**

| Lane | What it does |
|------|-------------|
| `fastlane certs` | Fetches existing certs/profiles (read-only). Use this for day-to-day development. |
| `fastlane setup_certs` | Creates or renews certs/profiles on the Apple Developer Portal and pushes them to the certs repo. Use this if profiles have expired or a new target is needed. |

## Running with the Automated Script

The script at `scripts/ble_test.sh` automates the entire process: it clones the
repo into a temp directory, installs tools, injects credentials, fetches signing
certs (iOS), and runs the test. You just provide a `.env` file.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/viamrobotics/viam_flutter_bluetooth_provisioning_widget/main/scripts/ble_test.sh) /path/to/your.env
```

Or if you have the repo checked out locally:

```bash
./scripts/ble_test.sh /path/to/your.env
```

### `.env` File Format

Create a `.env` file with the following variables:

**Required (all platforms):**

| Variable | Description |
|----------|-------------|
| `API_KEY` | Viam API key |
| `API_KEY_ID` | Viam API key ID |
| `ORG_ID` | Viam organization ID |
| `LOCATION_ID` | Viam location ID |
| `WIFI_SSID` | Wi-Fi network name for the device to connect to |
| `WIFI_PASSWORD` | Wi-Fi password |
| `DEVICE` | Device ID (from `flutter devices`) |
| `PLATFORM` | `ios` or `android` |

**Required (iOS only):**

| Variable | Description |
|----------|-------------|
| `MATCH_PASSWORD` | Passphrase to decrypt the certs in the viam-ios-certs repo |
| `MATCH_KEYCHAIN_PASSWORD` | Password for the local keychain (can be any value; used to create a temporary keychain) |

**Optional:**

| Variable | Default | Description |
|----------|---------|-------------|
| `RELEASE` | `true` (iOS) / `false` (Android) | Build in release mode |
| `VERBOSE` | `true` | Enable verbose patrol output |
