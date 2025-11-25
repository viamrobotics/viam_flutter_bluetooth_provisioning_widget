part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class BluetoothTetheringFlow extends StatefulWidget {
  BluetoothTetheringFlow({
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
  State<BluetoothTetheringFlow> createState() => _BluetoothTetheringFlowState();
}

class _BluetoothTetheringFlowState extends State<BluetoothTetheringFlow> {
  final PageController _pageController = PageController();

  bool _hasInternetConnection = false;

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

  Future<void> _onDeviceConnected(BluetoothDevice device) async {
    if (await widget.viewModel.isDeviceConnectionValid(context, device)) {
      _onNextPage();
    }
  }

  Future<void> _onWifiCredentials(String? ssid, String? password) async {
    if (await widget.viewModel.onWifiCredentials(context, ssid, password)) {
      _onNextPage();
    }
  }

  Future<void> _unlockBluetoothPairing() async {
    if (await widget.viewModel.unlockBluetoothPairing(context)) {
      _onNextPage();
    }
  }

  void _onInternetQuestionAnswered(bool yesInternet) {
    setState(() {
      _hasInternetConnection = yesInternet;
    });
    _onNextPage();
  }

  @override
  Widget build(BuildContext context) {
    final checkConnectedVm = CheckConnectedDeviceOnlineScreenViewModel(
      robot: widget.viewModel.robot,
      successTitle: widget.viewModel.copy.checkingOnlineSuccessTitle,
      successSubtitle: widget.viewModel.copy.checkingOnlineSuccessSubtitle,
      successCta: widget.viewModel.copy.checkingOnlineSuccessCta,
      handleSuccess: widget.viewModel.onSuccess,
      handleError: _onPreviousPage, // back to network selection
      checkingDeviceOnlineRepository: widget.viewModel.checkingDeviceOnlineRepository,
      connectBluetoothDeviceRepository: widget.viewModel.connectBluetoothDeviceRepository,
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
                      BluetoothScanningScreen(
                        viewModel: BluetoothScanningScreenViewModel(
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
                        ),
                      ),
                      InternetQuestionScreen(
                        handleYesTapped: () => _onInternetQuestionAnswered(true),
                        handleNoTapped: () => _onInternetQuestionAnswered(false),
                        title: widget.viewModel.copy.internetQuestionTitle,
                        subtitle: widget.viewModel.copy.internetQuestionSubtitle,
                      ),
                      if (!_hasInternetConnection && widget.viewModel.device != null) ...[
                        SetupTetheringScreen(
                          onCtaTapped: _unlockBluetoothPairing,
                          machineName: widget.viewModel.copy.tetheringMachineName,
                        ),
                        PairingInstructionsScreen(
                          onCtaTapped: _onNextPage,
                          title: widget.viewModel.copy.pairingInstructionsTitle,
                          iOSSubtitle: widget.viewModel.copy.pairingInstructionsIOSSubtitle,
                          androidSubtitle: widget.viewModel.copy.pairingInstructionsAndroidSubtitle,
                        ),
                        // If the machine is configured already (has machine credentials) and gets a connection from tethering,
                        // we won't be able to check agent online. The agent bluetooth service will be shut down at this point.
                        // The machine will be online in app.viam.com and we should skip to that check instead.
                        if (!widget.viewModel.isConfigured)
                          CheckDeviceAgentOnlineScreen(
                            viewModel: CheckAgentOnlineScreenViewModel(
                              handleOnline: () async {
                                await Future.delayed(Duration(seconds: 3)); // delay long enough to see success
                                await _onWifiCredentials(null, null); // shows loading
                              },
                              checkingAgentOnlineRepository: CheckingAgentOnlineRepository(device: widget.viewModel.device!),
                              connectBluetoothDeviceRepository: widget.viewModel.connectBluetoothDeviceRepository,
                              successTitle: widget.viewModel.copy.checkAgentOnlineSuccessTitle,
                              successSubtitle: widget.viewModel.copy.checkAgentOnlineSuccessSubtitle,
                            ),
                          ),
                      ],
                      if (_hasInternetConnection && widget.viewModel.device != null)
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
                      if (widget.viewModel.device != null) CheckConnectedDeviceOnlineScreen(viewModel: checkConnectedVm),
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
