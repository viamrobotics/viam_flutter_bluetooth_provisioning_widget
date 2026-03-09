import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:viam_example_app/main.dart';

void main() {
  patrolTest(
    'BLE provisioning flow navigates all screens and device comes online',
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
    config: PatrolTesterConfig(printLogs: true),
    ($) async {
      // Load .env (same file the app uses — Wi-Fi creds come from here too)
      await dotenv.load(fileName: ".env");
      final String testWifiSsid = dotenv.env['WIFI_SSID']!;
      final String testWifiPassword = dotenv.env['WIFI_PASSWORD']!;

      // Launch
      await $.pumpWidgetAndSettle(const MyApp());

      // Start Screen
      await $(find.byKey(const ValueKey('new-machine-flow'))).tap();

      // Android permissions (Location may not appear on Android 12+)
      if (Platform.isAndroid) {
        await $.pumpAndSettle();
        if (await $.platform.mobile.isPermissionDialogVisible()) {
          await $.platform.mobile.grantPermissionWhenInUse(); // Bluetooth Scan
        }
        await $.pumpAndSettle();
        if (await $.platform.mobile.isPermissionDialogVisible()) {
          await $.platform.mobile.grantPermissionWhenInUse(); // Bluetooth Connect
        }
        await $.pumpAndSettle();
        if (await $.platform.mobile.isPermissionDialogVisible()) {
          await $.platform.mobile.grantPermissionWhenInUse(); // Location
        }
      }

      // Provision New Machine Screen
      await $.pumpAndSettle();
      await $('Start Provisioning Flow').tap();

      // iOS: Local Network permission
      if (Platform.isIOS) {
        await $.pumpAndSettle();
        if (await $.platform.mobile.isPermissionDialogVisible()) {
          await $.platform.mobile.grantPermissionWhenInUse();
        }
      }

      // Wait for robot creation
      await $(find.byKey(const ValueKey('screen-1-cta'))).waitUntilVisible(timeout: const Duration(seconds: 45));

      // IntroScreenOne
      await $(find.byKey(const ValueKey('screen-1-cta'))).tap();

      // PowerDeviceInstructionsScreen
      await $(find.byKey(const ValueKey('screen-2-cta'))).tap();

      // BluetoothOnInstructionsScreen
      await $('Next').last.tap();

      // BluetoothScanningScreen — iOS: Bluetooth permission
      if (Platform.isIOS) {
        await $.pumpAndSettle();
        if (await $.platform.mobile.isPermissionDialogVisible()) {
          await $.platform.mobile.grantPermissionWhenInUse();
        }
      }

      await $(find.byKey(const ValueKey('device-tile'))).waitUntilVisible(timeout: const Duration(seconds: 45));
      await $(find.byKey(const ValueKey('device-tile'))).first.tap();

      // WiFi Screen
      await $('Choose your Wi-Fi').waitUntilVisible(timeout: const Duration(seconds: 45));

      // WiFi Network Selection
      await $(testWifiSsid).scrollTo(scrollDirection: AxisDirection.down).tap();

      // WiFi Password Entry
      await $(TextFormField).waitUntilVisible();
      await $(TextFormField).enterText(testWifiPassword);
      await $('Connect').tap();

      // Device Online Check
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
