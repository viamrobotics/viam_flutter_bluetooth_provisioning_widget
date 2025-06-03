import 'package:flutter/material.dart';
import 'package:viam_flutter_provisioning_widget/viam_flutter_provisioning_widget.dart';

// TODO: This can end up in library as part of https://viam.atlassian.net/browse/APP-8323
class BluetoothProvisioningFlowViewModel extends ChangeNotifier {
  BluetoothDevice? _connectedDevice;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  bool _saidYesToWifi = false;
  bool get saidYesToWifi => _saidYesToWifi;

  set connectedDevice(BluetoothDevice? device) {
    _connectedDevice = device;
    notifyListeners();
  }

  set saidYesToWifi(bool value) {
    _saidYesToWifi = value;
    notifyListeners();
  }
}
