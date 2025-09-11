part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class IntroScreenOne extends StatelessWidget {
  final VoidCallback handleCtaTapped;
  final String title;
  final String subtitle;
  final String ctaText;

  const IntroScreenOne({
    super.key,
    required this.handleCtaTapped,
    required this.title,
    required this.subtitle,
    required this.ctaText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Icon(Icons.tap_and_play, size: 64, color: const Color(0xFF9C9CA4)),
          const SizedBox(height: 24),
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
            onPressed: handleCtaTapped,
            child: Text(ctaText),
          ),
        ],
      ),
    );
  }
}
