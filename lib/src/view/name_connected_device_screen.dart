part of '../../viam_flutter_provisioning_widget.dart';

class NameConnectedDeviceScreen extends StatefulWidget {
  const NameConnectedDeviceScreen({
    super.key,
    required this.connectedPeripheral,
    required this.ssid,
    required this.passkey,
  });

  final String? ssid;
  final String? passkey;
  final BluetoothDevice connectedPeripheral;

  @override
  State<NameConnectedDeviceScreen> createState() => _NameConnectedDeviceScreenState();
}

class _NameConnectedDeviceScreenState extends State<NameConnectedDeviceScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Name your vessel", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            autofocus: true,
            cursorColor: Colors.blue,
            decoration: InputDecoration(
              label: Text("Name"),
            ),
            textInputAction: TextInputAction.done,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 32),
            child: Text(
              "Name must contain a letter or number. Cannot start with '-' or '_'. Spaces are allowed.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () {},
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator.adaptive(
                      backgroundColor: Colors.white,
                    ),
                  )
                : const Text("Done"),
          ),
        ],
      ),
    );
  }
}
