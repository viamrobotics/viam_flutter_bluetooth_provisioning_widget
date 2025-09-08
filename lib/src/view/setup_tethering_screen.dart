part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class SetupTetheringScreen extends StatelessWidget {
  final VoidCallback onCtaTapped;
  final String machineName;

  const SetupTetheringScreen({super.key, required this.onCtaTapped, required this.machineName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Text(
              'Set up Bluetooth Connection',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Platform.isIOS ? _buildIOSHotspotSteps(context) : _buildAndroidHotspotSteps(context),
            const SizedBox(height: 24),
            Text(
              "Come back to this page when you’re done.",
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.bodyLarge,
              overflow: TextOverflow.visible,
            ),
            const Spacer(),
            const Spacer(),
            FilledButton(
              onPressed: onCtaTapped,
              child: Text(
                'Next',
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
        RichText(
          text: TextSpan(
            style: textTheme,
            children: [
              const TextSpan(text: 'In your phone\'s settings, go to '),
              TextSpan(text: 'Settings', style: textTheme!.copyWith(fontStyle: FontStyle.italic)),
              const TextSpan(text: ' > '),
              TextSpan(text: 'Personal Hotspot.', style: textTheme.copyWith(fontWeight: FontWeight.bold)),
              const TextSpan(text: '\n\nMake sure "'),
              TextSpan(text: 'Allow Others to Join', style: textTheme.copyWith(fontWeight: FontWeight.bold)),
              const TextSpan(text: "\" is enabled:"),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text("The toggle should look like this:", style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Image.asset('packages/viam_flutter_bluetooth_provisioning_widget/lib/src/assets/ios_wifi_hotspot.png'),
      ],
    );
  }

  Widget _buildAndroidHotspotSteps(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.bodyLarge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: textTheme,
            children: [
              TextSpan(text: '1. ', style: textTheme!.copyWith(fontWeight: FontWeight.bold)),
              const TextSpan(text: "In your phone's settings, go to "),
              TextSpan(text: "Network & internet", style: textTheme.copyWith(fontWeight: FontWeight.bold)),
              const TextSpan(text: ", then "),
              TextSpan(text: "Hotspot & tethering", style: textTheme.copyWith(fontWeight: FontWeight.bold)),
              const TextSpan(text: '\n\nMake sure '),
              TextSpan(text: 'Bluetooth tethering', style: textTheme.copyWith(fontWeight: FontWeight.bold)),
              const TextSpan(text: " is enabled"),
            ],
          ),
        ),
        Image.asset('packages/viam_flutter_bluetooth_provisioning_widget/lib/src/assets/android_wifi_hotspot.png'),
      ],
    );
  }
}
