part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class PairingInstructionsScreen extends StatelessWidget {
  final VoidCallback onCtaTapped;

  final String title;
  final String iOSSubtitle;
  final String androidSubtitle;

  const PairingInstructionsScreen(
      {super.key, required this.onCtaTapped, required this.title, required this.iOSSubtitle, required this.androidSubtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Spacer(),
            Text(
              title,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Text(
              Platform.isIOS ? iOSSubtitle : androidSubtitle,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.bodyLarge,
              overflow: TextOverflow.visible,
            ),
            const Spacer(),
            const Spacer(),
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
