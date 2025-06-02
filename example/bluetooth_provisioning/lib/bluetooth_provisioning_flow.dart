import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ignore: depend_on_referenced_packages

import 'package:viam_flutter_provisioning_widget/viam_flutter_provisioning_widget.dart';

// mv, maybe no changes needed..?
class BluetoothProvisioningFlowViewModel extends ChangeNotifier {
  // TODO: dependencies
  // TODO: methods
}

// TODO: rename from FirstRunDialog, create view model maybe
class BluetoothProvisioningFlow extends StatefulWidget {
  const BluetoothProvisioningFlow({super.key});

  @override
  State<BluetoothProvisioningFlow> createState() => _BluetoothProvisioningFlowState();
}

class _BluetoothProvisioningFlowState extends State<BluetoothProvisioningFlow> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPage() {
    _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvisioningFlowViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(), // TODO: custom app bar
          body: SafeArea(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                IntroScreenOne(),
                // second
                // third..
              ],
            ),
          ),
        );
      },
    );
  }
}
