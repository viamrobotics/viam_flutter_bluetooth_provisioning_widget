part of '../../viam_flutter_provisioning_widget.dart';

class IntroScreenOne extends StatelessWidget {
  const IntroScreenOne({super.key});

  void _onGetStartedPressed(BuildContext context) {
    // final viewModel = context.read<VesselSetupViewModel>();
    // Navigator.of(context).push(MaterialPageRoute(
    //   builder: (context) => ChangeNotifierProvider.value(
    //     value: viewModel,
    //     child: IntroScreenTwo(),
    //   ),
    // ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Icon(Icons.tap_and_play, size: 64),
          const SizedBox(height: 24),
          Text(
            'Connect your device',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'We\'ll walk you through a short setup process to get your VC Box up and running.',
              textAlign: TextAlign.center,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
            ),
          ),
          const Spacer(),
          const Spacer(),
          FilledButton(
            onPressed: () => _onGetStartedPressed(context),
            child: const Text('Get started'),
          ),
        ],
      ),
    );
  }
}
