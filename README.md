# Viam Flutter Bluetooth Provisioning Widget

A Flutter package for provisioning Viam robots using Bluetooth connections. This widget provides two complete flows for connecting to robots via Bluetooth: a standard provisioning flow for robots with internet access, and a tethering flow for robots that need to share the mobile device's internet connection.

This package is built on top of [viam_flutter_provisioning](https://github.com/viamrobotics/viam-flutter-provisioning) which uses [flutter_blue_plus](https://github.com/chipweinberger/flutter_blue_plus) for Bluetooth communication with [viam-agent](https://github.com/viamrobotics/agent).

## Installation

`flutter pub add viam_flutter_bluetooth_provisioning_widget`

## Prerequisites

### Machine Setup

1. **Flash your Device**: Use the Viam CLI to flash your device. For more instructions on device setup, see the [Viam Documentation](https://docs.viam.com/installation/prepare/rpi-setup) for an example on flashing a Raspberry Pi.

2. **Configure provisioning defaults**: Create a provisioning configuration file (`viam-defaults.json`) by specifying at least the following info:

   ```json
   {
     "network_configuration": {
       "disable_bt_provisioning": false
     }
   }
   ```
   If you specify `hotspot_password` it will be used as a pre-shared key and should be passed into the provisioning flows so they can successfuly write Bluetooth characteristics.

   For more instructions on setting up the config, see the [Viam Documentation](https://docs.viam.com/manage/fleet/provision/setup/#configure-defaults).

3. **Install viam-agent**: Run the pre-install script and pass in the location of your `viam-defaults.json`:
   ```bash
   sudo ./preinstall.sh
   ```
   
   For more instructions on running the pre-install script, see the [Viam Documentation](https://docs.viam.com/manage/fleet/provision/setup/#install-viam-agent).

### Device Requirements

- **Physical Device Required**: This widget must be run on a physical device to discover nearby Bluetooth devices running `viam-agent` with Bluetooth provisioning enabled.
- **Bluetooth Enabled**: Ensure Bluetooth is enabled on both the mobile device and the target robot.
- **viam-agent Version**: The robot must be running a `0.20.0` and up of `viam-agent` with Bluetooth provisioning support. Tethering requires `0.21.0` of `viam-agent`.

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

1. **Initialize Viam instance**: Create a Viam instance with your API credentials
2. **Create or get a robot**: Either create a new robot or retrieve an existing one from your Viam organization
3. **Get the main part**: Retrieve the main robot part that will be provisioned

These steps are required because the widget needs a valid robot and Viam instance to communicate with the Viam cloud and provision the robot.

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
    psk: Consts.psk, // defaults to 'viamsetup', but will use your 'hotspot_password' from viam-defaults.json
    fragmentId: null,
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

The standard provisioning flow for robots with internet access. Scans for nearby Viam robots, connects via Bluetooth, configures Wi-Fi credentials, and verifies the robot comes online.

### BluetoothTetheringFlow

The tethering flow for robots that need internet access through the mobile device. Similar to the standard flow but includes options for internet tethering when the robot doesn't have direct network access.

## Example

See the [example app](example/README.md) for a complete working example that demonstrates both the standard provisioning flow and tethering flow for Viam devices.

## License

See the [LICENSE](LICENSE) file for license rights and limitations.