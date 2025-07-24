part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

// TODO: APP-8807 in progress, resolving with this ticket as screens are added

/// Takes you through provisioning flow with added support for tethering
class BluetoothTetheringFlow extends StatefulWidget {
  const BluetoothTetheringFlow({
    super.key,
  });

  @override
  State<BluetoothTetheringFlow> createState() => _BluetoothTetheringFlowState();
}

class _BluetoothTetheringFlowState extends State<BluetoothTetheringFlow> {
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
                PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    InternetYesNoScreen(
                      handleYesTapped: () {
                        _onNextPage(); // TODO: go to normal flow, network list
                      },
                      handleNoTapped: () {
                        _onNextPage(); // TODO: go to bluetooth/hotspot info screen
                      },
                    ),
                    BluetoothCellularInfoScreen(
                      handleCtaTapped: () {},
                      title: viewModel.copy.bluetoothCellularInfoTitle,
                      subtitle: viewModel.copy.bluetoothCellularInfoSubtitle,
                      ctaText: viewModel.copy.bluetoothCellularInfoCta,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
