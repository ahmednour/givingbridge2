import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Network status enumeration
enum NetworkStatus {
  connected,
  disconnected,
  unknown,
}

/// Network type enumeration
enum NetworkType {
  wifi,
  mobile,
  ethernet,
  none,
  unknown,
}

/// Network status service for monitoring connectivity
class NetworkStatusService extends ChangeNotifier {
  static final NetworkStatusService _instance =
      NetworkStatusService._internal();
  factory NetworkStatusService() => _instance;
  NetworkStatusService._internal();

  NetworkStatus _status = NetworkStatus.unknown;
  NetworkType _type = NetworkType.unknown;
  bool _isOnline = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _pingTimer;
  String? _lastError;

  /// Current network status
  NetworkStatus get status => _status;

  /// Current network type
  NetworkType get type => _type;

  /// Whether device is online
  bool get isOnline => _isOnline;

  /// Whether device is offline
  bool get isOffline => !_isOnline;

  /// Last network error
  String? get lastError => _lastError;

  /// Initialize the service
  Future<void> initialize() async {
    await _checkInitialConnectivity();
    _startConnectivityMonitoring();
    _startPingMonitoring();
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _pingTimer?.cancel();
    super.dispose();
  }

  /// Check initial connectivity status
  Future<void> _checkInitialConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      await _updateConnectivityStatus([result]);
    } catch (error) {
      _lastError = error.toString();
      _updateStatus(NetworkStatus.disconnected, NetworkType.none, false);
    }
  }

  /// Start monitoring connectivity changes
  void _startConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) => _updateConnectivityStatus([result]),
      onError: (error) {
        _lastError = error.toString();
        _updateStatus(NetworkStatus.disconnected, NetworkType.none, false);
      },
    );
  }

  /// Start ping monitoring for more accurate online status
  void _startPingMonitoring() {
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_status == NetworkStatus.connected) {
        await _pingTest();
      }
    });
  }

  /// Update connectivity status based on results
  Future<void> _updateConnectivityStatus(
      List<ConnectivityResult> results) async {
    if (results.isEmpty) {
      _updateStatus(NetworkStatus.disconnected, NetworkType.none, false);
      return;
    }

    // Check if any connection is available
    final hasConnection = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);

    if (!hasConnection) {
      _updateStatus(NetworkStatus.disconnected, NetworkType.none, false);
      return;
    }

    // Determine network type
    NetworkType networkType = NetworkType.unknown;
    if (results.contains(ConnectivityResult.wifi)) {
      networkType = NetworkType.wifi;
    } else if (results.contains(ConnectivityResult.mobile)) {
      networkType = NetworkType.mobile;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      networkType = NetworkType.ethernet;
    }

    // Perform ping test to verify actual connectivity
    final isActuallyOnline = await _pingTest();
    _updateStatus(
      isActuallyOnline ? NetworkStatus.connected : NetworkStatus.disconnected,
      networkType,
      isActuallyOnline,
    );
  }

  /// Perform ping test to verify actual internet connectivity
  Future<bool> _pingTest() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (error) {
      _lastError = error.toString();
      return false;
    }
  }

  /// Update status and notify listeners
  void _updateStatus(NetworkStatus status, NetworkType type, bool isOnline) {
    final statusChanged = _status != status;
    final typeChanged = _type != type;
    final onlineChanged = _isOnline != isOnline;

    _status = status;
    _type = type;
    _isOnline = isOnline;

    if (statusChanged || typeChanged || onlineChanged) {
      notifyListeners();

      if (kDebugMode) {
        debugPrint('NetworkStatusService: Status changed - '
            'Status: $status, Type: $type, Online: $isOnline');
      }
    }
  }

  /// Force check connectivity
  Future<void> forceCheck() async {
    await _checkInitialConnectivity();
  }

  /// Get network status as string
  String getStatusString() {
    if (!_isOnline) return 'Offline';

    switch (_type) {
      case NetworkType.wifi:
        return 'Connected (WiFi)';
      case NetworkType.mobile:
        return 'Connected (Mobile)';
      case NetworkType.ethernet:
        return 'Connected (Ethernet)';
      case NetworkType.none:
        return 'No Connection';
      case NetworkType.unknown:
        return 'Connected (Unknown)';
    }
  }

  /// Get network type as string
  String getTypeString() {
    switch (_type) {
      case NetworkType.wifi:
        return 'WiFi';
      case NetworkType.mobile:
        return 'Mobile Data';
      case NetworkType.ethernet:
        return 'Ethernet';
      case NetworkType.none:
        return 'No Connection';
      case NetworkType.unknown:
        return 'Unknown';
    }
  }

  /// Check if specific network type is available
  bool hasNetworkType(NetworkType type) {
    return _type == type && _isOnline;
  }

  /// Get connection quality (basic estimation)
  String getConnectionQuality() {
    if (!_isOnline) return 'No Connection';

    switch (_type) {
      case NetworkType.wifi:
        return 'Good';
      case NetworkType.ethernet:
        return 'Excellent';
      case NetworkType.mobile:
        return 'Fair';
      case NetworkType.none:
        return 'No Connection';
      case NetworkType.unknown:
        return 'Unknown';
    }
  }

  /// Get network status summary
  Map<String, dynamic> getStatusSummary() {
    return {
      'status': _status.name,
      'type': _type.name,
      'isOnline': _isOnline,
      'isOffline': !_isOnline,
      'statusString': getStatusString(),
      'typeString': getTypeString(),
      'connectionQuality': getConnectionQuality(),
      'lastError': _lastError,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Network status widget for displaying connectivity information
class NetworkStatusWidget extends StatelessWidget {
  final Widget Function(BuildContext context, NetworkStatusService service)?
      builder;
  final Widget? child;

  const NetworkStatusWidget({
    Key? key,
    this.builder,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NetworkStatusService>(
      create: (_) => NetworkStatusService()..initialize(),
      child: Consumer<NetworkStatusService>(
        builder: (context, service, _) {
          if (builder != null) {
            return builder!(context, service);
          }

          if (child != null) {
            return child!;
          }

          return _DefaultNetworkStatusWidget(service: service);
        },
      ),
    );
  }
}

/// Default network status widget
class _DefaultNetworkStatusWidget extends StatelessWidget {
  final NetworkStatusService service;

  const _DefaultNetworkStatusWidget({required this.service});

  @override
  Widget build(BuildContext context) {
    if (service.isOnline) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange,
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No internet connection',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          TextButton(
            onPressed: () => service.forceCheck(),
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Network status indicator widget
class NetworkStatusIndicator extends StatelessWidget {
  final double size;
  final Color? onlineColor;
  final Color? offlineColor;

  const NetworkStatusIndicator({
    Key? key,
    this.size = 16,
    this.onlineColor,
    this.offlineColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkStatusService>(
      builder: (context, service, _) {
        final color = service.isOnline
            ? (onlineColor ?? Colors.green)
            : (offlineColor ?? Colors.red);

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
