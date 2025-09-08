part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class BluetoothProvisioningFlowCopy {
  const BluetoothProvisioningFlowCopy({
    // Intro screen
    this.introScreenTitle = 'Connect your device',
    this.introScreenSubtitle = 'We\'ll walk you through a short setup process to get your device up and running.',
    this.introScreenCtaText = 'Get started',
    // Intro screen tow
    this.introScreenTwoTurnOnTitle = 'Turn on your machine',
    this.introScreenTwoTurnOnSubtitle = 'Plug in the machine and power it on.',
    this.introScreenTwoBluetoothTitle = 'Pair via Bluetooth',
    // TODO: add markdown package so we can have italicized text
    this.introScreenTwoBluetoothSubtitle = 'Open your phone’s settings app and go to Settings > Bluetooth. Make sure it is set to “ON.”',
    // Bluetooth scanning
    this.bluetoothScanningTitle = 'Select your Device',
    this.bluetoothScanningScanCtaText = 'Scan network again',
    this.bluetoothScanningNotSeeingDeviceCtaText = 'Not seeing your device?',
    this.bluetoothScanningTipsDialogTitle = 'Tips',
    this.bluetoothScanningTipsDialogSubtitle =
        'If the device isn\'t showing up, ensure Bluetooth is on and that the device is plugged in and turned on.\n\nYou may also need to change your phone\'s Bluetooth settings to allow it to connect to new devices.',
    this.bluetoothScanningTipsDialogCtaText = 'Close',
    // Connected device screen
    this.connectedDeviceTitle = 'Choose your Wi-Fi',
    this.connectedDeviceSubtitle = 'Choose the Wi-Fi network you\'d like to use to connect your device.',
    this.connectedDeviceNotSeeingDeviceCtaText = 'Not seeing your network?',
    this.connectedDeviceScanCtaText = 'Scan network again',
    this.connectedDeviceTipsDialogTitle = 'Tips',
    this.connectedDeviceTipsDialogSubtitle =
        'Make sure that the network isn\'t hidden and that your device is within range of your Wi-Fi router.\n\nPlease note that a 2.4GHz network is required.',
    this.connectedDeviceTipsDialogCtaText = 'Close',
    // Existing machine dialog
    this.existingMachineDialogTitle = 'Existing Machine',
    this.existingMachineDialogSubtitle =
        'This machine has credentials set.\n\nYou can find and re-connect this machine in your list of machines if you\'re the owner.',
    this.existingMachineDialogCta = 'Exit',
    // Agent incompatible dialog
    this.agentIncompatibleDialogTitle = 'Machine Incompatible',
    this.agentIncompatibleDialogSubtitle =
        'This machine\'s version is too low to connect via Bluetooth.\n\nPlease try a different provisioning method such as hotspot.',
    this.agentIncompatibleDialogCta = 'Exit',
    // Machine not found dialog
    this.machineNotFoundDialogTitle = 'Machine Not Found',
    this.machineNotFoundDialogSubtitle =
        'This machine does not have credentials set.\n\nIt can be setup as a new machine, but not re-connected.',
    this.machineNotFoundDialogCta = 'Exit',
    // Checking online
    this.checkingOnlineSuccessTitle = 'All set!',
    this.checkingOnlineSuccessSubtitle = 'Your machine is connected and ready to use.',
    this.checkingOnlineSuccessCta = 'Close',
    // Connection method
    this.connectionMethodCellularSubtitle =
        'If your machine doesn\'t have Internet, you can use Bluetooth to share your phone\'s cellular connection with the machine.',
    // Tethering
    this.tetheringMachineName = 'machine',
    // Check agent online
    this.checkAgentOnlineSuccessTitle = 'Success!',
    this.checkAgentOnlineSuccessSubtitle = 'Your machine is connected to the Internet',
  });

  // Intro screen one
  final String introScreenTitle;
  final String introScreenSubtitle;
  final String introScreenCtaText;

  // Intro screen two
  final String introScreenTwoTurnOnTitle;
  final String introScreenTwoTurnOnSubtitle;
  final String introScreenTwoBluetoothTitle;
  final String introScreenTwoBluetoothSubtitle;

  // Bluetooth scanning screen
  final String bluetoothScanningTitle;
  final String bluetoothScanningScanCtaText;
  final String bluetoothScanningNotSeeingDeviceCtaText;

  final String bluetoothScanningTipsDialogTitle;
  final String bluetoothScanningTipsDialogSubtitle;
  final String bluetoothScanningTipsDialogCtaText;

  // Connected device screen
  final String connectedDeviceTitle;
  final String connectedDeviceSubtitle;
  final String connectedDeviceScanCtaText;
  final String connectedDeviceNotSeeingDeviceCtaText;

  final String connectedDeviceTipsDialogTitle;
  final String connectedDeviceTipsDialogSubtitle;
  final String connectedDeviceTipsDialogCtaText;

  // Existing machine
  final String existingMachineDialogTitle;
  final String existingMachineDialogSubtitle;
  final String existingMachineDialogCta;

  // Agent incompatible
  final String agentIncompatibleDialogTitle;
  final String agentIncompatibleDialogSubtitle;
  final String agentIncompatibleDialogCta;

  // Machine not found
  final String machineNotFoundDialogTitle;
  final String machineNotFoundDialogSubtitle;
  final String machineNotFoundDialogCta;

  // Checking online
  final String checkingOnlineSuccessTitle;
  final String checkingOnlineSuccessSubtitle;
  final String checkingOnlineSuccessCta;

  // Connection method
  final String connectionMethodCellularSubtitle;

  // Tethering
  final String tetheringMachineName;

  // Check agent online
  final String checkAgentOnlineSuccessTitle;
  final String checkAgentOnlineSuccessSubtitle;
}
