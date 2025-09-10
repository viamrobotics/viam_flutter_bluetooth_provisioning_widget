part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class IntroScreenTwo extends StatelessWidget {
  final VoidCallback handleNextTapped;
  final String turnOnTitle;
  final String turnOnSubtitle;
  final String bluetoothTitle;
  final String bluetoothSubtitle;

  const IntroScreenTwo({
    super.key,
    required this.handleNextTapped,
    required this.turnOnTitle,
    required this.turnOnSubtitle,
    required this.bluetoothTitle,
    required this.bluetoothSubtitle,
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
            const SizedBox(height: 24),
            Text(
              turnOnTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                turnOnSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 64),
            Icon(Icons.bluetooth, size: 40, color: const Color(0xFF9C9CA4)),
            SizedBox(height: 24),
            Text(
              bluetoothTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                bluetoothSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
              ),
            ),
            const Spacer(),
            const Spacer(),
            FilledButton(
              key: ValueKey('screen-2-cta'),
              onPressed: handleNextTapped,
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
