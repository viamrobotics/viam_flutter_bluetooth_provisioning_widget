import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ignore: depend_on_referenced_packages

import 'package:viam_flutter_provisioning_widget/viam_flutter_provisioning_widget.dart';

import 'view_model.dart';

class BluetoothProvisioningFlow extends StatefulWidget {
  const BluetoothProvisioningFlow({super.key});

  @override
  State<BluetoothProvisioningFlow> createState() => _BluetoothProvisioningFlowState();
}

class _BluetoothProvisioningFlowState extends State<BluetoothProvisioningFlow> {
  late final PageController _pageController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPage() {
    _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _onDeviceConnected(BluetoothDevice device) {
    final viewModel = Provider.of<BluetoothProvisioningFlowViewModel>(context, listen: false);
    viewModel.connectedDevice = device;
    _onNextPage();
  }

  void _onWifiCredentials(String ssid, String? psk) async {
    final viewModel = Provider.of<BluetoothProvisioningFlowViewModel>(context, listen: false);
    try {
      setState(() {
        _isLoading = true;
      });
      await viewModel.writeConfig(ssid: ssid, psk: psk);
      _onNextPage();
    } catch (e) {
      if (mounted) {
        showErrorDialog(context, title: 'Failed to write config', error: e.toString());
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvisioningFlowViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(),
          body: SafeArea(
            child: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    IntroScreenOne(handleGetStartedTapped: _onNextPage),
                    IntroScreenTwo(handleNextTapped: _onNextPage),
                    BluetoothScanningScreen(onDeviceSelected: _onDeviceConnected),
                    if (viewModel.connectedDevice != null)
                      ConnectedBluetoothDeviceScreen(
                        handleWifiCredentials: _onWifiCredentials,
                        robot: viewModel.robot,
                        robotPart: viewModel.mainRobotPart,
                        connectedDevice: viewModel.connectedDevice!,
                      ),
                    if (viewModel.connectedDevice != null)
                      CheckConnectedDeviceOnlineScreen(
                        handleSuccess: () {
                          debugPrint('success'); // TODO: Flow callback I think, so caller of flow can wrapup/pop
                        },
                        viam: viewModel.viam,
                        robot: viewModel.robot,
                        connectedDevice: viewModel.connectedDevice!,
                      ),
                  ],
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
