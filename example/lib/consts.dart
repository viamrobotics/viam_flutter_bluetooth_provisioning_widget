import 'package:flutter_dotenv/flutter_dotenv.dart';

class Consts {
  // TODO: Populate with your own api Keys.
  static String apiKeyId = '';
  static String apiKey = '';

  static String organizationId = '';

  /// defaults to 'viamsetup', but if your viam-agent network configuration: https://docs.viam.com/manage/reference/viam-agent/#network_configuration
  /// has a value set for hotspot_password that will be used instead.
  /// this pre-shared key is prepended to bluetooth characteristic writes and decoded on the viam-agent side.
  static String psk = 'viamsetup';

  /// override static credentials with dotenv, if present
  static void reload() {
    apiKeyId = dotenv.env['VIAM_API_KEY_ID'] ?? apiKeyId;
    apiKey = dotenv.env['VIAM_API_KEY'] ?? apiKey;
    organizationId = dotenv.env['VIAM_ORG_ID'] ?? organizationId;
    psk = dotenv.env['VIAM_PSK'] ?? psk;
  }
}
