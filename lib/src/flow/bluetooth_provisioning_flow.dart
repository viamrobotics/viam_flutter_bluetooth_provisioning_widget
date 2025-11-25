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
    required existingMachineExit,
    required nonexistentMachineExit,
    required agentMinimumVersionExit,
  }) {
    viewModel = BluetoothProvisioningFlowViewModel(
      viam: viam,
      robot: robot,
      isNewMachine: isNewMachine,
      connectBluetoothDeviceRepository: ConnectBluetoothDeviceRepository(),
      checkingDeviceOnlineRepository: CheckingDeviceOnlineRepository(
        device: null,
        viam: viam,
        robot: robot,
      ),
      checkingAgentOnlineRepository: CheckingAgentOnlineRepository(device: null),
      mainRobotPart: mainRobotPart,
      psk: psk,
      fragmentId: fragmentId,
      agentMinimumVersion: agentMinimumVersion,
      copy: copy,
      onSuccess: onSuccess,
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
      _onNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkDeviceOnlineVm = CheckConnectedDeviceOnlineScreenViewModel(
      robot: widget.viewModel.robot,
      successTitle: widget.viewModel.copy.checkingOnlineSuccessTitle,
      successSubtitle: widget.viewModel.copy.checkingOnlineSuccessSubtitle,
      successCta: widget.viewModel.copy.checkingOnlineSuccessCta,
      handleSuccess: widget.viewModel.onSuccess,
      handleError: _onPreviousPage, // back to network selection
      checkingDeviceOnlineRepository: widget.viewModel.checkingDeviceOnlineRepository,
      connectBluetoothDeviceRepository: widget.viewModel.connectBluetoothDeviceRepository,
    );
    final scanningVm = BluetoothScanningScreenViewModel(
      onDeviceSelected: _onDeviceConnected,
      scanBluetoothDevicesRepository: ScanBluetoothDevicesRepository(
        viamBluetoothProvisioning: ViamBluetoothProvisioning(),
      ),
      connectBluetoothDeviceRepository: widget.viewModel.connectBluetoothDeviceRepository,
      title: widget.viewModel.copy.bluetoothScanningTitle,
      scanCtaText: widget.viewModel.copy.bluetoothScanningScanCtaText,
      notSeeingDeviceCtaText: widget.viewModel.copy.bluetoothScanningNotSeeingDeviceCtaText,
      tipsDialogTitle: widget.viewModel.copy.bluetoothScanningTipsDialogTitle,
      tipsDialogSubtitle: widget.viewModel.copy.bluetoothScanningTipsDialogSubtitle,
      tipsDialogCtaText: widget.viewModel.copy.bluetoothScanningTipsDialogCtaText,
    );

    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false, // can't be true if we want to hide the built-in back button
            leading: widget.viewModel.leadingIconButton(_onPreviousPage),
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
                      BluetoothScanningScreen(viewModel: scanningVm),
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
                      if (widget.viewModel.device != null) CheckConnectedDeviceOnlineScreen(viewModel: checkDeviceOnlineVm),
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
