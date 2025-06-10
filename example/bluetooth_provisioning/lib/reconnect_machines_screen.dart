import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';

import 'consts.dart';

class ListRobot {
  final Robot robot;
  final String locationName;

  ListRobot({required this.robot, required this.locationName});
}

class ReconnectRobotsScreen extends StatefulWidget {
  const ReconnectRobotsScreen({super.key});

  @override
  State<ReconnectRobotsScreen> createState() => _ReconnectRobotsScreenState();
}

class _ReconnectRobotsScreenState extends State<ReconnectRobotsScreen> {
  Viam? _viam;
  bool _isLoading = false;
  List<ListRobot> _robots = [];

  @override
  void initState() {
    super.initState();
    _loadRobots();
  }

  Future<void> _loadRobots() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _viam = await Viam.withApiKey(Consts.apiKeyId, Consts.apiKey);
      final locations = await _viam!.appClient.listLocations(Consts.organizationId);
      final newList = <ListRobot>[];
      for (final location in locations) {
        final locationRobots = await _viam!.appClient.listRobots(location.id);
        newList.addAll(locationRobots.map((e) => ListRobot(robot: e, locationName: location.name)));
      }
      setState(() {
        _robots = newList;
      });
    } catch (e) {
      debugPrint('Error loading robots: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goToBluetoothProvisioningFlow(BuildContext context, Viam viam, Robot robot) async {
    final mainPart = (await viam.appClient.listRobotParts(robot.id)).firstWhere((element) => element.mainPart);
    if (context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (context) => BluetoothProvisioningFlowViewModel(
            viam: viam,
            robot: robot,
            mainRobotPart: mainPart,
          ),
          builder: (context, child) => BluetoothProvisioningFlow(onSuccess: () {
            Navigator.of(context).pop();
          }),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconnect Machines'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive(backgroundColor: Colors.black))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _robots.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_robots[index].robot.name),
                subtitle: Text(_robots[index].locationName),
                onTap: () => _goToBluetoothProvisioningFlow(context, _viam!, _robots[index].robot),
              ),
            ),
    );
  }
}
