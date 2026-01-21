part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class ScanningListTile extends StatelessWidget {
  const ScanningListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 20,
      leading: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: const Color(0xFF9C9CA4),
          strokeWidth: 4,
        ),
      ),
      horizontalTitleGap: 16,
      minLeadingWidth: 0,
      title: Text('Scanning...', style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
