import 'dart:io';
import 'dart:convert';

void main() async {
  print('🧪 Testing Doctors API with HttpClient...');

  final client = HttpClient();

  try {
    // Test hospitals endpoint
    print('\n🏥 Testing hospitals endpoint...');
    final hospitalsRequest = await client.getUrl(
      Uri.parse('http://localhost:3000/api/hospitals'),
    );
    hospitalsRequest.headers.set('Content-Type', 'application/json');
    final hospitalsResponse = await hospitalsRequest.close();

    print('📡 Hospitals Response Status: ${hospitalsResponse.statusCode}');

    if (hospitalsResponse.statusCode == 200) {
      final hospitalsData = await hospitalsResponse
          .transform(utf8.decoder)
          .join();
      final hospitals = json.decode(hospitalsData);
      print('✅ Found ${hospitals.length} hospitals');

      if (hospitals.isNotEmpty) {
        final firstHospital = hospitals[0];
        print(
          '🏥 First hospital: ${firstHospital['hospitalName']} (ID: ${firstHospital['hospitalId']})',
        );

        // Test doctors endpoint with this hospital ID
        final hospitalId = firstHospital['hospitalId'];
        print('\n👨‍⚕️ Testing doctors endpoint for hospital: $hospitalId');

        final doctorsRequest = await client.getUrl(
          Uri.parse('http://localhost:3000/api/doctors/hospital/$hospitalId'),
        );
        doctorsRequest.headers.set('Content-Type', 'application/json');
        final doctorsResponse = await doctorsRequest.close();

        print('📡 Doctors Response Status: ${doctorsResponse.statusCode}');

        if (doctorsResponse.statusCode == 200) {
          final doctorsData = await doctorsResponse
              .transform(utf8.decoder)
              .join();
          final doctors = json.decode(doctorsData);
          print('✅ Found ${doctors.length} doctors for hospital $hospitalId');

          if (doctors.isNotEmpty) {
            final firstDoctor = doctors[0];
            print(
              '👨‍⚕️ First doctor: ${firstDoctor['doctorName']} - ${firstDoctor['specialization']} (Fee: \$${firstDoctor['consultationFee']})',
            );
            print('🔑 Doctor keys: ${firstDoctor.keys.toList()}');
          }
        } else {
          print('❌ Failed to load doctors: ${doctorsResponse.statusCode}');
          final errorData = await doctorsResponse
              .transform(utf8.decoder)
              .join();
          print('❌ Error response: $errorData');
        }
      }
    } else {
      print('❌ Failed to load hospitals: ${hospitalsResponse.statusCode}');
      final errorData = await hospitalsResponse.transform(utf8.decoder).join();
      print('❌ Error response: $errorData');
    }
  } catch (e) {
    print('💥 Error: $e');
  } finally {
    client.close();
  }
}
