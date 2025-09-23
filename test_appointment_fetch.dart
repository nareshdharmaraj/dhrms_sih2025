import 'lib/services/hospital_api_service.dart';

void main() async {
  print('🧪 Testing Doctor Appointment Fetch');
  print('=' * 50);

  // Test with the actual doctor ID from your database
  final String testDoctorId = '68c0065c99ba74782396e8ee';

  try {
    print('📡 Fetching appointments for doctor ID: $testDoctorId');

    final appointments = await HospitalApiService.getDoctorAppointments(
      testDoctorId,
    );

    print('✅ Successfully fetched ${appointments.length} appointments');

    if (appointments.isNotEmpty) {
      print('\n📋 First Appointment Details:');
      final firstAppointment = appointments[0];
      print('  - ID: ${firstAppointment['_id']}');
      print('  - Patient ID: ${firstAppointment['patientId']}');
      print('  - Patient Name: ${firstAppointment['patientName']}');
      print('  - Date: ${firstAppointment['appointmentDate']}');
      print('  - Time: ${firstAppointment['appointmentTime']}');
      print('  - Status: ${firstAppointment['status']}');
      print('  - Reason: ${firstAppointment['reason']}');
      print('  - Type: ${firstAppointment['type']}');
      print('  - Priority: ${firstAppointment['priority']}');
      print('  - Duration: ${firstAppointment['duration']}');

      // Location info
      final location = firstAppointment['location'];
      if (location != null && location is Map) {
        print('  - Hospital: ${location['hospitalName']}');
        print('  - Department: ${location['department']}');
        print('  - Room: ${location['roomNumber']}');
      }

      print('\n🔍 Full JSON:');
      print(firstAppointment);
    } else {
      print('⚠️  No appointments found for this doctor');
    }
  } catch (error) {
    print('❌ Error fetching appointments: $error');
  }

  print('\n✅ Test completed');
}
