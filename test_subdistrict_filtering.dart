// Test script to verify sub-district filtering for RHO assignment
// This script tests the fixed RHO filtering logic for dense districts like Kerala-Ernakulam

import 'dart:io';
import 'dart:convert';

Future<void> testSubDistrictFiltering() async {
  print('🔍 Testing Sub-District RHO Filtering');
  print('=====================================');

  // Test the backend API directly
  final client = HttpClient();
  
  try {
    // Test 1: Get RHOs for Kerala-Ernakulam without sub-district
    print('\n1. Testing Kerala-Ernakulam without sub-district filter:');
    final request1 = await client.getUrl(
      Uri.parse('http://localhost:3000/api/rho/public?state=Kerala&district=Ernakulam')
    );
    final response1 = await request1.close();
    final body1 = await response1.transform(utf8.decoder).join();
    final data1 = json.decode(body1);
    
    print('   Response: ${response1.statusCode}');
    if (data1['success'] == true) {
      print('   RHOs found: ${data1['rhos'].length}');
      for (var rho in data1['rhos']) {
        print('   - ${rho['fullName']} (${rho['officerId']})');
        if (rho['coverage'] != null && rho['coverage']['subDistricts'] != null) {
          print('     Sub-districts: ${rho['coverage']['subDistricts']}');
        }
      }
    }

    // Test 2: Get RHOs for Kerala-Ernakulam with specific sub-district
    print('\n2. Testing Kerala-Ernakulam with sub-district "Kochi":');
    final request2 = await client.getUrl(
      Uri.parse('http://localhost:3000/api/rho/public?state=Kerala&district=Ernakulam&subDistrict=Kochi')
    );
    final response2 = await request2.close();
    final body2 = await response2.transform(utf8.decoder).join();
    final data2 = json.decode(body2);
    
    print('   Response: ${response2.statusCode}');
    if (data2['success'] == true) {
      print('   Filtered RHOs: ${data2['rhos'].length}');
      for (var rho in data2['rhos']) {
        print('   - ${rho['fullName']} (${rho['officerId']})');
        if (rho['coverage'] != null && rho['coverage']['subDistricts'] != null) {
          print('     Sub-districts: ${rho['coverage']['subDistricts']}');
        }
      }
    }

    // Test 3: Test with another sub-district
    print('\n3. Testing Kerala-Ernakulam with sub-district "Aluva":');
    final request3 = await client.getUrl(
      Uri.parse('http://localhost:3000/api/rho/public?state=Kerala&district=Ernakulam&subDistrict=Aluva')
    );
    final response3 = await request3.close();
    final body3 = await response3.transform(utf8.decoder).join();
    final data3 = json.decode(body3);
    
    print('   Response: ${response3.statusCode}');
    if (data3['success'] == true) {
      print('   Filtered RHOs: ${data3['rhos'].length}');
      for (var rho in data3['rhos']) {
        print('   - ${rho['fullName']} (${rho['officerId']})');
        if (rho['coverage'] != null && rho['coverage']['subDistricts'] != null) {
          print('     Sub-districts: ${rho['coverage']['subDistricts']}');
        }
      }
    }

    print('\n✅ Sub-district filtering test completed');
    
  } catch (e) {
    print('❌ Error during test: $e');
  } finally {
    client.close();
  }
}

void main() async {
  await testSubDistrictFiltering();
}