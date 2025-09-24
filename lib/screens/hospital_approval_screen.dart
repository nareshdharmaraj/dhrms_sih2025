import 'package:flutter/material.dart';
import '../models/regional_health_officer.dart';
import '../services/rho_auth_service.dart';

class HospitalApprovalScreen extends StatefulWidget {
  final RegionalHealthOfficer rho;

  const HospitalApprovalScreen({super.key, required this.rho});

  @override
  _HospitalApprovalScreenState createState() => _HospitalApprovalScreenState();
}

class _HospitalApprovalScreenState extends State<HospitalApprovalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  String? error;

  // Statistics data
  Map<String, dynamic> statistics = {};
  List<dynamic> pendingHospitals = [];
  List<dynamic> allHospitals = [];
  
  String selectedFilter = 'All';
  List<String> filterOptions = ['All', 'Pending', 'Under Review', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      await Future.wait([
        _loadStatistics(),
        _loadPendingHospitals(),
        _loadAllHospitals()
      ]);
    } catch (e) {
      setState(() {
        error = 'Failed to load data: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadStatistics() async {
    try {
      print('🔍 Loading statistics...');
      
      // Try the RHO my/statistics endpoint first
      final myStatsResponse = await RHOAuthService.makeAuthenticatedRequest(
        'GET',
        '/rho/my/statistics',
      );
      print('🔍 My statistics response: $myStatsResponse');

      if (myStatsResponse['success'] == true) {
        setState(() {
          statistics = myStatsResponse['data'] ?? {};
        });
        print('📊 Loaded statistics from /rho/my/statistics: $statistics');
      } else {
        print('❌ Failed to load statistics from /rho/my/statistics, calculating from hospital data...');
        // If statistics endpoint fails, calculate from available data
        await _calculateStatisticsFromData();
      }
    } catch (e) {
      print('Error loading statistics: $e');
      await _calculateStatisticsFromData();
    }
  }
  
  Future<void> _calculateStatisticsFromData() async {
    try {
      // If we can't get statistics from API, calculate from hospital data
      int pendingCount = 0;
      int underReviewCount = 0;
      int approvedCount = 0;
      int rejectedCount = 0;
      
      // Count from pending hospitals list
      for (final hospital in pendingHospitals) {
        final status = hospital['approval']?['status'];
        if (status == 'Pending') {
          pendingCount++;
        } else if (status == 'Under Review') underReviewCount++;
      }
      
      // Count from all hospitals list
      for (final hospital in allHospitals) {
        final status = hospital['approval']?['status'];
        if (status == 'Approved') {
          approvedCount++;
        } else if (status == 'Rejected') rejectedCount++;
      }
      
      setState(() {
        statistics = {
          'pending': pendingCount + underReviewCount,
          'approved': approvedCount,
          'rejected': rejectedCount,
          'total': pendingCount + underReviewCount + approvedCount + rejectedCount,
        };
      });
      
      print('📊 Calculated statistics: $statistics');
    } catch (e) {
      print('❌ Error calculating statistics: $e');
    }
  }

  Future<void> _loadPendingHospitals() async {
    try {
      print('🔍 Starting to load pending hospitals...');
      
      // Check if we have proper authentication
      final token = await RHOAuthService.getAuthToken();
      final rhoData = await RHOAuthService.getStoredRHOData();
      print('🔍 Auth token exists: ${token != null}');
      print('🔍 RHO data: ${rhoData?.officerId} - ${rhoData?.assignedDistrict}, ${rhoData?.assignedState}');
      
      if (rhoData == null) {
        print('❌ No RHO data found, cannot load hospitals');
        setState(() {
          pendingHospitals = [];
        });
        return;
      }
      
      // Try the direct hospital endpoint since RHO endpoints are failing
      print('🔍 Calling /api/hospitals to get all hospitals...');
      final allHospitalsResponse = await RHOAuthService.makeAuthenticatedRequest(
        'GET',
        '/hospitals',
      );
      print('🔍 All hospitals response: $allHospitalsResponse');

      List<dynamic> combinedHospitals = [];
      
      if (allHospitalsResponse['success'] == true) {
        final hospitals = allHospitalsResponse['data'] ?? [];
        print('📋 Fetched ${hospitals.length} total hospitals, filtering for RHO assignment and status...');
        
        // Filter hospitals that are managed by this RHO and have pending/under review status
        for (final hospital in hospitals) {
          try {
            // Check RHO assignment and approval status
            final rhoAssignment = hospital['rhoAssignment'];
            final approval = hospital['approval'];
            
            print('🔍 Checking hospital: ${hospital['hospitalName'] ?? hospital['name']}');
            
            // Check if hospital is managed by this RHO
            bool isManagedByThisRHO = false;
            if (rhoAssignment != null && rhoAssignment['rhoId'] != null) {
              final assignedRHOId = rhoAssignment['rhoId'].toString();
              print('   Assigned RHO ID: $assignedRHOId');
              print('   Current RHO ID: ${rhoData.officerId}');
              isManagedByThisRHO = (assignedRHOId == rhoData.officerId);
            }
            
            // Check approval status
            String status = '';
            if (approval != null && approval['status'] != null) {
              status = approval['status'].toString();
            }
            print('   Status: $status');
            print('   Is managed by this RHO: $isManagedByThisRHO');
            
            // Add hospital if it's managed by this RHO and has pending/under review status
            if (isManagedByThisRHO && (status == 'Pending' || status == 'Under Review')) {
              combinedHospitals.add(hospital);
              print('✅ Found hospital managed by this RHO: ${hospital['hospitalName'] ?? hospital['name']} with status: $status');
            }
          } catch (e) {
            print('⚠️ Error processing hospital: $e');
          }
        }
      } else {
        print('❌ Failed to load hospitals: ${allHospitalsResponse['message'] ?? allHospitalsResponse['error']}');
      }

      // Remove duplicates (in case a hospital appears in both lists)
      final Map<String, dynamic> uniqueHospitals = {};
      for (final hospital in combinedHospitals) {
        final hospitalId = hospital['hospitalId'] ?? hospital['_id'];
        if (hospitalId != null) {
          uniqueHospitals[hospitalId] = hospital;
        }
      }

      setState(() {
        pendingHospitals = uniqueHospitals.values.toList();
      });
      
      print('📊 Total pending/under review hospitals: ${pendingHospitals.length}');
    } catch (e) {
      print('Error loading pending hospitals: $e');
    }
  }

  Future<void> _loadAllHospitals() async {
    try {
      print('🔍 Loading all hospitals with filter: $selectedFilter');
      
      final rhoData = await RHOAuthService.getStoredRHOData();
      if (rhoData == null) {
        print('❌ No RHO data found');
        setState(() {
          allHospitals = [];
        });
        return;
      }

      final response = await RHOAuthService.makeAuthenticatedRequest(
        'GET',
        '/hospitals',
      );

      if (response['success'] == true) {
        final hospitals = response['data'] ?? [];
        print('📋 Fetched ${hospitals.length} total hospitals for filtering...');
        
        List<dynamic> filteredHospitals = [];
        
        // Filter hospitals managed by this RHO
        for (final hospital in hospitals) {
          try {
            final rhoAssignment = hospital['rhoAssignment'];
            final approval = hospital['approval'];
            
            // Check if hospital is managed by this RHO
            bool isManagedByThisRHO = false;
            if (rhoAssignment != null && rhoAssignment['rhoId'] != null) {
              final assignedRHOId = rhoAssignment['rhoId'].toString();
              isManagedByThisRHO = (assignedRHOId == rhoData.officerId);
            }
            
            if (isManagedByThisRHO) {
              // Apply status filter
              if (selectedFilter == 'All') {
                filteredHospitals.add(hospital);
              } else if (approval != null) {
                final status = approval['status']?.toString() ?? '';
                if (status == selectedFilter) {
                  filteredHospitals.add(hospital);
                }
              }
            }
          } catch (e) {
            print('⚠️ Error filtering hospital: $e');
          }
        }
        
        setState(() {
          allHospitals = filteredHospitals;
        });
        
        print('📊 Filtered ${filteredHospitals.length} hospitals for RHO jurisdiction with filter: $selectedFilter');
      } else {
        print('❌ Failed to load all hospitals: ${response['message'] ?? response['error']}');
        setState(() {
          allHospitals = [];
        });
      }
    } catch (e) {
      print('Error loading all hospitals: $e');
      setState(() {
        allHospitals = [];
      });
    }
  }

  Future<void> _approveHospital(String hospitalId, String comments) async {
    try {
      final response = await RHOAuthService.makeAuthenticatedRequest(
        'POST',
        '/rho/hospitals/$hospitalId/approve',
        body: {
          'comments': comments,
        },
      );

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hospital approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData(); // Refresh data
      } else {
        throw Exception(response['message'] ?? 'Approval failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving hospital: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectHospital(String hospitalId, String comments) async {
    try {
      final response = await RHOAuthService.makeAuthenticatedRequest(
        'POST',
        '/rho/hospitals/$hospitalId/reject',
        body: {
          'comments': comments,
        },
      );

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hospital registration rejected'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadData(); // Refresh data
      } else {
        throw Exception(response['message'] ?? 'Rejection failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rejecting hospital: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospital Approval Management'),
        backgroundColor: Color(0xFF2196F3),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Pending Review (${pendingHospitals.length})'),
            Tab(text: 'All Hospitals (${allHospitals.length})'),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? _buildErrorWidget()
              : Column(
                  children: [
                    _buildStatisticsHeader(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPendingHospitalsList(),
                          _buildAllHospitalsList(),
                        ],
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        backgroundColor: Color(0xFF2196F3),
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hospital Approval Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2196F3),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  statistics['pending']?.toString() ?? '0',
                  Colors.orange,
                  Icons.pending_actions,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Approved',
                  statistics['approved']?.toString() ?? '0',
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Rejected',
                  statistics['rejected']?.toString() ?? '0',
                  Colors.red,
                  Icons.cancel,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Total',
                  statistics['total']?.toString() ?? '0',
                  Color(0xFF2196F3),
                  Icons.local_hospital,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingHospitalsList() {
    if (pendingHospitals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'No Pending Reviews',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'No hospitals are currently pending review or under review in your region.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: pendingHospitals.length,
      itemBuilder: (context, index) {
        final hospital = pendingHospitals[index];
        return _buildHospitalCard(hospital, isPending: true);
      },
    );
  }

  Widget _buildAllHospitalsList() {
    return Column(
      children: [
        // Filter bar
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filterOptions.map((filter) {
                      final isSelected = selectedFilter == filter;
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedFilter = filter;
                            });
                            _loadAllHospitals();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: allHospitals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No Hospitals Found',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No hospitals match the selected filter.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: allHospitals.length,
                  itemBuilder: (context, index) {
                    final hospital = allHospitals[index];
                    return _buildHospitalCard(hospital, isPending: false);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHospitalCard(Map<String, dynamic> hospital, {required bool isPending}) {
    final approval = hospital['approval'] ?? {};
    final location = hospital['location'] ?? {};
    final contact = hospital['contact'] ?? {};
    
    Color statusColor = _getStatusColor(approval['status']);
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
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
                      Text(
                        hospital['name'] ?? 'Unknown Hospital',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${location['city'] ?? ''}, ${location['state'] ?? ''}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPending) ...[
                        Icon(
                          approval['status'] == 'Under Review' ? Icons.rate_review : Icons.pending,
                          size: 12,
                          color: statusColor,
                        ),
                        SizedBox(width: 4),
                      ],
                      Text(
                        approval['status'] ?? 'Unknown',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  hospital['type'] ?? 'Unknown Type',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(width: 16),
                Icon(Icons.local_hospital, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  '${hospital['capacity']?['totalBeds'] ?? '0'} beds',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            if (contact['phone'] != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    contact['phone'],
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            if (approval['submittedAt'] != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    'Submitted: ${_formatDate(approval['submittedAt'])}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            if (isPending && (approval['status'] == 'Pending' || approval['status'] == 'Under Review')) ...[
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showApprovalDialog(hospital),
                      icon: Icon(Icons.check),
                      label: Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showRejectionDialog(hospital),
                      icon: Icon(Icons.close),
                      label: Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (!isPending) ...[
              SizedBox(height: 12),
              InkWell(
                onTap: () => _showHospitalDetails(hospital),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.visibility, size: 16, color: Color(0xFF2196F3)),
                      SizedBox(width: 4),
                      Text(
                        'View Details',
                        style: TextStyle(color: Color(0xFF2196F3)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Under Review':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  void _showApprovalDialog(Map<String, dynamic> hospital) {
    final commentsController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Approve Hospital'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to approve "${hospital['name']}"?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: commentsController,
              decoration: InputDecoration(
                labelText: 'Approval Comments (Optional)',
                hintText: 'Enter any comments about the approval...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approveHospital(hospital['hospitalId'], commentsController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog(Map<String, dynamic> hospital) {
    final commentsController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject Hospital'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to reject "${hospital['name']}"?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: commentsController,
              decoration: InputDecoration(
                labelText: 'Rejection Reason (Required)',
                hintText: 'Enter the reason for rejection...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (commentsController.text.trim().length < 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Rejection reason must be at least 10 characters'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _rejectHospital(hospital['hospitalId'], commentsController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showHospitalDetails(Map<String, dynamic> hospital) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(hospital['name'] ?? 'Hospital Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', hospital['type']),
              _buildDetailRow('Location', '${hospital['location']?['address']}, ${hospital['location']?['city']}, ${hospital['location']?['state']}'),
              _buildDetailRow('Contact', hospital['contact']?['phone']),
              _buildDetailRow('Total Beds', hospital['capacity']?['totalBeds']?.toString()),
              _buildDetailRow('Status', hospital['approval']?['status']),
              if (hospital['approval']?['reviewComments'] != null)
                _buildDetailRow('Comments', hospital['approval']['reviewComments']),
              if (hospital['approval']?['reviewedAt'] != null)
                _buildDetailRow('Reviewed On', _formatDate(hospital['approval']['reviewedAt'])),
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

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }
}