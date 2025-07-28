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
    required handleAgentConfigured,
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
      handleAgentConfigured: handleAgentConfigured,
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
  bool _isLoading = false;

  /// can be flipped on/off by the user depending on how they answer the internet question
  bool _useInternetFlow = false;

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

  void _onWifiCredentials(String ssid, String? psk) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await widget.viewModel.writeConfig(ssid: ssid, password: psk);
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

  void _onInternetYesNo(bool yesInternet) {
    setState(() {
      _useInternetFlow = yesInternet;
    });
    _onNextPage();
  }

  // TODO: APP-8807 handle loading isConnected in next screen, with view model in that screen, only call unlock here / in flow vm
  void _onSetupTethering() async {
    debugPrint('onSetupTethering');
    try {
      final status = await widget.viewModel.device!.readStatus();
      debugPrint('status: $status');
      await widget.viewModel.device!.unlockPairing();
      debugPrint('unlocked pairing');
    } catch (e) {
      debugPrint('error unlocking pairing: $e');
    }

    Timer.periodic(Duration(seconds: 5), (timer) async {
      final status = await widget.viewModel.device!.readStatus();
      if (status.isConnected) {
        debugPrint('agent connected ✅');
        timer.cancel();
      } else {
        debugPrint('agent not connected ❌');
      }
    });
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
                      InternetYesNoScreen(
                        handleYesTapped: () => _onInternetYesNo(true),
                        handleNoTapped: () => _onInternetYesNo(false),
                      ),
                      if (!_useInternetFlow) ...[
                        BluetoothCellularInfoScreen(
                          handleCtaTapped: _onNextPage,
                          title: widget.viewModel.copy.bluetoothCellularInfoTitle,
                          subtitle: widget.viewModel.copy.bluetoothCellularInfoSubtitle,
                          ctaText: widget.viewModel.copy.bluetoothCellularInfoCta,
                        ),
                        SetupTetheringScreen(
                          onCtaTapped: _onSetupTethering,
                          machineName: widget.viewModel.copy.tetheringMachineName,
                        ),
                      ],
                      if (_useInternetFlow)
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
                            handleAgentConfigured: widget.viewModel.handleAgentConfigured,
                            handleError: _onPreviousPage,
                            checkingDeviceOnlineRepository: CheckingDeviceOnlineRepository(
                              device: widget.viewModel.device!,
                              viam: widget.viewModel.viam,
                              robot: widget.viewModel.robot,
                            ),
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
