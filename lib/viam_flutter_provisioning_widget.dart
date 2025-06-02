import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:viam_flutter_provisioning/viam_bluetooth_provisioning.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:viam_sdk/viam_sdk.dart' hide Permission;
import 'package:viam_sdk/protos/app/app.dart'; // ?

export 'package:flutter_blue_plus/flutter_blue_plus.dart';
// export 'package:permission_handler/permission_handler.dart';
// export 'package:viam_flutter_provisioning/viam_bluetooth_provisioning.dart';
// export 'package:viam_sdk/viam_sdk.dart' hide Permission;

// views
part 'src/view/bluetooth_scanning_screens.dart';
part 'src/view/check_connected_device_online_screen.dart';
part 'src/view/connected_bluetooth_device_screen.dart';
part 'src/view/internet_success_screen.dart';
part 'src/view/intro_screen_one.dart';
part 'src/view/intro_screen_two.dart';
part 'src/view/name_connected_device_screen.dart';
part 'src/view/pairing_screen.dart';
part 'src/view/setup_hotspot_screen.dart';
part 'src/view/setup_tethering_screen.dart';
part 'src/view/wifi_question_screen.dart';

// widgets
part 'src/widgets/scanning_list_tile.dart';
part 'src/widgets/step_tile.dart';

// utils
part 'src/utils/dialogs.dart';
