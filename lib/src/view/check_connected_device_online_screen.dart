part of '../../viam_flutter_provisioning_widget.dart';

class CheckConnectedDeviceOnlineScreen extends StatefulWidget {
  const CheckConnectedDeviceOnlineScreen({
    super.key,
    required this.handleSuccess,
    required this.viam,
    required this.robot,
    required this.connectedDevice,
  });

  final VoidCallback handleSuccess;
  final Viam viam;
  final Robot robot;
  final BluetoothDevice connectedDevice;

  @override
  State<CheckConnectedDeviceOnlineScreen> createState() => _CheckConnectedDeviceOnlineScreenState();
}

enum _DeviceOnlineState {
  checking,
  agentConnected,
  success,
}

class _CheckConnectedDeviceOnlineScreenState extends State<CheckConnectedDeviceOnlineScreen> {
  Timer? _onlineTimer;
  _DeviceOnlineState _setupState = _DeviceOnlineState.checking;

  @override
  void initState() {
    super.initState();
    _initTimers();
  }

  @override
  void dispose() {
    _onlineTimer?.cancel();
    super.dispose();
  }

  void _initTimers() {
    _onlineTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkOnline();
      _checkAgentStatus();
    });
  }

  Future<void> _checkAgentStatus() async {
    try {
      final status = await widget.connectedDevice.readStatus();

      if (status.isConnected && status.isConfigured && _setupState != _DeviceOnlineState.success) {
        setState(() {
          _setupState = _DeviceOnlineState.agentConnected;
        });
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  void _checkOnline() async {
    final refreshedRobot = await widget.viam.appClient.getRobot(widget.robot.id);
    final seconds = refreshedRobot.lastAccess.seconds.toInt();
    final actual = DateTime.now().microsecondsSinceEpoch / Duration.microsecondsPerSecond;
    if ((actual - seconds) < 10) {
      setState(() {
        _setupState = _DeviceOnlineState.success;
      });
      _onlineTimer?.cancel();
    }
  }

  // Helper method for the 'checking' state
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

  // Helper method for the 'agentConnected' state
  Widget _buildAgentConnectedState(BuildContext context) {
    // Currently same as checking, can customize later if needed
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
            '${widget.robot.name} is connected and almost ready to use. You can leave this screen now and it will automatically come online in a few minutes.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
            maxLines: 4,
          ),
          Spacer(),
          FilledButton(
            onPressed: widget.handleSuccess,
            child: Text('Close'),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  // Helper method for the 'success' state
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
          Text('All set!', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
          SizedBox(height: 8),
          Text(
            '${widget.robot.name} is connected and ready to use.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          Spacer(),
          FilledButton(
            onPressed: widget.handleSuccess,
            child: Text('Close'),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: widget.handleSuccess,
        ),
      ),
      body: SafeArea(
        child: switch (_setupState) {
          _DeviceOnlineState.checking => _buildCheckingState(context),
          _DeviceOnlineState.agentConnected => _buildAgentConnectedState(context),
          _DeviceOnlineState.success => _buildSuccessState(context),
        },
      ),
    );
  }
}
