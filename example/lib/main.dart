import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'start_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      assert(dotenv.env['API_KEY_ID']!.isNotEmpty, 'apiKeyId is empty');
      assert(dotenv.env['API_KEY']!.isNotEmpty, 'apiKey is empty');
      assert(dotenv.env['ORG_ID']!.isNotEmpty, 'organizationId is empty');
      assert(dotenv.env['LOCATION_ID']!.isNotEmpty, 'locationId is empty');
    } catch (e) {
      debugPrint('Error: $e');
      // To use this example app populate the .env file with your own api Keys.
      rethrow;
    }

    return MaterialApp(
      title: 'Bluetooth Provisioning',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}
