part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class SetupTetheringScreen extends StatelessWidget {
  final VoidCallback onCtaTapped;

  const SetupTetheringScreen({super.key, required this.onCtaTapped});

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
              'Set up personal hotspot',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Platform.isIOS ? _buildIOSHotspotSteps(context) : _buildAndroidHotspotSteps(context),
            Spacer(),
            Text(
              "Once you've completed these steps, come back to this screen and tap \"Continue\".",
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

  Widget _buildIOSHotspotSteps(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.bodyLarge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepTile(
          stepNumber: '1',
          onTap: AppSettings.openAppSettings,
          children: [
            const TextSpan(text: 'In your phone\'s settings, go to '),
            TextSpan(text: 'Settings', style: textTheme!.copyWith(fontStyle: FontStyle.italic)),
            const TextSpan(text: ' > '),
            TextSpan(text: 'Personal Hotspot', style: textTheme.copyWith(fontWeight: FontWeight.bold)),
            const TextSpan(text: '\n\nMake sure "'),
            TextSpan(text: 'Allow Others to Join', style: textTheme.copyWith(fontWeight: FontWeight.bold)),
            const TextSpan(text: "\" is enabled"),
          ],
        ),
        Image.asset('packages/viam_flutter_bluetooth_provisioning_widget/lib/src/assets/ios_wifi_hotspot.png'),
        const SizedBox(height: 8),
        StepTile(
          stepNumber: '2',
          onTap: null,
          children: [
            const TextSpan(text: 'Go to '),
            TextSpan(text: 'Settings', style: textTheme!.copyWith(fontStyle: FontStyle.italic)),
            const TextSpan(text: ' > '),
            TextSpan(text: 'Bluetooth.', style: textTheme.copyWith(fontWeight: FontWeight.bold)),
            const TextSpan(text: 'You should see your machine.'), // TODO: custom copy
            const TextSpan(text: '\n\nTap to pair, and accept any pairing dialogs that pop up.'),
          ],
        ),
      ],
    );
  }

  Widget _buildAndroidHotspotSteps(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.bodyLarge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepTile(
          stepNumber: '1',
          onTap: null,
          children: [
            const TextSpan(text: "In your phone's settings, go to "),
            TextSpan(text: "Network & internet", style: textTheme!.copyWith(fontWeight: FontWeight.bold)),
            const TextSpan(text: ", then "),
            TextSpan(text: "Hotspot & tethering", style: textTheme.copyWith(fontWeight: FontWeight.bold)),
            const TextSpan(text: '\n\nMake sure '),
            TextSpan(text: 'Bluetooth tethering', style: textTheme.copyWith(fontWeight: FontWeight.bold)),
            const TextSpan(text: " is enabled"),
          ],
        ),
        Image.asset('packages/viam_flutter_bluetooth_provisioning_widget/lib/src/assets/android_wifi_hotspot.png'),
        const SizedBox(height: 8),
        StepTile(
          stepNumber: '2',
          onTap: null,
          children: [
            const TextSpan(text: 'Go to '),
            TextSpan(text: 'Settings', style: textTheme!.copyWith(fontStyle: FontStyle.italic)),
            const TextSpan(text: ' > '),
            TextSpan(text: 'Bluetooth.', style: textTheme.copyWith(fontWeight: FontWeight.bold)),
            const TextSpan(text: 'You should see your machine.'), // TODO: custom copy
            const TextSpan(text: '\n\nTap to pair, and accept any pairing dialogs that pop up.'),
          ],
        ),
      ],
    );
  }
}
