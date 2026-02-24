# Viam Flutter Bluetooth Provisioning Example

This directory contains a complete example app that demonstrates how to use the Viam Flutter Bluetooth Provisioning Widget with two flows: `BluetoothProvisioningFlow` and `BluetoothTetheringFlow`.

## Quick Start

1. **Set up your environment** — create a `.env` file in this directory with your Viam credentials (see `.env.example` for reference):

```
API_KEY_ID=your-api-key-id
API_KEY=your-api-key
ORG_ID=your-organization-id
LOCATION_ID=your-location-id
PSK=viamsetup // if you specify a hotspot_password in viam-defaults.json this must match
```

2. **Run the app** on a physical device:

```bash
flutter run
```

## Requirements

- **Physical Device**: Must be run on a physical device (not a simulator)
- **viam-agent Version**: Machine must be running `0.20.0`+ for standard flow, `0.21.0`+ for tethering
