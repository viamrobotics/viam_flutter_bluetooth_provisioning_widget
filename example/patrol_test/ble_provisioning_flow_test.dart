import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:viam_example_app/main.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Test configuration
//
// Before running:
//  1. Populate example/lib/consts.dart with real API keys and organization/location IDs.
//  2. Set the WiFi SSID and password below to match a network available in your
//     test environment.
//  3. Ensure a BLE-provisioning-capable Viam device is powered on and nearby.
//  4. Run:  patrol test -t patrol_test/ble_provisioning_flow_test.dart
//
// Note: Each run creates a new robot in your Viam organization. Clean up test
// robots afterwards if needed.
// ──────────────────────────────────────────────────────────────────────────────
const String testWifiSsid = 'YOUR_WIFI_SSID';
const String testWifiPassword = 'YOUR_WIFI_PASSWORD';

void main() {
  patrolTest(
    'BLE provisioning flow navigates all screens and device comes online',
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
    config: PatrolTesterConfig(printLogs: true),
    ($) async {
      // ── 1. Launch the app ─────────────────────────────────────────────────
      await $.pumpWidgetAndSettle(const MyApp());

      // ── 2. Start Screen ───────────────────────────────────────────────────
      await $(find.byKey(const ValueKey('new-machine-flow'))).tap();

      // Handle Android permission dialogs.
      // On Android 12+, Location may not appear since BLE no longer requires it.
      if (Platform.isAndroid) {
        if (await $.platform.mobile.isPermissionDialogVisible()) {
          await $.platform.mobile.grantPermissionWhenInUse(); // Bluetooth Scan
        }
        if (await $.platform.mobile.isPermissionDialogVisible()) {
          await $.platform.mobile.grantPermissionWhenInUse(); // Bluetooth Connect
        }
        if (await $.platform.mobile.isPermissionDialogVisible()) {
          await $.platform.mobile.grantPermissionWhenInUse(); // Location
        }
      }

      // ── 3. Provision New Machine Screen ───────────────────────────────────
      await $.pumpAndSettle();
      await $('Start Provisioning Flow').tap();

      // iOS: "Allow to find devices on local networks" dialog appears
      // when Viam.withApiKey() makes the first network call.
      if (Platform.isIOS) {
        if (await $.platform.mobile.isPermissionDialogVisible()) {
          await $.platform.mobile.grantPermissionWhenInUse();
        }
      }

      // ── 4. Wait for robot creation -> IntroScreenOne ──────────────────────
      // Viam.withApiKey() + createRobot() + 3s name display, then navigates
      // into BluetoothProvisioningFlow.
      await $(find.byKey(const ValueKey('screen-1-cta'))).waitUntilVisible(timeout: const Duration(seconds: 45));

      // ── 5. IntroScreenOne (page 0) ────────────────────────────────────────
      await $(find.byKey(const ValueKey('screen-1-cta'))).tap();

      // ── 6. PowerDeviceInstructionsScreen (page 1) ─────────────────────────
      await $(find.byKey(const ValueKey('screen-2-cta'))).tap();

      // ── 7. BluetoothOnInstructionsScreen (page 2) ─────────────────────────
      // No ValueKey on "Next"; use .last to avoid the off-screen duplicate.
      await $('Next').last.tap();

      // ── 8. BluetoothScanningScreen (page 3) ──────────────────────────────
      // iOS: "Allow to find Bluetooth devices" dialog appears here.
      if (Platform.isIOS) {
        if (await $.platform.mobile.isPermissionDialogVisible()) {
          await $.platform.mobile.grantPermissionWhenInUse();
        }
      }

      // Wait for a BLE device to appear in scan results.
      await $(find.byKey(const ValueKey('device-tile'))).waitUntilVisible(timeout: const Duration(seconds: 60));
      await $(find.byKey(const ValueKey('device-tile'))).first.tap();

      // ── 9. WiFi Screen ────────────────────────────────────────────────────
      // After tapping a device: stop scan, connect, validate, navigate to
      // WiFi screen, read network list.
      await $('Choose your Wi-Fi').waitUntilVisible(timeout: const Duration(seconds: 60));

      // ── 10. WiFi Network Selection ────────────────────────────────────────
      // Scroll the list if needed to find the target SSID, then tap it.
      await $(testWifiSsid).scrollTo(scrollDirection: AxisDirection.down).tap();

      // ── 11. WiFi Password Entry ───────────────────────────────────────────
      await $(TextFormField).waitUntilVisible();
      await $(TextFormField).enterText(testWifiPassword);
      await $('Connect').tap();

      // ── 12. Device Online Check ───────────────────────────────────────────
      // Polls Viam API every 5s. Can take 1-3 minutes.
      // Try waiting for success screen; if it times out, check for error screen.
      try {
        await $(find.byKey(const ValueKey('device-connected-viam'))).waitUntilVisible(timeout: const Duration(minutes: 2));
      } catch (_) {
        if (find.byKey(const ValueKey('device-error')).evaluate().isNotEmpty) {
          fail('Device showed "Error during setup" instead of coming online.');
        }
        rethrow;
      }
    },
  );
}
