import 'dart:convert';
import 'dart:io';

void main() async {
  final httpClient = HttpClient();
  
  try {
    // Create the request
    final request = await httpClient.postUrl(Uri.parse('http://localhost:3000/api/auth/login'));
    request.headers.set('Content-Type', 'application/json');
    
    // Send the request body
    final body = json.encode({
      'usernameOrEmail': 'SARD029205',
      'password': 'sar1234',
    });
    request.write(body);
    
    // Get the response
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('=== FLUTTER API TEST ===');
    print('Status Code: ${response.statusCode}');
    print('Response Body: $responseBody');
    
    if (response.statusCode == 200) {
      final responseData = json.decode(responseBody);
      print('Parsed Response: ${json.encode(responseData)}');
      print('Response Keys: ${responseData.keys.toList()}');
      print('Has patientData: ${responseData.containsKey('patientData')}');
      
      if (responseData.containsKey('patientData')) {
        print('Patient Data: ${responseData['patientData']}');
      }
    }
    
  } catch (e) {
    print('Error: $e');
  } finally {
    httpClient.close();
  }
}