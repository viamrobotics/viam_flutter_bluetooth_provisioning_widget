part of '../../viam_flutter_provisioning_widget.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key, required this.connectedDevice});

  // TODO: grab it from the parent view model.. and read it that way!
  final BluetoothDevice connectedDevice;

  // static MaterialPageRoute<void> route({
  //   required BluetoothDevice connectedPeripheral,
  //   required VesselSetupViewModel viewModel,
  // }) {
  //   return MaterialPageRoute(
  //     builder: (context) => ChangeNotifierProvider.value(
  //       value: viewModel,
  //       child: PairingScreen(connectedPeripheral: connectedPeripheral),
  //     ),
  //   );
  // }

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  bool _isPaired = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start a timer to switch to the paired state after 3 seconds
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isPaired = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onNextPressed(BuildContext context) {
    //   final viewModel = context.read<VesselSetupViewModel>();
    //   Navigator.of(context).push(
    //     WifiQuestionScreen.route(
    //       connectedPeripheral: widget.connectedPeripheral,
    //       viewModel: viewModel,
    //     ),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: _isPaired ? _buildPairedState(context) : _buildPairingState(context),
        ),
      ),
    );
  }

  // Widget for the "Pairing..." state
  Widget _buildPairingState(BuildContext context) {
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
          'Pairing...',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'When you see a Bluetooth pairing request, tap "Pair"',
            maxLines: 3,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const Spacer(),
        const Spacer(),
      ],
    );
  }

  // Widget for the "Paired" state
  Widget _buildPairedState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Icon(Icons.check_circle, color: Colors.green, size: 48),
        const SizedBox(height: 24),
        Text(
          'Paired',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Next, let\'s get your VC Box online.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const Spacer(),
        const Spacer(),
        FilledButton(
          onPressed: () => _onNextPressed(context),
          child: const Text('Next'),
        ),
      ],
    );
  }
}
