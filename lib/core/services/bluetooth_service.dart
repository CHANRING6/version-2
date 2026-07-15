import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// A single nearby BLE device found during a scan.
class BleDevice {
  final String id;
  final String name;
  final int rssi;

  const BleDevice({required this.id, required this.name, required this.rssi});

  /// Rough human-readable proximity based on signal strength.
  String get signalLabel {
    if (rssi >= -60) return 'Very close';
    if (rssi >= -75) return 'Nearby';
    return 'Far';
  }
}

/// Thin wrapper around flutter_blue_plus for scanning nearby Bluetooth
/// Low Energy devices — used for the "Nearby Devices" feature (Week 11
/// device connectivity). Bluetooth hardware isn't exposed to browsers,
/// so this service is a no-op on web.
class BluetoothService {
  /// Whether Bluetooth scanning is even possible on this platform.
  static bool get isSupported => !kIsWeb;

  /// Requests the runtime permissions Android 12+ needs for BLE scanning.
  /// Returns true if scanning can proceed.
  static Future<bool> requestPermissions() async {
    if (!isSupported) return false;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();
      return statuses.values.every((s) => s.isGranted || s.isLimited);
    }
    // iOS asks for Bluetooth permission automatically on first scan.
    return true;
  }

  /// True if the device's Bluetooth adapter is currently powered on.
  static Future<bool> isOn() async {
    if (!isSupported) return false;
    try {
      return await FlutterBluePlus.adapterState.first
          .timeout(const Duration(seconds: 2))
          .then((s) => s == BluetoothAdapterState.on);
    } catch (_) {
      return false;
    }
  }

  /// Scans for nearby BLE devices for [duration], streaming de-duplicated,
  /// signal-sorted results as they're found.
  static Stream<List<BleDevice>> scan({
    Duration duration = const Duration(seconds: 8),
  }) {
    final controller = StreamController<List<BleDevice>>();
    final found = <String, BleDevice>{};

    () async {
      if (!isSupported) {
        controller.addError(
            BluetoothServiceException('Bluetooth isn\'t available on web.'));
        await controller.close();
        return;
      }

      final granted = await requestPermissions();
      if (!granted) {
        controller.addError(BluetoothServiceException(
            'Bluetooth & location permissions are needed to scan for nearby devices.'));
        await controller.close();
        return;
      }

      if (!await isOn()) {
        controller.addError(
            BluetoothServiceException('Please turn on Bluetooth and try again.'));
        await controller.close();
        return;
      }

      final sub = FlutterBluePlus.onScanResults.listen((results) {
        for (final r in results) {
          final name = r.device.platformName.isNotEmpty
              ? r.device.platformName
              : (r.advertisementData.advName.isNotEmpty
                  ? r.advertisementData.advName
                  : 'Unknown device');
          found[r.device.remoteId.str] = BleDevice(
            id: r.device.remoteId.str,
            name: name,
            rssi: r.rssi,
          );
        }
        final list = found.values.toList()
          ..sort((a, b) => b.rssi.compareTo(a.rssi));
        if (!controller.isClosed) controller.add(list);
      }, onError: (_) {});

      try {
        await FlutterBluePlus.startScan(timeout: duration);
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(
              BluetoothServiceException('Could not start Bluetooth scan.'));
        }
      }

      await Future.delayed(duration);
      await sub.cancel();
      await controller.close();
    }();

    return controller.stream;
  }

  static Future<void> stopScan() async {
    if (!isSupported) return;
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {
      // Ignore — scan may already have finished.
    }
  }
}

class BluetoothServiceException implements Exception {
  final String message;
  BluetoothServiceException(this.message);
  @override
  String toString() => message;
}
