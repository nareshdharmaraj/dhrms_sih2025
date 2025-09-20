import 'package:flutter/material.dart';

class HospitalsScreen extends StatefulWidget {
  final Map<String, dynamic>? patientData;

  const HospitalsScreen({super.key, this.patientData});

  @override
  State<HospitalsScreen> createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends State<HospitalsScreen> {
  final List<Map<String, dynamic>> _hospitals = [];
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Hospitals'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            _buildFilterChips(),
            Expanded(
              child: _hospitals.isEmpty
                  ? _buildEmptyState()
                  : _buildHospitalsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSampleHospitals,
        backgroundColor: Colors.blue.shade600,
        icon: const Icon(Icons.refresh, color: Colors.white),
        label: const Text(
          'Load Sample Data',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Emergency', 'General', 'Specialist', 'Private'];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = selected ? filter : 'All';
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue.shade600,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_hospital_outlined,
            size: 120,
            color: Colors.blue.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No Hospitals Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Enable location to find nearby hospitals',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _addSampleHospitals,
            icon: const Icon(Icons.location_searching),
            label: const Text('Find Hospitals'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalsList() {
    final filteredHospitals = _selectedFilter == 'All'
        ? _hospitals
        : _hospitals.where((h) => h['type'] == _selectedFilter).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredHospitals.length,
      itemBuilder: (context, index) {
        final hospital = filteredHospitals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getHospitalTypeColor(hospital['type']),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getHospitalIcon(hospital['type']),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hospital['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            hospital['address'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(hospital['type']),
                      backgroundColor: _getHospitalTypeColor(
                        hospital['type'],
                      ).withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: _getHospitalTypeColor(hospital['type']),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      hospital['rating'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.location_on,
                      color: Colors.grey.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${hospital['distance']} km away',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: hospital['isOpen'] ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        hospital['isOpen'] ? 'Open' : 'Closed',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showHospitalDetails(hospital),
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: const Text('Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToHospital(hospital),
                        icon: const Icon(Icons.directions, size: 16),
                        label: const Text('Navigate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getHospitalTypeColor(String type) {
    switch (type) {
      case 'Emergency':
        return Colors.red;
      case 'General':
        return Colors.blue;
      case 'Specialist':
        return Colors.purple;
      case 'Private':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getHospitalIcon(String type) {
    switch (type) {
      case 'Emergency':
        return Icons.emergency;
      case 'General':
        return Icons.local_hospital;
      case 'Specialist':
        return Icons.medical_services;
      case 'Private':
        return Icons.business;
      default:
        return Icons.local_hospital;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Hospitals'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select hospital type:'),
            const SizedBox(height: 16),
            ...['All', 'Emergency', 'General', 'Specialist', 'Private'].map(
              (filter) => RadioListTile<String>(
                title: Text(filter),
                value: filter,
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHospitalDetails(Map<String, dynamic> hospital) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(hospital['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Type', hospital['type']),
            _buildDetailRow('Address', hospital['address']),
            _buildDetailRow('Phone', hospital['phone']),
            _buildDetailRow('Distance', '${hospital['distance']} km'),
            _buildDetailRow('Rating', '${hospital['rating']}/5.0'),
            _buildDetailRow(
              'Status',
              hospital['isOpen'] ? 'Open 24/7' : 'Closed',
            ),
            if (hospital['specialties'] != null) ...[
              const SizedBox(height: 8),
              const Text(
                'Specialties:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(hospital['specialties'].join(', ')),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToHospital(hospital);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Get Directions'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _navigateToHospital(Map<String, dynamic> hospital) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening directions to ${hospital['name']}'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _addSampleHospitals() {
    setState(() {
      _hospitals.clear();
      _hospitals.addAll([
        {
          'name': 'City General Hospital',
          'address': '123 Main Street, Downtown',
          'type': 'General',
          'phone': '+1 (555) 123-4567',
          'distance': 2.3,
          'rating': 4.2,
          'isOpen': true,
          'specialties': ['Emergency Care', 'Surgery', 'Cardiology'],
        },
        {
          'name': 'Emergency Medical Center',
          'address': '456 Health Avenue, Central',
          'type': 'Emergency',
          'phone': '+1 (555) 987-6543',
          'distance': 1.8,
          'rating': 4.5,
          'isOpen': true,
          'specialties': ['Emergency Care', 'Trauma', 'Intensive Care'],
        },
        {
          'name': 'Specialized Heart Institute',
          'address': '789 Cardiac Lane, Medical District',
          'type': 'Specialist',
          'phone': '+1 (555) 456-7890',
          'distance': 3.1,
          'rating': 4.7,
          'isOpen': false,
          'specialties': ['Cardiology', 'Cardiac Surgery', 'Rehabilitation'],
        },
        {
          'name': 'Premium Private Hospital',
          'address': '321 Luxury Health Blvd, Uptown',
          'type': 'Private',
          'phone': '+1 (555) 654-3210',
          'distance': 4.5,
          'rating': 4.8,
          'isOpen': true,
          'specialties': ['General Medicine', 'Cosmetic Surgery', 'VIP Care'],
        },
        {
          'name': 'Community Health Center',
          'address': '654 Community Road, Suburbs',
          'type': 'General',
          'phone': '+1 (555) 789-0123',
          'distance': 5.2,
          'rating': 3.9,
          'isOpen': true,
          'specialties': ['Primary Care', 'Pediatrics', 'Women\'s Health'],
        },
      ]);
    });
  }
}
