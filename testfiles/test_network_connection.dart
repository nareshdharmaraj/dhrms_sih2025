import 'dart:io';
import 'dart:convert';

void main() async {
  print('🔍 Testing network connection to backend server...\n');
  
  final client = HttpClient();
  
  try {
    // Test the updated IP address
    print('Testing connection to: http://172.2.4.104:3000/health');
    final request = await client.getUrl(Uri.parse('http://172.2.4.104:3000/health'));
    final response = await request.close();
    
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      print('✅ Connection successful!');
      print('📊 Status Code: ${response.statusCode}');
      print('📋 Response: $responseBody');
    } else {
      print('❌ Server responded with status: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Connection failed: $e');
  } finally {
    client.close();
  }

  // Also test the API endpoint for patient registration
  final client2 = HttpClient();
  try {
    print('\n🔍 Testing patient registration endpoint...');
    print('Testing: http://172.2.4.104:3000/api/patients/register');
    
    final request = await client2.postUrl(Uri.parse('http://172.2.4.104:3000/api/patients/register'));
    request.headers.set('content-type', 'application/json');
    request.write('{}'); // Empty JSON to test endpoint availability
    final response = await request.close();
    
    print('📊 Registration endpoint status: ${response.statusCode}');
    if (response.statusCode == 400 || response.statusCode == 422) {
      print('✅ Endpoint is accessible (expected validation error for empty data)');
    } else {
      final responseBody = await response.transform(utf8.decoder).join();
      print('📋 Response: $responseBody');
    }
  } catch (e) {
    print('❌ Registration endpoint test failed: $e');
  } finally {
    client2.close();
  }
}