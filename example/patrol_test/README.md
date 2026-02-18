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