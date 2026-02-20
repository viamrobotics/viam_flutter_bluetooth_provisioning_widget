#!/usr/bin/env bash

# This script runs BLE provisioning integration tests. It is intended to be run directly from a download, with a command such as:
# bash <(curl -fsSL https://raw.githubusercontent.com/viamrobotics/viam_flutter_bluetooth_provisioning_widget/main/scripts/run_integration_test.sh) /path/to/.env

# By default, this script will run the test in release mode for iOS and debug mode for Android. You can override this in the .env file.

# This script requires that you pass it a .env file that contains the following variables.
#   API_KEY
#   API_KEY_ID
#   ORG_ID
#   LOCATION_ID
#   WIFI_SSID
#   WIFI_PASSWORD
#   DEVICE
#   PLATFORM  ("ios" or "android")
#   MATCH_PASSWORD (iOS only)
#   MATCH_KEYCHAIN_PASSWORD (iOS only)

# Optional .env variables:
#   RELEASE=true|false   (default: true for iOS, false for Android)
#   VERBOSE=true|false   (default: true)



set -euo pipefail

die() { echo "FAIL: $*" >&2; exit 1; }

# Load .env file from first argument
ENV_FILE="${1:-}"
[[ -z "$ENV_FILE" ]] && die "Usage: $0 <path-to-env-file>"
[[ -f "$ENV_FILE" ]] || die "Env file not found: $ENV_FILE"

# Export everything so fastlane can access it
set -a
# Read all variables from the .env file
source "$ENV_FILE"
set +a

[[ "${PLATFORM:-}" != "ios" && "${PLATFORM:-}" != "android" ]] && die "PLATFORM must be set to 'ios' or 'android' in your .env file"

# Validate required env vars
REQUIRED_VARS=(API_KEY API_KEY_ID ORG_ID LOCATION_ID WIFI_SSID WIFI_PASSWORD DEVICE)
[[ "$PLATFORM" == "ios" ]] && REQUIRED_VARS+=(MATCH_PASSWORD MATCH_KEYCHAIN_PASSWORD)

for var in "${REQUIRED_VARS[@]}"; do
  [[ -z "${!var:-}" ]] && die "Missing required variable: $var"
done

echo "All required env vars present (platform: $PLATFORM)"

# Clone repo into a temp directory that is automatically cleaned up on exit
TMPDIR_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_ROOT"' EXIT
echo "Working in: $TMPDIR_ROOT"

git clone --depth 1 https://github.com/viamrobotics/viam_flutter_bluetooth_provisioning_widget.git "$TMPDIR_ROOT/repo"
EXAMPLE_DIR="$TMPDIR_ROOT/repo/example"

# Install tools
echo "Installing Patrol CLI ..."
flutter pub global activate patrol_cli

if [[ "$PLATFORM" == "ios" ]] && ! command -v fastlane &>/dev/null; then
  echo "Installing Fastlane ..."
  brew install fastlane
fi

# Inject credentials into source files
echo "Injecting credentials ..."

sed -i.bak \
  -e "s|static const String apiKeyId = '';|static const String apiKeyId = '$API_KEY_ID';|" \
  -e "s|static const String apiKey = '';|static const String apiKey = '$API_KEY';|" \
  -e "s|static const String organizationId = '';|static const String organizationId = '$ORG_ID';|" \
  -e "s|static const String locationId = '';|static const String locationId = '$LOCATION_ID';|" \
  "$EXAMPLE_DIR/lib/consts.dart"

sed -i.bak \
  -e "s|const String testWifiSsid = 'YOUR_WIFI_SSID';|const String testWifiSsid = '$WIFI_SSID';|" \
  -e "s|const String testWifiPassword = 'YOUR_WIFI_PASSWORD';|const String testWifiPassword = '$WIFI_PASSWORD';|" \
  "$EXAMPLE_DIR/patrol_test/ble_provisioning_flow_test.dart"

# Fetch signing certificates (iOS only)
if [[ "$PLATFORM" == "ios" ]]; then
  echo "Fetching iOS signing certificates ..."
  (cd "$EXAMPLE_DIR/ios" && fastlane certs)
fi

# Run the test
echo "Running flutter pub get ..."
(cd "$EXAMPLE_DIR" && flutter pub get)

# Default: release on for iOS, off for Android. Verbose always on.
PATROL_FLAGS=()
if [[ "$PLATFORM" == "ios" ]]; then
  [[ "${RELEASE:-true}" != "false" ]] && PATROL_FLAGS+=(--release)
else
  [[ "${RELEASE:-false}" != "false" ]] && PATROL_FLAGS+=(--release)
fi
[[ "${VERBOSE:-true}" != "false" ]] && PATROL_FLAGS+=(--verbose)

echo "Running patrol integration test on device: $DEVICE ..."
TEST_EXIT=0
(cd "$EXAMPLE_DIR" && patrol test -t patrol_test/ble_provisioning_flow_test.dart "${PATROL_FLAGS[@]+"${PATROL_FLAGS[@]}"}" -d "$DEVICE") || TEST_EXIT=$?

if [[ $TEST_EXIT -eq 0 ]]; then
  echo "PASSED"
else
  echo "FAILED (exit code: $TEST_EXIT)"
fi

exit $TEST_EXIT
