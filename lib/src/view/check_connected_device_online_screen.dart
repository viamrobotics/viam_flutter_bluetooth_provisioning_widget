part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class CheckConnectedDeviceOnlineScreen extends StatefulWidget {
  const CheckConnectedDeviceOnlineScreen({super.key, required this.viewModel});

  final CheckConnectedDeviceOnlineScreenViewModel viewModel;

  @override
  State<CheckConnectedDeviceOnlineScreen> createState() => _CheckConnectedDeviceOnlineScreenState();
}

class _CheckConnectedDeviceOnlineScreenState extends State<CheckConnectedDeviceOnlineScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.startChecking();
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
              'Finishing up...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Please keep this screen open until setup is complete. This should take a minute or two.',
              maxLines: null,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Spacer(),
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
          Spacer(),
          FilledButton(
            onPressed: widget.viewModel.handleSuccess,
            child: Text(widget.viewModel.successCta),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildErrorConnectingState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Spacer(),
          Icon(Icons.error, color: Colors.red, size: 40),
          SizedBox(height: 24),
          Text('Error during setup', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
          SizedBox(height: 8),
          Text(
            widget.viewModel.errorMessage ?? 'There was an error getting your machine online. Please try again.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          Spacer(),
          FilledButton(
            onPressed: widget.viewModel.handleError,
            child: Text('Try again'),
          ),
          SizedBox(height: 16),
        ],
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
          child: switch (widget.viewModel.deviceOnlineState) {
            DeviceOnlineState.checking => _buildCheckingState(context),
            DeviceOnlineState.success => _buildSuccessState(context),
            DeviceOnlineState.errorConnecting => _buildErrorConnectingState(context),
          },
        );
      },
    );
  }
}
