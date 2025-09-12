part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class InternetQuestionScreen extends StatelessWidget {
  final VoidCallback handleYesTapped;
  final VoidCallback handleNoTapped;
  final String title;
  final String? subtitle;

  const InternetQuestionScreen({
    super.key,
    required this.handleYesTapped,
    required this.handleNoTapped,
    required this.title,
    required this.subtitle,
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
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
              ),
            ),
          const SizedBox(height: 40),
          OutlinedButton(
            onPressed: handleYesTapped,
            style: FilledButton.styleFrom(
              minimumSize: Size(double.infinity, 60),
            ),
            child: Text('Yes'),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: handleNoTapped,
            style: FilledButton.styleFrom(
              minimumSize: Size(double.infinity, 60),
            ),
            child: Text('No'),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
