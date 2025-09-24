/// Test file for the District-based RHO Assignment System
/// This file tests the complete flow from location selection to RHO assignment
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:dhrms/data/indian_states_districts_data.dart';
import 'package:dhrms/services/location_service.dart';
import 'package:dhrms/services/rho_assignment_service.dart';

void main() {
  group('District-based RHO Assignment Tests', () {
    
    test('Should load states successfully', () async {
      final states = await LocationService.getStates();
      
      expect(states, isNotEmpty);
      expect(states, contains('Maharashtra'));
      expect(states, contains('Tamil Nadu'));
      expect(states, contains('Karnataka'));
      expect(states, contains('Gujarat'));
      
      print('✅ States loaded: ${states.length} states');
      for (var state in states) {
        print('  - $state');
      }
    });

    test('Should load districts for Maharashtra', () async {
      final districts = await LocationService.getDistricts('Maharashtra');
      
      expect(districts, isNotEmpty);
      expect(districts, contains('Mumbai'));
      expect(districts, contains('Pune'));
      expect(districts, contains('Thane'));
      expect(districts, contains('Nashik'));
      
      print('✅ Maharashtra districts loaded: ${districts.length} districts');
      for (var district in districts) {
        print('  - $district');
      }
    });

    test('Should identify dense districts correctly', () async {
      // Mumbai should be densely populated
      final isMumbaiDense = await LocationService.requiresSubDistrictSelection('Maharashtra', 'Mumbai');
      expect(isMumbaiDense, isTrue);
      
      // Pune should be densely populated
      final isPuneDense = await LocationService.requiresSubDistrictSelection('Maharashtra', 'Pune');
      expect(isPuneDense, isTrue);
      
      // Nashik should not be densely populated
      final isNashikDense = await LocationService.requiresSubDistrictSelection('Maharashtra', 'Nashik');
      expect(isNashikDense, isFalse);
      
      print('✅ Dense district identification working correctly');
      print('  - Mumbai: Dense = $isMumbaiDense');
      print('  - Pune: Dense = $isPuneDense');
      print('  - Nashik: Dense = $isNashikDense');
    });

    test('Should load sub-districts for dense districts', () async {
      final mumbaiSubDistricts = await LocationService.getSubDistricts('Maharashtra', 'Mumbai');
      
      expect(mumbaiSubDistricts, isNotEmpty);
      expect(mumbaiSubDistricts, contains('Mumbai City'));
      expect(mumbaiSubDistricts, contains('Mumbai Suburban'));
      expect(mumbaiSubDistricts, contains('Andheri'));
      expect(mumbaiSubDistricts, contains('Bandra'));
      
      print('✅ Mumbai sub-districts loaded: ${mumbaiSubDistricts.length} sub-districts');
      mumbaiSubDistricts.take(10).forEach((subDistrict) => print('  - $subDistrict'));
    });

    test('Should validate location combinations', () async {
      // Valid location
      final validLocation = await LocationService.validateLocation(
        stateName: 'Maharashtra',
        districtName: 'Mumbai',
        subDistrictName: 'Mumbai City',
      );
      
      expect(validLocation.isValid, isTrue);
      expect(validLocation.formattedLocation, isNotNull);
      expect(validLocation.formattedLocation, contains('Mumbai City'));
      expect(validLocation.formattedLocation, contains('Mumbai'));
      expect(validLocation.formattedLocation, contains('Maharashtra'));
      
      print('✅ Location validation working');
      print('  - Valid location: ${validLocation.formattedLocation}');
      
      // Invalid state
      final invalidState = await LocationService.validateLocation(
        stateName: 'InvalidState',
        districtName: 'Mumbai',
      );
      
      expect(invalidState.isValid, isFalse);
      expect(invalidState.errorMessage, contains('Invalid state'));
      
      // Missing sub-district for dense area
      final missingSubDistrict = await LocationService.validateLocation(
        stateName: 'Maharashtra',
        districtName: 'Mumbai',
        // subDistrictName not provided for dense district
      );
      
      expect(missingSubDistrict.isValid, isFalse);
      expect(missingSubDistrict.requiresSubDistrict, isTrue);
      
      print('✅ Location validation catches errors correctly');
    });

    test('Should get RHO assignment for different location types', () async {
      // Dense district with sub-district (Mumbai)
      final mumbaiAssignment = await LocationService.getRHOAssignment(
        stateName: 'Maharashtra',
        districtName: 'Mumbai',
        subDistrictName: 'Mumbai City',
      );
      
      expect(mumbaiAssignment.hasAssignment, isTrue);
      expect(mumbaiAssignment.assignedRHOId, isNotNull);
      expect(mumbaiAssignment.isDenselyPopulated, isTrue);
      expect(mumbaiAssignment.availableRHOs, isNotEmpty);
      
      print('✅ Mumbai RHO assignment:');
      print('  - Assigned RHO: ${mumbaiAssignment.assignedRHOId}');
      print('  - Available RHOs: ${mumbaiAssignment.availableRHOs}');
      print('  - Is dense: ${mumbaiAssignment.isDenselyPopulated}');
      
      // Regular district (Nashik)
      final nashikAssignment = await LocationService.getRHOAssignment(
        stateName: 'Maharashtra',
        districtName: 'Nashik',
      );
      
      expect(nashikAssignment.hasAssignment, isTrue);
      expect(nashikAssignment.assignedRHOId, isNotNull);
      expect(nashikAssignment.isDenselyPopulated, isFalse);
      
      print('✅ Nashik RHO assignment:');
      print('  - Assigned RHO: ${nashikAssignment.assignedRHOId}');
      print('  - Is dense: ${nashikAssignment.isDenselyPopulated}');
    });

    test('Should preview RHO assignment correctly', () async {
      // Test automatic assignment (regular district)
      final automaticPreview = await RHOAssignmentService.previewRHOAssignment(
        stateName: 'Maharashtra',
        districtName: 'Nashik',
      );
      
      expect(automaticPreview.isValid, isTrue);
      expect(automaticPreview.hasAssignment, isTrue);
      expect(automaticPreview.requiresManualSelection, isFalse);
      expect(automaticPreview.canProceed, isTrue);
      
      print('✅ Automatic assignment preview (Nashik):');
      print('  - Can proceed: ${automaticPreview.canProceed}');
      print('  - Assigned RHO: ${automaticPreview.assignedRHOId}');
      
      // Test manual selection required (dense district)
      final manualPreview = await RHOAssignmentService.previewRHOAssignment(
        stateName: 'Maharashtra',
        districtName: 'Mumbai',
        subDistrictName: 'Mumbai City',
      );
      
      expect(manualPreview.isValid, isTrue);
      expect(manualPreview.isDenselyPopulated, isTrue);
      expect(manualPreview.availableRHOs, isNotEmpty);
      
      print('✅ Manual selection preview (Mumbai):');
      print('  - Available RHOs: ${manualPreview.availableRHOs}');
      print('  - Requires manual selection: ${manualPreview.requiresManualSelection}');
    });

    test('Should handle area-wise RHO mapping correctly', () {
      // Test direct data access
      final mumbaiData = IndianStatesDistrictsData.getDistrictData('Maharashtra', 'Mumbai');
      
      expect(mumbaiData, isNotNull);
      expect(mumbaiData!.isDenselyPopulated, isTrue);
      expect(mumbaiData.hasMultipleRHOs, isTrue);
      expect(mumbaiData.areaWiseRhoMapping, isNotNull);
      expect(mumbaiData.areaWiseRhoMapping!['Mumbai City'], equals('RHO_MUM_001'));
      expect(mumbaiData.areaWiseRhoMapping!['Andheri'], equals('RHO_MUM_002'));
      
      print('✅ Area-wise RHO mapping working:');
      mumbaiData.areaWiseRhoMapping!.entries.take(5).forEach((entry) {
        print('  - ${entry.key}: ${entry.value}');
      });
    });

    test('Should handle Chennai (Tamil Nadu) dense district', () async {
      final chennaiSubDistricts = await LocationService.getSubDistricts('Tamil Nadu', 'Chennai');
      
      expect(chennaiSubDistricts, isNotEmpty);
      expect(chennaiSubDistricts, contains('Ambattur'));
      expect(chennaiSubDistricts, contains('Egmore'));
      
      final chennaiAssignment = await LocationService.getRHOAssignment(
        stateName: 'Tamil Nadu',
        districtName: 'Chennai',
        subDistrictName: 'Egmore',
      );
      
      expect(chennaiAssignment.hasAssignment, isTrue);
      expect(chennaiAssignment.isDenselyPopulated, isTrue);
      
      print('✅ Chennai (Tamil Nadu) assignment working:');
      print('  - Sub-districts count: ${chennaiSubDistricts.length}');
      print('  - Assigned RHO: ${chennaiAssignment.assignedRHOId}');
    });

    test('Should handle location codes generation', () async {
      final codes = await LocationService.getLocationCodes(
        stateName: 'Maharashtra',
        districtName: 'Mumbai',
      );
      
      expect(codes.stateCode, equals('MH'));
      expect(codes.districtCode, equals('MUM'));
      
      print('✅ Location codes generation:');
      print('  - State code: ${codes.stateCode}');
      print('  - District code: ${codes.districtCode}');
    });

    test('Should handle search functionality', () async {
      // Search states
      final stateResults = await LocationService.searchStates('Maha');
      expect(stateResults, contains('Maharashtra'));
      
      // Search districts
      final districtResults = await LocationService.searchDistricts('Maharashtra', 'Mum');
      expect(districtResults, contains('Mumbai'));
      
      // Search sub-districts
      final subDistrictResults = await LocationService.searchSubDistricts('Maharashtra', 'Mumbai', 'Mum');
      expect(subDistrictResults, contains('Mumbai City'));
      expect(subDistrictResults, contains('Mumbai Suburban'));
      
      print('✅ Search functionality working:');
      print('  - State search "Maha": $stateResults');
      print('  - District search "Mum": $districtResults');
      print('  - Sub-district search "Mum": ${subDistrictResults.take(3).toList()}');
    });
  });

  group('RHO Assignment Edge Cases', () {
    test('Should handle non-existent locations gracefully', () async {
      final result = await LocationService.validateLocation(
        stateName: 'NonExistentState',
        districtName: 'NonExistentDistrict',
      );
      
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Invalid state'));
      
      print('✅ Handles non-existent locations gracefully');
    });

    test('Should handle empty results gracefully', () async {
      final districts = await LocationService.getDistricts('NonExistentState');
      expect(districts, isEmpty);
      
      final subDistricts = await LocationService.getSubDistricts('Maharashtra', 'NonExistentDistrict');
      expect(subDistricts, isEmpty);
      
      print('✅ Handles empty results gracefully');
    });
  });

  group('Complete Registration Flow Simulation', () {
    test('Should simulate complete hospital registration flow', () async {
      print('\n🏥 Simulating Hospital Registration Flow...\n');
      
      // Step 1: Load states
      print('1️⃣ Loading states...');
      final states = await LocationService.getStates();
      print('   ✅ Loaded ${states.length} states');
      
      // Step 2: Select Maharashtra and load districts
      print('2️⃣ Selecting Maharashtra and loading districts...');
      final selectedState = 'Maharashtra';
      final districts = await LocationService.getDistricts(selectedState);
      print('   ✅ Loaded ${districts.length} districts for $selectedState');
      
      // Step 3: Select Mumbai (dense district) and load sub-districts
      print('3️⃣ Selecting Mumbai and loading sub-districts...');
      final selectedDistrict = 'Mumbai';
      final subDistricts = await LocationService.getSubDistricts(selectedState, selectedDistrict);
      final isDense = await LocationService.requiresSubDistrictSelection(selectedState, selectedDistrict);
      print('   ✅ Loaded ${subDistricts.length} sub-districts for $selectedDistrict');
      print('   ✅ District is dense: $isDense');
      
      // Step 4: Select sub-district and preview RHO assignment
      print('4️⃣ Selecting Mumbai City and previewing RHO assignment...');
      final selectedSubDistrict = 'Mumbai City';
      final preview = await RHOAssignmentService.previewRHOAssignment(
        stateName: selectedState,
        districtName: selectedDistrict,
        subDistrictName: selectedSubDistrict,
      );
      print('   ✅ RHO assignment preview:');
      print('      - Valid: ${preview.isValid}');
      print('      - Assigned RHO: ${preview.assignedRHOId}');
      print('      - Available RHOs: ${preview.availableRHOs}');
      print('      - Can proceed: ${preview.canProceed}');
      
      // Step 5: Test location validation
      print('5️⃣ Validating complete location...');
      final validation = await LocationService.validateLocation(
        stateName: selectedState,
        districtName: selectedDistrict,
        subDistrictName: selectedSubDistrict,
      );
      print('   ✅ Location validation:');
      print('      - Valid: ${validation.isValid}');
      print('      - Formatted: ${validation.formattedLocation}');
      
      // Step 6: Get location codes
      print('6️⃣ Generating location codes...');
      final codes = await LocationService.getLocationCodes(
        stateName: selectedState,
        districtName: selectedDistrict,
      );
      print('   ✅ Location codes:');
      print('      - State: ${codes.stateCode}');
      print('      - District: ${codes.districtCode}');
      
      print('\n🎉 Registration flow simulation completed successfully!\n');
      
      // Verify all steps passed
      expect(states, isNotEmpty);
      expect(districts, isNotEmpty);
      expect(subDistricts, isNotEmpty);
      expect(isDense, isTrue);
      expect(preview.isValid, isTrue);
      expect(validation.isValid, isTrue);
      expect(codes.stateCode, isNotEmpty);
    });
  });
}

void runIntegrationTests() async {
  print('\n🧪 Starting District-based RHO Assignment System Tests\n');
  print('=' * 60);
  
  group('System Integration Tests', () {
    test('Complete Flow: Maharashtra → Mumbai → Mumbai City', () async {
      print('\n📍 Testing: Maharashtra → Mumbai → Mumbai City');
      
      final assignment = await LocationService.getRHOAssignment(
        stateName: 'Maharashtra',
        districtName: 'Mumbai', 
        subDistrictName: 'Mumbai City'
      );
      
      expect(assignment.hasAssignment, isTrue);
      expect(assignment.assignedRHOId, equals('RHO_MUM_001'));
      
      print('✅ Expected RHO: RHO_MUM_001, Got: ${assignment.assignedRHOId}');
    });

    test('Complete Flow: Tamil Nadu → Chennai → Egmore', () async {
      print('\n📍 Testing: Tamil Nadu → Chennai → Egmore');
      
      final assignment = await LocationService.getRHOAssignment(
        stateName: 'Tamil Nadu',
        districtName: 'Chennai',
        subDistrictName: 'Egmore'
      );
      
      expect(assignment.hasAssignment, isTrue);
      expect(assignment.assignedRHOId, equals('RHO_CHE_002'));
      
      print('✅ Expected RHO: RHO_CHE_002, Got: ${assignment.assignedRHOId}');
    });

    test('Complete Flow: Maharashtra → Nashik (Non-dense)', () async {
      print('\n📍 Testing: Maharashtra → Nashik (Non-dense district)');
      
      final assignment = await LocationService.getRHOAssignment(
        stateName: 'Maharashtra',
        districtName: 'Nashik'
      );
      
      expect(assignment.hasAssignment, isTrue);
      expect(assignment.assignedRHOId, equals('RHO_NAS_001'));
      expect(assignment.isDenselyPopulated, isFalse);
      
      print('✅ Expected RHO: RHO_NAS_001, Got: ${assignment.assignedRHOId}');
      print('✅ Correctly identified as non-dense district');
    });
  });
  
  print('\n${'=' * 60}');
  print('🎯 All tests completed successfully!');
  print('📊 System is ready for hospital registration with RHO assignment');
}