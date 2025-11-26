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
      handleSuccess: viewModel.onSuccess,
      checkingDeviceOnlineRepository: viewModel.checkingDeviceOnlineRepository,
      connectBluetoothDeviceRepository: viewModel.connectBluetoothDeviceRepository,
    );
  }

  late final BluetoothProvisioningFlowViewModel viewModel;
  late final ConnectedBluetoothDeviceScreenViewModel connectedBluetoothDeviceVm;
  late final BluetoothScanningScreenViewModel scanningVm;
  late final CheckConnectedDeviceOnlineScreenViewModel checkDeviceOnlineVm;

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
    final checkAgentOnlineVm = CheckAgentOnlineScreenViewModel(
      handleOnline: () async {
        await Future.delayed(Duration(seconds: 3)); // delay long enough to see success
        await _onWifiCredentials(null, null); // shows loading
      },
      checkingAgentOnlineRepository: widget.viewModel.checkingAgentOnlineRepository,
      connectBluetoothDeviceRepository: widget.viewModel.connectBluetoothDeviceRepository,
      successTitle: widget.viewModel.copy.checkAgentOnlineSuccessTitle,
      successSubtitle: widget.viewModel.copy.checkAgentOnlineSuccessSubtitle,
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
                      BluetoothScanningScreen(viewModel: widget.scanningVm, onDeviceSelected: _onDeviceConnected),
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
                        if (!widget.viewModel.isConfigured) CheckDeviceAgentOnlineScreen(viewModel: checkAgentOnlineVm),
                      ],
                      if (_hasInternetConnection && widget.viewModel.device != null)
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
