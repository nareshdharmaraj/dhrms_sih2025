import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  
  try {
    // Test the actual login API endpoint
    final request = await client.postUrl(Uri.parse('http://localhost:3000/api/auth/login'));
    request.headers.set('Content-Type', 'application/json');
    
    final body = jsonEncode({
      'usernameOrEmail': 'SARD029205',
      'password': 'sar1234',
    });
    
    request.write(body);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('=== API TEST RESULTS ===');
    print('Status Code: ${response.statusCode}');
    print('Response Body: $responseBody');
    
    if (response.statusCode == 200) {
      final responseData = jsonDecode(responseBody);
      print('\n=== PARSED RESPONSE ===');
      print('Success: ${responseData['success']}');
      print('User Type: ${responseData['userType']}');
      print('Has patientData: ${responseData.containsKey('patientData')}');
      
      if (responseData.containsKey('patientData')) {
        final patientData = responseData['patientData'];
        print('\n=== PATIENT DATA ===');
        print('UHID: ${patientData['uhid']}');
        print('Blood Group: ${patientData['bloodGroup']}');
        print('Date of Birth: ${patientData['dateOfBirth']}');
      }
    }
    
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}