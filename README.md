# Viam Flutter Bluetooth Provisioning Widget

A Flutter package for provisioning Viam machines using Bluetooth. This widget provides two complete flows for connecting to machines via Bluetooth: a standard provisioning flow for machines with internet access, and a tethering flow for machines that need to share the mobile device's internet connection.

This package is built on top of [viam_flutter_provisioning](https://github.com/viamrobotics/viam_flutter_provisioning) which uses [flutter_blue_plus](https://github.com/chipweinberger/flutter_blue_plus) for Bluetooth communication with [viam-agent](https://github.com/viamrobotics/agent). 

This package also relies on the [viam-flutter-sdk](https://github.com/viamrobotics/viam-flutter-sdk).

## Installation

`flutter pub add viam_flutter_bluetooth_provisioning_widget`

## Prerequisites

### Machine Setup

1. **Flash your Device**: See the [Viam Documentation](https://docs.viam.com/installation/prepare/rpi-setup) for an example of flashing a Raspberry Pi.
2. **Configure provisioning defaults**: Create a provisioning configuration file (`viam-defaults.json`) by specifying at least the following info:

   ```json
   {
     "network_configuration": {
       "disable_bt_provisioning": false
     }
   }
   ```
   If you specify `hotspot_password` it will be used as a pre-shared key and should be passed into the provisioning flows so they can write successfully.

   For more instructions on setting up the config, see the [Viam Documentation](https://docs.viam.com/manage/fleet/provision/setup/#configure-defaults).

3. **Install viam-agent**: Run the pre-install script and pass in the location of your `viam-defaults.json`:
   ```bash
   sudo ./preinstall.sh
   ```
   
   For more instructions on running the pre-install script, see the [Viam Documentation](https://docs.viam.com/manage/fleet/provision/setup/#install-viam-agent).

### Device Requirements

- **Physical Device Required**: App's relying on this widget must be run on a physical device to discover nearby Bluetooth devices running `viam-agent` with Bluetooth provisioning enabled.
- **Bluetooth Enabled**: Ensure Bluetooth is enabled on both the mobile device and the target machine.
- **viam-agent Version**: The machine must be running `0.20.0` and up of `viam-agent`. Tethering requires `0.21.0` of `viam-agent`.

## Platform Requirements

### iOS

Add the following to your `Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>YOUR COPY</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>YOUR COPY</string>
```

### Android

Add the following permissions to your `AndroidManifest.xml` files:

```xml
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN"/>
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
    <!-- Location permissions required for Bluetooth scanning on Android 12+ -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

## Usage

### Viam Setup

Before starting a provisioning flow, you need to:

1. Create a [Viam](https://flutter.viam.dev/viam_sdk/Viam-class.html) instance
2. Either create a new robot or retrieve an existing one
3. Retrieve the main robot part

### Basic Example

```dart
import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';

// Initialize Viam and get robot
final viam = await Viam.withApiKey(apiKeyId, apiKey);
final robot = await viam.appClient.getRobot(robotId);
final mainPart = (await viam.appClient.listRobotParts(robot.id)).firstWhere((element) => element.mainPart);

// Initialize and navigate to flow
Navigator.of(context).push(MaterialPageRoute(
  builder: (context) => BluetoothProvisioningFlow(
    viam: viam,
    robot: robot,
    isNewMachine: true,
    mainRobotPart: mainPart,
    psk: 'viamsetup', // defaults to 'viamsetup', but will use your 'hotspot_password' from viam-defaults.json
    fragmentId: null, // when passing null, the fragment will be read from viam-defaults.json
    agentMinimumVersion: '0.20.0',
    copy: BluetoothProvisioningFlowCopy(
      checkingOnlineSuccessSubtitle: '${robot.name} is connected and ready to use.',
    ),
    onSuccess: () {
      Navigator.of(context).pop();
    },
    existingMachineExit: () {
      Navigator.of(context).pop();
    },
    nonexistentMachineExit: () {
      Navigator.of(context).pop();
    },
    agentMinimumVersionExit: () {
      Navigator.of(context).pop();
    },
  ),
));
```

For a complete working example with both standard and tethering flows, see the [example app](example/README.md).

## Flow Types

### BluetoothProvisioningFlow

The standard provisioning flow for machines with internet access. Scans for nearby Viam machines, connects via Bluetooth, configures Wi-Fi credentials, and verifies the machine comes online.

### BluetoothTetheringFlow

The tethering flow for machines that need internet access through the mobile device. Similar to the standard flow but includes options for internet tethering when the machine doesn't have direct network access.

## License

See the [LICENSE](LICENSE) file for license rights and limitations.
