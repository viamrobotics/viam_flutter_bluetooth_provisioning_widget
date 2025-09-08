part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class PairingInstructionsScreen extends StatelessWidget {
  final VoidCallback onCtaTapped;
  // TODO: title, subtitle

  const PairingInstructionsScreen({super.key, required this.onCtaTapped});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pair with your machine.',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              "TODO: LONG TEXT, iOS AND ANDROID SPECIFIC",
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.bodyLarge,
              overflow: TextOverflow.visible,
            ),
            Spacer(),
            FilledButton(
              onPressed: onCtaTapped,
              child: Text(
                'Continue',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
