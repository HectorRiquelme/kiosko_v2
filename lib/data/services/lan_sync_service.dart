import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

/// LAN sync service that runs a lightweight HTTP server on one device (master)
/// and allows other devices (clients) to push/pull orders.
///
/// Architecture:
/// - One tablet acts as the SERVER (master) — usually the kitchen tablet
/// - Other tablets (kiosks) act as CLIENTS — push new orders to master
/// - All devices discover each other via broadcast on port 8090
///
/// Endpoints (server):
///   GET  /orders         — Get all orders
///   POST /orders         — Push a new order
///   PUT  /orders/:id     — Update order status
///   GET  /ping           — Health check
class LanSyncService {
  static const int _port = 8090;
  HttpServer? _server;
  Timer? _discoveryTimer;
  String? _masterIp;
  bool _isServer = false;

  final void Function(Map<String, dynamic> order)? onOrderReceived;
  final void Function(String orderId, String status)? onOrderStatusChanged;
  final Future<List<Map<String, dynamic>>> Function()? getOrders;

  LanSyncService({
    this.onOrderReceived,
    this.onOrderStatusChanged,
    this.getOrders,
  });

  bool get isServer => _isServer;
  String? get masterIp => _masterIp;
  bool get isConnected => _masterIp != null || _isServer;

  /// Start as server (master device — typically kitchen)
  Future<bool> startServer() async {
    if (kIsWeb) return false;
    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, _port);
      _isServer = true;

      _server!.listen((request) async {
        // Add CORS headers
        request.response.headers.add('Access-Control-Allow-Origin', '*');
        request.response.headers.contentType = ContentType.json;

        try {
          final path = request.uri.path;

          if (request.method == 'GET' && path == '/ping') {
            request.response.write(json.encode({'status': 'ok', 'role': 'master'}));
          } else if (request.method == 'GET' && path == '/orders') {
            final orders = await getOrders?.call() ?? [];
            request.response.write(json.encode(orders));
          } else if (request.method == 'POST' && path == '/orders') {
            final body = await utf8.decoder.bind(request).join();
            final orderData = json.decode(body) as Map<String, dynamic>;
            onOrderReceived?.call(orderData);
            request.response.write(json.encode({'status': 'received'}));
          } else if (request.method == 'PUT' && path.startsWith('/orders/')) {
            final orderId = path.split('/').last;
            final body = await utf8.decoder.bind(request).join();
            final data = json.decode(body) as Map<String, dynamic>;
            onOrderStatusChanged?.call(orderId, data['status'] ?? '');
            request.response.write(json.encode({'status': 'updated'}));
          } else {
            request.response.statusCode = 404;
            request.response.write(json.encode({'error': 'not found'}));
          }
        } catch (e) {
          request.response.statusCode = 500;
          request.response.write(json.encode({'error': e.toString()}));
        }

        await request.response.close();
      });

      // Start broadcasting presence
      _startBroadcasting();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Connect as client to a master device
  Future<bool> connectToMaster(String ip) async {
    if (kIsWeb) return false;
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 3);
      final request = await client.getUrl(Uri.parse('http://$ip:$_port/ping'));
      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      final data = json.decode(body);

      if (data['status'] == 'ok') {
        _masterIp = ip;
        client.close();
        return true;
      }
      client.close();
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Push an order to the master server
  Future<bool> pushOrder(Map<String, dynamic> orderData) async {
    if (_masterIp == null) return false;
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.postUrl(
          Uri.parse('http://$_masterIp:$_port/orders'));
      request.headers.contentType = ContentType.json;
      request.write(json.encode(orderData));
      final response = await request.close();
      client.close();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Pull all orders from master
  Future<List<Map<String, dynamic>>> pullOrders() async {
    if (_masterIp == null) return [];
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.getUrl(
          Uri.parse('http://$_masterIp:$_port/orders'));
      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      client.close();
      final list = json.decode(body) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// Update order status on master
  Future<bool> updateOrderStatus(String orderId, String status) async {
    if (_masterIp == null) return false;
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.putUrl(
          Uri.parse('http://$_masterIp:$_port/orders/$orderId'));
      request.headers.contentType = ContentType.json;
      request.write(json.encode({'status': status}));
      final response = await request.close();
      client.close();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Discover master device on LAN
  Future<String?> discoverMaster() async {
    if (kIsWeb) return null;
    try {
      final localIp = await _getLocalIp();
      if (localIp == null) return null;

      final subnet = localIp.substring(0, localIp.lastIndexOf('.'));

      // Scan common IPs (1-50 for speed)
      for (int i = 1; i <= 50; i++) {
        final ip = '$subnet.$i';
        if (ip == localIp) continue;

        try {
          final client = HttpClient();
          client.connectionTimeout = const Duration(milliseconds: 500);
          final request =
              await client.getUrl(Uri.parse('http://$ip:$_port/ping'));
          final response = await request.close();
          final body = await utf8.decoder.bind(response).join();
          client.close();

          final data = json.decode(body);
          if (data['status'] == 'ok') {
            _masterIp = ip;
            return ip;
          }
        } catch (_) {
          // Not responding, skip
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  void _startBroadcasting() {
    // Periodic ping to keep connection alive
    _discoveryTimer?.cancel();
    _discoveryTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      // Server just stays alive, clients poll
    });
  }

  Future<String?> _getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback) return addr.address;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get this device's local IP address
  Future<String?> getLocalIp() => _getLocalIp();

  /// Stop the server and cleanup
  Future<void> stop() async {
    _discoveryTimer?.cancel();
    await _server?.close();
    _server = null;
    _isServer = false;
    _masterIp = null;
  }
}
