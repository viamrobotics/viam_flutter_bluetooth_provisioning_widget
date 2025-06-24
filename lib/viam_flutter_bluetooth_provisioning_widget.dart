// dart imports
import 'dart:async';
import 'dart:io';

// package imports
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:viam_flutter_provisioning/viam_bluetooth_provisioning.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:viam_sdk/viam_sdk.dart' hide Permission;
import 'package:viam_sdk/protos/app/app.dart';
import 'package:provider/provider.dart';

// export
export 'package:viam_flutter_provisioning/viam_bluetooth_provisioning.dart';
export 'package:viam_sdk/viam_sdk.dart' hide Permission;
export 'package:viam_sdk/protos/app/app.dart';

// flows
part 'src/flow/bluetooth_provisioning_flow.dart';

// views
part 'src/view/bluetooth_scanning_screen.dart';
part 'src/view/check_connected_device_online_screen.dart';
part 'src/view/connected_bluetooth_device_screen.dart';
part 'src/view/intro_screen_one.dart';
part 'src/view/intro_screen_two.dart';
part 'src/view/name_connected_device_screen.dart';

// widgets
part 'src/widgets/scanning_list_tile.dart';
part 'src/widgets/step_tile.dart';

// utils
part 'src/utils/dialogs.dart';

// view models
part 'src/view_models/connected_bluetooth_device_screen_view_model.dart';
part 'src/view_models/bluetooth_provisioning_flow_view_model.dart';
part 'src/view_models/check_connected_device_online_screen_view_model.dart';
part 'src/view_models/bluetooth_scanning_screen_view_model.dart';

// models
part 'src/models/device_online_state.dart';

// repositories
part 'src/repositories/checking_device_online_repository.dart';
