import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';
import 'package:mockito/annotations.dart';
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
  CheckingDeviceOnlineRepository,
])
void main() {}
