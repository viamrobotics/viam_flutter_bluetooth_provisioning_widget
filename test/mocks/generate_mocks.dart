import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/material.dart';
import 'package:viam_sdk/src/app/app.dart';
import 'package:viam_sdk/src/gen/google/protobuf/timestamp.pb.dart';

@GenerateMocks([
  BluetoothDevice,
  BluetoothService,
  BluetoothCharacteristic,
  Viam,
  Robot,
  RobotPart,
  AppClient,
  ViamBluetoothProvisioning,
  Timestamp,
  ConnectBluetoothDeviceRepository,
])
void main() {}
