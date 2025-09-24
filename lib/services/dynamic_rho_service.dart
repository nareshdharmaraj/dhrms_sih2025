import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_constants.dart';
import '../models/regional_health_officer.dart';
import 'location_service.dart';

/// Service for dynamically fetching RHO assignments from backend
/// This replaces hardcoded RHO mappings with real data from SHO-created RHOs
class DynamicRHOService {
  static String get _baseUrl => '${AppConstants.baseUrl}/rho';

  /// Cache for RHO data to avoid frequent API calls
  static final Map<String, List<RegionalHealthOfficer>> _rhoCache = {};
  static DateTime? _lastCacheUpdate;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  /// Fetch all RHOs from backend (with caching)
  static Future<List<RegionalHealthOfficer>> getAllRHOs() async {
    // Check cache first
    if (_shouldUseCache()) {
      return _getAllRHOsFromCache();
    }

    try {
      print('🔍 Fetching all RHOs from backend via public endpoint...');
      final response = await http.get(
        Uri.parse('$_baseUrl/public'), // Use public endpoint for hospital registration
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['rhos'] != null) {
          final List<RegionalHealthOfficer> rhos = (data['rhos'] as List)
              .map((rho) => RegionalHealthOfficer.fromJson(rho))
              .where((rho) => rho.isActive) // Only active RHOs
              .toList();

          // Update cache
          _updateCache(rhos);
          
          print('🔍 Successfully fetched ${rhos.length} active RHOs from public endpoint');
          return rhos;
        }
      }
      
      print('❌ Failed to fetch RHOs from public endpoint: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Error fetching RHOs from public endpoint: $e');
      return [];
    }
  }

  /// Get RHOs assigned to a specific state and district
  static Future<List<RegionalHealthOfficer>> getRHOsForLocation({
    required String stateName,
    required String districtName,
  }) async {
    // Use direct API call with filters for better performance
    try {
      print('🔍 Fetching RHOs for specific location: $stateName, $districtName');
      final response = await http.get(
        Uri.parse('$_baseUrl/public?state=${Uri.encodeComponent(stateName)}&district=${Uri.encodeComponent(districtName)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['rhos'] != null) {
          final List<RegionalHealthOfficer> rhos = (data['rhos'] as List)
              .map((rho) => RegionalHealthOfficer.fromJson(rho))
              .where((rho) => rho.isActive) // Only active RHOs
              .toList();

          print('✅ Found ${rhos.length} RHOs for $districtName, $stateName');
          return rhos;
        }
      }
      
      print('❌ Failed to fetch RHOs for location: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Error fetching RHOs for location: $e');
      // Fallback to cached/all RHOs with client-side filtering
      final allRHOs = await getAllRHOs();
      
      return allRHOs.where((rho) => 
        rho.assignedState.toLowerCase() == stateName.toLowerCase() &&
        rho.assignedDistrict.toLowerCase() == districtName.toLowerCase()
      ).toList();
    }
  }

  /// Get the best RHO assignment for a specific location
  /// Returns the RHO with the least workload or specific area assignment
  static Future<RegionalHealthOfficer?> getAssignedRHOForLocation({
    required String stateName,
    required String districtName,
    String? subDistrictName,
  }) async {
    final availableRHOs = await getRHOsForLocation(
      stateName: stateName,
      districtName: districtName,
    );

    if (availableRHOs.isEmpty) {
      print('⚠️ No RHOs found for $districtName, $stateName');
      return null;
    }

    // If only one RHO, return it
    if (availableRHOs.length == 1) {
      return availableRHOs.first;
    }

    // For multiple RHOs, try to find area-specific assignment
    if (subDistrictName != null && subDistrictName.isNotEmpty) {
      // Check if any RHO has this sub-district in their assigned areas
      for (final rho in availableRHOs) {
        if (rho.assignedAreas.isNotEmpty) {
          for (final area in rho.assignedAreas) {
            // Check if area name matches or contains the sub-district name
            if (area.name.toLowerCase().contains(subDistrictName.toLowerCase())) {
              print('✅ Found area-specific RHO: ${rho.officerId} for $subDistrictName');
              return rho;
            }
          }
        }
      }
    }

    // If no area-specific match, return the RHO with least workload
    // For now, just return the first one (could be enhanced with workload balancing)
    print('✅ Assigned RHO by availability: ${availableRHOs.first.officerId}');
    return availableRHOs.first;
  }

  /// Get RHO assignment result for location (similar to current LocationService)
  static Future<RHOAssignmentResult> getRHOAssignment({
    required String stateName,
    required String districtName,
    String? subDistrictName,
  }) async {
    final availableRHOs = await getRHOsForLocation(
      stateName: stateName,
      districtName: districtName,
    );

    final assignedRHO = await getAssignedRHOForLocation(
      stateName: stateName,
      districtName: districtName,
      subDistrictName: subDistrictName,
    );

    final isDenseDistrict = availableRHOs.length > 1;
    final requiresSubDistrict = isDenseDistrict && subDistrictName == null;

    return RHOAssignmentResult(
      assignedRHOId: assignedRHO?.officerId,
      availableRHOs: availableRHOs.map((rho) => rho.officerId).toList(),
      isDenselyPopulated: isDenseDistrict,
      requiresSubDistrict: requiresSubDistrict,
      assignedRHO: assignedRHO,
    );
  }

  /// Get a specific RHO by ID
  static Future<RegionalHealthOfficer?> getRHOById(String rhoId) async {
    final allRHOs = await getAllRHOs();
    
    try {
      return allRHOs.firstWhere((rho) => rho.officerId == rhoId);
    } catch (e) {
      print('⚠️ RHO with ID $rhoId not found');
      return null;
    }
  }

  /// Check if a district has multiple RHOs (densely populated)
  static Future<bool> isDistrictDenselyPopulated(String stateName, String districtName) async {
    final rhos = await getRHOsForLocation(
      stateName: stateName,
      districtName: districtName,
    );
    return rhos.length > 1;
  }

  /// Get all available RHO IDs for a district
  static Future<List<String>> getAvailableRHOIds(String stateName, String districtName) async {
    final rhos = await getRHOsForLocation(
      stateName: stateName,
      districtName: districtName,
    );
    return rhos.map((rho) => rho.officerId).toList();
  }

  /// Clear cache (useful for refreshing data)
  static void clearCache() {
    _rhoCache.clear();
    _lastCacheUpdate = null;
    print('🧹 RHO cache cleared');
  }

  /// Refresh RHO data from backend
  static Future<void> refreshRHOData() async {
    clearCache();
    await getAllRHOs();
    print('🔄 RHO data refreshed');
  }

  // Private helper methods

  static bool _shouldUseCache() {
    if (_lastCacheUpdate == null) return false;
    final now = DateTime.now();
    return now.difference(_lastCacheUpdate!) < _cacheTimeout && _rhoCache.isNotEmpty;
  }

  static List<RegionalHealthOfficer> _getAllRHOsFromCache() {
    final allRHOs = <RegionalHealthOfficer>[];
    for (final rhoList in _rhoCache.values) {
      allRHOs.addAll(rhoList);
    }
    print('📋 Using cached RHO data (${allRHOs.length} RHOs)');
    return allRHOs;
  }

  static void _updateCache(List<RegionalHealthOfficer> rhos) {
    _rhoCache.clear();
    
    // Group RHOs by state-district combination
    for (final rho in rhos) {
      final key = '${rho.assignedState}-${rho.assignedDistrict}';
      if (!_rhoCache.containsKey(key)) {
        _rhoCache[key] = [];
      }
      _rhoCache[key]!.add(rho);
    }
    
    _lastCacheUpdate = DateTime.now();
    print('💾 RHO cache updated with ${rhos.length} RHOs');
  }
}