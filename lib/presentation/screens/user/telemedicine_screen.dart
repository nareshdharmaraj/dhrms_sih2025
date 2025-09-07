import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';

class TelemedicineScreen extends StatefulWidget {
  const TelemedicineScreen({super.key});

  @override
  State<TelemedicineScreen> createState() => _TelemedicineScreenState();
}

class _TelemedicineScreenState extends State<TelemedicineScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<Doctor> _availableDoctors = [
    Doctor(
      name: 'Dr. Sarah Joseph',
      specialization: 'General Medicine',
      experience: '12 years',
      rating: 4.8,
      consultationFee: 250,
      isOnline: true,
      nextAvailable: 'Available now',
      image: 'assets/images/doctor1.jpg',
    ),
    Doctor(
      name: 'Dr. Rajesh Kumar',
      specialization: 'Cardiology',
      experience: '15 years',
      rating: 4.9,
      consultationFee: 400,
      isOnline: true,
      nextAvailable: 'Available now',
      image: 'assets/images/doctor2.jpg',
    ),
    Doctor(
      name: 'Dr. Priya Nair',
      specialization: 'Dermatology',
      experience: '8 years',
      rating: 4.7,
      consultationFee: 300,
      isOnline: false,
      nextAvailable: 'Available at 2:00 PM',
      image: 'assets/images/doctor3.jpg',
    ),
    Doctor(
      name: 'Dr. Arun Menon',
      specialization: 'Pediatrics',
      experience: '10 years',
      rating: 4.6,
      consultationFee: 200,
      isOnline: true,
      nextAvailable: 'Available now',
      image: 'assets/images/doctor4.jpg',
    ),
  ];

  final List<Consultation> _pastConsultations = [
    Consultation(
      doctorName: 'Dr. Sarah Joseph',
      specialization: 'General Medicine',
      date: DateTime.now().subtract(const Duration(days: 2)),
      duration: '25 minutes',
      type: 'Video Call',
      status: 'Completed',
      prescription: 'Rest and medication prescribed',
    ),
    Consultation(
      doctorName: 'Dr. Rajesh Kumar',
      specialization: 'Cardiology',
      date: DateTime.now().subtract(const Duration(days: 7)),
      duration: '30 minutes',
      type: 'Video Call',
      status: 'Completed',
      prescription: 'Follow-up in 2 weeks',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Telemedicine'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          indicatorColor: AppColors.white,
          tabs: const [
            Tab(text: 'Doctors', icon: Icon(Icons.medical_services)),
            Tab(text: 'Appointments', icon: Icon(Icons.schedule)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.emergency),
            onPressed: () => _showEmergencyConsultation(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDoctorsTab(),
          _buildAppointmentsTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildDoctorsTab() {
    return Column(
      children: [
        // Search and filters
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            children: [
              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search doctors by name or specialization',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusLarge,
                    ),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                ),
              ),
              const SizedBox(height: AppDimensions.marginMedium),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', true),
                    _buildFilterChip('Available Now', false),
                    _buildFilterChip('General Medicine', false),
                    _buildFilterChip('Cardiology', false),
                    _buildFilterChip('Dermatology', false),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Doctors list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
            ),
            itemCount: _availableDoctors.length,
            itemBuilder: (context, index) {
              return _buildDoctorCard(_availableDoctors[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentsTab() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick booking card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.video_call,
                        color: AppColors.primaryBlue,
                        size: 24,
                      ),
                      const SizedBox(width: AppDimensions.marginSmall),
                      Text(
                        'Quick Consultation',
                        style: AppTextStyles.headline6.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.marginMedium),
                  Text(
                    'Connect with available doctors instantly for quick consultations.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginMedium),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _startQuickConsultation(),
                      icon: const Icon(Icons.video_call),
                      label: const Text('Start Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.marginLarge),

          // Upcoming appointments
          Text(
            'Upcoming Appointments',
            style: AppTextStyles.headline6.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.marginMedium),

          // No appointments message
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, size: 80, color: AppColors.grey400),
                  const SizedBox(height: AppDimensions.marginMedium),
                  Text(
                    'No upcoming appointments',
                    style: AppTextStyles.headline6.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginSmall),
                  Text(
                    'Book a consultation with our available doctors',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.marginLarge),
                  ElevatedButton(
                    onPressed: () => _tabController.animateTo(0),
                    child: const Text('Find Doctors'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: _pastConsultations.length,
      itemBuilder: (context, index) {
        return _buildConsultationCard(_pastConsultations[index]);
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.marginSmall),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // TODO: Implement filter logic
        },
        selectedColor: AppColors.primaryBlue.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          children: [
            Row(
              children: [
                // Doctor image placeholder
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                  child: Text(
                    doctor.name.split(' ').map((n) => n[0]).join(),
                    style: AppTextStyles.headline6.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.marginMedium),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: AppTextStyles.subtitle1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        doctor.specialization,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                      Text(
                        '${doctor.experience} experience',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingSmall,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: doctor.isOnline
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusSmall,
                        ),
                      ),
                      child: Text(
                        doctor.isOnline ? 'Online' : 'Offline',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: doctor.isOnline
                              ? AppColors.success
                              : AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 16, color: AppColors.warning),
                        const SizedBox(width: 2),
                        Text(
                          doctor.rating.toString(),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Consultation Fee',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                      Text(
                        '₹${doctor.consultationFee}',
                        style: AppTextStyles.subtitle1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Available',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                      Text(
                        doctor.nextAvailable,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: doctor.isOnline
                      ? () => _bookConsultation(doctor)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                  ),
                  child: Text(doctor.isOnline ? 'Book Now' : 'Schedule'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultationCard(Consultation consultation) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  consultation.doctorName,
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingSmall,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusSmall,
                    ),
                  ),
                  child: Text(
                    consultation.status,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginSmall),

            Text(
              consultation.specialization,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: AppDimensions.marginSmall),

            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppColors.grey500),
                const SizedBox(width: 4),
                Text(
                  _formatDate(consultation.date),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(width: AppDimensions.marginMedium),
                Icon(Icons.access_time, size: 16, color: AppColors.grey500),
                const SizedBox(width: 4),
                Text(
                  consultation.duration,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginSmall),

            Text(consultation.prescription, style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppDimensions.marginMedium),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadPrescription(consultation),
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                  ),
                ),
                const SizedBox(width: AppDimensions.marginMedium),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _bookFollowUp(consultation),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Book Follow-up'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _bookConsultation(Doctor doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBookingSheet(doctor),
    );
  }

  Widget _buildBookingSheet(Doctor doctor) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book Consultation',
              style: AppTextStyles.headline6.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.marginLarge),

            // Doctor info
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                  child: Text(
                    doctor.name.split(' ').map((n) => n[0]).join(),
                    style: AppTextStyles.subtitle1.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.marginMedium),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: AppTextStyles.subtitle1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      doctor.specialization,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginLarge),

            // Consultation type
            Text(
              'Consultation Type',
              style: AppTextStyles.subtitle1.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            Row(
              children: [
                Expanded(
                  child: _buildConsultationType(
                    Icons.video_call,
                    'Video Call',
                    '₹${doctor.consultationFee}',
                    true,
                  ),
                ),
                const SizedBox(width: AppDimensions.marginMedium),
                Expanded(
                  child: _buildConsultationType(
                    Icons.phone,
                    'Voice Call',
                    '₹${doctor.consultationFee - 50}',
                    false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginLarge),

            // Brief symptoms
            Text(
              'Brief Description',
              style: AppTextStyles.subtitle1.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe your symptoms briefly...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _confirmBooking(doctor);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                ),
                child: Text(
                  'Book Consultation - ₹${doctor.consultationFee}',
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultationType(
    IconData icon,
    String type,
    String price,
    bool isSelected,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColors.primaryBlue : AppColors.grey300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.1) : null,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryBlue : AppColors.grey600,
            size: 30,
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          Text(
            type,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primaryBlue : AppColors.grey700,
            ),
          ),
          Text(
            price,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
          ),
        ],
      ),
    );
  }

  void _confirmBooking(Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: AppColors.success,
          size: 50,
        ),
        title: const Text('Consultation Booked'),
        content: Text(
          'Your consultation with ${doctor.name} has been booked successfully. You will receive a call shortly.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startQuickConsultation() {
    // TODO: Start quick consultation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting quick consultation...')),
    );
  }

  void _showEmergencyConsultation() {
    // TODO: Show emergency consultation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Emergency consultation available 24/7')),
    );
  }

  void _downloadPrescription(Consultation consultation) {
    // TODO: Download prescription
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading prescription...')),
    );
  }

  void _bookFollowUp(Consultation consultation) {
    // TODO: Book follow-up appointment
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking follow-up appointment...')),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else {
      return '$difference days ago';
    }
  }
}

class Doctor {
  final String name;
  final String specialization;
  final String experience;
  final double rating;
  final int consultationFee;
  final bool isOnline;
  final String nextAvailable;
  final String image;

  Doctor({
    required this.name,
    required this.specialization,
    required this.experience,
    required this.rating,
    required this.consultationFee,
    required this.isOnline,
    required this.nextAvailable,
    required this.image,
  });
}

class Consultation {
  final String doctorName;
  final String specialization;
  final DateTime date;
  final String duration;
  final String type;
  final String status;
  final String prescription;

  Consultation({
    required this.doctorName,
    required this.specialization,
    required this.date,
    required this.duration,
    required this.type,
    required this.status,
    required this.prescription,
  });
}
