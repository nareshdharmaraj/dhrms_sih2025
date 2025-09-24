import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Testing Doctors API...');

  try {
    // Test hospitals endpoint
    print('\n🏥 Testing hospitals endpoint...');
    final hospitalsResponse = await http.get(
      Uri.parse('http://localhost:3000/api/hospitals'),
      headers: {'Content-Type': 'application/json'},
    );

    print('📡 Hospitals Response Status: ${hospitalsResponse.statusCode}');
    if (hospitalsResponse.statusCode == 200) {
      final hospitals = json.decode(hospitalsResponse.body);
      print('✅ Found ${hospitals.length} hospitals');
      if (hospitals.isNotEmpty) {
        final firstHospital = hospitals[0];
        print(
          '🏥 First hospital: ${firstHospital['hospitalName']} (ID: ${firstHospital['hospitalId']})',
        );

        // Test doctors endpoint with this hospital ID
        final hospitalId = firstHospital['hospitalId'];
        print('\n👨‍⚕️ Testing doctors endpoint for hospital: $hospitalId');

        final doctorsResponse = await http.get(
          Uri.parse('http://localhost:3000/api/doctors/hospital/$hospitalId'),
          headers: {'Content-Type': 'application/json'},
        );

        print('📡 Doctors Response Status: ${doctorsResponse.statusCode}');
        print('📦 Doctors Response Body: ${doctorsResponse.body}');

        if (doctorsResponse.statusCode == 200) {
          final doctors = json.decode(doctorsResponse.body);
          print('✅ Found ${doctors.length} doctors for hospital $hospitalId');

          if (doctors.isNotEmpty) {
            final firstDoctor = doctors[0];
            print(
              '👨‍⚕️ First doctor: ${firstDoctor['doctorName']} - ${firstDoctor['specialization']} (Fee: \$${firstDoctor['consultationFee']})',
            );
          }
        } else {
          print('❌ Failed to load doctors: ${doctorsResponse.statusCode}');
        }
      }
    } else {
      print('❌ Failed to load hospitals: ${hospitalsResponse.statusCode}');
    }
  } catch (e) {
    print('💥 Error: $e');
  }
}
