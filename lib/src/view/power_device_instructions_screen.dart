part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class PowerDeviceInstructionsScreen extends StatelessWidget {
  final VoidCallback handleNextTapped;
  final String title;
  final String subtitle;

  const PowerDeviceInstructionsScreen({
    super.key,
    required this.handleNextTapped,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Icon(Icons.power_settings_new, size: 40, color: const Color(0xFF9C9CA4)),
            SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: handleNextTapped,
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
