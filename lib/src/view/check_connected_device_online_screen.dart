part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class CheckConnectedDeviceOnlineScreen extends StatefulWidget {
  const CheckConnectedDeviceOnlineScreen({super.key});

  @override
  State<CheckConnectedDeviceOnlineScreen> createState() => _CheckConnectedDeviceOnlineScreenState();
}

class _CheckConnectedDeviceOnlineScreenState extends State<CheckConnectedDeviceOnlineScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CheckConnectedDeviceOnlineScreenViewModel>().startChecking();
    });
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
              maxLines: 3,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentConnectedState(BuildContext context) {
    final viewModel = Provider.of<CheckConnectedDeviceOnlineScreenViewModel>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'Connected!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '${viewModel.robot.name} is connected and almost ready to use. You can leave this screen now and it will automatically come online in a few minutes.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
            maxLines: 4,
          ),
          Spacer(),
          FilledButton(
            onPressed: viewModel.handleAgentConfigured,
            child: Text('Close'),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    final viewModel = Provider.of<CheckConnectedDeviceOnlineScreenViewModel>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Spacer(),
          Icon(Icons.check_circle, color: Colors.green, size: 40),
          SizedBox(height: 24),
          Text('All set!', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
          SizedBox(height: 8),
          Text(
            '${viewModel.robot.name} is connected and ready to use.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          Spacer(),
          FilledButton(
            onPressed: viewModel.handleSuccess,
            child: Text('Close'),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildErrorConnectingState(BuildContext context) {
    final viewModel = Provider.of<CheckConnectedDeviceOnlineScreenViewModel>(context);
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
            viewModel.errorMessage ?? 'There was an error getting your machine online. Please try again.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          Spacer(),
          FilledButton(
            onPressed: viewModel.handleError,
            child: Text('Try again'),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckConnectedDeviceOnlineScreenViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: switch (viewModel.deviceOnlineState) {
            DeviceOnlineState.checking => _buildCheckingState(context),
            DeviceOnlineState.agentConnected => _buildAgentConnectedState(context),
            DeviceOnlineState.success => _buildSuccessState(context),
            DeviceOnlineState.errorConnecting => _buildErrorConnectingState(context),
          },
        );
      },
    );
  }
}
