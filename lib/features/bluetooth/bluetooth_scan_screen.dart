import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/bluetooth_service.dart';
import '../../core/utils/app_notify.dart';

/// "Nearby Devices" — scans for nearby Bluetooth Low Energy devices and
/// lists them by signal strength (Week 11 device connectivity feature).
class BluetoothScanScreen extends StatefulWidget {
  const BluetoothScanScreen({super.key});

  @override
  State<BluetoothScanScreen> createState() => _BluetoothScanScreenState();
}

class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
  List<BleDevice> _devices = [];
  bool _scanning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (BluetoothService.isSupported) {
      _startScan();
    } else {
      _error = "Bluetooth scanning isn't available in a web browser — "
          'try this on the Android app.';
    }
  }

  @override
  void dispose() {
    BluetoothService.stopScan();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _scanning = true;
      _error = null;
      _devices = [];
    });

    BluetoothService.scan().listen(
      (devices) {
        if (mounted) setState(() => _devices = devices);
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            _error = e.toString();
            _scanning = false;
          });
        }
      },
      onDone: () {
        if (mounted) setState(() => _scanning = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Nearby Devices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _scanning || !BluetoothService.isSupported
                ? null
                : _startScan,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: Row(
              children: [
                Icon(
                  _scanning
                      ? Icons.bluetooth_searching_rounded
                      : Icons.bluetooth_rounded,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _scanning
                        ? 'Scanning for nearby Bluetooth devices…'
                        : 'Scan complete — found ${_devices.length} device'
                            '${_devices.length == 1 ? '' : 's'}.',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ),
                if (_scanning)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppTheme.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _devices.isEmpty && !_scanning && _error == null
                ? const Center(
                    child: Text(
                      'No devices found nearby.',
                      style: TextStyle(color: AppTheme.textLight),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _devices.length,
                    itemBuilder: (context, i) {
                      final d = _devices[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: AppTheme.cardDecoration(),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSM),
                            ),
                            child: const Icon(Icons.devices_other_rounded,
                                color: AppTheme.primary, size: 20),
                          ),
                          title: Text(
                            d.name,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${d.signalLabel} · ${d.rssi} dBm',
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textLight),
                          ),
                          onTap: () => AppNotify.info(
                            context,
                            'Found ${d.name} — pairing isn\'t needed for '
                            'this demo.',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
