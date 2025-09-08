part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

enum InternetConnectionOption { wifi, cellular }

class ChooseConnectionMethodScreen extends StatefulWidget {
  final void Function(InternetConnectionOption) onConnectionOptionSelected;
  final String cellularSubtitle;

  const ChooseConnectionMethodScreen({
    super.key,
    required this.onConnectionOptionSelected,
    required this.cellularSubtitle,
  });

  @override
  State<ChooseConnectionMethodScreen> createState() => _ChooseConnectionMethodScreenState();
}

class _ChooseConnectionMethodScreenState extends State<ChooseConnectionMethodScreen> {
  InternetConnectionOption? selectedOption;

  void _handleOptionSelected(InternetConnectionOption option) {
    setState(() {
      selectedOption = option;
    });
  }

  void _handleNextPressed() {
    assert(selectedOption != null);
    widget.onConnectionOptionSelected(selectedOption!);
  }

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
            'Choose connection method',
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: RadioListTile<InternetConnectionOption>(
                  value: InternetConnectionOption.wifi,
                  groupValue: selectedOption,
                  onChanged: (value) => _handleOptionSelected(value!),
                  title: const Text(
                    'Wi-Fi, Ethernet, or Starlink',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text('Recommend. Most reliable connection.'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  dense: false,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: RadioListTile<InternetConnectionOption>(
                  value: InternetConnectionOption.cellular,
                  groupValue: selectedOption,
                  onChanged: (value) => _handleOptionSelected(value!),
                  title: const Text(
                    'Use phone\'s cellular connection',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.cellularSubtitle),
                      const SizedBox(height: 4),
                      const Text('We recommend using this as backup if other sources of Internet are unavailable.'),
                    ],
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  dense: false,
                  isThreeLine: true,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Spacer(),
          FilledButton(
            onPressed: selectedOption != null ? _handleNextPressed : null,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
