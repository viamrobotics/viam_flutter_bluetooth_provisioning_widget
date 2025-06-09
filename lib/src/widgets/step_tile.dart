part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class StepTile extends StatelessWidget {
  const StepTile({
    super.key,
    required this.stepNumber,
    required this.children,
    required this.onTap,
  });

  final String stepNumber;
  final List<InlineSpan> children;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.bodyLarge;
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          stepNumber,
          style: TextStyle(
            fontSize: 12,
          ),
        ),
      ),
      horizontalTitleGap: 8,
      contentPadding: const EdgeInsets.only(left: 0),
      title: RichText(
        textAlign: TextAlign.start,
        text: TextSpan(
          style: textTheme,
          children: children,
        ),
      ),
    );
  }
}
