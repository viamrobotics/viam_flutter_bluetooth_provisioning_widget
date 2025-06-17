part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class BluetoothProvisioningFlow extends StatefulWidget {
  const BluetoothProvisioningFlow({super.key, required this.onSuccess});

  final VoidCallback onSuccess;

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
      // can safely disconnect after writing config
      await viewModel.connectedDevice!.disconnect();
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
                        value: BluetoothScanningScreenViewModel(onDeviceSelected: _onDeviceConnected),
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
                            viam: viewModel.viam,
                            robot: viewModel.robot,
                            connectedDevice: viewModel.connectedDevice!,
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
