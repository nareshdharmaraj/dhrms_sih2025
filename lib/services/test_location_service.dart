import 'dart:developer' as developer;
import '../data/indian_states_districts_data.dart';
import '../services/location_service.dart';

/// Quick test to verify that the location service is working correctly
/// and that states/districts are loading properly for hospital registration
class LocationServiceTest {
  
  /// Test if states are loading correctly
  static Future<void> testStatesLoading() async {
    developer.log('🧪 Testing LocationService.getStates()...');
    
    try {
      // Test the service method
      final states = await LocationService.getStates();
      developer.log('✅ Successfully loaded ${states.length} states');
      developer.log('📋 First 10 states: ${states.take(10).toList()}');
      
      // Test if Kerala is present
      final hasKerala = states.contains('Kerala');
      developer.log('🔍 Kerala present: $hasKerala');
      
      // Test if Maharashtra is present
      final hasMaharashtra = states.contains('Maharashtra');
      developer.log('🔍 Maharashtra present: $hasMaharashtra');
      
      if (states.isEmpty) {
        developer.log('❌ ERROR: No states loaded!');
      } else {
        developer.log('✅ States loading test PASSED');
      }
      
    } catch (e) {
      developer.log('❌ ERROR loading states: $e');
    }
  }
  
  /// Test if districts are loading correctly for a specific state
  static Future<void> testDistrictsLoading() async {
    developer.log('🧪 Testing LocationService.getDistricts()...');
    
    try {
      // Test Kerala districts
      final keralaDistricts = await LocationService.getDistricts('Kerala');
      developer.log('✅ Kerala has ${keralaDistricts.length} districts');
      developer.log('📋 Kerala districts: ${keralaDistricts.take(5).toList()}');
      
      // Test Maharashtra districts
      final maharashtraDistricts = await LocationService.getDistricts('Maharashtra');
      developer.log('✅ Maharashtra has ${maharashtraDistricts.length} districts');
      developer.log('📋 Maharashtra districts: ${maharashtraDistricts.take(5).toList()}');
      
      if (keralaDistricts.isEmpty && maharashtraDistricts.isEmpty) {
        developer.log('❌ ERROR: No districts loaded!');
      } else {
        developer.log('✅ Districts loading test PASSED');
      }
      
    } catch (e) {
      developer.log('❌ ERROR loading districts: $e');
    }
  }
  
  /// Test the static data directly
  static void testStaticData() {
    developer.log('🧪 Testing IndianStatesDistrictsData directly...');
    
    try {
      final stateNames = IndianStatesDistrictsData.stateNames;
      developer.log('✅ Static data has ${stateNames.length} states');
      developer.log('📋 All states: $stateNames');
      
      final keralaDistricts = IndianStatesDistrictsData.getDistrictNamesForState('Kerala');
      developer.log('✅ Kerala districts from static data: $keralaDistricts');
      
      if (stateNames.isEmpty) {
        developer.log('❌ ERROR: Static states data is empty!');
      } else {
        developer.log('✅ Static data test PASSED');
      }
      
    } catch (e) {
      developer.log('❌ ERROR accessing static data: $e');
    }
  }
  
  /// Run all tests
  static Future<void> runAllTests() async {
    developer.log('🚀 Starting LocationService tests...');
    
    testStaticData();
    await testStatesLoading();
    await testDistrictsLoading();
    
    developer.log('🏁 LocationService tests completed');
  }
}

/// Example usage (can be called from main.dart or debugging)
/// 
/// To test the location service:
/// ```dart
/// await LocationServiceTest.runAllTests();
/// ```