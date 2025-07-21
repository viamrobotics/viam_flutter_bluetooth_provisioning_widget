part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class BluetoothProvisioningFlowCopy {
  const BluetoothProvisioningFlowCopy({
    // Intro screen one
    this.introScreenTitle = 'Connect your device',
    this.introScreenSubtitle = 'We\'ll walk you through a short setup process to get your device up and running.',
    this.introScreenCtaText = 'Get started',
    // Bluetooth scanning strings
    this.bluetoothScanningTitle = 'Select your Device',
    this.bluetoothScanningScanCtaText = 'Scan network again',
    this.bluetoothScanningNotSeeingDeviceCtaText = 'Not seeing your device?',
    this.bluetoothScanningTipsDialogTitle = 'Tips',
    this.bluetoothScanningTipsDialogSubtitle =
        'If the device isn\'t showing up, ensure Bluetooth is on and that the device is plugged in and turned on.\n\nYou may also need to change your phone\'s Bluetooth settings to allow it to connect to new devices.',
    this.bluetoothScanningTipsDialogCtaText = 'Close',
    // Connected device screen strings
    this.connectedDeviceErrorReadingNetworks = 'Error reading network list',
    this.connectedDevicePasswordLabel = 'Password',
    this.connectedDeviceConnectButton = 'Connect',
    this.connectedDeviceTitle = 'Choose your Wi-Fi',
    this.connectedDeviceSubtitle = 'Choose the Wi-Fi network you\'d like to use to connect your device.',
    this.connectedDeviceNotSeeingNetworkButton = 'Not seeing your network?',
    this.connectedDeviceNetworkTipsContent =
        'Make sure that the network isn\'t hidden and that your device is within range of your Wi-Fi router.\n\nPlease note that a 2.4GHz network is required.',
    this.connectedDeviceCancelButton = 'Cancel',
    // Name device screen strings
    this.nameDeviceTitle = 'Name your vessel',
    this.nameDeviceNameLabel = 'Name',
    this.nameDeviceValidationText = 'Name must contain a letter or number. Cannot start with \'-\' or \'_\'. Spaces are allowed.',
    this.nameDeviceDoneButton = 'Done',
    // Check device online strings
    this.checkDeviceOnlineFinishingUp = 'Finishing up...',
    this.checkDeviceOnlineKeepScreenOpenText = 'Please keep this screen open until setup is complete. This should take a minute or two.',
    this.checkDeviceOnlineConnectedTitle = 'Connected!',
    this.checkDeviceOnlineConnectedAlmostReadyText =
        'is connected and almost ready to use. You can leave this screen now and it will automatically come online in a few minutes.',
    this.checkDeviceOnlineAllSetTitle = 'All set!',
    this.checkDeviceOnlineConnectedReadyText = 'is connected and ready to use.',
    this.checkDeviceOnlineErrorTitle = 'Error during setup',
    this.checkDeviceOnlineErrorText = 'There was an error getting your machine online. Please try again.',
    this.checkDeviceOnlineTryAgainButton = 'Try again',
    // Flow dialog strings
    this.flowDialogFailedToWriteConfig = 'Failed to write config',
    this.flowDialogExistingMachineTitle = 'Existing Machine',
    this.flowDialogExistingMachineContent =
        'This machine has credentials set.\n\nYou can find and re-connect this machine in your list of machines if you\'re the owner.',
    this.flowDialogExitButton = 'Exit',
    this.flowDialogMachineIncompatibleTitle = 'Machine Incompatible',
    this.flowDialogMachineIncompatibleContent =
        'This machine\'s version is too low to connect via Bluetooth.\n\nPlease try a different provisioning method such as hotspot.',
    this.flowDialogMachineNotFoundTitle = 'Machine Not Found',
    this.flowDialogMachineNotFoundContent =
        'This machine does not have credentials set.\n\nIt can be setup as a new machine, but not re-connected.',
    // Widget strings
    this.widgetScanningText = 'Scanning...',
    // Error dialog strings
    this.errorDialogTitle = 'An Error Occurred',
    this.errorDialogOkButton = 'OK',
  });

  // Intro screen one
  final String introScreenTitle;
  final String introScreenSubtitle;
  final String introScreenCtaText;

  // Bluetooth scanning screen
  final String bluetoothScanningTitle;
  final String bluetoothScanningScanCtaText;
  final String bluetoothScanningNotSeeingDeviceCtaText;

  final String bluetoothScanningTipsDialogTitle;
  final String bluetoothScanningTipsDialogSubtitle;
  final String bluetoothScanningTipsDialogCtaText;

  // Connected device screen
  final String connectedDeviceErrorReadingNetworks;
  final String connectedDevicePasswordLabel;
  final String connectedDeviceConnectButton;
  final String connectedDeviceTitle;
  final String connectedDeviceSubtitle;
  final String connectedDeviceNotSeeingNetworkButton;
  final String connectedDeviceNetworkTipsContent;
  final String connectedDeviceCancelButton;

  // Name device screen
  final String nameDeviceTitle;
  final String nameDeviceNameLabel;
  final String nameDeviceValidationText;
  final String nameDeviceDoneButton;

  // Check device online
  final String checkDeviceOnlineFinishingUp;
  final String checkDeviceOnlineKeepScreenOpenText;
  final String checkDeviceOnlineConnectedTitle;
  final String checkDeviceOnlineConnectedAlmostReadyText;
  final String checkDeviceOnlineAllSetTitle;
  final String checkDeviceOnlineConnectedReadyText;
  final String checkDeviceOnlineErrorTitle;
  final String checkDeviceOnlineErrorText;
  final String checkDeviceOnlineTryAgainButton;

  // Flow dialog strings (???)
  final String flowDialogFailedToWriteConfig;
  final String flowDialogExistingMachineTitle;
  final String flowDialogExistingMachineContent;
  final String flowDialogExitButton;
  final String flowDialogMachineIncompatibleTitle;
  final String flowDialogMachineIncompatibleContent;
  final String flowDialogMachineNotFoundTitle;
  final String flowDialogMachineNotFoundContent;
  // Widget strings (???)
  final String widgetScanningText;
  // Error dialog strings (???)
  final String errorDialogTitle;
  final String errorDialogOkButton;
}
