part of '../../viam_flutter_provisioning_widget.dart';

class IntroScreenTwo extends StatelessWidget {
  const IntroScreenTwo({super.key});

  void _onNextPressed(BuildContext context) {
    // final viewModel = context.read<VesselSetupViewModel>();
    // Navigator.of(context).push(
    //   BluetoothScanningScreen.route(viewModel),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Spacer(),
                Text(
                  'Make sure that...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 40),
                Icon(Icons.power_settings_new, size: 32),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge,
                      children: [
                        TextSpan(text: 'VC Box is '),
                        TextSpan(
                          text: 'plugged in ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: 'and '),
                        TextSpan(
                          text: 'powered on',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '. The light should be slowly flashing blue.'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Icon(Icons.bluetooth, size: 32),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge,
                      children: [
                        TextSpan(
                          text: 'Bluetooth ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: 'is enabled on your phone. You can do this in '),
                        TextSpan(
                          text: 'Settings > Bluetooth',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Spacer(),
                FilledButton(
                  onPressed: () => _onNextPressed(context),
                  child: Text('Next'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
