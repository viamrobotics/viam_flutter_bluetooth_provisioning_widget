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
    required onSuccess,
    required checkingOnlineExit,
    required existingMachineExit,
    required nonexistentMachineExit,
    required agentMinimumVersionExit,
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
      onSuccess: onSuccess,
      checkingOnlineExit: checkingOnlineExit,
      existingMachineExit: existingMachineExit,
      nonexistentMachineExit: nonexistentMachineExit,
      agentMinimumVersionExit: agentMinimumVersionExit,
    );
  }

  late final BluetoothProvisioningFlowViewModel viewModel;

  @override
  State<BluetoothProvisioningFlow> createState() => _BluetoothProvisioningFlowState();
}

class _BluetoothProvisioningFlowState extends State<BluetoothProvisioningFlow> {
  final PageController _pageController = PageController();
  bool _performingFinalOnlineCheck = false;

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
    if (await widget.viewModel.isDeviceConnectionValid(context, device)) {
      _onNextPage();
    }
  }

  Future<void> _onWifiCredentials(String ssid, String? password) async {
    if (await widget.viewModel.onWifiCredentials(context, ssid, password)) {
      setState(() {
        _performingFinalOnlineCheck = true;
      });
      _onNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: _performingFinalOnlineCheck ? const Icon(Icons.close, size: 24) : const Icon(Icons.arrow_back, size: 24),
              onPressed: _performingFinalOnlineCheck ? widget.viewModel.checkingOnlineExit : _onPreviousPage,
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Opacity(
                  opacity: widget.viewModel.isLoading ? 0.0 : 1.0,
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
                      PowerDeviceInstructionsScreen(
                        handleNextTapped: _onNextPage,
                        title: widget.viewModel.copy.powerOnInstructionsTitle,
                        subtitle: widget.viewModel.copy.powerOnInstructionsSubtitle,
                      ),
                      BluetoothOnInstructionsScreen(
                        handleNextTapped: _onNextPage,
                        title: widget.viewModel.copy.bluetoothOnInstructionsTitle,
                        subtitle: widget.viewModel.copy.bluetoothOnInstructionsSubtitle,
                      ),
                      BluetoothScanningScreen(
                        viewModel: BluetoothScanningScreenViewModel(
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
                      ),
                      ConnectedBluetoothDeviceScreen(
                        viewModel: ConnectedBluetoothDeviceScreenViewModel(
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
                      ),
                      if (widget.viewModel.device != null)
                        CheckConnectedDeviceOnlineScreen(
                          viewModel: CheckConnectedDeviceOnlineScreenViewModel(
                            robot: widget.viewModel.robot,
                            successTitle: widget.viewModel.copy.checkingOnlineSuccessTitle,
                            successSubtitle: widget.viewModel.copy.checkingOnlineSuccessSubtitle,
                            successCta: widget.viewModel.copy.checkingOnlineSuccessCta,
                            handleSuccess: widget.viewModel.onSuccess,
                            handleError: _onPreviousPage, // back to network selection
                            checkingDeviceOnlineRepository: CheckingDeviceOnlineRepository(
                              device: widget.viewModel.device!,
                              viam: widget.viewModel.viam,
                              robot: widget.viewModel.robot,
                            ),
                            connectBluetoothDeviceRepository: widget.viewModel.connectBluetoothDeviceRepository,
                          ),
                        ),
                    ],
                  ),
                ),
                if (widget.viewModel.isLoading) const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        );
      },
    );
  }
}
