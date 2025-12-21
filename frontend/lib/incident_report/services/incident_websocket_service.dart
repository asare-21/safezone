import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:safe_zone/map/models/incident_model.dart';
import 'package:latlong2/latlong.dart';

/// Service for managing real-time incident updates via WebSocket
class IncidentWebSocketService {
  IncidentWebSocketService({
    required this.baseUrl,
  });

  final String baseUrl;
  WebSocketChannel? _channel;
  StreamController<Incident>? _incidentController;
  Timer? _reconnectTimer;
  bool _isDisposed = false;
  bool _isConnecting = false;

  /// Stream of new incidents received in real-time
  Stream<Incident> get incidentStream {
    _incidentController ??= StreamController<Incident>.broadcast();
    return _incidentController!.stream;
  }

  /// Connect to the WebSocket server
  void connect() {
    if (_isDisposed || _isConnecting) return;
    
    _isConnecting = true;
    
    try {
      // Convert HTTP URL to WebSocket URL
      final wsUrl = baseUrl
          .replaceFirst('http://', 'ws://')
          .replaceFirst('https://', 'wss://');
      
      final uri = Uri.parse('$wsUrl/ws/incidents/');
      
      debugPrint('Connecting to WebSocket: $uri');
      
      _channel = WebSocketChannel.connect(uri);
      
      // Listen to messages from the WebSocket
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: false,
      );
      
      _isConnecting = false;
      debugPrint('WebSocket connected successfully');
    } catch (e) {
      _isConnecting = false;
      debugPrint('Failed to connect to WebSocket: $e');
      _scheduleReconnect();
    }
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    try {
      final data = json.decode(message as String) as Map<String, dynamic>;
      
      if (data['type'] == 'incident_update') {
        final incidentData = data['incident'] as Map<String, dynamic>;
        final incident = _incidentFromJson(incidentData);
        
        // Emit the new incident to the stream
        _incidentController?.add(incident);
        
        debugPrint('Received incident update: ${incident.title}');
      }
    } catch (e) {
      debugPrint('Error parsing WebSocket message: $e');
    }
  }

  /// Handle WebSocket errors
  void _handleError(Object error) {
    debugPrint('WebSocket error: $error');
    _scheduleReconnect();
  }

  /// Handle WebSocket connection closure
  void _handleDone() {
    debugPrint('WebSocket connection closed');
    _scheduleReconnect();
  }

  /// Schedule a reconnection attempt
  void _scheduleReconnect() {
    if (_isDisposed) return;
    
    // Cancel existing timer if any
    _reconnectTimer?.cancel();
    
    // Try to reconnect after 5 seconds with exponential backoff up to 30 seconds
    const baseDelay = Duration(seconds: 5);
    const maxDelay = Duration(seconds: 30);
    
    final delay = baseDelay; // Simple fixed delay for now
    
    _reconnectTimer = Timer(delay, () {
      if (!_isDisposed) {
        debugPrint('Attempting to reconnect to WebSocket...');
        connect();
      }
    });
  }

  /// Convert JSON to Incident model
  Incident _incidentFromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'].toString(),
      category: _categoryFromString(json['category'] as String),
      location: LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      confirmedBy: json['confirmed_by'] as int? ?? 1,
      notifyNearby: json['notify_nearby'] as bool? ?? false,
    );
  }

  /// Convert string to IncidentCategory enum
  IncidentCategory _categoryFromString(String category) {
    switch (category) {
      case 'accident':
        return IncidentCategory.accident;
      case 'fire':
        return IncidentCategory.fire;
      case 'theft':
        return IncidentCategory.theft;
      case 'suspicious':
        return IncidentCategory.suspicious;
      case 'lighting':
        return IncidentCategory.lighting;
      case 'assault':
        return IncidentCategory.assault;
      case 'vandalism':
        return IncidentCategory.vandalism;
      case 'harassment':
        return IncidentCategory.harassment;
      case 'roadHazard':
        return IncidentCategory.roadHazard;
      case 'animalDanger':
        return IncidentCategory.animalDanger;
      case 'medicalEmergency':
        return IncidentCategory.medicalEmergency;
      case 'naturalDisaster':
        return IncidentCategory.naturalDisaster;
      case 'powerOutage':
        return IncidentCategory.powerOutage;
      case 'waterIssue':
        return IncidentCategory.waterIssue;
      case 'noise':
        return IncidentCategory.noise;
      case 'trespassing':
        return IncidentCategory.trespassing;
      case 'drugActivity':
        return IncidentCategory.drugActivity;
      case 'weaponSighting':
        return IncidentCategory.weaponSighting;
      default:
        // Log unrecognized category and return suspicious as fallback
        // This maintains compatibility with existing data while alerting developers
        debugPrint('WARNING: Unknown incident category "$category", using suspicious as fallback');
        return IncidentCategory.suspicious;
    }
  }

  /// Disconnect from the WebSocket server
  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _channel?.sink.close();
    _channel = null;
  }

  /// Dispose of the service and clean up resources
  void dispose() {
    _isDisposed = true;
    disconnect();
    _incidentController?.close();
    _incidentController = null;
  }
}
