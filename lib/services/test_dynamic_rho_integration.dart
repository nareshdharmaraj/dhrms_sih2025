import 'dart:developer' as developer;
import 'location_service.dart';
import 'dynamic_rho_service.dart';

/// Test file to verify dynamic RHO integration
/// This file demonstrates the difference between static and dynamic RHO assignment
class DynamicRHOIntegrationTest {
  
  /// Test both static and dynamic RHO assignment for comparison
  static Future<void> testRHOAssignmentComparison() async {
    const testState = 'Kerala';
    const testDistrict = 'Thiruvananthapuram';
    
    developer.log('Testing RHO assignment for $testState, $testDistrict');
    
    try {
      // Test static assignment (legacy)
      final staticResult = await LocationService.getRHOAssignment(
        stateName: testState,
        districtName: testDistrict,
      );
      
      developer.log('Static Assignment:');
      developer.log('  - Assigned RHO ID: ${staticResult.assignedRHOId}');
      developer.log('  - Available RHOs: ${staticResult.availableRHOs.length}');
      developer.log('  - Is Dense: ${staticResult.isDenselyPopulated}');
      developer.log('  - Actual RHO Object: ${staticResult.assignedRHO}');
      
      // Test dynamic assignment (new)
      final dynamicResult = await LocationService.getDynamicRHOAssignment(
        stateName: testState,
        districtName: testDistrict,
      );
      
      developer.log('Dynamic Assignment:');
      developer.log('  - Assigned RHO ID: ${dynamicResult.assignedRHOId}');
      developer.log('  - Available RHOs: ${dynamicResult.availableRHOs.length}');
      developer.log('  - Is Dense: ${dynamicResult.isDenselyPopulated}');
      developer.log('  - Actual RHO Object: ${dynamicResult.assignedRHO?.toString()}');
      
    } catch (e) {
      developer.log('Error testing RHO assignment: $e');
    }
  }
  
  /// Test RHO data fetching directly from dynamic service
  static Future<void> testDynamicServiceDirectly() async {
    developer.log('Testing DynamicRHOService directly...');
    
    try {
      // Test getting all RHOs
      final allRHOs = await DynamicRHOService.getAllRHOs();
      developer.log('Total RHOs in system: ${allRHOs.length}');
      
      // Test getting RHOs for specific location
      final keralaRHOs = await DynamicRHOService.getRHOsForLocation(
        stateName: 'Kerala',
        districtName: 'Thiruvananthapuram',
      );
      developer.log('RHOs available for Kerala-Thiruvananthapuram: ${keralaRHOs.length}');
      
      // Test getting assigned RHO
      final assignedRHO = await DynamicRHOService.getAssignedRHOForLocation(
        stateName: 'Kerala',
        districtName: 'Thiruvananthapuram',
      );
      developer.log('Assigned RHO: ${assignedRHO?.fullName ?? 'None'}');
      
    } catch (e) {
      developer.log('Error testing DynamicRHOService: $e');
    }
  }
}

/// Example usage (can be called from main.dart or debugging)
/// 
/// To test the integration:
/// ```dart
/// await DynamicRHOIntegrationTest.testRHOAssignmentComparison();
/// await DynamicRHOIntegrationTest.testDynamicServiceDirectly();
/// ```