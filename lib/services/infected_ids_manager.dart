import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Manages infected device IDs from backend server
/// Handles fetching, caching, and querying infected IDs
class InfectedIDsManager {
  static final InfectedIDsManager _instance = InfectedIDsManager._internal();
  factory InfectedIDsManager() => _instance;
  InfectedIDsManager._internal();

  // Configuration
  static const String _baseUrl =
      'https://your-api-endpoint.com'; // Replace with actual API
  static const String _infectedIdsEndpoint = '/api/infected-ids';
  static const String _reportInfectionEndpoint = '/api/report-infection';
  static const String _prefsKey = 'cached_infected_ids';
  static const String _lastUpdateKey = 'last_infected_ids_update';
  static const Duration _cacheExpiry = Duration(hours: 1);

  // State
  final Set<String> _infectedIds = {};
  DateTime? _lastUpdate;
  bool _isInitialized = false;
  bool _isFetching = false;

  // Stream for infected IDs updates
  final StreamController<Set<String>> _infectedIdsController =
      StreamController<Set<String>>.broadcast();

  Stream<Set<String>> get infectedIdsStream => _infectedIdsController.stream;

  /// Initialize the manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadCachedInfectedIds();

      // Fetch fresh data if cache is expired
      if (_isCacheExpired()) {
        await fetchInfectedIDs();
      }

      _isInitialized = true;
      debugPrint(
        '✅ InfectedIDsManager initialized with ${_infectedIds.length} cached IDs',
      );
    } catch (e) {
      debugPrint('❌ Failed to initialize InfectedIDsManager: $e');
      _isInitialized = true; // Continue with empty cache
    }
  }

  /// Fetch infected IDs from backend server
  Future<bool> fetchInfectedIDs() async {
    if (_isFetching) return false;

    _isFetching = true;

    try {
      debugPrint('📡 Fetching infected IDs from server...');

      final response = await http
          .get(
            Uri.parse('$_baseUrl$_infectedIdsEndpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<String> newInfectedIds = List<String>.from(
          data['infected_ids'] ?? [],
        );

        await _updateInfectedIds(newInfectedIds);
        debugPrint(
          '✅ Successfully fetched ${newInfectedIds.length} infected IDs',
        );
        return true;
      } else {
        debugPrint('❌ Failed to fetch infected IDs: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error fetching infected IDs: $e');
      return false;
    } finally {
      _isFetching = false;
    }
  }

  /// Update infected IDs list
  Future<void> _updateInfectedIds(List<String> newIds) async {
    final oldCount = _infectedIds.length;
    _infectedIds.clear();
    _infectedIds.addAll(newIds);

    _lastUpdate = DateTime.now();
    await _cacheInfectedIds();

    _infectedIdsController.add(Set.from(_infectedIds));

    debugPrint('📊 Infected IDs updated: $oldCount → ${_infectedIds.length}');
  }

  /// Check if a device ID is infected
  bool isInfected(String deviceId) {
    return _infectedIds.contains(deviceId);
  }

  /// Get all infected IDs
  Set<String> getInfectedIds() {
    return Set.from(_infectedIds);
  }

  /// Get infected IDs count
  int getInfectedCount() {
    return _infectedIds.length;
  }

  /// Report a positive case (device ID becomes infected)
  Future<bool> reportInfection(
    String deviceId, {
    String? healthAuthorityCode,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      debugPrint('📤 Reporting infection for device ID: $deviceId');

      final requestBody = {
        'device_id': deviceId,
        'timestamp': DateTime.now().toIso8601String(),
        'health_authority_code': healthAuthorityCode,
        'metadata': metadata ?? {},
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl$_reportInfectionEndpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Add to local cache immediately
        _infectedIds.add(deviceId);
        await _cacheInfectedIds();
        _infectedIdsController.add(Set.from(_infectedIds));

        debugPrint('✅ Successfully reported infection');
        return true;
      } else {
        debugPrint('❌ Failed to report infection: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error reporting infection: $e');
      return false;
    }
  }

  /// Load cached infected IDs from local storage
  Future<void> _loadCachedInfectedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load cached IDs
      final cachedIds = prefs.getStringList(_prefsKey) ?? [];
      _infectedIds.addAll(cachedIds);

      // Load last update time
      final lastUpdateStr = prefs.getString(_lastUpdateKey);
      if (lastUpdateStr != null) {
        _lastUpdate = DateTime.parse(lastUpdateStr);
      }

      debugPrint('📂 Loaded ${_infectedIds.length} cached infected IDs');
    } catch (e) {
      debugPrint('❌ Error loading cached infected IDs: $e');
    }
  }

  /// Cache infected IDs to local storage
  Future<void> _cacheInfectedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setStringList(_prefsKey, _infectedIds.toList());

      if (_lastUpdate != null) {
        await prefs.setString(_lastUpdateKey, _lastUpdate!.toIso8601String());
      }
    } catch (e) {
      debugPrint('❌ Error caching infected IDs: $e');
    }
  }

  /// Check if cache is expired
  bool _isCacheExpired() {
    if (_lastUpdate == null) return true;
    return DateTime.now().difference(_lastUpdate!) > _cacheExpiry;
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
      await prefs.remove(_lastUpdateKey);

      _infectedIds.clear();
      _lastUpdate = null;

      _infectedIdsController.add(Set.from(_infectedIds));
      debugPrint('🗑️ Cleared infected IDs cache');
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
    }
  }

  /// Get cache status information
  Map<String, dynamic> getCacheStatus() {
    return {
      'infected_count': _infectedIds.length,
      'last_update': _lastUpdate?.toIso8601String(),
      'cache_expired': _isCacheExpired(),
      'is_fetching': _isFetching,
    };
  }

  /// Force refresh from server
  Future<bool> forceRefresh() async {
    _lastUpdate = null; // Force cache expiry
    return await fetchInfectedIDs();
  }

  /// Test connection to backend server
  Future<bool> testConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/health'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Connection test failed: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _infectedIdsController.close();
  }

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isFetching => _isFetching;
  DateTime? get lastUpdate => _lastUpdate;
  int get cachedCount => _infectedIds.length;
}
