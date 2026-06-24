import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import 'admin_shell.dart';

// ─────────────────────────────────────────────────────────────
// Admin Networking Screen
// Live Firebase connection status, Firestore read/write ping,
// Auth session info, and request log.
// ─────────────────────────────────────────────────────────────
class AdminNetworkingScreen extends StatefulWidget {
  const AdminNetworkingScreen({super.key});

  @override
  State<AdminNetworkingScreen> createState() => _AdminNetworkingScreenState();
}

class _AdminNetworkingScreenState extends State<AdminNetworkingScreen> {
  // ── Status ───────────────────────────────────────────────
  bool _firestoreConnected = false;
  bool _authConnected = false;
  int? _firestorePingMs;
  int? _authPingMs;
  bool _pinging = false;

  final List<_RequestLog> _logs = [];
  int _totalReads = 0;
  int _totalWrites = 0;
  int _failedRequests = 0;

  // ── Firebase config ──────────────────────────────────────
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  StreamSubscription<ConnectivityStatus>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    _runPing();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  Future<void> _runPing() async {
    setState(() => _pinging = true);

    // ── Firestore ping ────────────────────────────────────
    final fsStart = DateTime.now();
    try {
      await _firestore.collection('_ping').limit(1).get(
            const GetOptions(source: Source.server),
          );
      final fsMs =
          DateTime.now().difference(fsStart).inMilliseconds;
      _addLog(_RequestLog(
        type: 'GET',
        endpoint: 'firestore/_ping',
        status: 200,
        ms: fsMs,
        success: true,
      ));
      setState(() {
        _firestoreConnected = true;
        _firestorePingMs = fsMs;
        _totalReads++;
      });
    } catch (e) {
      final fsMs =
          DateTime.now().difference(fsStart).inMilliseconds;
      _addLog(_RequestLog(
        type: 'GET',
        endpoint: 'firestore/_ping',
        status: 503,
        ms: fsMs,
        success: false,
        error: e.toString().split(']').last.trim(),
      ));
      setState(() {
        _firestoreConnected = false;
        _firestorePingMs = null;
        _failedRequests++;
      });
    }

    // ── Auth ping ─────────────────────────────────────────
    final authStart = DateTime.now();
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.getIdToken(false);
      }
      final authMs =
          DateTime.now().difference(authStart).inMilliseconds;
      _addLog(_RequestLog(
        type: 'GET',
        endpoint: 'firebase_auth/id_token',
        status: 200,
        ms: authMs,
        success: true,
      ));
      setState(() {
        _authConnected = true;
        _authPingMs = authMs;
        _totalReads++;
      });
    } catch (e) {
      final authMs =
          DateTime.now().difference(authStart).inMilliseconds;
      _addLog(_RequestLog(
        type: 'GET',
        endpoint: 'firebase_auth/id_token',
        status: 401,
        ms: authMs,
        success: false,
        error: e.toString().split(']').last.trim(),
      ));
      setState(() {
        _authConnected = false;
        _authPingMs = null;
        _failedRequests++;
      });
    }

    setState(() => _pinging = false);
  }

  Future<void> _runWritePing() async {
    setState(() => _pinging = true);
    final start = DateTime.now();
    final testDoc = _firestore
        .collection('_admin_ping')
        .doc('test_write');
    try {
      await testDoc.set({
        'ts': FieldValue.serverTimestamp(),
        'by': _auth.currentUser?.uid ?? 'unknown',
      });
      await testDoc.delete();
      final ms = DateTime.now().difference(start).inMilliseconds;
      _addLog(_RequestLog(
        type: 'WRITE',
        endpoint: 'firestore/_admin_ping/test_write',
        status: 200,
        ms: ms,
        success: true,
      ));
      setState(() => _totalWrites++);
    } catch (e) {
      final ms = DateTime.now().difference(start).inMilliseconds;
      _addLog(_RequestLog(
        type: 'WRITE',
        endpoint: 'firestore/_admin_ping/test_write',
        status: 403,
        ms: ms,
        success: false,
        error: e.toString().split(']').last.trim(),
      ));
      setState(() => _failedRequests++);
    }
    setState(() => _pinging = false);
  }

  void _addLog(_RequestLog log) {
    setState(() {
      _logs.insert(0, log);
      if (_logs.length > 50) _logs.removeLast();
    });
  }

  void _clearLogs() => setState(() => _logs.clear());

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AdminAppBar(
        title: '📡 Networking',
        actions: [
          IconButton(
            icon: _pinging
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _pinging ? null : _runPing,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Connection Status ────────────────────────────
          _SectionTitle(title: 'Connection Status'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _StatusCard(
                  icon: Icons.storage_rounded,
                  label: 'Firestore',
                  connected: _firestoreConnected,
                  pingMs: _firestorePingMs,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatusCard(
                  icon: Icons.verified_user_rounded,
                  label: 'Firebase Auth',
                  connected: _authConnected,
                  pingMs: _authPingMs,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Config ──────────────────────────────────────
          _SectionTitle(title: 'Firebase Configuration'),
          const SizedBox(height: 8),
          _ConfigCard(entries: [
            _ConfigEntry('Project', 'mega-mart-app (from firebase_options.dart)'),
            _ConfigEntry('Auth Domain', 'mega-mart-app.firebaseapp.com'),
            _ConfigEntry('Storage Bucket', 'mega-mart-app.appspot.com'),
            _ConfigEntry('Platform', _platform()),
            _ConfigEntry('SDK', 'firebase_core ^3.6.0'),
          ]),

          const SizedBox(height: 16),

          // ── Auth Session ────────────────────────────────
          _SectionTitle(title: 'Current Auth Session'),
          const SizedBox(height: 8),
          _ConfigCard(entries: [
            _ConfigEntry('Status',
                user != null ? '✅ Authenticated' : '❌ Not signed in'),
            if (user != null) ...[
              _ConfigEntry('UID', user.uid),
              _ConfigEntry('Email', user.email ?? '-'),
              _ConfigEntry('Provider',
                  user.providerData.map((p) => p.providerId).join(', ')),
              _ConfigEntry('Email Verified', '${user.emailVerified}'),
              _ConfigEntry('Created',
                  user.metadata.creationTime?.toLocal().toString() ?? '-'),
              _ConfigEntry('Last Sign In',
                  user.metadata.lastSignInTime?.toLocal().toString() ?? '-'),
            ],
          ]),

          const SizedBox(height: 16),

          // ── Request Stats ────────────────────────────────
          _SectionTitle(title: 'Session Request Stats'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _StatTile(
                      label: 'Reads',
                      value: '$_totalReads',
                      color: AppTheme.primary)),
              const SizedBox(width: 8),
              Expanded(
                  child: _StatTile(
                      label: 'Writes',
                      value: '$_totalWrites',
                      color: AppTheme.success)),
              const SizedBox(width: 8),
              Expanded(
                  child: _StatTile(
                      label: 'Failed',
                      value: '$_failedRequests',
                      color: AppTheme.error)),
            ],
          ),

          const SizedBox(height: 16),

          // ── Actions ──────────────────────────────────────
          _SectionTitle(title: 'Manual Tests'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pinging ? null : _runPing,
                  icon: const Icon(Icons.wifi_rounded, size: 16),
                  label: const Text('Read Ping'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: BorderSide(color: AppTheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pinging ? null : _runWritePing,
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Write Ping'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accent,
                    side: BorderSide(color: AppTheme.accent),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Request Log ──────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionTitle(title: 'Request Log (${_logs.length})'),
              if (_logs.isNotEmpty)
                TextButton.icon(
                  onPressed: _clearLogs,
                  icon: const Icon(Icons.delete_outline_rounded, size: 14),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textLight,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_logs.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
              child: const Center(
                child: Text(
                  'No requests yet. Hit a ping button above.',
                  style: TextStyle(color: AppTheme.textHint, fontSize: 13),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                children: _logs
                    .asMap()
                    .entries
                    .map((e) => _LogRow(
                          log: e.value,
                          isLast: e.key == _logs.length - 1,
                        ))
                    .toList(),
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _platform() {
    try {
      // kIsWeb equivalent without import
      return 'Web (Flutter)';
    } catch (_) {
      return 'Mobile';
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────
class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool connected;
  final int? pingMs;

  const _StatusCard({
    required this.icon,
    required this.label,
    required this.connected,
    this.pingMs,
  });

  @override
  Widget build(BuildContext context) {
    final color = connected ? AppTheme.success : AppTheme.error;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            connected
                ? (pingMs != null ? '${pingMs}ms' : 'Connected')
                : 'Unreachable',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigCard extends StatelessWidget {
  final List<_ConfigEntry> entries;

  const _ConfigCard({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: entries
            .asMap()
            .entries
            .map((e) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(
                              e.value.label,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onLongPress: () => Clipboard.setData(
                                  ClipboardData(text: e.value.value)),
                              child: Text(
                                e.value.value,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (e.key != entries.length - 1)
                      const Divider(height: 1, color: AppTheme.divider),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  final _RequestLog log;
  final bool isLast;

  const _LogRow({required this.log, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final color = log.success ? AppTheme.success : AppTheme.error;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              // Type badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (log.type == 'WRITE'
                          ? AppTheme.accent
                          : AppTheme.primary)
                      .withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  log.type,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: log.type == 'WRITE'
                        ? AppTheme.accent
                        : AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Endpoint
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.endpoint,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: AppTheme.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (log.error != null)
                      Text(
                        log.error!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.error,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Status + timing
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${log.status}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    '${log.ms}ms',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, color: AppTheme.divider),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppTheme.textDark,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Data classes
// ─────────────────────────────────────────────────────────────
class _RequestLog {
  final String type;
  final String endpoint;
  final int status;
  final int ms;
  final bool success;
  final String? error;
  final DateTime time;

  _RequestLog({
    required this.type,
    required this.endpoint,
    required this.status,
    required this.ms,
    required this.success,
    this.error,
  }) : time = DateTime.now();
}

class _ConfigEntry {
  final String label;
  final String value;

  const _ConfigEntry(this.label, this.value);
}

enum ConnectivityStatus { connected, disconnected }
