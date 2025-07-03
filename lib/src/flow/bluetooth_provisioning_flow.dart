part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class BluetoothProvisioningFlow extends StatefulWidget {
  const BluetoothProvisioningFlow({super.key, required this.onSuccess, required this.existingMachineExit});

  final VoidCallback onSuccess;
  final VoidCallback existingMachineExit;

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
    viewModel.connectedDevice = device;
    if (viewModel.isNewMachine) {
      try {
        final status = await device.readStatus();
        if (status.isConfigured && mounted) {
          _avoidOverwritingExistingMachineDialog(context);
          return;
        }
      } catch (e) {
        debugPrint('Error reading device status: $e');
      }
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
                      IntroScreenOne(handleGetStartedTapped: _onNextPage),
                      IntroScreenTwo(handleNextTapped: _onNextPage),
                      ChangeNotifierProvider.value(
                        value: BluetoothScanningScreenViewModel(
                          onDeviceSelected: _onDeviceConnected,
                          scanBluetoothDevicesRepository: ScanBluetoothDevicesRepository(),
                        ),
                        child: BluetoothScanningScreen(),
                      ),
                      if (viewModel.connectedDevice != null)
                        ChangeNotifierProvider.value(
                          value: ConnectedBluetoothDeviceScreenViewModel(
                            handleWifiCredentials: _onWifiCredentials,
                            connectedDevice: viewModel.connectedDevice!,
                          ),
                          child: ConnectedBluetoothDeviceScreen(),
                        ),
                      if (viewModel.connectedDevice != null)
                        ChangeNotifierProvider.value(
                          value: CheckConnectedDeviceOnlineScreenViewModel(
                            handleSuccess: widget.onSuccess,
                            handleError: () {
                              _onPreviousPage(); // back to network selection
                            },
                            checkingDeviceOnlineRepository: CheckingDeviceOnlineRepository(
                              device: viewModel.connectedDevice!,
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
