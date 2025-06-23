part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class IntroScreenTwo extends StatelessWidget {
  final VoidCallback handleNextTapped;

  const IntroScreenTwo({super.key, required this.handleNextTapped});

  @override
  Widget build(BuildContext context) {
    return Center(
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
                    TextSpan(text: 'Your device is '),
                    TextSpan(
                      text: 'plugged in ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: 'and '),
                    TextSpan(
                      text: 'powered on',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
              onPressed: handleNextTapped,
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
