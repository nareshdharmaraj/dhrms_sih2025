import 'package:http/http.dart' as http;
import 'dart:convert';

class SimpleApiTest {
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<void> testHospitalsAndDoctors() async {
    print('🧪 Simple API Test Starting...');

    try {
      // Test hospitals
      print('\n1. Testing hospitals endpoint...');
      final hospitalsResponse = await http.get(
        Uri.parse('$baseUrl/hospitals'),
        headers: {'Content-Type': 'application/json'},
      );

      print('🏥 Hospitals Response Status: ${hospitalsResponse.statusCode}');

      if (hospitalsResponse.statusCode == 200) {
        final hospitals = json.decode(hospitalsResponse.body);
        print('✅ Hospitals loaded: ${hospitals.length} found');

        if (hospitals.isNotEmpty) {
          final hospital = hospitals[0];
          final hospitalId = hospital['hospitalId'];
          print(
            '🏥 Using hospital: ${hospital['hospitalName']} (ID: $hospitalId)',
          );

          // Test doctors
          print('\n2. Testing doctors endpoint...');
          final doctorsResponse = await http.get(
            Uri.parse('$baseUrl/doctors/hospital/$hospitalId'),
            headers: {'Content-Type': 'application/json'},
          );

          print('👨‍⚕️ Doctors Response Status: ${doctorsResponse.statusCode}');
          print(
            '📦 Doctors Response Body Length: ${doctorsResponse.body.length}',
          );

          if (doctorsResponse.statusCode == 200) {
            final doctors = json.decode(doctorsResponse.body);
            print('✅ Doctors loaded: ${doctors.length} found');

            if (doctors.isNotEmpty) {
              final doctor = doctors[0];
              print(
                '👨‍⚕️ First doctor: ${doctor['doctorName']} - ${doctor['specialization']}',
              );
              print('💰 Consultation fee: \$${doctor['consultationFee']}');
              print('🔑 Available fields: ${doctor.keys.toList()}');

              // Test appointment booking payload
              print('\n3. Testing appointment booking payload...');

              final appointmentData = {
                'patientId': 'PAT-001',
                'patientName': 'Test Patient',
                'doctorId': doctor['doctorId'],
                'doctorName': doctor['doctorName'],
                'hospitalId': hospitalId,
                'hospitalName': hospital['hospitalName'],
                'appointmentDate': '25/9/2025',
                'appointmentTime': '10:00 AM',
                'reason': 'General consultation',
                'consultationFee': doctor['consultationFee'],
              };

              print('📋 Appointment payload ready:');
              appointmentData.forEach((key, value) {
                print('   $key: $value');
              });

              // Test actual booking
              print('\n4. Testing appointment booking...');
              final bookingResponse = await http.post(
                Uri.parse('$baseUrl/appointments'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(appointmentData),
              );

              print(
                '📅 Booking Response Status: ${bookingResponse.statusCode}',
              );
              print('📦 Booking Response: ${bookingResponse.body}');

              if (bookingResponse.statusCode == 201) {
                print('✅ Appointment booking successful!');
              } else {
                print('❌ Appointment booking failed');
              }
            }
          } else {
            print('❌ Failed to load doctors');
          }
        }
      } else {
        print('❌ Failed to load hospitals');
      }
    } catch (e) {
      print('💥 Error during test: $e');
    }

    print('\n🏁 API Test Complete');
  }
}
