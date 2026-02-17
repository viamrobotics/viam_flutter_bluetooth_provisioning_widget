part of '../../viam_flutter_bluetooth_provisioning_widget.dart';

class CheckConnectedDeviceOnlineScreen extends StatefulWidget {
  final VoidCallback handleSuccess;
  final VoidCallback handleError;
  final CheckConnectedDeviceOnlineScreenViewModel viewModel;

  const CheckConnectedDeviceOnlineScreen({
    super.key,
    required this.viewModel,
    required this.handleSuccess,
    required this.handleError,
  });

  @override
  State<CheckConnectedDeviceOnlineScreen> createState() => _CheckConnectedDeviceOnlineScreenState();
}

class _CheckConnectedDeviceOnlineScreenState extends State<CheckConnectedDeviceOnlineScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.reconnect(); // reconnect to device if it was disconnected
    widget.viewModel.startChecking();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: switch (widget.viewModel.deviceOnlineState) {
            DeviceOnlineState.idle => _CheckingWidget(), // could be in this state right before starting to check, but not long
            DeviceOnlineState.checking => _CheckingWidget(),
            DeviceOnlineState.success => _SuccessWidget(
                title: widget.viewModel.successTitle,
                subtitle: widget.viewModel.successSubtitle,
                handleSuccess: widget.handleSuccess,
                cta: widget.viewModel.successCta,
              ),
            DeviceOnlineState.errorConnecting => _ErrorWidget(
                errorMessage: widget.viewModel.errorMessage,
                handleError: widget.handleError,
              ),
          },
        );
      },
    );
  }
}

class _SuccessWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String cta;

  final VoidCallback handleSuccess;

  const _SuccessWidget({required this.title, required this.subtitle, required this.handleSuccess, required this.cta});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        key: ValueKey('device-connected-viam'),
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Spacer(),
          Icon(Icons.check_circle, color: Colors.green, size: 40),
          SizedBox(height: 24),
          Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
            maxLines: null,
          ),
          Spacer(),
          FilledButton(
            onPressed: handleSuccess,
            child: Text(cta),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CheckingWidget extends StatelessWidget {
  const _CheckingWidget();

  @override
  Widget build(BuildContext context) {
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
}

class _ErrorWidget extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback handleError;

  const _ErrorWidget({required this.errorMessage, required this.handleError});

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey('device-error'),
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
            errorMessage ?? 'There was an error getting your machine online. Please try again.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          Spacer(),
          FilledButton(
            onPressed: handleError,
            child: Text('Try again'),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
