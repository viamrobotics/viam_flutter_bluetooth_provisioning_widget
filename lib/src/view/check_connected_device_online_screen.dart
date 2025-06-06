part of '../../viam_flutter_provisioning_widget.dart';

class CheckConnectedDeviceOnlineScreen extends StatelessWidget {
  const CheckConnectedDeviceOnlineScreen({super.key});

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
    // Currently same as checking, can customize later if needed
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
            onPressed: viewModel.handleSuccess,
            child: Text('Close'),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  // Helper method for the 'success' state
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
          },
        );
      },
    );
  }
}
