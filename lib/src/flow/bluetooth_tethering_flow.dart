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
    final checkingAgentOnlineRepository = CheckingAgentOnlineRepository(device: null);
    final checkingDeviceOnlineRepository = CheckingDeviceOnlineRepository(
      device: null,
      viam: viam,
      robot: robot,
    );
    viewModel = BluetoothProvisioningFlowViewModel(
      viam: viam,
      robot: robot,
      isNewMachine: isNewMachine,
      connectBluetoothDeviceRepository: connectBluetoothDeviceRepository,
      checkingDeviceOnlineRepository: checkingDeviceOnlineRepository,
      checkingAgentOnlineRepository: checkingAgentOnlineRepository,
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
      successTitle: copy.checkingOnlineSuccessTitle,
      successSubtitle: copy.checkingOnlineSuccessSubtitle,
      successCta: copy.checkingOnlineSuccessCta,
      checkingDeviceOnlineRepository: checkingDeviceOnlineRepository,
      connectBluetoothDeviceRepository: connectBluetoothDeviceRepository,
    );
    checkAgentOnlineVm = CheckAgentOnlineScreenViewModel(
      checkingAgentOnlineRepository: checkingAgentOnlineRepository,
      connectBluetoothDeviceRepository: connectBluetoothDeviceRepository,
      successTitle: copy.checkAgentOnlineSuccessTitle,
      successSubtitle: copy.checkAgentOnlineSuccessSubtitle,
    );
  }

  late final BluetoothProvisioningFlowViewModel viewModel;
  late final ConnectedBluetoothDeviceScreenViewModel connectedBluetoothDeviceVm;
  late final BluetoothScanningScreenViewModel scanningVm;
  late final CheckConnectedDeviceOnlineScreenViewModel checkDeviceOnlineVm;
  late final CheckAgentOnlineScreenViewModel checkAgentOnlineVm;

  @override
  State<BluetoothTetheringFlow> createState() => _BluetoothTetheringFlowState();
}

class _BluetoothTetheringFlowState extends State<BluetoothTetheringFlow> {
  final PageController _pageController = PageController();
  StreamSubscription<bool>? _agentOnlineSubscription;
  bool _hasInternetConnection = false;
  bool _agentOnline = false;

  @override
  initState() {
    super.initState();
    _setupAgentOnlineListener();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _agentOnlineSubscription?.cancel();
    super.dispose();
  }

  /// This could almost be done in the view model, except for the page changing logic required to move to the next screen
  void _setupAgentOnlineListener() {
    _agentOnlineSubscription = widget.checkAgentOnlineVm.checkingAgentOnlineRepository.agentOnlineStateStream.listen((online) async {
      if (_agentOnline == online) return;
      _agentOnline = online;
      if (online) {
        await Future.delayed(Duration(seconds: 3)); // delay long enough to see success
        await _onWifiCredentials(null, null); // shows loading
      }
    });
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
    if (await widget.viewModel.isDeviceConnectionValid(context, device) && mounted) {
      _onNextPage();
      widget.connectedBluetoothDeviceVm.readNetworkList(context);
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
                        if (!widget.viewModel.isConfigured) CheckAgentOnlineScreen(viewModel: widget.checkAgentOnlineVm),
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
                          handleSuccess: widget.viewModel.onSuccess,
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
