## Patrol Integration Tests

This project uses [Patrol](https://patrol.leancode.co/) for integration testing. Patrol extends Flutter's integration test framework with native interaction support — like tapping OS-level permission dialogs (Bluetooth, Location, Local Network) — which standard `integration_test` cannot do.

### Setup

```bash
flutter pub global activate patrol_cli
brew install fastlane   # iOS only
```

### iOS code signing

Running Patrol tests on a physical iOS device requires code signing the `RunnerUITests` target via [Fastlane Match](https://docs.fastlane.tools/actions/match/).

To fetch the signing credentials:

```bash
cd ../ios
fastlane certs
```

This downloads the provisioning profile and certificate from the [viam-ios-certs](https://github.com/viamrobotics/viam-ios-certs) repo and configures the `RunnerUITests` target for manual signing. You will be prompted for the Match passphrase.

### Admin: creating or renewing profiles

If profiles have expired or a new signing target is needed:

```bash
cd ../ios
fastlane setup_certs
```

This creates new certificates/profiles on the Apple Developer Portal and pushes them to the certs repo.
