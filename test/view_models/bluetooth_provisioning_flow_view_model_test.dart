import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/generate_mocks.mocks.dart';

void main() {
  group('BluetoothProvisioningFlowViewModel', () {
    late BluetoothProvisioningFlowViewModel vmNewMachine;
    late BluetoothProvisioningFlowViewModel vmExistingMachine;

    late MockConnectBluetoothDeviceRepository mockConnectBluetoothDeviceRepository;
    late MockBluetoothDevice mockDevice;
    late MockCheckingDeviceOnlineRepository mockCheckingDeviceOnlineRepository;
    late MockCheckingAgentOnlineRepository mockCheckingAgentOnlineRepository;
    late MockRobotPart mockRobotPart;
    late MockRobot mockRobot;
    late MockViam mockViam;
    late MockBluetoothService mockBluetoothService;
    late MockBluetoothCharacteristic viamStatusCharacteristic;
    late StreamController<DeviceOnlineState> deviceOnlineStateStream;

    setUp(() {
      mockDevice = MockBluetoothDevice();
      when(mockDevice.isConnected).thenReturn(true);

      when(mockDevice.discoverServices(
        subscribeToServicesChanged: true,
        timeout: 15,
      )).thenAnswer((_) async => <BluetoothService>[mockBluetoothService]);

      mockBluetoothService = MockBluetoothService();
      when(mockBluetoothService.uuid).thenReturn(Guid.fromString(ViamBluetoothUUIDs.serviceUUID));

      viamStatusCharacteristic = MockBluetoothCharacteristic();
      when(viamStatusCharacteristic.uuid).thenReturn(Guid.fromString(ViamBluetoothUUIDs.statusUUID));

      when(mockBluetoothService.characteristics).thenReturn(<BluetoothCharacteristic>[viamStatusCharacteristic]);

      mockConnectBluetoothDeviceRepository = MockConnectBluetoothDeviceRepository();
      when(mockConnectBluetoothDeviceRepository.currentDevice).thenReturn(mockDevice);
      mockCheckingDeviceOnlineRepository = MockCheckingDeviceOnlineRepository();
      deviceOnlineStateStream = StreamController<DeviceOnlineState>.broadcast();
      when(mockCheckingDeviceOnlineRepository.deviceOnlineStateStream).thenAnswer((_) => deviceOnlineStateStream.stream);
      when(mockCheckingDeviceOnlineRepository.deviceOnlineState).thenReturn(DeviceOnlineState.idle);
      deviceOnlineStateStream.add(DeviceOnlineState.idle);
      mockCheckingAgentOnlineRepository = MockCheckingAgentOnlineRepository();
      mockRobotPart = MockRobotPart();
      mockRobot = MockRobot();
      mockViam = MockViam();

      vmNewMachine = BluetoothProvisioningFlowViewModel(
        viam: mockViam,
        robot: mockRobot,
        isNewMachine: true,
        connectBluetoothDeviceRepository: mockConnectBluetoothDeviceRepository,
        checkingDeviceOnlineRepository: mockCheckingDeviceOnlineRepository,
        checkingAgentOnlineRepository: mockCheckingAgentOnlineRepository,
        mainRobotPart: mockRobotPart,
        psk: 'viamsetup',
        fragmentId: null,
        agentMinimumVersion: '0.20.0',
        copy: BluetoothProvisioningFlowCopy(),
        onSuccess: () {},
        existingMachineExit: () {},
        nonexistentMachineExit: () {},
        agentMinimumVersionExit: () {},
      );
      vmExistingMachine = BluetoothProvisioningFlowViewModel(
        viam: mockViam,
        robot: mockRobot,
        isNewMachine: false, // only difference at the moment
        connectBluetoothDeviceRepository: mockConnectBluetoothDeviceRepository,
        checkingDeviceOnlineRepository: mockCheckingDeviceOnlineRepository,
        checkingAgentOnlineRepository: mockCheckingAgentOnlineRepository,
        mainRobotPart: mockRobotPart,
        psk: 'viamsetup',
        fragmentId: null,
        agentMinimumVersion: '0.20.0',
        copy: BluetoothProvisioningFlowCopy(),
        onSuccess: () {},
        existingMachineExit: () {},
        nonexistentMachineExit: () {},
        agentMinimumVersionExit: () {},
      );
    });

    tearDown(() {
      vmNewMachine.dispose();
      vmExistingMachine.dispose();
    });

    test('write config', () async {
      try {
        await vmNewMachine.writeConfig(ssid: 'ssid', password: 'password');
        verify(
          mockConnectBluetoothDeviceRepository.writeConfig(
            viam: mockViam,
            robot: mockRobot,
            mainRobotPart: mockRobotPart,
            ssid: 'ssid',
            password: 'password',
            psk: 'viamsetup',
            fragmentId: null,
            fragmentOverride: true,
          ),
        ).called(1);
      } catch (e) {
        fail('Expected no exception');
      }
    });

    test('agent version below minimum', () async {
      when(mockConnectBluetoothDeviceRepository.isAgentVersionBelowMinimum('0.20.0')).thenAnswer((_) => Future.value(true));
      final result = await vmNewMachine.agentVersionBelowMinimum();
      expect(result, true);
    });

    group('is device connection valid', () {
      test('new machine, not configured, valid', () async {
        when(viamStatusCharacteristic.read()).thenAnswer((_) => Future.value([0])); // not configured, not online
        when(mockConnectBluetoothDeviceRepository.isAgentVersionBelowMinimum('0.20.0')).thenAnswer((_) => Future.value(false));

        final result = await vmNewMachine.isDeviceConnectionValid(null, mockDevice);
        expect(result, true);
      });

      test('minimum version exit, invalid', () async {
        when(viamStatusCharacteristic.read()).thenAnswer((_) => Future.value([0])); // not configured, not online
        when(mockConnectBluetoothDeviceRepository.isAgentVersionBelowMinimum('0.20.0')).thenAnswer((_) => Future.value(true));

        final result = await vmNewMachine.isDeviceConnectionValid(null, mockDevice);
        expect(result, false);
      });

      test('already configured, not able to setup as new', () async {
        when(viamStatusCharacteristic.read()).thenAnswer((_) => Future.value([1])); // configured, not online
        when(mockConnectBluetoothDeviceRepository.isAgentVersionBelowMinimum('0.20.0')).thenAnswer((_) => Future.value(false));

        final result = await vmNewMachine.isDeviceConnectionValid(null, mockDevice);
        expect(result, false);
      });

      test('existing machine, cannot setup as new', () async {
        when(viamStatusCharacteristic.read()).thenAnswer((_) => Future.value([0])); // not configured, not online
        when(mockConnectBluetoothDeviceRepository.isAgentVersionBelowMinimum('0.20.0')).thenAnswer((_) => Future.value(false));

        final result = await vmExistingMachine.isDeviceConnectionValid(null, mockDevice);
        expect(result, false);
      });
    });

    group('on wifi credentials', () {
      test('success', () async {
        when(mockConnectBluetoothDeviceRepository.writeConfig(
                viam: mockViam,
                robot: mockRobot,
                mainRobotPart: mockRobotPart,
                ssid: 'ssid',
                password: 'password',
                psk: 'viamsetup',
                fragmentId: null,
                fragmentOverride: true))
            .thenAnswer((_) => Future.value());
        final result = await vmNewMachine.onWifiCredentials(null, 'ssid', 'password');
        expect(result, true);
      });

      test('failure', () async {
        when(mockConnectBluetoothDeviceRepository.writeConfig(
                viam: mockViam,
                robot: mockRobot,
                mainRobotPart: mockRobotPart,
                ssid: 'ssid',
                password: 'password',
                psk: 'viamsetup',
                fragmentId: null,
                fragmentOverride: true))
            .thenAnswer((_) => Future.error('Error'));
        final result = await vmNewMachine.onWifiCredentials(null, 'ssid', 'password');
        expect(result, false);
      });
    });

    group('unlock bluetooth pairing', () {
      test('success', () async {
        when(mockConnectBluetoothDeviceRepository.unlockPairing(psk: 'viamsetup')).thenAnswer((_) => Future.value());
        final result = await vmNewMachine.unlockBluetoothPairing(null);
        expect(result, true);
      });

      test('failure', () async {
        when(mockConnectBluetoothDeviceRepository.unlockPairing(psk: 'viamsetup')).thenAnswer((_) => Future.error('Error'));
        final result = await vmNewMachine.unlockBluetoothPairing(null);
        expect(result, false);
      });
    });

    group('leading icon', () {
      test('checking', () async {
        deviceOnlineStateStream.add(DeviceOnlineState.checking);
        await pumpEventQueue();
        final result = vmNewMachine.leadingIconButton(() {});
        expect(result, isNull);
      });
      test('success', () async {
        deviceOnlineStateStream.add(DeviceOnlineState.success);
        await pumpEventQueue();
        final result = vmNewMachine.leadingIconButton(() {});
        expect(result!.icon, isA<Icon>().having((i) => i.icon, 'icon', Icons.close).having((i) => i.size, 'size', 24));
      });
      test('idle', () async {
        deviceOnlineStateStream.add(DeviceOnlineState.idle);
        await pumpEventQueue();
        final result = vmNewMachine.leadingIconButton(() {});
        expect(result!.icon, isA<Icon>().having((i) => i.icon, 'icon', Icons.arrow_back).having((i) => i.size, 'size', 24));
      });
      test('error connecting', () async {
        deviceOnlineStateStream.add(DeviceOnlineState.errorConnecting);
        await pumpEventQueue();
        final result = vmNewMachine.leadingIconButton(() {});
        expect(result!.icon, isA<Icon>().having((i) => i.icon, 'icon', Icons.arrow_back).having((i) => i.size, 'size', 24));
      });
    });
  });
}
