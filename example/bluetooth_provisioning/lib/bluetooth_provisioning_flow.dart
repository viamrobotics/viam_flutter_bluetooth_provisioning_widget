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

  // selected ~> connected?
  void _onDeviceSelected(BluetoothDevice device) {
    final viewModel = Provider.of<BluetoothProvisioningFlowViewModel>(context, listen: false);
    viewModel.connectedDevice = device;
    _onNextPage();
  }

  void _onYesToWifiTapped() {
    final viewModel = Provider.of<BluetoothProvisioningFlowViewModel>(context, listen: false);
    viewModel.saidYesToWifi = true;
    _onNextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvisioningFlowViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(), // TODO: custom app bar back button?
          body: SafeArea(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                IntroScreenOne(handleGetStartedTapped: _onNextPage),
                IntroScreenTwo(handleNextTapped: _onNextPage),
                BluetoothScanningScreen(onDeviceSelected: _onDeviceSelected), // get back device.. set on viewmodel.. read in my child!
                if (viewModel.connectedDevice != null)
                  PairingScreen(
                    connectedDevice: viewModel.connectedDevice!,
                  ),
                if (viewModel.connectedDevice != null)
                  WifiQuestionScreen(
                    handleYesTapped: _onYesToWifiTapped,
                    connectedDevice: viewModel.connectedDevice!,
                  ),
                if (viewModel.connectedDevice != null) ConnectedBluetoothDeviceScreen(connectedDevice: viewModel.connectedDevice!),
              ],
            ),
          ),
        );
      },
    );
  }
}
