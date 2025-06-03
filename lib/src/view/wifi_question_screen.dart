part of '../../viam_flutter_provisioning_widget.dart';

class WifiQuestionScreen extends StatefulWidget {
  const WifiQuestionScreen({
    super.key,
    required this.handleYesTapped,
    required this.connectedDevice,
    this.startInConnectingState = false,
  });

  final VoidCallback handleYesTapped;
  final BluetoothDevice connectedDevice;
  final bool startInConnectingState;

  @override
  State<WifiQuestionScreen> createState() => _WifiQuestionScreenState();
}

class _WifiQuestionScreenState extends State<WifiQuestionScreen> {
  late bool _isConnecting;

  @override
  void initState() {
    super.initState();
    _isConnecting = widget.startInConnectingState;
    if (_isConnecting) {
      // Schedule the connection check after the first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onNoPressed(context);
      });
    }
  }

  Future<void> _onNoPressed(BuildContext context) async {
    setState(() {
      _isConnecting = true;
    });

    if (!mounted) return;

    try {
      final status = await widget.connectedDevice.readStatus();
      debugPrint(status.toString());
      if (!context.mounted) return;
      // final viewModel = context.read<VesselSetupViewModel>();
      // if (status.isConnected) {
      //   Navigator.of(context).push(
      //     InternetSuccessScreen.route(
      //       widget.connectedPeripheral,
      //       viewModel,
      //     ),
      //   );
      // } else {
      //   if (context.mounted) {
      //     Navigator.of(context).push(
      //       SetupHotspotScreen.route(widget.connectedPeripheral, viewModel),
      //     );
      //   }
      // }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Connection Error'),
              content: const Text(
                'Failed to check connection status. Please try again with another device.',
              ),
              actions: <Widget>[
                OutlinedButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    // TODO: Pop back to scanning
                  },
                ),
              ],
            );
          },
        );
      }
    }

    setState(() {
      _isConnecting = false;
    });
  }

  // Widget for the "Connecting..." state
  Widget _buildConnectingState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
        const SizedBox(height: 32),
        Text(
          'Trying to connect...',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          "Attempting to use Bluetooth to share your phone's cellular connection",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 3,
        ),
        const Spacer(),
        const Spacer(),
      ],
    );
  }

  // Widget for the initial question state
  Column _buildQuestionState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Spacer(),
        Text(
          'Does your boat have an\nInternet connection?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Wi-Fi, Ethernet, or Starlink',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 48),
        OutlinedButton(
          onPressed: () => widget.handleYesTapped(),
          child: Text(
            'Yes',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => _onNoPressed(context),
          child: Text(
            'No',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Add the AppBar back, assuming it was intended
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _isConnecting ? _buildConnectingState(context) : _buildQuestionState(context),
          ),
        ),
      ),
    );
  }
}
