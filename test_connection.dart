import 'dart:io';
import 'dart:convert';

void main() async {
  print('Testing connection to backend...');
  
  try {
    // Test connection to emulator-accessible backend
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('http://10.0.2.2:3000/health'));
    final response = await request.close();
    
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      print('✅ Backend connection successful!');
      print('Response: $responseBody');
    } else {
      print('❌ Backend responded with status: ${response.statusCode}');
    }
    
    client.close();
  } catch (e) {
    print('❌ Connection failed: $e');
    
    // Try localhost as fallback
    try {
      print('Trying localhost fallback...');
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('http://localhost:3000/health'));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        print('✅ Localhost connection successful!');
        print('Response: $responseBody');
      } else {
        print('❌ Localhost responded with status: ${response.statusCode}');
      }
      
      client.close();
    } catch (e2) {
      print('❌ Localhost connection also failed: $e2');
    }
  }
}