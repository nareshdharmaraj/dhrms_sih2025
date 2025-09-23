// Simple test to verify the fixed API call
// Run this from the Flutter project root: dart test_api_fix.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Testing Fixed API Call');
  print('=' * 50);

  final testDoctorId = '68c0065c99ba74782396e8ee';
  final baseUrl =
      'http://localhost:3000/api'; // This is what ConfigurationManager provides
  final endpoint =
      '/appointments/staff/$testDoctorId'; // This is what HospitalApiService adds
  final fullUrl = '$baseUrl$endpoint';

  print('Base URL: $baseUrl');
  print('Endpoint: $endpoint');
  print('Full URL: $fullUrl');
  print('');

  try {
    print('📡 Making request...');
    final response = await http.get(Uri.parse(fullUrl));

    print('Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Success! Found ${data.length} appointments');

      if (data.isNotEmpty) {
        final first = data[0];
        print('First appointment:');
        print('  - ID: ${first['_id']}');
        print('  - Date: ${first['appointmentDate']}');
        print('  - Time: ${first['appointmentTime']}');
        print('  - Status: ${first['status']}');
        print('  - Reason: ${first['reason']}');
      }
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }

  print('\n✅ Test completed');
}
