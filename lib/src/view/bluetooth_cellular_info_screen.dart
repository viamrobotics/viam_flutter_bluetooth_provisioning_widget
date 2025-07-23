part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class BluetoothCellularInfoScreen extends StatelessWidget {
  final VoidCallback handleCtaTapped;
  final String title;
  final String subtitle;
  final String ctaText;

  const BluetoothCellularInfoScreen({
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
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16), // additional padding
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
            ),
          ),
          const Spacer(),
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
