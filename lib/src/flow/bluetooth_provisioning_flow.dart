part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class BluetoothProvisioningFlow extends StatefulWidget {
  BluetoothProvisioningFlow({
    super.key,
    required viam,
    required robot,
    required isNewMachine,
    required mainRobotPart,
    required String psk,
    required String? fragmentId,
    required String agentMinimumVersion,
    required BluetoothProvisioningFlowCopy copy,
    required this.onSuccess,
    required this.handleAgentConfigured,
    required this.existingMachineExit,
    required this.nonexistentMachineExit,
    required this.agentMinimumVersionExit,
  }) {
    viewModel = BluetoothProvisioningFlowViewModel(
      viam: viam,
      robot: robot,
      isNewMachine: isNewMachine,
      connectBluetoothDeviceRepository: ConnectBluetoothDeviceRepository(),
      mainRobotPart: mainRobotPart,
      psk: psk,
      fragmentId: fragmentId,
      agentMinimumVersion: agentMinimumVersion,
      copy: copy,
    );
  }

  late final BluetoothProvisioningFlowViewModel viewModel;
  final VoidCallback onSuccess;

  /// agent has indicated the machine is online and has machine credentials
  /// though it may not be online in app.viam.com yet
  final VoidCallback handleAgentConfigured;

  final VoidCallback existingMachineExit;
  final VoidCallback nonexistentMachineExit;

  /// called when the connected machine's agent version is lower (or we can't read it) compared to the agentMinimumVersion in the view model
  final VoidCallback agentMinimumVersionExit;

  @override
  State<BluetoothProvisioningFlow> createState() => _BluetoothProvisioningFlowState();
}

class _BluetoothProvisioningFlowState extends State<BluetoothProvisioningFlow> {
  final PageController _pageController = PageController();
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPage() {
    _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _onPreviousPage() {
    if (_pageController.page == 0) {
      Navigator.of(context).pop();
    } else {
      _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _onDeviceConnected(BluetoothDevice device) async {
    try {
      // agent minimum check
      if (await widget.viewModel.agentVersionBelowMinimum() && mounted) {
        // disconnect the device to avoid any `pairing request` dialogs.
        device.disconnect();

        _agentMinimumVersionDialog(
          context,
          widget.agentMinimumVersionExit,
          widget.viewModel.copy.agentIncompatibleDialogTitle,
          widget.viewModel.copy.agentIncompatibleDialogSubtitle,
          widget.viewModel.copy.agentIncompatibleDialogCta,
        );
        return;
      }
      // status check
      final status = await device.readStatus();
      if (widget.viewModel.isNewMachine && status.isConfigured && mounted) {
        _avoidOverwritingExistingMachineDialog(
          context,
          widget.viewModel.copy.existingMachineDialogTitle,
          widget.viewModel.copy.existingMachineDialogSubtitle,
          widget.viewModel.copy.existingMachineDialogCta,
        );
        return;
      } else if (!widget.viewModel.isNewMachine && !status.isConfigured && mounted) {
        _reconnectingNonexistentMachineDialog(
          context,
          widget.viewModel.copy.machineNotFoundDialogTitle,
          widget.viewModel.copy.machineNotFoundDialogSubtitle,
          widget.viewModel.copy.machineNotFoundDialogCta,
        );
        return;
      }
    } catch (e) {
      debugPrint('Error reading device status: $e');
    }
    _onNextPage();
  }

  void _onWifiCredentials(String ssid, String? psk) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await widget.viewModel.writeConfig(ssid: ssid, password: psk);
      // you can safely disconnect now, but then you can't read the agent status from the connected device while we're waiting to get online
      _onNextPage();
    } catch (e) {
      if (mounted) {
        _showErrorDialog(context, title: 'Failed to write config', error: e.toString());
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _avoidOverwritingExistingMachineDialog(
    BuildContext context,
    String title,
    String subtitle,
    String ctaText,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(
            subtitle,
          ),
          actions: <Widget>[
            OutlinedButton(
              child: Text(ctaText),
              onPressed: () {
                Navigator.pop(context);
                widget.existingMachineExit();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _agentMinimumVersionDialog(
    BuildContext context,
    VoidCallback exitFunction,
    String title,
    String subtitle,
    String ctaText,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(subtitle),
          actions: <Widget>[
            OutlinedButton(
              child: Text(ctaText),
              onPressed: () {
                Navigator.pop(context);
                exitFunction();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _reconnectingNonexistentMachineDialog(
    BuildContext context,
    String title,
    String subtitle,
    String ctaText,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(subtitle),
          actions: <Widget>[
            OutlinedButton(
              child: Text(ctaText),
              onPressed: () {
                Navigator.pop(context);
                widget.nonexistentMachineExit();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, size: 24),
              onPressed: _onPreviousPage,
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Opacity(
                  opacity: _isLoading ? 0.0 : 1.0,
                  child: PageView(
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      IntroScreenOne(
                        handleCtaTapped: _onNextPage,
                        title: widget.viewModel.copy.introScreenTitle,
                        subtitle: widget.viewModel.copy.introScreenSubtitle,
                        ctaText: widget.viewModel.copy.introScreenCtaText,
                      ),
                      IntroScreenTwo(
                        handleNextTapped: _onNextPage,
                        turnOnTitle: widget.viewModel.copy.introScreenTwoTurnOnTitle,
                        turnOnSubtitle: widget.viewModel.copy.introScreenTwoTurnOnSubtitle,
                        bluetoothTitle: widget.viewModel.copy.introScreenTwoBluetoothTitle,
                        bluetoothSubtitle: widget.viewModel.copy.introScreenTwoBluetoothSubtitle,
                      ),
                      ChangeNotifierProvider.value(
                        value: BluetoothScanningScreenViewModel(
                          onDeviceSelected: _onDeviceConnected,
                          scanBluetoothDevicesRepository: ScanBluetoothDevicesRepository(),
                          connectBluetoothDeviceRepository: widget.viewModel.connectBluetoothDeviceRepository,
                          title: widget.viewModel.copy.bluetoothScanningTitle,
                          scanCtaText: widget.viewModel.copy.bluetoothScanningScanCtaText,
                          notSeeingDeviceCtaText: widget.viewModel.copy.bluetoothScanningNotSeeingDeviceCtaText,
                          tipsDialogTitle: widget.viewModel.copy.bluetoothScanningTipsDialogTitle,
                          tipsDialogSubtitle: widget.viewModel.copy.bluetoothScanningTipsDialogSubtitle,
                          tipsDialogCtaText: widget.viewModel.copy.bluetoothScanningTipsDialogCtaText,
                        ),
                        child: BluetoothScanningScreen(),
                      ),
                      ChangeNotifierProvider.value(
                        value: ConnectedBluetoothDeviceScreenViewModel(
                          handleWifiCredentials: _onWifiCredentials,
                          connectBluetoothDeviceRepository: widget.viewModel.connectBluetoothDeviceRepository,
                          title: widget.viewModel.copy.connectedDeviceTitle,
                          subtitle: widget.viewModel.copy.connectedDeviceSubtitle,
                          scanCtaText: widget.viewModel.copy.connectedDeviceScanCtaText,
                          notSeeingDeviceCtaText: widget.viewModel.copy.connectedDeviceNotSeeingDeviceCtaText,
                          tipsDialogTitle: widget.viewModel.copy.connectedDeviceTipsDialogTitle,
                          tipsDialogSubtitle: widget.viewModel.copy.connectedDeviceTipsDialogSubtitle,
                          tipsDialogCtaText: widget.viewModel.copy.connectedDeviceTipsDialogCtaText,
                        ),
                        child: ConnectedBluetoothDeviceScreen(),
                      ),
                      if (widget.viewModel.device != null)
                        ChangeNotifierProvider.value(
                          value: CheckConnectedDeviceOnlineScreenViewModel(
                            handleSuccess: widget.onSuccess,
                            handleAgentConfigured: widget.handleAgentConfigured,
                            handleError: _onPreviousPage, // back to network selection
                            checkingDeviceOnlineRepository: CheckingDeviceOnlineRepository(
                              device: widget.viewModel.device!,
                              viam: widget.viewModel.viam,
                              robot: widget.viewModel.robot,
                            ),
                            robot: widget.viewModel.robot,
                          ),
                          child: CheckConnectedDeviceOnlineScreen(
                            successTitle: widget.viewModel.copy.checkingOnlineSuccessTitle,
                            successSubtitle: widget.viewModel.copy.checkingOnlineSuccessSubtitle,
                            successCta: widget.viewModel.copy.checkingOnlineSuccessCta,
                          ),
                        ),
                    ],
                  ),
                ),
                if (_isLoading) const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        );
      },
    );
  }
}
