part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class CheckAgentOnlineScreen extends StatefulWidget {
  final CheckAgentOnlineScreenViewModel viewModel;

  const CheckAgentOnlineScreen({super.key, required this.viewModel});

  @override
  State<CheckAgentOnlineScreen> createState() => _CheckAgentOnlineScreenState();
}

class _CheckAgentOnlineScreenState extends State<CheckAgentOnlineScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.startChecking();
    widget.viewModel.reconnect();
  }

  Widget _buildCheckingState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 32),
            Text(
              'Trying to connect...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Attempting to use Bluetooth to share your phone’s cellular connection',
              maxLines: null,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineState(BuildContext context) {
    print('BUILD ONLINE STATE 📡');
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          key: ValueKey('online-state'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 40),
            SizedBox(height: 24),
            Text(widget.viewModel.successTitle, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            SizedBox(height: 8),
            Text(
              widget.viewModel.successSubtitle,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: (widget.viewModel.agentOnline) ? _buildOnlineState(context) : _buildCheckingState(context),
        );
      },
    );
  }
}
