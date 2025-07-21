part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class BluetoothProvisioningFlow extends StatefulWidget {
  const BluetoothProvisioningFlow({
    super.key,
    required this.onSuccess,
    required this.handleAgentConfigured,
    required this.existingMachineExit,
    required this.nonexistentMachineExit,
    required this.agentMinimumVersionExit,
  });

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
    final viewModel = Provider.of<BluetoothProvisioningFlowViewModel>(context, listen: false);
    try {
      // agent minimum check
      if (await viewModel.agentVersionBelowMinimum() && mounted) {
        _agentMinimumVersionDialog(context, widget.agentMinimumVersionExit);
        return;
      }
      // status check
      final status = await device.readStatus();
      if (viewModel.isNewMachine && status.isConfigured && mounted) {
        _avoidOverwritingExistingMachineDialog(context);
        return;
      } else if (!viewModel.isNewMachine && !status.isConfigured && mounted) {
        _reconnectingNonexistentMachineDialog(context);
        return;
      }
    } catch (e) {
      debugPrint('Error reading device status: $e');
    }
    _onNextPage();
  }

  void _onWifiCredentials(String ssid, String? psk) async {
    final viewModel = Provider.of<BluetoothProvisioningFlowViewModel>(context, listen: false);
    try {
      setState(() {
        _isLoading = true;
      });
      await viewModel.writeConfig(ssid: ssid, password: psk);
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

  Future<void> _avoidOverwritingExistingMachineDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Existing Machine'),
          content: const Text(
            'This machine has credentials set.\n\nYou can find and re-connect this machine in your list of machines if you\'re the owner.',
          ),
          actions: <Widget>[
            OutlinedButton(
              child: const Text('Exit'),
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

  Future<void> _agentMinimumVersionDialog(BuildContext context, VoidCallback exitFunction) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Machine Incompatible'),
          content: const Text(
            'This machine\'s version is too low to connect via Bluetooth.\n\nPlease try a different provisioning method such as hotspot.',
          ),
          actions: <Widget>[
            OutlinedButton(
              child: const Text('Exit'),
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

  Future<void> _reconnectingNonexistentMachineDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Machine Not Found'),
          content: const Text(
            'This machine does not have credentials set.\n\nIt can be setup as a new machine, but not re-connected.',
          ),
          actions: <Widget>[
            OutlinedButton(
              child: const Text('Exit'),
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
    return Consumer<BluetoothProvisioningFlowViewModel>(
      builder: (context, viewModel, child) {
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
                        title: viewModel.copy.introScreenTitle,
                        subtitle: viewModel.copy.introScreenSubtitle,
                        ctaText: viewModel.copy.introScreenCtaText,
                      ),
                      IntroScreenTwo(handleNextTapped: _onNextPage),
                      ChangeNotifierProvider.value(
                        value: BluetoothScanningScreenViewModel(
                          onDeviceSelected: _onDeviceConnected,
                          scanBluetoothDevicesRepository: ScanBluetoothDevicesRepository(),
                          connectBluetoothDeviceRepository: viewModel.connectBluetoothDeviceRepository,
                        ),
                        child: BluetoothScanningScreen(
                          title: viewModel.copy.bluetoothScanningTitle,
                          scanCtaText: viewModel.copy.bluetoothScanningScanCtaText,
                          notSeeingDeviceCtaText: viewModel.copy.bluetoothScanningNotSeeingDeviceCtaText,
                          tipsDialogTitle: viewModel.copy.bluetoothScanningTipsDialogTitle,
                          tipsDialogSubtitle: viewModel.copy.bluetoothScanningTipsDialogSubtitle,
                          tipsDialogCtaText: viewModel.copy.bluetoothScanningTipsDialogCtaText,
                        ),
                      ),
                      ChangeNotifierProvider.value(
                        value: ConnectedBluetoothDeviceScreenViewModel(
                          handleWifiCredentials: _onWifiCredentials,
                          connectBluetoothDeviceRepository: viewModel.connectBluetoothDeviceRepository,
                        ),
                        child: ConnectedBluetoothDeviceScreen(),
                      ),
                      if (viewModel.device != null)
                        ChangeNotifierProvider.value(
                          value: CheckConnectedDeviceOnlineScreenViewModel(
                            handleSuccess: widget.onSuccess,
                            handleAgentConfigured: widget.handleAgentConfigured,
                            handleError: () {
                              _onPreviousPage(); // back to network selection
                            },
                            checkingDeviceOnlineRepository: CheckingDeviceOnlineRepository(
                              device: viewModel.device!,
                              viam: viewModel.viam,
                              robot: viewModel.robot,
                            ),
                            robot: viewModel.robot,
                          ),
                          child: CheckConnectedDeviceOnlineScreen(),
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
