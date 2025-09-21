import 'package:flutter/material.dart';
import '../models/who_admin.dart';
import '../services/who_service.dart';

class WhoHospitalManagementScreen extends StatefulWidget {
  final WhoAdmin whoAdmin;

  const WhoHospitalManagementScreen({super.key, required this.whoAdmin});

  @override
  _WhoHospitalManagementScreenState createState() => _WhoHospitalManagementScreenState();
}

class _WhoHospitalManagementScreenState extends State<WhoHospitalManagementScreen> {
  bool isLoading = true;
  List<HospitalOverview> hospitals = [];
  List<HospitalOverview> filteredHospitals = [];
  String? error;
  String searchQuery = '';
  String? selectedState;
  String? selectedStatus;

  // Indian states list
  final List<String> indianStates = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  final List<String> statusOptions = ['Active', 'Inactive', 'Under Review'];

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  Future<void> _loadHospitals() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final result = await WhoService.getAllHospitals();
      
      if (result['success']) {
        setState(() {
          hospitals = result['hospitals'];
          filteredHospitals = hospitals;
          isLoading = false;
        });
      } else {
        setState(() {
          error = result['message'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load hospitals: $e';
        isLoading = false;
      });
    }
  }

  void _filterHospitals() {
    setState(() {
      filteredHospitals = hospitals.where((hospital) {
        final matchesSearch = hospital.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                            hospital.city.toLowerCase().contains(searchQuery.toLowerCase());
        final matchesState = selectedState == null || hospital.state == selectedState;
        final matchesStatus = selectedStatus == null || 
                            (selectedStatus == 'Active' && hospital.isActive) ||
                            (selectedStatus == 'Inactive' && !hospital.isActive);
        
        return matchesSearch && matchesState && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Hospital Overview'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadHospitals,
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Hospital management is handled by Regional Officers. WHO admins have view-only access.'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          _buildStatsRow(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : error != null
                ? _buildErrorWidget()
                : _buildHospitalsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search hospitals by name or location...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
              _filterHospitals();
            },
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedState,
                  decoration: InputDecoration(
                    labelText: 'State',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: Text('All States')),
                    ...indianStates.map((state) => DropdownMenuItem(
                      value: state,
                      child: Text(state),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedState = value;
                    });
                    _filterHospitals();
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: Text('All Status')),
                    ...statusOptions.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                    _filterHospitals();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final activeHospitals = filteredHospitals.where((h) => h.isActive).length;
    final totalPatients = filteredHospitals.fold(0, (sum, h) => sum + h.totalPatients);
    final averageRating = filteredHospitals.isNotEmpty
        ? filteredHospitals.fold(0.0, (sum, h) => sum + h.rating) / filteredHospitals.length
        : 0.0;

    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Active Hospitals',
              '$activeHospitals',
              Icons.local_hospital,
              Colors.green,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Total Patients',
              '$totalPatients',
              Icons.people,
              Colors.blue,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Avg Rating',
              averageRating.toStringAsFixed(1),
              Icons.star,
              Colors.orange,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Total Hospitals',
              '${filteredHospitals.length}',
              Icons.business,
              Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
            SizedBox(height: 20),
            Text(
              'Error Loading Hospitals',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadHospitals,
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalsList() {
    if (filteredHospitals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_hospital, size: 80, color: Colors.grey.shade400),
            SizedBox(height: 20),
            Text(
              'No Hospitals Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Try adjusting your search criteria',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredHospitals.length,
      itemBuilder: (context, index) {
        return _buildHospitalCard(filteredHospitals[index]);
      },
    );
  }

  Widget _buildHospitalCard(HospitalOverview hospital) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showHospitalDetails(hospital),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                hospital.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildStatusChip(hospital.isActive ? 'Active' : 'Inactive'),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${hospital.city}, ${hospital.state}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'view',
                        child: Text('View Details'),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'view') {
                        _showHospitalDetails(hospital);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildHospitalStat(
                      'Patients',
                      '${hospital.totalPatients}',
                      Icons.people,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildHospitalStat(
                      'Staff',
                      '${hospital.totalStaff}',
                      Icons.people_alt,
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildHospitalStat(
                      'Rating',
                      '${hospital.rating.toStringAsFixed(1)}⭐',
                      Icons.star,
                      Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _buildHospitalStat(
                      'Type',
                      hospital.type,
                      Icons.business,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'inactive':
        color = Colors.red;
        break;
      case 'under review':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHospitalStat(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _showHospitalDetails(HospitalOverview hospital) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(hospital.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Location', '${hospital.city}, ${hospital.state}'),
              _buildDetailRow('Type', hospital.type),
              _buildDetailRow('Status', hospital.isActive ? 'Active' : 'Inactive'),
              _buildDetailRow('Total Patients', '${hospital.totalPatients}'),
              _buildDetailRow('Total Staff', '${hospital.totalStaff}'),
              _buildDetailRow('Rating', '${hospital.rating.toStringAsFixed(1)} / 5.0'),
              _buildDetailRow('Last Activity', hospital.lastActivity.toString().split(' ')[0]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}