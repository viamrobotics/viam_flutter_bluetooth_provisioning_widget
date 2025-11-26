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
    final connectBluetoothDeviceRepository = ConnectBluetoothDeviceRepository();
    viewModel = BluetoothProvisioningFlowViewModel(
      viam: viam,
      robot: robot,
      isNewMachine: isNewMachine,
      connectBluetoothDeviceRepository: connectBluetoothDeviceRepository,
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
    connectedBluetoothDeviceVm = ConnectedBluetoothDeviceScreenViewModel(
      connectBluetoothDeviceRepository: connectBluetoothDeviceRepository,
      title: copy.connectedDeviceTitle,
      subtitle: copy.connectedDeviceSubtitle,
      scanCtaText: copy.connectedDeviceScanCtaText,
      notSeeingDeviceCtaText: copy.connectedDeviceNotSeeingDeviceCtaText,
      tipsDialogTitle: copy.connectedDeviceTipsDialogTitle,
      tipsDialogSubtitle: copy.connectedDeviceTipsDialogSubtitle,
      tipsDialogCtaText: copy.connectedDeviceTipsDialogCtaText,
    );
    scanningVm = BluetoothScanningScreenViewModel(
      scanBluetoothDevicesRepository: ScanBluetoothDevicesRepository(
        viamBluetoothProvisioning: ViamBluetoothProvisioning(),
      ),
      connectBluetoothDeviceRepository: connectBluetoothDeviceRepository,
      title: copy.bluetoothScanningTitle,
      scanCtaText: copy.bluetoothScanningScanCtaText,
      notSeeingDeviceCtaText: copy.bluetoothScanningNotSeeingDeviceCtaText,
      tipsDialogTitle: copy.bluetoothScanningTipsDialogTitle,
      tipsDialogSubtitle: copy.bluetoothScanningTipsDialogSubtitle,
      tipsDialogCtaText: copy.bluetoothScanningTipsDialogCtaText,
    );
    checkDeviceOnlineVm = CheckConnectedDeviceOnlineScreenViewModel(
      successTitle: viewModel.copy.checkingOnlineSuccessTitle,
      successSubtitle: viewModel.copy.checkingOnlineSuccessSubtitle,
      successCta: viewModel.copy.checkingOnlineSuccessCta,
      checkingDeviceOnlineRepository: viewModel.checkingDeviceOnlineRepository,
      connectBluetoothDeviceRepository: viewModel.connectBluetoothDeviceRepository,
    );
  }

  late final BluetoothProvisioningFlowViewModel viewModel;
  late final ConnectedBluetoothDeviceScreenViewModel connectedBluetoothDeviceVm;
  late final BluetoothScanningScreenViewModel scanningVm;
  late final CheckConnectedDeviceOnlineScreenViewModel checkDeviceOnlineVm;

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
                      BluetoothScanningScreen(viewModel: widget.scanningVm, onDeviceSelected: _onDeviceConnected),
                      ConnectedBluetoothDeviceScreen(
                        handleWifiCredentials: _onWifiCredentials,
                        viewModel: widget.connectedBluetoothDeviceVm,
                      ),
                      if (widget.viewModel.device != null)
                        CheckConnectedDeviceOnlineScreen(
                          viewModel: widget.checkDeviceOnlineVm,
                          handleError: _onPreviousPage,
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
