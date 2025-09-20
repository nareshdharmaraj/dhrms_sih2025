import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegionalOfficerDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;

  const RegionalOfficerDashboard({super.key, required this.userData});

  @override
  _RegionalOfficerDashboardState createState() => _RegionalOfficerDashboardState();
}

class _RegionalOfficerDashboardState extends State<RegionalOfficerDashboard> {
  List<dynamic> healthStats = [];
  List<dynamic> hospitals = [];
  Map<String, dynamic> regionalData = {};
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadOfficerData();
  }

  Future<void> loadOfficerData() async {
    try {
      setState(() => isLoading = true);
      
      // Load health statistics
      final statsResponse = await http.get(
        Uri.parse('http://localhost:3000/api/health-statistics'),
        headers: {'Content-Type': 'application/json'},
      );

      // Load hospital staff data for regional overview
      final hospitalStaffResponse = await http.get(
        Uri.parse('http://localhost:3000/api/hospital-staff'),
        headers: {'Content-Type': 'application/json'},
      );

      // Load patients data for regional overview
      final patientsResponse = await http.get(
        Uri.parse('http://localhost:3000/api/patients'),
        headers: {'Content-Type': 'application/json'},
      );

      if (statsResponse.statusCode == 200) {
        healthStats = json.decode(statsResponse.body);
      }

      List<dynamic> hospitalStaff = [];
      List<dynamic> patients = [];

      if (hospitalStaffResponse.statusCode == 200) {
        hospitalStaff = json.decode(hospitalStaffResponse.body);
      }

      if (patientsResponse.statusCode == 200) {
        patients = json.decode(patientsResponse.body);
      }

      // Process regional data
      _processRegionalData(hospitalStaff, patients);

      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        error = 'Failed to load regional data: $e';
        isLoading = false;
      });
    }
  }

  void _processRegionalData(List<dynamic> hospitalStaff, List<dynamic> patients) {
    // Group hospitals by name
    Map<String, List<dynamic>> hospitalGroups = {};
    for (var staff in hospitalStaff) {
      String hospital = staff['hospitalName'] ?? 'Unknown Hospital';
      if (!hospitalGroups.containsKey(hospital)) {
        hospitalGroups[hospital] = [];
      }
      hospitalGroups[hospital]!.add(staff);
    }

    hospitals = hospitalGroups.keys.map((hospitalName) => {
      'name': hospitalName,
      'staffCount': hospitalGroups[hospitalName]!.length,
      'departments': hospitalGroups[hospitalName]!.map((s) => s['department']).toSet().toList(),
      'staff': hospitalGroups[hospitalName]!,
    }).toList();

    // Calculate regional statistics
    regionalData = {
      'totalHospitals': hospitals.length,
      'totalStaff': hospitalStaff.length,
      'totalPatients': patients.length,
      'totalDoctors': hospitalStaff.where((s) => s['staffRole'] == 'doctor').length,
      'totalNurses': hospitalStaff.where((s) => s['staffRole'] == 'nurse').length,
      'migrantWorkers': patients.length, // All patients in this system are migrant workers
      'activeRegions': widget.userData['assignedStates']?.length ?? 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Regional Officer Dashboard'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadOfficerData,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(error!, style: TextStyle(color: Colors.red)),
                      ElevatedButton(
                        onPressed: loadOfficerData,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Officer Information Card
                      _buildOfficerInfoCard(),
                      SizedBox(height: 20),
                      
                      // Management Actions
                      _buildManagementActions(),
                      SizedBox(height: 20),
                      
                      // Regional Overview Stats
                      _buildRegionalStats(),
                      SizedBox(height: 20),
                      
                      // Health Statistics
                      _buildHealthStatistics(),
                      SizedBox(height: 20),
                      
                      // Hospital Network
                      _buildHospitalNetwork(),
                      SizedBox(height: 20),
                      
                      // Jurisdiction Details
                      _buildJurisdictionDetails(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildOfficerInfoCard() {
    String rank = widget.userData['officerRank'] ?? 'officer';
    String department = widget.userData['department'] ?? 'Health Department';
    String region = widget.userData['assignedRegion'] ?? 'Regional';

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.purple.shade100,
                  child: Icon(Icons.account_balance, size: 40, color: Colors.purple.shade700),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userData['fullName'] ?? 'Unknown',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        rank.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        department,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        'Region: $region',
                        style: TextStyle(color: Colors.purple.shade600, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem('Service Years', '${widget.userData['yearsOfService'] ?? 0}'),
                _buildInfoItem('Clearance', widget.userData['clearanceLevel'] ?? 'basic'),
                _buildInfoItem('Employee ID', widget.userData['employeeId'] ?? 'N/A'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildManagementActions() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Management Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildActionButton(
                  'Hospital Management',
                  'Manage hospitals in your region',
                  Icons.local_hospital,
                  Colors.blue,
                  () => _navigateToHospitalManagement(),
                ),
                _buildActionButton(
                  'Staff Oversight',
                  'Monitor hospital staff',
                  Icons.people,
                  Colors.green,
                  () => _showComingSoon('Staff Oversight'),
                ),
                _buildActionButton(
                  'Health Reports',
                  'Generate regional reports',
                  Icons.assessment,
                  Colors.orange,
                  () => _showComingSoon('Health Reports'),
                ),
                _buildActionButton(
                  'Emergency Response',
                  'Emergency coordination',
                  Icons.emergency,
                  Colors.red,
                  () => _showComingSoon('Emergency Response'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHospitalManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Hospital Management')),
          body: const Center(
            child: Text('Hospital Management Screen - Coming Soon'),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildRegionalStats() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Regional Health Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard('Hospitals', regionalData['totalHospitals']?.toString() ?? '0', Icons.local_hospital, Colors.blue),
                _buildStatCard('Medical Staff', regionalData['totalStaff']?.toString() ?? '0', Icons.medical_services, Colors.green),
                _buildStatCard('Registered Patients', regionalData['totalPatients']?.toString() ?? '0', Icons.people, Colors.orange),
                _buildStatCard('Active Regions', regionalData['activeRegions']?.toString() ?? '0', Icons.map, Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatistics() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Health Statistics Reports',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full statistics view
                  },
                  child: Text('View All'),
                ),
              ],
            ),
            SizedBox(height: 12),
            healthStats.isEmpty
                ? Container(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.analytics, size: 48, color: Colors.grey[400]),
                          SizedBox(height: 8),
                          Text(
                            'No health statistics available',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: healthStats.take(2).map((stat) {
                      return _buildHealthStatItem(stat);
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthStatItem(Map<String, dynamic> stat) {
    var statistics = stat['statistics'] ?? {};
    var trends = stat['trends'] as List<dynamic>? ?? [];
    var alerts = stat['alerts'] as List<dynamic>? ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stat['region']} - ${stat['district']}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Period: ${stat['reportingPeriod']}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (alerts.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, size: 16, color: Colors.red),
                      SizedBox(width: 4),
                      Text(
                        '${alerts.length} Alerts',
                        style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          
          // Key Statistics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('Population', statistics['totalPopulation']?.toString() ?? '0'),
              _buildMiniStat('Patients', statistics['totalPatients']?.toString() ?? '0'),
              _buildMiniStat('Active Cases', statistics['activeCases']?.toString() ?? '0'),
              _buildMiniStat('Emergencies', statistics['emergencyCases']?.toString() ?? '0'),
            ],
          ),
          
          if (trends.isNotEmpty) ...[
            SizedBox(height: 12),
            Divider(),
            Text(
              'Trends',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: trends.take(3).map((trend) {
                Color trendColor = trend['trend'] == 'increasing' ? Colors.red :
                                 trend['trend'] == 'decreasing' ? Colors.green : Colors.orange;
                IconData trendIcon = trend['trend'] == 'increasing' ? Icons.trending_up :
                                   trend['trend'] == 'decreasing' ? Icons.trending_down : Icons.trending_flat;
                
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trendColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(trendIcon, size: 14, color: trendColor),
                      SizedBox(width: 4),
                      Text(
                        '${trend['metric']}: ${trend['changePercentage']?.toStringAsFixed(1) ?? '0'}%',
                        style: TextStyle(fontSize: 11, color: trendColor),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildHospitalNetwork() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hospital Network',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Icon(Icons.local_hospital, size: 16, color: Colors.blue),
                    SizedBox(width: 4),
                    Text(
                      '${hospitals.length} Hospitals',
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            hospitals.isEmpty
                ? Container(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'No hospitals data available',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                : Column(
                    children: hospitals.map((hospital) {
                      return _buildHospitalItem(hospital);
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalItem(Map<String, dynamic> hospital) {
    List<dynamic> departments = hospital['departments'] ?? [];
    int staffCount = hospital['staffCount'] ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  hospital['name'] ?? 'Unknown Hospital',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$staffCount Staff',
                  style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (departments.isNotEmpty) ...[
            Text(
              'Departments:',
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: departments.map((dept) => Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dept.toString(),
                  style: TextStyle(fontSize: 10, color: Colors.blue),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJurisdictionDetails() {
    var responsibilities = widget.userData['responsibilities'] as List<dynamic>? ?? [];
    var permissions = widget.userData['accessPermissions'] as List<dynamic>? ?? [];
    var assignedStates = widget.userData['assignedStates'] as List<dynamic>? ?? [];
    var assignedDistricts = widget.userData['assignedDistricts'] as List<dynamic>? ?? [];

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jurisdiction & Responsibilities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            
            // Assigned Areas
            if (assignedStates.isNotEmpty || assignedDistricts.isNotEmpty) ...[
              _buildJurisdictionSection('Assigned Areas', [
                ...assignedStates.map((state) => 'State: $state'),
                ...assignedDistricts.map((district) => 'District: $district'),
              ], Colors.purple),
              SizedBox(height: 12),
            ],
            
            // Responsibilities
            if (responsibilities.isNotEmpty) ...[
              _buildJurisdictionSection(
                'Key Responsibilities', 
                responsibilities.map((r) => r.toString().replaceAll('_', ' ').toUpperCase()).toList(),
                Colors.blue
              ),
              SizedBox(height: 12),
            ],
            
            // Access Permissions
            if (permissions.isNotEmpty) ...[
              _buildJurisdictionSection(
                'Access Permissions', 
                permissions.map((p) => p.toString().replaceAll('_', ' ').toUpperCase()).toList(),
                Colors.green
              ),
            ],
            
            // Office Information
            SizedBox(height: 16),
            _buildOfficeInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildJurisdictionSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: items.map((item) => Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              item,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildOfficeInfo() {
    var officeAddress = widget.userData['officeAddress'];
    if (officeAddress == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business, color: Colors.grey[700], size: 20),
              SizedBox(width: 8),
              Text(
                'Office Information',
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('${officeAddress['buildingName'] ?? ''}, ${officeAddress['street'] ?? ''}'),
          Text('${officeAddress['city'] ?? ''}, ${officeAddress['state'] ?? ''} ${officeAddress['zipCode'] ?? ''}'),
          if (widget.userData['officePhone'] != null) ...[
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  widget.userData['officePhone'],
                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blue),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
